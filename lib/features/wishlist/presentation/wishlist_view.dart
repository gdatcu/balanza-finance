import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../providers/wishlist_provider.dart';
import '../../settings/providers/time_cost_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../settings/providers/locale_provider.dart';
import '../../transactions/presentation/transaction_input_sheet.dart';
import '../../../core/utils/currency_formatter.dart';

class WishlistView extends ConsumerWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistItems = ref.watch(wishlistProvider);
    final activeItems = wishlistItems.where((item) => item.status == 'cooling_off').toList();
    final selectedMonth = ref.watch(selectedMonthProvider);
    final locale = ref.watch(localeProvider);
    final isRo = locale.languageCode == 'ro';
    final l10n = AppLocalizations.of(context)!;

    final totalReflectionAmount = activeItems.fold<double>(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          l10n.coolingOffWishlist,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF7A5A), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bookmark_added, color: Color(0xFFFF7A5A), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isRo ? 'Bani în perioada de reflecție' : 'Money held in reflection',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${CurrencyFormatter.format(totalReflectionAmount)} RON',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF7A5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRo
                          ? 'Aceste achiziții sunt întrerupte temporar pentru a preveni cheltuielile impulsive.'
                          : 'These purchases are on pause to prevent impulse buying friction.',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (activeItems.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.sentiment_satisfied_alt, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noWishlistItemsYet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeItems.length,
                  itemBuilder: (context, idx) {
                    final item = activeItems[idx];
                    final timeCostResult = ref.watch(
                      timeCostProvider(
                        TimeCostParams(month: selectedMonth, amount: item.amount),
                      ),
                    );

                    final timeCostStr = timeCostResult?.formatDuration(isRomanian: isRo);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF10B981)),
                                  ),
                                  child: Text(
                                    l10n.daysLeft(item.daysRemaining),
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${CurrencyFormatter.format(item.amount)} RON',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF7A5A),
                                  ),
                                ),
                                if (timeCostStr != null) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    '($timeCostStr ${isRo ? "de muncă" : "of work"})',
                                    style: const TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      ref.read(wishlistProvider.notifier).removeItem(item.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isRo
                                                ? 'Ai renunțat la achiziție! Ai economisit ${CurrencyFormatter.format(item.amount)} RON! 🎉'
                                                : 'Item discarded! You saved ${CurrencyFormatter.format(item.amount)} RON! 🎉',
                                          ),
                                          backgroundColor: const Color(0xFF10B981),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF10B981)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.discardItem,
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final result = await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: const Color(0xFF0F172A),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        builder: (context) => TransactionInputSheet(
                                          initialAmount: item.amount,
                                          initialDescription: (item.title != 'Pre-purchase Item' && item.title != 'Achiziție în reflecție')
                                              ? item.title
                                              : null,
                                        ),
                                      );
                                      if (result == true) {
                                        await ref.read(wishlistProvider.notifier).markBought(item.id);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF7A5A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.buyNow,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
