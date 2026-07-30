import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../../models/transaction.dart';
import '../../../models/category.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/category_localizer.dart';
import '../providers/transaction_provider.dart';
import 'categories_data.dart';
import 'transaction_input_sheet.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    // Watch live transaction state if updated remotely or locally
    final currentTx = transactionsAsync.maybeWhen(
      data: (transactions) => transactions.firstWhere(
        (t) => t.id == transaction.id,
        orElse: () => transaction,
      ),
      orElse: () => transaction,
    );

    final isIncome = currentTx.amount > 0;
    final cat = defaultCategories.firstWhere(
      (c) => c.id == currentTx.categoryId,
      orElse: () => Category(
        id: currentTx.categoryId ?? 'uncategorized',
        name: currentTx.categoryId == null ? 'other' : 'uncategorized',
        createdAt: DateTime.now(),
      ),
    );

    final color = getCategoryColor(cat.color);
    final icon = getCategoryIcon(cat.icon);
    final localizedCategoryName = CategoryLocalizer.getLocalizedName(context, cat.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.transactionDetails,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppLocalizations.of(context)!.edit,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: const Color(0xFF1E293B),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => TransactionInputSheet(transactionToEdit: currentTx),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF7A5A)),
            tooltip: AppLocalizations.of(context)!.delete,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.deleteTransactionTitle),
                  content: Text(AppLocalizations.of(context)!.confirmDeleteTransaction),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        AppLocalizations.of(context)!.delete,
                        style: const TextStyle(color: Color(0xFFFF7A5A)),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(transactionRepositoryProvider).deleteTransaction(currentTx.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.transactionDeleted),
                      backgroundColor: const Color(0xFF1E293B),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount & Hero Card
            Card(
              color: const Color(0xFF1E293B),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: color.withValues(alpha: 0.2),
                      child: Icon(icon, size: 36, color: color),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizedCategoryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isIncome
                          ? '+${CurrencyFormatter.format(currentTx.amount)}'
                          : CurrencyFormatter.format(currentTx.amount),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                      ),
                    ),
                    if (currentTx.originalCurrency == 'EUR' && currentTx.originalAmount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        currentTx.originalAmount! > 0
                            ? '+€${currentTx.originalAmount!.toStringAsFixed(2)}'
                            : '-€${currentTx.originalAmount!.abs().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metadata Detail List Card
            Card(
              color: const Color(0xFF1E293B),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      icon: Icons.swap_horiz,
                      label: AppLocalizations.of(context)!.type,
                      value: isIncome
                          ? AppLocalizations.of(context)!.typeIncome
                          : AppLocalizations.of(context)!.typeExpense,
                      valueColor: isIncome ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _buildDetailRow(
                      context,
                      icon: Icons.calendar_today,
                      label: AppLocalizations.of(context)!.date,
                      value: '${currentTx.date.year}-${currentTx.date.month.toString().padLeft(2, '0')}-${currentTx.date.day.toString().padLeft(2, '0')}',
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _buildDetailRow(
                      context,
                      icon: Icons.category_outlined,
                      label: AppLocalizations.of(context)!.category,
                      value: localizedCategoryName,
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _buildDetailRow(
                      context,
                      icon: Icons.notes,
                      label: AppLocalizations.of(context)!.noteOptional,
                      value: (currentTx.description != null && currentTx.description!.trim().isNotEmpty)
                          ? currentTx.description!
                          : AppLocalizations.of(context)!.noNote,
                      isDescription: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isDescription = false,
  }) {
    return Row(
      crossAxisAlignment: isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
