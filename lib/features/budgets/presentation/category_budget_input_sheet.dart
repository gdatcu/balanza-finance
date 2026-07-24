import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../../models/category_budget.dart';
import '../../../core/utils/category_localizer.dart';
import '../../transactions/presentation/categories_data.dart';
import '../repositories/category_budget_repository.dart';

class CategoryBudgetInputSheet extends ConsumerStatefulWidget {
  final CategoryBudget? budgetToEdit;

  const CategoryBudgetInputSheet({
    super.key,
    this.budgetToEdit,
  });

  @override
  ConsumerState<CategoryBudgetInputSheet> createState() => _CategoryBudgetInputSheetState();
}

class _CategoryBudgetInputSheetState extends ConsumerState<CategoryBudgetInputSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCategory;
  late TextEditingController _amountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.budgetToEdit?.category ?? defaultCategories.first.id;
    _amountController = TextEditingController(
      text: widget.budgetToEdit != null ? widget.budgetToEdit!.amountLimit.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(categoryBudgetRepositoryProvider).upsertCategoryBudget(
            _selectedCategory,
            amount,
          );
      ref.invalidate(categoryBudgetsStreamProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.budgetUpdatedSuccessfully),
            backgroundColor: const Color(0xFF1E293B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving budget: $e'),
            backgroundColor: const Color(0xFFFF7A5A),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budgetToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
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
                        ? AppLocalizations.of(context)!.editCategoryBudget
                        : AppLocalizations.of(context)!.setCategoryBudget,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              const SizedBox(height: 20),

              // ignore: deprecated_member_use
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: defaultCategories.any((c) => c.id == _selectedCategory)
                    ? _selectedCategory
                    : defaultCategories.first.id,
                dropdownColor: const Color(0xFF1E293B),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category,
                  prefixIcon: const Icon(Icons.category_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: defaultCategories.map((c) {
                  final name = CategoryLocalizer.getLocalizedName(context, c.name);
                  final color = getCategoryColor(c.color);
                  final icon = getCategoryIcon(c.icon);
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 18),
                        const SizedBox(width: 10),
                        Text(name, style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: isEditing
                    ? null
                    : (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
              ),
              const SizedBox(height: 16),

              // Amount Limit Input Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.monthlyLimit,
                  hintText: 'e.g. 500',
                  prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.grey),
                  suffixText: 'RON',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterBudgetAmount;
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return AppLocalizations.of(context)!.pleaseEnterBudgetAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        AppLocalizations.of(context)!.saveBudget,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              if (isEditing) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final nav = Navigator.of(context);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.deleteBudgetTitle),
                              content: Text(AppLocalizations.of(context)!.confirmDeleteBudget),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(
                                    AppLocalizations.of(context)!.delete,
                                    style: const TextStyle(color: Color(0xFFFF7A5A)),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref
                                .read(categoryBudgetRepositoryProvider)
                                .deleteCategoryBudget(widget.budgetToEdit!.id);
                            ref.invalidate(categoryBudgetsStreamProvider);
                            if (mounted) {
                              nav.pop();
                            }
                          }
                        },
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: const TextStyle(color: Color(0xFFFF7A5A)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
