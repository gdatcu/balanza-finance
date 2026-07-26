import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/features/auth/presentation/lock_screen.dart';
import 'package:balanza/features/auth/presentation/biometric_lock_wrapper.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';

class TestLockNotifier extends BiometricLockNotifier {
  final bool initialLocked;
  TestLockNotifier(this.initialLocked);

  @override
  bool build() => initialLocked;
}

void main() {
  testWidgets('LockScreen renders security icon and unlock button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: LockScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Balanza Secure Lock'), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
  });

  testWidgets('BiometricLockWrapper displays LockScreen when locked and child when unlocked', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final lockNotifier = TestLockNotifier(true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          biometricLockProvider.overrideWith(() => lockNotifier),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: BiometricLockWrapper(
            child: Text('Secret Protected Content'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Balanza Secure Lock'), findsOneWidget);
    expect(find.text('Secret Protected Content'), findsNothing);

    // Unlock
    lockNotifier.setLocked(false);
    await tester.pumpAndSettle();

    expect(find.text('Balanza Secure Lock'), findsNothing);
    expect(find.text('Secret Protected Content'), findsOneWidget);
  });
}
