import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/main.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/savings_goals/providers/savings_goal_provider.dart';
import 'package:balanza/features/savings_goals/presentation/savings_goal_input_sheet.dart';
import 'package:balanza/features/savings_goals/presentation/deposit_withdraw_sheet.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';
import 'app_e2e_test.dart';
import '../widgets/savings_goals_view_test.dart';

void main() {
  testWidgets('E2E Savings Goals Flow - Navigate from drawer, add goal, deposit funds', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockTxRepo = E2EMockTransactionRepository();
    final mockSavingsRepo = MockWidgetSavingsGoalRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockTxRepo),
          savingsGoalRepositoryProvider.overrideWithValue(mockSavingsRepo),
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

    // 1. Open Navigation Drawer
    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // 2. Tap Savings Goals in Drawer
    final goalsTileRo = find.text('Obiective de Economisire');
    final goalsTileEn = find.text('Savings Goals');
    final targetTile = goalsTileRo.evaluate().isNotEmpty ? goalsTileRo : goalsTileEn;
    expect(targetTile, findsOneWidget);
    await tester.tap(targetTile);
    await tester.pumpAndSettle();

    // 3. Verify Savings Goals View is loaded
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // 4. Tap FAB to add Goal
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 5. Fill out form: "Emergency Fund", Target: 10000, Initial: 2500
    final nameField = find.byType(TextFormField).first;
    final targetField = find.byType(TextFormField).at(1);
    final currentField = find.byType(TextFormField).last;

    await tester.enterText(nameField, 'Emergency Fund');
    await tester.enterText(targetField, '10000');
    await tester.enterText(currentField, '2500');

    final submitBtn = find.descendant(
      of: find.byType(SavingsGoalInputSheet),
      matching: find.byType(ElevatedButton),
    );
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // 6. Verify Goal appears on view
    expect(find.text('Emergency Fund'), findsOneWidget);
    expect(find.text('25.0%'), findsOneWidget);

    // 7. Deposit 500 RON to Emergency Fund
    final depositBtnRo = find.text('Depune');
    final depositBtnEn = find.text('Deposit');
    final targetDepositBtn = depositBtnRo.evaluate().isNotEmpty ? depositBtnRo : depositBtnEn;
    expect(targetDepositBtn, findsWidgets);
    await tester.tap(targetDepositBtn.first);
    await tester.pumpAndSettle();

    final depositAmountField = find.byType(TextFormField).first;
    await tester.enterText(depositAmountField, '500');

    final modalDepositBtn = find.descendant(
      of: find.byType(DepositWithdrawSheet),
      matching: find.byType(ElevatedButton),
    );
    expect(modalDepositBtn, findsOneWidget);
    await tester.tap(modalDepositBtn);
    await tester.pumpAndSettle();

    // 8. Verify updated balance (2500 + 500 = 3000 RON -> 30.0%)
    expect(find.text('30.0%'), findsOneWidget);
  });
}
