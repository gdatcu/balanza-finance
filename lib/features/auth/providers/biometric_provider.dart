import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:balanza/l10n/app_localizations.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate(BuildContext context) async {
    if (kIsWeb) {
      return true;
    }
    final reason = AppLocalizations.of(context)!.biometricAuthReason;
    
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;

      if (!isSupported || !canCheck) {
        // Biometrics not supported/available on current platform/hardware (e.g. web or desktop)
        return true; 
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // fallback to passcode/pin if biometrics not enrolled
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricAuthProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

class BiometricLockNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true; // initially locked
  }

  void setLocked(bool val) {
    state = val;
  }
}

final biometricLockProvider = NotifierProvider<BiometricLockNotifier, bool>(() {
  return BiometricLockNotifier();
});
