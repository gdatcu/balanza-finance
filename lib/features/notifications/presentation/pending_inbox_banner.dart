import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/presentation/transaction_input_sheet.dart';

class PendingInboxBanner extends ConsumerWidget {
  const PendingInboxBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingTransactionsProvider);

    return pendingAsync.when(
      data: (pendingList) {
        if (pendingList.isEmpty) {
          return const SizedBox.shrink();
        }

        final loc = AppLocalizations.of(context)!;
        final repository = ref.read(transactionRepositoryProvider);

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.move_to_inbox_rounded, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.pendingInboxTitle(pendingList.length),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  loc.pendingInboxSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingList.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFF334155), height: 1),
                  itemBuilder: (context, index) {
                    final tx = pendingList[index];
                    return Dismissible(
                      key: Key(tx.id),
                      background: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              loc.approve,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              loc.reject,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.delete_forever_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Approve
                          await repository.approvePendingTransaction(tx.id);
                          ref.invalidate(transactionListProvider);
                          ref.invalidate(pendingTransactionsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.pendingTransactionApproved)),
                            );
                          }
                          return true;
                        } else {
                          // Reject / Delete
                          await repository.deleteTransaction(tx.id);
                          ref.invalidate(pendingTransactionsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.pendingTransactionRejected)),
                            );
                          }
                          return true;
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 20),
                        ),
                        title: Text(
                          tx.description ?? 'Bank Purchase',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          '${tx.originalCurrency} ${tx.amount.abs().toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.format(tx.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: tx.amount < 0 ? const Color(0xFFFF7A5A) : const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit_rounded, color: Colors.grey, size: 18),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => TransactionInputSheet(transactionToEdit: tx),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
