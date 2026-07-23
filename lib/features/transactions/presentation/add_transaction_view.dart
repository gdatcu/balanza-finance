import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/transaction.dart';
import '../../../models/category.dart';
import '../../../models/account.dart';
import '../providers/transaction_provider.dart';
import 'categories_data.dart';
import 'accounts_data.dart';

import '../providers/tagging_rules_provider.dart';
import '../utils/transaction_parser.dart';

class AddTransactionView extends ConsumerStatefulWidget {
  const AddTransactionView({super.key});

  @override
  ConsumerState<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends ConsumerState<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late Account _selectedAccount;
  late Category _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;
  String? _lastAutoTaggedRuleId;

  @override
  void initState() {
    super.initState();
    _selectedAccount = defaultAccounts.first;
    _selectedCategory = expenseCategories.first;
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    final rules = ref.read(taggingRulesProvider).value;
    if (rules == null || rules.isEmpty) return;

    final result = TransactionParser.parseText(_descriptionController.text, rules);
    if (result != null && result.matchedRule.id != _lastAutoTaggedRuleId) {
      final allCategories = [...expenseCategories, ...incomeCategories];
      final matchedCat = allCategories.firstWhere(
        (c) =>
            (result.categoryId != null && c.id == result.categoryId) ||
            c.name.toLowerCase() == result.category.toLowerCase() ||
            c.id == result.category,
        orElse: () => expenseCategories.first,
      );

      _lastAutoTaggedRuleId = result.matchedRule.id;

      if (_selectedCategory.id != matchedCat.id) {
        setState(() {
          _selectedCategory = matchedCat;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-tagged as ${matchedCat.name} based on remote rules.'),
              backgroundColor: Colors.green,
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
    _descriptionController.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final double amountVal = double.parse(_amountController.text.trim());
      final double finalAmount = _isExpense ? -amountVal : amountVal;

      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: '00000000-0000-0000-0000-000000000000',
        accountId: _selectedAccount.id,
        categoryId: _selectedCategory.id,
        amount: finalAmount,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
      );

      await ref.read(transactionRepositoryProvider).addTransaction(transaction);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine dynamic list of categories based on transaction type
    final filteredCategories = _isExpense ? expenseCategories : incomeCategories;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Add Transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Transaction Type SegmentedButton
              Center(
                child: SegmentedButton<bool>(
                  segments: const <ButtonSegment<bool>>[
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                  ],
                  selected: <bool>{_isExpense},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isExpense = newSelection.first;
                      // Instantly update selected category to match filtered categories
                      final newFiltered = _isExpense ? expenseCategories : incomeCategories;
                      _selectedCategory = newFiltered.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Account Selector Dropdown
              DropdownButtonFormField<Account>(
                // ignore: deprecated_member_use
                value: _selectedAccount,
                decoration: InputDecoration(
                  labelText: 'Account *',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: defaultAccounts.map((Account acc) {
                  return DropdownMenuItem<Account>(
                    value: acc,
                    child: Text(acc.name),
                  );
                }).toList(),
                onChanged: (Account? newAcc) {
                  if (newAcc != null) {
                    setState(() {
                      _selectedAccount = newAcc;
                    });
                  }
                },
                validator: (val) => val == null ? 'Please select an account' : null,
              ),
              const SizedBox(height: 16),

              // Category Selector Dropdown (Dynamically Filtered)
              DropdownButtonFormField<Category>(
                // ignore: deprecated_member_use
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: filteredCategories.map((Category cat) {
                  final color = getCategoryColor(cat.color);
                  final icon = getCategoryIcon(cat.icon);
                  return DropdownMenuItem<Category>(
                    value: cat,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: color.withValues(alpha: 0.2),
                          child: Icon(icon, size: 16, color: color),
                        ),
                        const SizedBox(width: 12),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Category? newCat) {
                  if (newCat != null) {
                    setState(() {
                      _selectedCategory = newCat;
                    });
                  }
                },
                validator: (val) => val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Amount Input Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final double? parsedVal = double.tryParse(val.trim());
                  if (parsedVal == null) {
                    return 'Please enter a valid number';
                  }
                  if (parsedVal <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker Selector
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note Text Field (Optional)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isExpense ? Colors.red.shade600 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Transaction',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
