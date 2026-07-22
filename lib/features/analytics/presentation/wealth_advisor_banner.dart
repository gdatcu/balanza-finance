import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/locale_provider.dart';
import '../models/advisor_nudge.dart';
import '../providers/wealth_advisor_provider.dart';

/// Top-of-dashboard sleek banner displaying universal behavioral wealth nudges.
class WealthAdvisorBanner extends ConsumerWidget {
  const WealthAdvisorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nudge = ref.watch(wealthAdvisorProvider);
    if (nudge == null) return const SizedBox.shrink();

    final currentLocale = ref.watch(localeProvider);
    final isRo = currentLocale.languageCode == 'ro';

    Color accentColor;
    Color bgColor;
    String headerTitle;

    switch (nudge.severity) {
      case NudgeSeverity.alert:
        accentColor = const Color(0xFFEF4444); // Red alert
        bgColor = const Color(0xFF451A1A);
        headerTitle = isRo ? 'ALERTĂ ADVISOR WEALTH' : 'WEALTH ADVISOR ALERT';
        break;
      case NudgeSeverity.warning:
        accentColor = const Color(0xFFF59E0B); // Amber warning
        bgColor = const Color(0xFF3B2D13);
        headerTitle = isRo ? 'ATENȚIE ADVISOR WEALTH' : 'WEALTH ADVISOR NOTICE';
        break;
      case NudgeSeverity.safe:
        accentColor = const Color(0xFF10B981); // Emerald green
        bgColor = const Color(0xFF133B2B);
        headerTitle = isRo ? 'SUCCES ADVISOR WEALTH' : 'WEALTH ADVISOR INSIGHT';
        break;
      case NudgeSeverity.info:
        accentColor = const Color(0xFF3B82F6); // Slate Blue info
        bgColor = const Color(0xFF1E293B);
        headerTitle = isRo ? 'RECOMANDARE ADVISOR' : 'WEALTH ADVISOR NUDGE';
        break;
    }

    final textContent = nudge.getLocalizedText(currentLocale.languageCode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: accentColor.withValues(alpha: 0.2),
            child: Icon(nudge.icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      headerTitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  textContent,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              ref.read(dismissedNudgesProvider.notifier).dismiss(nudge.id);
            },
          ),
        ],
      ),
    );
  }
}
