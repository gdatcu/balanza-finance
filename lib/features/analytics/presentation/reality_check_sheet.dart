import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../settings/providers/time_cost_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../settings/providers/locale_provider.dart';
import '../../transactions/presentation/transaction_input_sheet.dart';

/// Full-screen / BottomSheet pre-purchase "Reality Check" behavioral intervention calculator.
class RealityCheckSheet extends ConsumerStatefulWidget {
  const RealityCheckSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const RealityCheckSheet(),
    );
  }

  @override
  ConsumerState<RealityCheckSheet> createState() => _RealityCheckSheetState();
}

class _RealityCheckSheetState extends ConsumerState<RealityCheckSheet> {
  String _inputAmountStr = '';

  void _onKeyPress(String val) {
    setState(() {
      if (val == '.') {
        if (!_inputAmountStr.contains('.')) {
          _inputAmountStr = _inputAmountStr.isEmpty ? '0.' : '$_inputAmountStr.';
        }
      } else if (val == '⌫') {
        if (_inputAmountStr.isNotEmpty) {
          _inputAmountStr = _inputAmountStr.substring(0, _inputAmountStr.length - 1);
        }
      } else {
        if (_inputAmountStr == '0') {
          _inputAmountStr = val;
        } else {
          // Limit max 7 digits before decimal and max 2 decimal places
          if (_inputAmountStr.contains('.')) {
            final parts = _inputAmountStr.split('.');
            if (parts[1].length < 2) {
              _inputAmountStr += val;
            }
          } else if (_inputAmountStr.length < 8) {
            _inputAmountStr += val;
          }
        }
      }
    });
  }

  void _clear() {
    setState(() {
      _inputAmountStr = '';
    });
  }

  void _onWalkAway() {
    _clear();
    Navigator.of(context).pop();
  }

  void _onPutInWishlist(double amount) {
    final scaffold = ScaffoldMessenger.of(context);
    final isRo = ref.read(localeProvider).languageCode == 'ro';
    Navigator.of(context).pop();
    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          isRo
              ? 'Adăugat în Lista de Dorințe! O perioadă de reflecție este cea mai bună alegere. 🎉'
              : 'Added to Wishlist! Taking a cooling-off period is the best financial choice. 🎉',
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _onBuyingAnyway(double amount) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TransactionInputSheet(initialAmount: amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedAmount = double.tryParse(_inputAmountStr) ?? 0.0;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final locale = ref.watch(localeProvider);
    final isRo = locale.languageCode == 'ro';
    final l10n = AppLocalizations.of(context)!;

    final timeCostResult = parsedAmount > 0
        ? ref.watch(
            timeCostProvider(
              TimeCostParams(month: selectedMonth, amount: parsedAmount),
            ),
          )
        : null;

    String timeCostText = '';
    if (parsedAmount > 0) {
      if (timeCostResult != null && timeCostResult.timeCostHours > 0) {
        final hours = timeCostResult.timeCostHours;
        final dailyHours = timeCostResult.dailyWorkingHours;
        if (hours < dailyHours) {
          final hStr = hours.toStringAsFixed(1);
          timeCostText = isRo
              ? 'Asta te costă $hStr ore din viața ta.'
              : 'That costs you $hStr hours of your life.';
        } else {
          final days = hours / dailyHours;
          final dStr = days.toStringAsFixed(1);
          timeCostText = isRo
              ? 'Asta te costă $dStr zile de muncă din viața ta.'
              : 'That costs you $dStr work days of your life.';
        }
      } else {
        timeCostText = l10n.noIncomeWarning;
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Color(0xFFFF7A5A)),
                    const SizedBox(width: 8),
                    Text(
                      l10n.realityCheck,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Top display section: Amount & Time-to-Value cost
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  Text(
                    _inputAmountStr.isEmpty ? '0 RON' : '$_inputAmountStr RON',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: _inputAmountStr.isEmpty ? Colors.grey : const Color(0xFFFF7A5A),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      timeCostText.isEmpty ? (isRo ? 'Tastează suma pe tastatură' : 'Type an amount below') : timeCostText,
                      key: ValueKey(timeCostText),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: (timeCostResult != null && timeCostResult.timeCostHours > 0)
                            ? const Color(0xFFF59E0B)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Intervention Action Buttons (Visible when amount > 0)
            if (parsedAmount > 0) ...[
              ElevatedButton.icon(
                onPressed: () => _onPutInWishlist(parsedAmount),
                icon: const Icon(Icons.bookmark_add, color: Colors.white),
                label: Text(
                  l10n.putInWishlist,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _onWalkAway,
                icon: const Icon(Icons.directions_walk, color: Color(0xFF10B981)),
                label: Text(
                  l10n.walkAway,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => _onBuyingAnyway(parsedAmount),
                child: Text(
                  l10n.buyingAnyway,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Custom Keypad
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'].map(
                  (val) => Material(
                    key: Key('keypad_$val'),
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _onKeyPress(val),
                      child: Center(
                        child: Text(
                          val,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
