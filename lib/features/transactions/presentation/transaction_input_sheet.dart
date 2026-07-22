import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/transaction_provider.dart';
import '../../../models/transaction.dart';
import 'categories_data.dart';

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

  // Seeded Account IDs: Main Checking is default
  final String _selectedAccountId = '00000000-0000-0000-0000-000000000001';

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
      final double finalAmount = _isIncome ? amt : -amt;

      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: '00000000-0000-0000-0000-000000000000', // Default mock user id
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        amount: finalAmount,
        description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
      );

      ref.read(transactionListProvider.notifier).add(transaction);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully!'),
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
                      'Add Transaction',
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
                    _isIncome ? 'Type: Income' : 'Type: Expense',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  secondary: Icon(
                    _isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: _isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                  ),
                  value: _isIncome,
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

                // Amount text input field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (RON)',
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
                      return 'Please enter an amount';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
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
                        labelText: 'Category',
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
                              Text(cat.name),
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
                          return 'Please select a category';
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
                      labelText: 'Date',
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
                    labelText: 'Note (Optional)',
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
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(
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
