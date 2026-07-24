import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/transactions/presentation/home_view.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/transactions/providers/exchange_rate_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/category.dart';

class MockTransactionRepository implements TransactionRepository {
  @override
  Stream<List<Transaction>> getTransactionsStream(DateTime month) {
    return Stream.value([
      Transaction(
        id: 't1',
        userId: 'u1',
        accountId: 'a1',
        amount: -50.0,
        description: 'Groceries Spend',
        date: DateTime.parse('2026-07-21T10:00:00Z'),
        createdAt: DateTime.parse('2026-07-21T10:00:00Z'),
      ),
    ]);
  }

  @override
  Future<List<Transaction>> getTransactions(DateTime month) async {
    return [
      Transaction(
        id: 't1',
        userId: 'u1',
        accountId: 'a1',
        amount: -50.0,
        description: 'Groceries Spend',
        date: DateTime.parse('2026-07-21T10:00:00Z'),
        createdAt: DateTime.parse('2026-07-21T10:00:00Z'),
      ),
    ];
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async => transaction;

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async => transaction;

  @override
  Future<void> deleteTransaction(String id) async {}
}

void main() {
  testWidgets('HomeView displays transactions and opening add modal works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'monthly_budget_limit': 1000.0});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockTransactionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockRepo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedOut, null))),
          supabaseCategoriesProvider.overrideWith((ref) => Future.value([
            Category(
              id: '00000000-0000-0000-0000-0000000000c1',
              name: 'Food',
              icon: 'lunch_dining',
              color: '#FF9800',
              createdAt: DateTime.now(),
            ),
          ])),
          exchangeRateProvider.overrideWith((ref) => Future.value(4.97)),
          biometricLockProvider.overrideWith(() => FakeBiometricLockNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: HomeView(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Balanza Finance'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);

    expect(find.text('Groceries Spend'), findsOneWidget);
    expect(find.text('-RON 50.00'), findsNWidgets(3));

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
  });

  testWidgets('SettingsView pre-fills current budget and saving updates state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'monthly_budget_limit': 1000.0});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockTransactionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockRepo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedOut, null))),
          supabaseCategoriesProvider.overrideWith((ref) => Future.value([
            Category(
              id: '00000000-0000-0000-0000-0000000000c1',
              name: 'Food',
              icon: 'lunch_dining',
              color: '#FF9800',
              createdAt: DateTime.now(),
            ),
          ])),
          exchangeRateProvider.overrideWith((ref) => Future.value(4.97)),
          biometricLockProvider.overrideWith(() => FakeBiometricLockNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: HomeView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open drawer to access Settings
    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    final settingsBtn = find.text('Settings');
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Configure Budget'), findsOneWidget);

    final textFormField = find.byType(TextFormField);
    expect(textFormField, findsOneWidget);

    await tester.enterText(textFormField, '1500.0');
    await tester.pump();

    final saveBtn = find.text('Save Budget');
    expect(saveBtn, findsOneWidget);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();
    expect(find.text('Balanza Finance'), findsOneWidget);
    expect(find.text('Spent: RON 50.00 / RON 1500.00'), findsOneWidget);
  });
}

class FakeBiometricLockNotifier extends BiometricLockNotifier {
  @override
  bool build() => false;
}
