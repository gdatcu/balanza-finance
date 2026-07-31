import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/category_localizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/default_tagging_rules.dart';
import '../../../models/transaction.dart';
import '../providers/tagging_rules_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/csv_bank_statement_parser.dart';
import 'categories_data.dart';

enum CsvFilterTab { all, spending, transfers }

/// Bottom sheet modal for pasting bank CSV text, reviewing auto-tagged preview lines, adjusting categories, and bulk importing.
class CsvImportSheet extends ConsumerStatefulWidget {
  const CsvImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
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
  CsvFilterTab _activeTab = CsvFilterTab.all;

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

    final remoteRules = ref.read(taggingRulesProvider).value ?? [];
    // Combine remote Supabase rules with local fallback default rules so auto-tagging never returns 0
    final rules = [...remoteRules, ...defaultTaggingRules];
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

  void _toggleSelect(int index, bool? value) {
    if (value == null) return;
    setState(() {
      _parsedTransactions[index] = _parsedTransactions[index].copyWith(isSelected: value);
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

  void _selectAll(bool select) {
    setState(() {
      _parsedTransactions = _parsedTransactions.map((t) => t.copyWith(isSelected: select)).toList();
    });
  }

  void _deselectTransfers() {
    setState(() {
      _parsedTransactions = _parsedTransactions
          .map((t) => t.isInternalTransfer ? t.copyWith(isSelected: false) : t)
          .toList();
    });
  }

  void _discardSelected() {
    setState(() {
      _parsedTransactions.removeWhere((t) => t.isSelected);
    });
  }

  Future<void> _importSelected() async {
    final selectedItems = _parsedTransactions.where((t) => t.isSelected).toList();
    if (selectedItems.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final defaultCat = defaultCategories.first;

      for (final item in selectedItems) {
        final tx = Transaction(
          id: const Uuid().v4(),
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
        final count = selectedItems.length;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $count transactions!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import CSV: $e'),
            backgroundColor: const Color(0xFFFF7A5A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body Content
          Expanded(
            child: _isParsed ? _buildPreviewList() : _buildInputForm(),
          ),

          // Footer Action Bar
          if (_isParsed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Edit CSV Text'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() => _isParsed = false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      _isSubmitting
                          ? 'Importing...'
                          : 'Import (${_parsedTransactions.where((t) => t.isSelected).length}) Selected',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting || _parsedTransactions.where((t) => t.isSelected).isEmpty
                        ? null
                        : _importSelected,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Paste Exported CSV Content:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            TextButton(
              onPressed: () {
                _csvController.text = _sampleBT;
              },
              child: const Text('Load Sample BT CSV', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Expanded(
          child: TextField(
            controller: _csvController,
            maxLines: null,
            expands: true,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Paste CSV text exported from your online banking app here...\n\nData;Descriere;Suma;Moneda\n2026-07-21;UBER TRIP RIDE;22.50;RON',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Parse & Auto-Tag Statement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _parseCsv,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewList() {
    final allCategories = ref.watch(supabaseCategoriesProvider).value ?? defaultCategories;
    final parentCategories = allCategories.where((c) => c.parentId == null).toList();

    if (_parsedTransactions.isEmpty) {
      return const Center(
        child: Text(
          'No valid transaction lines detected in CSV.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final autoTaggedCount = _parsedTransactions.where((t) => t.categoryId != null).length;
    final internalTransfersCount = _parsedTransactions.where((t) => t.isInternalTransfer).length;

    // Filter displayed list based on active tab
    List<int> visibleIndices = [];
    for (int i = 0; i < _parsedTransactions.length; i++) {
      final tx = _parsedTransactions[i];
      if (_activeTab == CsvFilterTab.spending && tx.isInternalTransfer) continue;
      if (_activeTab == CsvFilterTab.transfers && !tx.isInternalTransfer) continue;
      visibleIndices.add(i);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Bar Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Auto-tagged $autoTaggedCount / ${_parsedTransactions.length}',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              if (internalTransfersCount > 0)
                Text(
                  '🔄 $internalTransfersCount Transfers (Unchecked)',
                  style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Tabs & Bulk Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Filter Tabs
            Row(
              children: [
                _buildFilterChip('All (${_parsedTransactions.length})', CsvFilterTab.all),
                const SizedBox(width: 6),
                _buildFilterChip('Spending (${_parsedTransactions.length - internalTransfersCount})', CsvFilterTab.spending),
                const SizedBox(width: 6),
                _buildFilterChip('Transfers ($internalTransfersCount)', CsvFilterTab.transfers),
              ],
            ),

            // Bulk Actions Popup Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
              color: const Color(0xFF1E293B),
              onSelected: (val) {
                if (val == 'select_all') _selectAll(true);
                if (val == 'deselect_all') _selectAll(false);
                if (val == 'deselect_transfers') _deselectTransfers();
                if (val == 'discard_selected') _discardSelected();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'select_all', child: Text('Select All', style: TextStyle(color: Colors.white, fontSize: 13))),
                const PopupMenuItem(value: 'deselect_all', child: Text('Deselect All', style: TextStyle(color: Colors.white, fontSize: 13))),
                const PopupMenuItem(value: 'deselect_transfers', child: Text('Uncheck Internal Transfers', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13))),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'discard_selected', child: Text('Discard Selected Items', style: TextStyle(color: Color(0xFFFF7A5A), fontSize: 13))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // List View
        Expanded(
          child: ListView.separated(
            itemCount: visibleIndices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, vIdx) {
              final index = visibleIndices[vIdx];
              final tx = _parsedTransactions[index];
              final subcategories = allCategories.where((c) => c.parentId == tx.categoryId).toList();

              final parentIds = parentCategories.map((c) => c.id).toSet();
              final safeParentValue = (tx.categoryId != null && parentIds.contains(tx.categoryId)) ? tx.categoryId : null;

              final subcategoryIds = subcategories.map((c) => c.id).toSet();
              final safeSubValue = (tx.subcategoryId != null && subcategoryIds.contains(tx.subcategoryId)) ? tx.subcategoryId : null;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tx.isSelected ? const Color(0xFF0F172A) : const Color(0xFF0F172A).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: tx.isSelected ? Colors.white10 : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox, Description, Amount & Delete
                    Row(
                      children: [
                        Checkbox(
                          value: tx.isSelected,
                          onChanged: (val) => _toggleSelect(index, val),
                          activeColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Colors.white38),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.description,
                                style: TextStyle(
                                  color: tx.isSelected ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '📅 ${tx.date.toString().split(' ')[0]}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                  if (tx.isInternalTransfer) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '🔄 Internal Transfer',
                                        style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  if (tx.matchedMerchant != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '🏷️ ${tx.matchedMerchant}',
                                        style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(tx.amount),
                              style: TextStyle(
                                color: tx.amount < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
                              onPressed: () => _removeRow(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
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
                            value: safeParentValue,
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
                              value: safeSubValue,
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

  Widget _buildFilterChip(String label, CsvFilterTab tab) {
    final isSelected = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
