import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/main.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';
import 'app_e2e_test.dart';

void main() {
  testWidgets('E2E Locale Switcher Flow - Toggle language between English (EN) and Romanian (RO)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'app_locale': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final mockTxRepo = E2EMockTransactionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockTxRepo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(
            AuthChangeEvent.signedIn,
            Session(
              accessToken: 'mock_token',
              tokenType: 'bearer',
              user: const User(
                id: '00000000-0000-0000-0000-000000000000',
                appMetadata: {},
                userMetadata: {},
                aud: 'authenticated',
                createdAt: '2026-07-26T12:00:00Z',
              ),
            ),
          ))),
          biometricLockProvider.overrideWith(() => E2EFakeBiometricLockNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify default English UI labels
    expect(find.text('BY DATE'), findsOneWidget);
    expect(find.text('BY CATEGORY'), findsOneWidget);

    // 2. Open Navigation Drawer
    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // 3. Tap 'RO' language option
    final roBtn = find.text('RO');
    expect(roBtn, findsOneWidget);
    await tester.tap(roBtn);
    await tester.pumpAndSettle();

    // Close drawer
    Navigator.of(tester.element(find.byType(Drawer))).pop();
    await tester.pumpAndSettle();

    // 4. Verify Romanian tab labels
    expect(find.text('DUPĂ DATĂ'), findsOneWidget);
    expect(find.text('DUPĂ CATEGORIE'), findsOneWidget);

    // 5. Open drawer again and switch back to 'EN'
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    final enBtn = find.text('EN');
    expect(enBtn, findsOneWidget);
    await tester.tap(enBtn);
    await tester.pumpAndSettle();

    // Close drawer
    Navigator.of(tester.element(find.byType(Drawer))).pop();
    await tester.pumpAndSettle();

    // 6. Verify English labels restored
    expect(find.text('BY DATE'), findsOneWidget);
    expect(find.text('BY CATEGORY'), findsOneWidget);
  });
}
