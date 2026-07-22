import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/locale_provider.dart';
import '../providers/wealth_advisor_provider.dart';

/// Responsive, dark-themed Wealth Advisor card component with full EN/RO localization support.
class WealthAdvisorCard extends ConsumerWidget {
  final WealthAdvisorState state;
  final VoidCallback? onDismiss;

  const WealthAdvisorCard({
    super.key,
    required this.state,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final languageCode = currentLocale.languageCode;

    final isNudge = state.type == AdvisorType.nudge;
    final accentColor = isNudge ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6);

    final titleText = state.getLocalizedTitle(languageCode);
    final messageText = state.getLocalizedText(languageCode);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
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
                backgroundColor: accentColor.withValues(alpha: 0.15),
                child: Icon(state.icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      messageText,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDismiss ??
                    () {
                      ref.read(dismissedNudgesProvider.notifier).dismiss(state.id);
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
