import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';

class MockTransactionRepository implements TransactionRepository {
  final List<Transaction> transactions;

  MockTransactionRepository(this.transactions);

  @override
  Future<List<Transaction>> getTransactions(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
    final filtered = transactions
        .where((tx) => tx.date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
                       tx.date.isBefore(end.add(const Duration(milliseconds: 1))))
        .toList();
    return filtered..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    transactions.add(transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final idx = transactions.indexWhere((tx) => tx.id == transaction.id);
    if (idx != -1) {
      transactions[idx] = transaction;
    }
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((tx) => tx.id == id);
  }
}

void main() {
  group('Transaction Provider and Notifier Tests', () {
    late List<Transaction> initialData;
    late MockTransactionRepository mockRepository;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'monthly_budget_limit': 1000.0});
      final prefs = await SharedPreferences.getInstance();

      initialData = [
        Transaction(
          id: 't1',
          userId: 'u1',
          accountId: 'a1',
          amount: -50.0,
          description: 'Initial Tx 1',
          date: DateTime.parse('2026-07-21T10:00:00Z'),
          createdAt: DateTime.parse('2026-07-21T10:00:00Z'),
        ),
        Transaction(
          id: 't2',
          userId: 'u1',
          accountId: 'a1',
          amount: 150.0,
          description: 'Initial Tx 2',
          date: DateTime.parse('2026-07-21T11:00:00Z'),
          createdAt: DateTime.parse('2026-07-21T11:00:00Z'),
        ),
      ];
      mockRepository = MockTransactionRepository(initialData);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockRepository),
          authProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedOut, null))),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads transactions initially in descending date order', () async {
      // First read triggers the build method of TransactionListNotifier
      final list = await container.read(transactionListProvider.future);

      // Verify that list returns the initialData sorted descending by date
      expect(list.length, 2);
      expect(list[0].id, 't2'); // t2 is 11:00, t1 is 10:00
      expect(list[1].id, 't1');
    });

    test('Add transaction inserts and updates provider state', () async {
      // Initialize provider state
      await container.read(transactionListProvider.future);

      final newTx = Transaction(
        id: 't3',
        userId: 'u1',
        accountId: 'a1',
        amount: -25.5,
        description: 'New Tx',
        date: DateTime.parse('2026-07-21T12:00:00Z'),
        createdAt: DateTime.parse('2026-07-21T12:00:00Z'),
      );

      await container.read(transactionListProvider.notifier).add(newTx);

      final currentState = container.read(transactionListProvider);
      expect(currentState.hasValue, true);
      
      final list = currentState.value!;
      expect(list.length, 3);
      expect(list[0].id, 't3'); // t3 is 12:00, so it's first
      expect(list[1].id, 't2');
      expect(list[2].id, 't1');
    });

    test('Update transaction modifies local provider state', () async {
      // Initialize provider state
      await container.read(transactionListProvider.future);

      final updatedTx = Transaction(
        id: 't1',
        userId: 'u1',
        accountId: 'a1',
        amount: -80.0, // Modified amount
        description: 'Updated Tx 1', // Modified description
        date: DateTime.parse('2026-07-21T10:00:00Z'),
        createdAt: DateTime.parse('2026-07-21T10:00:00Z'),
      );

      await container.read(transactionListProvider.notifier).updateTx(updatedTx);

      final currentState = container.read(transactionListProvider);
      expect(currentState.hasValue, true);

      final list = currentState.value!;
      final updatedItem = list.firstWhere((tx) => tx.id == 't1');
      expect(updatedItem.amount, -80.0);
      expect(updatedItem.description, 'Updated Tx 1');
    });

    test('Delete transaction removes it from provider state', () async {
      // Initialize provider state
      await container.read(transactionListProvider.future);

      await container.read(transactionListProvider.notifier).delete('t1');

      final currentState = container.read(transactionListProvider);
      expect(currentState.hasValue, true);

      final list = currentState.value!;
      expect(list.length, 1);
      expect(list.any((tx) => tx.id == 't1'), false);
    });
  });
}
