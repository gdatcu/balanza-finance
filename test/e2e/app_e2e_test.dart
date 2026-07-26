import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/main.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/category.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/transactions/providers/exchange_rate_provider.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';

class E2EMockTransactionRepository implements TransactionRepository {
  final List<Transaction> _list = [];
  final StreamController<List<Transaction>> _controller = StreamController<List<Transaction>>.broadcast();

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(List.from(_list));
    }
  }

  @override
  Stream<List<Transaction>> getTransactionsStream(DateTime month) {
    return Stream.multi((multiController) async {
      multiController.add(List.from(_list));
      final sub = _controller.stream.listen((data) {
        if (!multiController.isClosed) {
          multiController.add(data);
        }
      });
      multiController.onCancel = () {
        sub.cancel();
      };
    });
  }

  @override
  Future<List<Transaction>> getTransactions(DateTime month) async {
    return List.from(_list);
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    _list.add(transaction);
    _notify();
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final idx = _list.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) _list[idx] = transaction;
    _notify();
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _list.removeWhere((t) => t.id == id);
    _notify();
  }
}

class E2EFakeBiometricLockNotifier extends BiometricLockNotifier {
  @override
  bool build() => false;
}

void main() {
  testWidgets('E2E Full Application Workflow Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'monthly_budget_limit': 1000.0});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = E2EMockTransactionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockRepo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedIn, Session(
            accessToken: 'mock_token',
            tokenType: 'bearer',
            user: const User(
              id: '00000000-0000-0000-0000-000000000000',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: '2026-07-26T12:00:00Z',
            ),
          )))),
          supabaseCategoriesProvider.overrideWith((ref) => Future.value([
            Category(
              id: '00000000-0000-0000-0000-000000000c1',
              name: 'Food',
              icon: 'lunch_dining',
              color: '#FF9800',
              createdAt: DateTime.now(),
            ),
          ])),
          exchangeRateProvider.overrideWith((ref) => Future.value(4.97)),
          biometricLockProvider.overrideWith(() => E2EFakeBiometricLockNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify HomeView is loaded
    expect(find.text('Balanza Finance'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);

    // 2. Open Add Transaction Modal
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);

    // 3. Fill and submit transaction form
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '75.00');

    final noteField = find.byType(TextFormField).last;
    await tester.enterText(noteField, 'E2E Test Dinner');

    final saveBtn = find.text('Save Transaction');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // 4. Verify transaction appears on dashboard
    expect(find.text('E2E Test Dinner'), findsOneWidget);
    expect(find.text('-RON 75.00'), findsNWidgets(3));

    // 5. Open Navigation Drawer and Settings
    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    final settingsBtn = find.text('Settings');
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle();

    // 6. Change Budget in Settings
    expect(find.text('Settings'), findsOneWidget);
    final budgetField = find.byType(TextFormField);
    await tester.enterText(budgetField, '2000.0');

    final saveBudgetBtn = find.text('Save Budget');
    await tester.tap(saveBudgetBtn);
    await tester.pumpAndSettle();

    // 7. Verify updated budget on HomeView
    expect(find.text('Balanza Finance'), findsOneWidget);
    expect(find.text('Spent: RON 75.00 / RON 2000.00'), findsOneWidget);
  });
}
