import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/models/transaction.dart';

import 'package:balanza/models/debug_notification.dart';

class MockFullTransactionRepo implements TransactionRepository {
  final List<Transaction> _list = [];

  @override
  Stream<List<Transaction>> getTransactionsStream(DateTime month) {
    return Stream.value(_list);
  }

  @override
  Future<List<Transaction>> getTransactions(DateTime month) async {
    return List.from(_list);
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    _list.add(transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final idx = _list.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) _list[idx] = transaction;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _list.removeWhere((t) => t.id == id);
  }

  @override
  Stream<List<Transaction>> getPendingTransactionsStream() => Stream.value([]);
  @override
  Future<List<Transaction>> getPendingTransactions() async => [];
  @override
  Future<void> approvePendingTransaction(String id) async {}
  @override
  Future<bool> checkDuplicateRecentTransaction(double amount, {String? merchant, int windowSeconds = 60}) async => false;
  @override
  Future<void> logDebugNotification(dynamic notification) async {}
  @override
  Future<void> claimUnassignedPendingTransactions() async {}
  @override
  Future<List<DebugNotification>> getDebugNotifications() async => [];
}

void main() {
  group('TransactionRepository Logic Tests', () {
    late MockFullTransactionRepo repo;

    setUp(() {
      repo = MockFullTransactionRepo();
    });

    test('addTransaction inserts record', () async {
      final tx = Transaction(
        id: 'tx-1',
        userId: 'u1',
        accountId: 'a1',
        amount: -50.0,
        date: DateTime.parse('2026-07-26T12:00:00Z'),
        createdAt: DateTime.parse('2026-07-26T12:00:00Z'),
      );

      final result = await repo.addTransaction(tx);
      expect(result.id, 'tx-1');

      final list = await repo.getTransactions(DateTime(2026, 7));
      expect(list.length, 1);
    });

    test('updateTransaction modifies record', () async {
      final tx = Transaction(
        id: 'tx-1',
        userId: 'u1',
        accountId: 'a1',
        amount: -50.0,
        date: DateTime.parse('2026-07-26T12:00:00Z'),
        createdAt: DateTime.parse('2026-07-26T12:00:00Z'),
      );
      await repo.addTransaction(tx);

      final updatedTx = tx.copyWith(amount: -75.0);
      final result = await repo.updateTransaction(updatedTx);
      expect(result.amount, -75.0);
    });

    test('deleteTransaction removes record', () async {
      final tx = Transaction(
        id: 'tx-1',
        userId: 'u1',
        accountId: 'a1',
        amount: -50.0,
        date: DateTime.parse('2026-07-26T12:00:00Z'),
        createdAt: DateTime.parse('2026-07-26T12:00:00Z'),
      );
      await repo.addTransaction(tx);
      await repo.deleteTransaction('tx-1');

      final list = await repo.getTransactions(DateTime(2026, 7));
      expect(list, isEmpty);
    });
  });
}
