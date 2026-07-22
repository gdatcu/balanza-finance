import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../providers/biometric_provider.dart';

class LockScreen extends ConsumerWidget {
  const LockScreen({super.key});

  Future<void> _attemptUnlock(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(biometricAuthProvider).authenticate(context);
    if (success) {
      ref.read(biometricLockProvider.notifier).setLocked(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    
    // Trigger biometric check on initial frame build (mobile only)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        _attemptUnlock(context, ref);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Branded Security Shield Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A5A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 80,
                    color: Color(0xFFFF7A5A),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                localizations.lockScreenTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.lockScreenSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _attemptUnlock(context, ref),
                icon: const Icon(Icons.fingerprint_rounded, size: 24),
                label: Text(
                  localizations.unlockButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
