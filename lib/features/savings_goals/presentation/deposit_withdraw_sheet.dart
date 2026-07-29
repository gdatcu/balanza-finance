import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../../../models/savings_goal.dart';
import '../../transactions/presentation/accounts_data.dart';
import '../providers/savings_goal_provider.dart';

class DepositWithdrawSheet extends ConsumerStatefulWidget {
  final SavingsGoal goal;
  final bool isDeposit;

  const DepositWithdrawSheet({
    super.key,
    required this.goal,
    required this.isDeposit,
  });

  @override
  ConsumerState<DepositWithdrawSheet> createState() => _DepositWithdrawSheetState();
}

class _DepositWithdrawSheetState extends ConsumerState<DepositWithdrawSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late String _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = defaultAccounts.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());
      final isRo = Localizations.localeOf(context).languageCode == 'ro';
      final description = widget.isDeposit
          ? (isRo ? 'Pus la ciorap: ${widget.goal.title}' : 'Saved to Goal: ${widget.goal.title}')
          : (isRo ? 'Retras din ciorap: ${widget.goal.title}' : 'Withdrawn from Goal: ${widget.goal.title}');

      if (widget.isDeposit) {
        ref.read(savingsGoalListProvider.notifier).deposit(
          widget.goal.id,
          amount,
          accountId: _selectedAccountId,
          description: description,
        );
      } else {
        ref.read(savingsGoalListProvider.notifier).withdraw(
          widget.goal.id,
          amount,
          accountId: _selectedAccountId,
          description: description,
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final actionColor = widget.isDeposit ? const Color(0xFF10B981) : const Color(0xFFFF7A5A);
    final titleText = widget.isDeposit
        ? '${AppLocalizations.of(context)!.deposit}: ${widget.goal.title}'
        : '${AppLocalizations.of(context)!.withdraw}: ${widget.goal.title}';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAccountId,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Account',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.account_balance, color: Colors.grey),
                ),
                items: defaultAccounts.map((acc) {
                  return DropdownMenuItem<String>(
                    value: acc.id,
                    child: Text(acc.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedAccountId = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amountFieldLabel,
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.isDeposit
                      ? AppLocalizations.of(context)!.deposit
                      : AppLocalizations.of(context)!.withdraw,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

