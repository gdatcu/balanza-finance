import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../models/recurring_bill.dart';
import '../../providers/recurring_bills_provider.dart';
import '../../../transactions/presentation/categories_data.dart';
import '../../../transactions/providers/transaction_provider.dart';

class RecurringBillInputSheet extends ConsumerStatefulWidget {
  final RecurringBill? existingBill;

  const RecurringBillInputSheet({super.key, this.existingBill});

  static Future<void> show(BuildContext context, {RecurringBill? existingBill}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecurringBillInputSheet(existingBill: existingBill),
    );
  }

  @override
  ConsumerState<RecurringBillInputSheet> createState() => _RecurringBillInputSheetState();
}

class _RecurringBillInputSheetState extends ConsumerState<RecurringBillInputSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late int _dueDay;
  late bool _isIncome;
  late String _categoryId;
  String? _subcategoryId;

  @override
  void initState() {
    super.initState();
    final bill = widget.existingBill;
    _titleController = TextEditingController(text: bill?.title ?? '');
    _amountController = TextEditingController(text: bill != null ? bill.amount.abs().toStringAsFixed(2) : '');
    _dueDay = bill?.dueDay ?? 1;
    _isIncome = bill?.isIncome ?? false;
    _categoryId = bill?.categoryId ?? defaultCategories.first.id;
    _subcategoryId = bill?.subcategoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final parsedAmt = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    final finalAmount = _isIncome ? parsedAmt.abs() : -parsedAmt.abs();

    if (widget.existingBill != null) {
      final updated = widget.existingBill!.copyWith(
        title: title,
        amount: finalAmount,
        dueDay: _dueDay,
        isIncome: _isIncome,
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
      );
      ref.read(recurringBillsProvider.notifier).updateBill(updated);
    } else {
      final newBill = RecurringBill(
        id: const Uuid().v4(),
        title: title,
        amount: finalAmount,
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
        dueDay: _dueDay,
        isIncome: _isIncome,
        createdAt: DateTime.now(),
      );
      ref.read(recurringBillsProvider.notifier).addBill(newBill);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final allCategories = ref.watch(supabaseCategoriesProvider).value ?? defaultCategories;
    final parentCategories = allCategories.where((c) => c.parentId == null).toList();

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingBill != null ? 'Edit Recurring Bill' : 'Add Recurring Bill / Income',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Income / Expense Toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isIncome ? const Color(0xFFEF4444) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Bill / Expense',
                            style: TextStyle(
                              color: !_isIncome ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isIncome ? const Color(0xFF10B981) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income / Salary',
                            style: TextStyle(
                              color: _isIncome ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title Input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title / Vendor Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g. Netflix, Chirie, Salary',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (RON)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g. 250.00',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  if (double.tryParse(val.replaceAll(',', '.')) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Due Day Slider (1 to 31)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Due Day of Month:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    'Day $_dueDay',
                    style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Slider(
                value: _dueDay.toDouble(),
                min: 1,
                max: 31,
                divisions: 30,
                activeColor: const Color(0xFF3B82F6),
                inactiveColor: Colors.white10,
                label: 'Day $_dueDay',
                onChanged: (val) => setState(() => _dueDay = val.toInt()),
              ),
              const SizedBox(height: 12),

              // Category Picker
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _categoryId,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: parentCategories.map((cat) {
                  final name = CategoryLocalizer.getLocalizedName(context, cat.name);
                  return DropdownMenuItem(value: cat.id, child: Text(name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _categoryId = val;
                      _subcategoryId = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _submit,
                  child: Text(widget.existingBill != null ? 'Update Bill' : 'Save Recurring Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
