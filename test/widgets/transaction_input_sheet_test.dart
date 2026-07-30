import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/features/transactions/presentation/transaction_input_sheet.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/transactions/providers/exchange_rate_provider.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/category.dart';

class MockSheetTransactionRepo implements TransactionRepository {
  bool added = false;
  bool updated = false;

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    added = true;
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    updated = true;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<List<Transaction>> getTransactions(DateTime month) async => [];

  @override
  Stream<List<Transaction>> getTransactionsStream(DateTime month) => Stream.value([]);
}

void main() {
  testWidgets('TransactionInputSheet allows creating new EUR transaction with currency conversion', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final mockRepo = MockSheetTransactionRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
          exchangeRateProvider.overrideWith((ref) => Future.value(5.0)),
          supabaseCategoriesProvider.overrideWith((ref) => Future.value([
            Category(
              id: '00000000-0000-0000-0000-000000000c16',
              name: 'Groceries',
              icon: 'shopping_basket',
              color: '#FF9800',
              isIncome: false,
              createdAt: DateTime.now(),
            ),
          ])),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: TransactionInputSheet(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);

    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '100');
    await tester.pumpAndSettle();

    final saveBtn = find.text('Save Transaction');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(mockRepo.added, true);
  });

  testWidgets('TransactionInputSheet allows editing an existing transaction', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final mockRepo = MockSheetTransactionRepo();

    final existingTx = Transaction(
      id: 'tx-edit-1',
      userId: 'u1',
      accountId: 'a1',
      categoryId: '00000000-0000-0000-0000-000000000c16',
      amount: -150.0,
      description: 'Original note',
      date: DateTime.parse('2026-07-26T12:00:00Z'),
      createdAt: DateTime.parse('2026-07-26T12:00:00Z'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
          exchangeRateProvider.overrideWith((ref) => Future.value(4.97)),
          supabaseCategoriesProvider.overrideWith((ref) => Future.value([
            Category(
              id: '00000000-0000-0000-0000-000000000c16',
              name: 'Groceries',
              icon: 'shopping_basket',
              color: '#FF9800',
              isIncome: false,
              createdAt: DateTime.now(),
            ),
          ])),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TransactionInputSheet(transactionToEdit: existingTx),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);

    final editSaveBtn = find.text('Edit');
    await tester.tap(editSaveBtn);
    await tester.pumpAndSettle();

    expect(mockRepo.updated, true);
  });
}
