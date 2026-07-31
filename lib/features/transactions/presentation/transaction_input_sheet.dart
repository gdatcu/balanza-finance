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
import '../../settings/providers/locale_provider.dart';

class TransactionInputSheet extends ConsumerStatefulWidget {
  final Transaction? transactionToEdit;
  final double? initialAmount;
  final String? initialDescription;

  const TransactionInputSheet({
    super.key,
    this.transactionToEdit,
    this.initialAmount,
    this.initialDescription,
  });

  @override
  ConsumerState<TransactionInputSheet> createState() => _TransactionInputSheetState();
}

class _TransactionInputSheetState extends ConsumerState<TransactionInputSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isIncome = false;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'RON';
  String? _lastAutoTaggedRuleId;
  String _emotionalStatus = 'neutral';

  // Seeded Account IDs: Main Checking is default
  final String _selectedAccountId = '00000000-0000-0000-0000-000000000001';

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _isIncome = tx.amount > 0;
      _selectedCategoryId = tx.categoryId;
      _selectedSubcategoryId = tx.subcategoryId;
      _selectedDate = tx.date;
      _selectedCurrency = tx.originalCurrency;
      _emotionalStatus = tx.emotionalStatus;
      final absAmt = tx.originalAmount != null
          ? tx.originalAmount!.abs()
          : tx.amount.abs();
      _amountController.text = absAmt.toString();
      _noteController.text = tx.description ?? '';
    } else {
      if (widget.initialAmount != null && widget.initialAmount! > 0) {
        _amountController.text = widget.initialAmount!.toStringAsFixed(2);
      }
      if (widget.initialDescription != null && widget.initialDescription!.isNotEmpty) {
        _noteController.text = widget.initialDescription!;
      }
    }
    _amountController.addListener(_onAmountChanged);
    _noteController.addListener(_onNoteChanged);
  }

  void _onAmountChanged() {
    setState(() {}); // refresh live currency conversion preview
  }

  void _onNoteChanged() {
    final rules = ref.read(taggingRulesProvider).value;
    if (rules == null || rules.isEmpty) return;

    final categories = ref.read(supabaseCategoriesProvider).value ?? defaultCategories;

    final result = TransactionParser.parseText(_noteController.text, rules);
    if (result != null && result.matchedRule.id != _lastAutoTaggedRuleId) {
      final matchedCat = CategoryMatcher.findMatchingCategory(
        result: result,
        categories: categories,
      );

      _lastAutoTaggedRuleId = result.matchedRule.id;

      String? mainCatId;
      String? subCatId;

      if (matchedCat.isSubcategory) {
        subCatId = matchedCat.id;
        mainCatId = matchedCat.parentId;
      } else {
        mainCatId = matchedCat.id;
        if (result.subCategory != null && result.subCategory!.isNotEmpty) {
          final matchedSub = categories.firstWhere(
            (c) => c.parentId == mainCatId && (c.name.toLowerCase() == result.subCategory!.toLowerCase() || c.id == result.subCategory),
            orElse: () => matchedCat,
          );
          if (matchedSub.isSubcategory) {
            subCatId = matchedSub.id;
          }
        }
      }

      if (_selectedCategoryId != mainCatId || _selectedSubcategoryId != subCatId || _isIncome != matchedCat.isIncome) {
        setState(() {
          _isIncome = matchedCat.isIncome;
          _selectedCategoryId = mainCatId;
          _selectedSubcategoryId = subCatId;
        });

        if (mounted) {
          final localizedCategoryName = CategoryLocalizer.getLocalizedName(context, matchedCat.name);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.autoTaggedMessage(localizedCategoryName)),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }



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

  Future<void> _submit() async {
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

      if (widget.transactionToEdit != null) {
        final updatedTx = Transaction(
          id: widget.transactionToEdit!.id,
          userId: widget.transactionToEdit!.userId,
          accountId: _selectedAccountId,
          categoryId: _selectedCategoryId,
          subcategoryId: _selectedSubcategoryId,
          amount: finalAmount,
          description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          date: _selectedDate,
          createdAt: widget.transactionToEdit!.createdAt,
          originalCurrency: originalCurrencyVal,
          originalAmount: originalAmount,
          emotionalStatus: _emotionalStatus,
        );

        try {
          await ref.read(transactionRepositoryProvider).updateTransaction(updatedTx);
          if (mounted) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.transactionUpdatedSuccessfully),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update transaction: $e'),
                backgroundColor: const Color(0xFFFF7A5A),
              ),
            );
          }
        }
        return;
      }

      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: '00000000-0000-0000-0000-000000000000', // Default mock user id
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        subcategoryId: _selectedSubcategoryId,
        amount: finalAmount,
        description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
        originalCurrency: originalCurrencyVal,
        originalAmount: originalAmount,
        emotionalStatus: _emotionalStatus,
      );

      try {
        await ref.read(transactionRepositoryProvider).addTransaction(transaction);
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.transactionAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save transaction: $e'),
              backgroundColor: const Color(0xFFFF7A5A),
            ),
          );
        }
      }
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
                      widget.transactionToEdit != null
                          ? AppLocalizations.of(context)!.editTransaction
                          : AppLocalizations.of(context)!.addTransaction,
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

                // Dynamic Categories & Subcategories Dropdown fetching from Supabase
                categoriesAsync.when(
                  data: (categories) {
                    final parentCategories = categories.where((c) {
                      final matchesType = _isIncome ? c.isIncome : !c.isIncome;
                      return matchesType && !c.isSubcategory;
                    }).toList();

                    if (_selectedCategoryId == null ||
                        !parentCategories.any((c) => c.id == _selectedCategoryId)) {
                      _selectedCategoryId = parentCategories.isNotEmpty ? parentCategories.first.id : null;
                    }

                    final subcategories = categories.where((c) {
                      return c.parentId == _selectedCategoryId;
                    }).toList();

                    if (_selectedSubcategoryId != null &&
                        !subcategories.any((c) => c.id == _selectedSubcategoryId)) {
                      _selectedSubcategoryId = null;
                    }

                    final isRo = ref.watch(localeProvider).languageCode == 'ro';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
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
                          items: parentCategories.map((cat) {
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
                              _selectedSubcategoryId = null;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return AppLocalizations.of(context)!.pleaseSelectCategory;
                            }
                            return null;
                          },
                        ),
                        if (subcategories.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: isRo ? 'Subcategorie (Opțional)' : 'Subcategory (Optional)',
                              prefixIcon: Icon(Icons.subdirectory_arrow_right, color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A)),
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
                            value: _selectedSubcategoryId,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  isRo ? '-- Fără subcategorie --' : '-- No Subcategory --',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              ...subcategories.map((subCat) {
                                final color = getCategoryColor(subCat.color);
                                final icon = getCategoryIcon(subCat.icon);
                                return DropdownMenuItem<String>(
                                  value: subCat.id,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: color.withValues(alpha: 0.2),
                                        child: Icon(icon, size: 14, color: color),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(CategoryLocalizer.getLocalizedName(context, subCat.name)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedSubcategoryId = val;
                              });
                            },
                          ),
                        ],
                      ],
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
                if (!_isIncome) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.emotionalEvaluation,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _emotionalStatus = 'worth_it';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _emotionalStatus == 'worth_it' ? const Color(0xFF10B981) : Colors.grey.shade700,
                              width: _emotionalStatus == 'worth_it' ? 2.0 : 1.0,
                            ),
                            backgroundColor: _emotionalStatus == 'worth_it'
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.worthIt,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _emotionalStatus == 'worth_it' ? const Color(0xFF10B981) : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _emotionalStatus = 'regret';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _emotionalStatus == 'regret' ? const Color(0xFFFF7A5A) : Colors.grey.shade700,
                              width: _emotionalStatus == 'regret' ? 2.0 : 1.0,
                            ),
                            backgroundColor: _emotionalStatus == 'regret'
                                ? const Color(0xFFFF7A5A).withValues(alpha: 0.15)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.regret,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _emotionalStatus == 'regret' ? const Color(0xFFFF7A5A) : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                    widget.transactionToEdit != null
                        ? AppLocalizations.of(context)!.edit
                        : AppLocalizations.of(context)!.saveTransaction,
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
