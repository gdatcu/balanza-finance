import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/category_localizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/category.dart';
import '../../../models/transaction.dart';
import '../providers/tagging_rules_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/csv_bank_statement_parser.dart';
import 'categories_data.dart';

/// Modal bottom sheet for importing transactions from bank CSV statements (ING, BT, Revolut, BCR, Raiffeisen).
class CsvImportSheet extends ConsumerStatefulWidget {
  const CsvImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CsvImportSheet(),
    );
  }

  @override
  ConsumerState<CsvImportSheet> createState() => _CsvImportSheetState();
}

class _CsvImportSheetState extends ConsumerState<CsvImportSheet> {
  final TextEditingController _csvController = TextEditingController();
  List<ParsedCsvTransaction> _parsedTransactions = [];
  bool _isParsed = false;
  bool _isSubmitting = false;

  static const String _sampleBT = '''Data;Descriere;Suma;Moneda
2026-07-21;UBER TRIP RIDE;22.50;RON
2026-07-20;MEGA IMAGE BUCURESTI;145.80;RON
2026-07-19;CATENA FARMACIE;64.00;RON
2026-07-18;STARBUCKS COFFEE;24.00;RON
2026-07-15;SALARIU LUNAR BT;5500.00;RON''';

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  void _parseCsv() {
    final text = _csvController.text;
    if (text.trim().isEmpty) return;

    final rules = ref.read(taggingRulesProvider).value ?? [];
    final categories = ref.read(supabaseCategoriesProvider).value ?? defaultCategories;

    final parsed = CsvBankStatementParser.parseCsvContent(
      rawCsv: text,
      rules: rules,
      categories: categories,
    );

    setState(() {
      _parsedTransactions = parsed;
      _isParsed = true;
    });
  }

  void _updateCategory(int index, String categoryId) {
    setState(() {
      final current = _parsedTransactions[index];
      _parsedTransactions[index] = current.copyWith(
        categoryId: categoryId,
        subcategoryId: null, // Reset subcategory when parent changes
      );
    });
  }

  void _updateSubcategory(int index, String? subcategoryId) {
    setState(() {
      final current = _parsedTransactions[index];
      _parsedTransactions[index] = current.copyWith(
        subcategoryId: subcategoryId,
      );
    });
  }

  void _removeRow(int index) {
    setState(() {
      _parsedTransactions.removeAt(index);
    });
  }

  Future<void> _importAll() async {
    if (_parsedTransactions.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final defaultCat = defaultCategories.first;

      for (final item in _parsedTransactions) {
        final tx = Transaction(
          id: 'csv_${DateTime.now().microsecondsSinceEpoch}_${item.description.hashCode}',
          userId: '00000000-0000-0000-0000-000000000000',
          accountId: '00000000-0000-0000-0000-000000000001',
          amount: item.amount,
          categoryId: item.categoryId ?? defaultCat.id,
          subcategoryId: item.subcategoryId,
          date: item.date,
          description: item.description,
          createdAt: DateTime.now(),
        );

        await repo.addTransaction(tx);
      }

      if (mounted) {
        final count = _parsedTransactions.length;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Successfully imported $count transactions from statement!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing transactions: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(supabaseCategoriesProvider).value ?? defaultCategories;
    final parentCategories = categories.where((c) => c.parentId == null).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: Color(0xFF3B82F6), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Import Bank CSV Statement',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Revolut, BT, ING, BCR, Raiffeisen Supported',
                        style: TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body: Input vs Preview
          Expanded(
            child: !_isParsed
                ? _buildCsvInputSection()
                : _buildPreviewList(parentCategories, categories),
          ),

          const SizedBox(height: 16),

          // Bottom Action Bar
          if (!_isParsed)
            ElevatedButton.icon(
              onPressed: _parseCsv,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Parse CSV & Auto-Tag Transactions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _isParsed = false),
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    label: const Text('Edit CSV Text', style: TextStyle(color: Colors.white70)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting || _parsedTransactions.isEmpty ? null : _importAll,
                    icon: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_isSubmitting ? 'Importing...' : 'Import ${_parsedTransactions.length} Transactions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCsvInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Paste CSV Text:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            TextButton.icon(
              onPressed: () {
                _csvController.text = _sampleBT;
                _parseCsv();
              },
              icon: const Icon(Icons.flash_on, size: 16, color: Color(0xFFF59E0B)),
              label: const Text('Load Sample Data', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TextField(
            controller: _csvController,
            maxLines: null,
            expands: true,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Paste CSV exported from your bank app...\ne.g.\nData;Descriere;Suma;Moneda\n2026-07-21;UBER TRIP;22.50;RON',
              hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'monospace', fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewList(List<Category> parentCategories, List<Category> allCategories) {
    if (_parsedTransactions.isEmpty) {
      return const Center(
        child: Text(
          'No valid transaction lines detected in CSV.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                'Auto-tagged ${_parsedTransactions.where((t) => t.categoryId != null).length} / ${_parsedTransactions.length} transactions',
                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _parsedTransactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final tx = _parsedTransactions[index];
              final subcategories = allCategories.where((c) => c.parentId == tx.categoryId).toList();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tx.description,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(tx.amount),
                          style: TextStyle(
                            color: tx.amount < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                          onPressed: () => _removeRow(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Date & Merchant chip
                    Row(
                      children: [
                        Text(
                          '📅 ${tx.date.toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        if (tx.matchedMerchant != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '🏷️ ${tx.matchedMerchant}',
                              style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category & Subcategory Pickers
                    Row(
                      children: [
                        // Parent Category Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: tx.categoryId,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                            hint: const Text('Select Category', style: TextStyle(color: Colors.white38, fontSize: 12)),
                            items: parentCategories.map((cat) {
                              final name = CategoryLocalizer.getLocalizedName(context, cat.name);
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Text(name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) _updateCategory(index, val);
                            },
                          ),
                        ),
                        if (subcategories.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              // ignore: deprecated_member_use
                              value: tx.subcategoryId,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E293B),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                filled: true,
                                fillColor: const Color(0xFF1E293B),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              hint: const Text('-- Subcategory --', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('-- None --', style: TextStyle(color: Colors.white38)),
                                ),
                                ...subcategories.map((sub) {
                                  final name = CategoryLocalizer.getLocalizedName(context, sub.name);
                                  return DropdownMenuItem<String?>(
                                    value: sub.id,
                                    child: Text(name, overflow: TextOverflow.ellipsis),
                                  );
                                }),
                              ],
                              onChanged: (val) => _updateSubcategory(index, val),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
