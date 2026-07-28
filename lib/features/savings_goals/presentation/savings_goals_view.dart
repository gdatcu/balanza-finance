import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../../models/savings_goal.dart';
import '../providers/savings_goal_provider.dart';
import 'savings_goal_input_sheet.dart';
import 'deposit_withdraw_sheet.dart';

class SavingsGoalsView extends ConsumerWidget {
  const SavingsGoalsView({super.key});

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF10B981);
    }
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SavingsGoalInputSheet(),
    );
  }

  void _showEditSheet(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SavingsGoalInputSheet(goalToEdit: goal),
    );
  }

  void _showDepositWithdrawSheet(BuildContext context, SavingsGoal goal, bool isDeposit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DepositWithdrawSheet(goal: goal, isDeposit: isDeposit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalListProvider);
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.savingsGoals,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: goalsAsync.when(
        data: (goals) {
          final totalSaved = goals.fold<double>(0.0, (sum, g) => sum + g.currentAmount);
          final totalTarget = goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);
          final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

          // Compute average monthly net savings rate from transactions
          double monthlyNetSavingsPace = 0.0;
          final txList = transactionsAsync.value ?? [];
          for (final tx in txList) {
            monthlyNetSavingsPace += tx.amount; // income positive, expense negative
          }
          final bool hasPositivePace = monthlyNetSavingsPace > 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Banner Card
              Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.totalSaved,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(totalSaved),
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.totalTarget,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(totalTarget),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 12,
                          child: LinearProgressIndicator(
                            value: overallProgress,
                            backgroundColor: const Color(0xFF0F172A),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(overallProgress * 100).toStringAsFixed(1)}% Completed',
                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Smart Projection Insight Banner
              if (goals.isNotEmpty && hasPositivePace) ...[
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF10B981), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.insights, color: Color(0xFF10B981), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.projectionTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Current monthly cash flow (+${CurrencyFormatter.format(monthlyNetSavingsPace)}) helps you progress towards your targets!',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (goals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noGoalsYet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...goals.map((goal) {
                  final accentColor = _parseColor(goal.color);
                  final isCompleted = goal.isCompleted;

                  return Card(
                    key: ValueKey(goal.id),
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isCompleted ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.05),
                        width: isCompleted ? 2.0 : 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: accentColor.withValues(alpha: 0.2),
                                    child: Icon(Icons.savings, color: accentColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    goal.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                color: const Color(0xFF0F172A),
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showEditSheet(context, goal);
                                  } else if (val == 'delete') {
                                    ref.read(savingsGoalListProvider.notifier).deleteGoal(goal.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(AppLocalizations.of(context)!.editSavingsGoal,
                                        style: const TextStyle(color: Colors.white)),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(AppLocalizations.of(context)!.deleteGoal,
                                        style: const TextStyle(color: Color(0xFFFF7A5A))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${CurrencyFormatter.format(goal.currentAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '${goal.progressPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 8,
                              child: LinearProgressIndicator(
                                value: (goal.progressPercentage / 100).clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFF0F172A),
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showDepositWithdrawSheet(context, goal, false),
                                icon: const Icon(Icons.remove, size: 16),
                                label: Text(AppLocalizations.of(context)!.withdraw),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFF7A5A),
                                  side: const BorderSide(color: Color(0xFFFF7A5A)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showDepositWithdrawSheet(context, goal, true),
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(AppLocalizations.of(context)!.deposit),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Color(0xFFFF7A5A))),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
