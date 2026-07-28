import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/main.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';
import '../e2e/app_e2e_test.dart';

void main() {
  testWidgets('Dashboard Charts Widget Test - Switch between Breakdown Donut Chart and Burn Rate Gauge', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockTxRepo = E2EMockTransactionRepository();

    // Add Income and Expenses
    await mockTxRepo.addTransaction(Transaction(
      id: 'tx-inc-1',
      userId: '00000000-0000-0000-0000-000000000000',
      accountId: '00000000-0000-0000-0000-000000000000',
      amount: 4000.0,
      date: DateTime.now(),
      categoryId: 'salary',
      description: 'Salary',
      createdAt: DateTime.now(),
    ));

    await mockTxRepo.addTransaction(Transaction(
      id: 'tx-exp-1',
      userId: '00000000-0000-0000-0000-000000000000',
      accountId: '00000000-0000-0000-0000-000000000000',
      amount: -1500.0, // 37.5% burn rate (Green)
      date: DateTime.now(),
      categoryId: 'groceries',
      description: 'Monthly Groceries',
      createdAt: DateTime.now(),
    ));

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

    // 1. Verify Segmented Control exists
    final segmentedControl = find.byType(CupertinoSlidingSegmentedControl<int>);
    expect(segmentedControl, findsOneWidget);

    // 2. Default view is Breakdown (Donut Chart)
    expect(find.byKey(const ValueKey('donut_chart_data')), findsOneWidget);

    // 3. Switch to Burn Rate Gauge
    final burnRateTabRo = find.textContaining('Ritm');
    final burnRateTabEn = find.textContaining('Burn Rate');
    final targetBurnTab = burnRateTabRo.evaluate().isNotEmpty ? burnRateTabRo : burnRateTabEn;
    expect(targetBurnTab, findsOneWidget);

    await tester.tap(targetBurnTab);
    await tester.pumpAndSettle();

    // 4. Verify Burn Rate Gauge is displayed
    final gaugeFinder = find.byKey(const ValueKey('burn_rate_gauge_data'));
    expect(gaugeFinder, findsOneWidget);

    final indicatorFinder = find.descendant(of: gaugeFinder, matching: find.byType(LinearProgressIndicator));
    expect(indicatorFinder, findsOneWidget);

    // 5. Verify progress indicator value is ~0.375 for 37.5% burn rate
    final progressIndicator = tester.widget<LinearProgressIndicator>(indicatorFinder);
    expect(progressIndicator.value, closeTo(0.375, 0.01));
  });
}
