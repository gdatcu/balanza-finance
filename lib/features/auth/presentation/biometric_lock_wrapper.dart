import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/biometric_provider.dart';
import 'lock_screen.dart';

class BiometricLockWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const BiometricLockWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<BiometricLockWrapper> createState() => _BiometricLockWrapperState();
}

class _BiometricLockWrapperState extends ConsumerState<BiometricLockWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Require authentication again when app goes to background
      ref.read(biometricLockProvider.notifier).setLocked(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(biometricLockProvider);

    if (isLocked) {
      return const LockScreen();
    }

    return widget.child;
  }
}
