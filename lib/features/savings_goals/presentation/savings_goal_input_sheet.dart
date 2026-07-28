import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../../../models/savings_goal.dart';
import '../providers/savings_goal_provider.dart';

class SavingsGoalInputSheet extends ConsumerStatefulWidget {
  final SavingsGoal? goalToEdit;

  const SavingsGoalInputSheet({super.key, this.goalToEdit});

  @override
  ConsumerState<SavingsGoalInputSheet> createState() => _SavingsGoalInputSheetState();
}

class _SavingsGoalInputSheetState extends ConsumerState<SavingsGoalInputSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  DateTime? _selectedTargetDate;
  String _selectedColor = '#10B981';

  final List<String> _availableColors = [
    '#10B981', // Sage Mint
    '#FF7A5A', // Coral Orange
    '#F59E0B', // Warm Amber
    '#3B82F6', // Royal Blue
    '#8B5CF6', // Purple
    '#EC4899', // Pink
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goalToEdit?.title ?? '');
    _targetAmountController = TextEditingController(
        text: widget.goalToEdit != null ? widget.goalToEdit!.targetAmount.toStringAsFixed(0) : '');
    _currentAmountController = TextEditingController(
        text: widget.goalToEdit != null ? widget.goalToEdit!.currentAmount.toStringAsFixed(0) : '0');
    _selectedTargetDate = widget.goalToEdit?.targetDate;
    _selectedColor = widget.goalToEdit?.color ?? '#10B981';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF10B981);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final targetAmount = double.parse(_targetAmountController.text.trim());
      final currentAmount = double.tryParse(_currentAmountController.text.trim()) ?? 0.0;

      if (widget.goalToEdit != null) {
        final updated = widget.goalToEdit!.copyWith(
          title: title,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _selectedTargetDate,
          color: _selectedColor,
        );
        ref.read(savingsGoalListProvider.notifier).updateGoal(updated);
      } else {
        final newGoal = SavingsGoal(
          id: const Uuid().v4(),
          userId: '',
          title: title,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _selectedTargetDate,
          color: _selectedColor,
          createdAt: DateTime.now(),
        );
        ref.read(savingsGoalListProvider.notifier).addGoal(newGoal);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalToEdit != null;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + keyboardInset,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing
                          ? AppLocalizations.of(context)!.editSavingsGoal
                          : AppLocalizations.of(context)!.addSavingsGoal,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name,
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppLocalizations.of(context)!.pleaseEnterName
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _targetAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.targetAmount,
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    final parsed = double.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _currentAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.currentAmount,
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Color Picker Row
                Row(
                  children: [
                    const Text('Badge Color: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 8,
                      children: _availableColors.map((hex) {
                        final color = _parseColor(hex);
                        final isSelected = _selectedColor == hex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = hex),
                          child: CircleAvatar(
                            radius: isSelected ? 16 : 12,
                            backgroundColor: color,
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _parseColor(_selectedColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing
                        ? AppLocalizations.of(context)!.editSavingsGoal
                        : AppLocalizations.of(context)!.addSavingsGoal,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
