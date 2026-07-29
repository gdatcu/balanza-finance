import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balanza/features/transactions/presentation/add_transaction_view.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/transactions/providers/tagging_rules_provider.dart';
import 'package:balanza/models/tagging_rule.dart';

class MockTransactionRepo implements TransactionRepository {
  Transaction? addedTransaction;

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    addedTransaction = transaction;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<List<Transaction>> getTransactions(DateTime month) async => [];

  @override
  Stream<List<Transaction>> getTransactionsStream(DateTime month) => Stream.value([]);

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async => transaction;

  @override
  Stream<List<Transaction>> getPendingTransactionsStream() => Stream.value([]);
  @override
  Future<List<Transaction>> getPendingTransactions() async => [];
  @override
  Future<void> approvePendingTransaction(String id) async {}
  @override
  Future<bool> checkDuplicateRecentTransaction(double amount, {int windowSeconds = 60}) async => false;
  @override
  Future<void> logDebugNotification(dynamic notification) async {}
}

class FakeTaggingRulesNotifier extends TaggingRulesNotifier {
  @override
  Future<List<TaggingRule>> build() async {
    return const [
      TaggingRule(id: 'rule-1', keyword: 'starbucks', category: 'coffee_tea'),
    ];
  }
}

void main() {
  testWidgets('AddTransactionView renders, toggles income/expense, and submits successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final mockRepo = MockTransactionRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
          taggingRulesProvider.overrideWith(() => FakeTaggingRulesNotifier()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AddTransactionView(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);

    // Toggle to Income
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    // Enter Amount
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '250.00');

    // Enter Note
    final noteField = find.byType(TextFormField).last;
    await tester.enterText(noteField, 'Salary bonus');

    // Submit form
    final saveButton = find.text('Save Transaction');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(mockRepo.addedTransaction, isNotNull);
    expect(mockRepo.addedTransaction!.amount, 250.00);
    expect(mockRepo.addedTransaction!.description, 'Salary bonus');
  });
}
