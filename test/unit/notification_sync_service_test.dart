import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/features/notifications/services/notification_sync_service.dart';
import 'package:balanza/features/transactions/repositories/transaction_repository.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/debug_notification.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> addedTransactions = [];
  final List<DebugNotification> loggedDebugNotifications = [];
  bool shouldReturnDuplicate = false;

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    addedTransactions.add(transaction);
    return transaction;
  }

  @override
  Future<void> logDebugNotification(DebugNotification notification) async {
    loggedDebugNotifications.add(notification);
  }

  @override
  Future<bool> checkDuplicateRecentTransaction(double amount, {String? merchant, int windowSeconds = 60}) async {
    return shouldReturnDuplicate;
  }

  @override
  Future<void> claimUnassignedPendingTransactions() async {}
  @override
  Future<List<DebugNotification>> getDebugNotifications() async => [];

  @override
  Stream<List<Transaction>> getTransactionsStream(DateTime month) => Stream.value([]);
  @override
  Future<List<Transaction>> getTransactions(DateTime month) async => [];
  @override
  Stream<List<Transaction>> getPendingTransactionsStream() => Stream.value([]);
  @override
  Future<List<Transaction>> getPendingTransactions() async => [];
  @override
  Future<void> approvePendingTransaction(String id) async {}
  @override
  Future<Transaction> updateTransaction(Transaction transaction) async => transaction;
  @override
  Future<void> deleteTransaction(String id) async {}
}

void main() {
  group('NotificationSyncService Unit Tests', () {
    late FakeTransactionRepository fakeRepo;
    late NotificationSyncService service;

    setUp(() {
      fakeRepo = FakeTransactionRepository();
      service = NotificationSyncService(fakeRepo);
    });

    test('Ignores notifications from non-bank apps', () async {
      final handled = await service.handleNotificationEvent(
        packageName: 'com.whatsapp',
        title: 'Friend',
        body: 'Spent 100 RON at restaurant',
      );
      expect(handled, isFalse);
      expect(fakeRepo.addedTransactions, isEmpty);
      expect(fakeRepo.loggedDebugNotifications, isEmpty);
    });

    test('Logs debug notification when regex fails for allowed bank package', () async {
      final handled = await service.handleNotificationEvent(
        packageName: 'com.revolut.office',
        title: 'Revolut Update',
        body: 'New terms of service are now live.',
      );
      expect(handled, isFalse);
      expect(fakeRepo.addedTransactions, isEmpty);
      expect(fakeRepo.loggedDebugNotifications, hasLength(1));
      expect(fakeRepo.loggedDebugNotifications.first.packageName, equals('com.revolut.office'));
    });

    test('Deduplicates 60-second duplicate transactions', () async {
      fakeRepo.shouldReturnDuplicate = true;
      final handled = await service.handleNotificationEvent(
        packageName: 'com.revolut.office',
        title: 'Revolut',
        body: 'You spent 50.00 RON at Starbucks. Sold: 200 RON',
      );
      expect(handled, isFalse);
      expect(fakeRepo.addedTransactions, isEmpty);
    });

    test('Successfully parses and logs pending transaction for allowed bank package', () async {
      fakeRepo.shouldReturnDuplicate = false;
      final handled = await service.handleNotificationEvent(
        packageName: 'ro.bcr.georgego',
        title: 'George BCR',
        body: 'Plata cu cardul - 120.00 RON la Kaufland din contul RO123.',
      );
      expect(handled, isTrue);
      expect(fakeRepo.addedTransactions, hasLength(1));

      final tx = fakeRepo.addedTransactions.first;
      expect(tx.amount, equals(-120.00));
      expect(tx.description, equals('Kaufland'));
      expect(tx.isPendingReview, isTrue);
    });
  });
}
