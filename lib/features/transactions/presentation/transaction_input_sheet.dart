import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../../../models/transaction.dart';
import '../../../core/utils/category_localizer.dart';
import 'categories_data.dart';

import '../providers/tagging_rules_provider.dart';
import '../utils/transaction_parser.dart';

class TransactionInputSheet extends ConsumerStatefulWidget {
  const TransactionInputSheet({super.key});

  @override
  ConsumerState<TransactionInputSheet> createState() => _TransactionInputSheetState();
}

class _TransactionInputSheetState extends ConsumerState<TransactionInputSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isIncome = false;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'RON';
  String? _lastAutoTaggedRuleId;

  // Seeded Account IDs: Main Checking is default
  final String _selectedAccountId = '00000000-0000-0000-0000-000000000001';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _noteController.addListener(_onNoteChanged);
  }

  void _onAmountChanged() {
    setState(() {}); // refresh live currency conversion preview
  }

  void _onNoteChanged() {
    final rules = ref.read(taggingRulesProvider).value;
    if (rules == null || rules.isEmpty) return;

    final categories = ref.read(supabaseCategoriesProvider).value;
    if (categories == null || categories.isEmpty) return;

    final result = TransactionParser.parseText(_noteController.text, rules);
    if (result != null && result.matchedRule.id != _lastAutoTaggedRuleId) {
      final matchedCat = categories.firstWhere(
        (c) =>
            (result.categoryId != null && c.id == result.categoryId) ||
            c.name.toLowerCase() == result.category.toLowerCase() ||
            c.id == result.category,
        orElse: () => categories.firstWhere(
          (c) => c.name.toLowerCase().contains(result.category.toLowerCase()),
          orElse: () => categories.first,
        ),
      );

      _lastAutoTaggedRuleId = result.matchedRule.id;

      if (_selectedCategoryId != matchedCat.id) {
        setState(() {
          _selectedCategoryId = matchedCat.id;
        });

        if (mounted) {
          final localizedCategoryName = CategoryLocalizer.getLocalizedName(context, matchedCat.name);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-tagged as $localizedCategoryName based on remote rules.'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  final Set<String> _expenseCategoryIds = {
    '00000000-0000-0000-0000-0000000000c1', // Food
    '00000000-0000-0000-0000-0000000000c2', // Transport
    '00000000-0000-0000-0000-0000000000c3', // Rent
    '00000000-0000-0000-0000-0000000000c4', // Utilities
    '00000000-0000-0000-0000-0000000000c6', // Entertainment
    '00000000-0000-0000-0000-0000000000c7', // Shopping
  };

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double amt = double.parse(_amountController.text);
      
      double finalAmountVal = amt;
      String originalCurrencyVal = _selectedCurrency;

      if (_selectedCurrency == 'RON') {
        finalAmountVal = amt;
      } else {
        final rate = ref.read(exchangeRateProvider).value ?? 4.97;
        finalAmountVal = amt * rate;
      }

      final double finalAmount = _isIncome ? finalAmountVal : -finalAmountVal;
      final double originalAmount = _isIncome ? amt : -amt;

      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: '00000000-0000-0000-0000-000000000000', // Default mock user id
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        amount: finalAmount,
        description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
        originalCurrency: originalCurrencyVal,
        originalAmount: originalAmount,
      );

      ref.read(transactionRepositoryProvider).addTransaction(transaction);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.transactionAddedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(supabaseCategoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.addTransaction,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle Switch for Income vs Expense
                SwitchListTile(
                  title: Text(
                    _isIncome
                        ? '${AppLocalizations.of(context)!.type}: ${AppLocalizations.of(context)!.typeIncome}'
                        : '${AppLocalizations.of(context)!.type}: ${AppLocalizations.of(context)!.typeExpense}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  secondary: Icon(
                    _isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                  ),
                  value: _isIncome,
                  // ignore: deprecated_member_use
                  activeColor: const Color(0xFF10B981),
                  inactiveThumbColor: const Color(0xFFFF7A5A),
                  inactiveTrackColor: const Color(0xFFFF7A5A).withValues(alpha: 0.2),
                  onChanged: (val) {
                    setState(() {
                      _isIncome = val;
                      _selectedCategoryId = null; // Reset category
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Amount text input field with currency selector
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: _selectedCurrency == 'RON'
                              ? AppLocalizations.of(context)!.amountFieldLabel
                              : '${AppLocalizations.of(context)!.amount} ($_selectedCurrency)',
                          prefixIcon: Icon(Icons.wallet, color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.pleaseEnterAmount;
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return AppLocalizations.of(context)!.pleaseEnterValidPositiveNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 56, // matching TextFormField height
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            dropdownColor: const Color(0xFF1E293B),
                            items: const [
                              DropdownMenuItem(value: 'RON', child: Text('RON', style: TextStyle(fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'EUR', child: Text('EUR', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCurrency = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedCurrency == 'EUR') ...[
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final exchangeRateAsync = ref.watch(exchangeRateProvider);
                      return exchangeRateAsync.when(
                        data: (rate) {
                          final inputAmt = double.tryParse(_amountController.text) ?? 0.0;
                          final converted = inputAmt * rate;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              '≈ RON ${converted.toStringAsFixed(2)}  (1 EUR = $rate RON)',
                              style: TextStyle(
                                color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text('Fetching exchange rate...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                        error: (err, __) => const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text('Service unavailable. Defaulting to 1 EUR = 4.97 RON.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Dynamic Categories Dropdown fetching from Supabase
                categoriesAsync.when(
                  data: (categories) {
                    final filtered = categories.where((c) {
                      if (_isIncome) {
                        return !_expenseCategoryIds.contains(c.id);
                      } else {
                        return _expenseCategoryIds.contains(c.id);
                      }
                    }).toList();

                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.category,
                        prefixIcon: Icon(Icons.category, color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                            width: 2,
                          ),
                        ),
                      ),
                      // ignore: deprecated_member_use
                      value: _selectedCategoryId,
                      items: filtered.map((cat) {
                        final color = getCategoryColor(cat.color);
                        final icon = getCategoryIcon(cat.icon);
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: color.withValues(alpha: 0.2),
                                child: Icon(icon, size: 16, color: color),
                              ),
                              const SizedBox(width: 12),
                              Text(CategoryLocalizer.getLocalizedName(context, cat.name)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.pleaseSelectCategory;
                        }
                        return null;
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, __) => Text(
                    'Error loading categories: $err',
                    style: const TextStyle(color: Color(0xFFFF7A5A)),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Selector Picker
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.date,
                      prefixIcon: Icon(Icons.calendar_today, color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Optional description note
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.noteOptional,
                    prefixIcon: Icon(Icons.description, color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.saveTransaction,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
