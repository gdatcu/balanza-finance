import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/transactions/presentation/transaction_details_screen.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';

class MockDetailsRepo implements TransactionRepository {
  bool deleted = false;

  @override
  Future<Transaction> addTransaction(Transaction transaction) async => transaction;

  @override
  Future<void> deleteTransaction(String id) async {
    deleted = true;
  }

  @override
  Future<List<Transaction>> getTransactions(DateTime month) async => [];

  @override
  Stream<List<Transaction>> getTransactionsStream(DateTime month) => Stream.value([]);

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async => transaction;
}

void main() {
  testWidgets('TransactionDetailsScreen displays metadata and allows deletion', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final mockRepo = MockDetailsRepo();

    final testTx = Transaction(
      id: 'tx-details-1',
      userId: 'u1',
      accountId: 'a1',
      amount: -120.50,
      description: 'Supermarket test purchase',
      date: DateTime.parse('2026-07-26T12:00:00Z'),
      createdAt: DateTime.parse('2026-07-26T12:00:00Z'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: TransactionDetailsScreen(transaction: testTx),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('-RON 120.50'), findsOneWidget);
    expect(find.text('Supermarket test purchase'), findsOneWidget);

    // Tap delete button in AppBar
    final deleteIcon = find.byIcon(Icons.delete_outline);
    expect(deleteIcon, findsOneWidget);
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();

    // Confirm dialog
    expect(find.text('Delete Transaction?'), findsOneWidget);
    final confirmDeleteBtn = find.widgetWithText(TextButton, 'Delete');
    await tester.tap(confirmDeleteBtn);
    await tester.pumpAndSettle();

    expect(mockRepo.deleted, true);
  });
}
