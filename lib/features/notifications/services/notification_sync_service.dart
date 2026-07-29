import 'package:flutter/widgets.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:uuid/uuid.dart';
import '../../../models/transaction.dart';
import '../../../models/debug_notification.dart';
import '../../../core/utils/notification_parser.dart';
import '../../transactions/repositories/transaction_repository.dart';

const List<String> allowedBankPackages = [
  'com.revolut.office',
  'ro.bcr.georgego',
  'ro.salt.bank',
  'ro.ing.mobile.banking',
  'com.google.android.apps.walletnfcrel',
];

/// Top-level background callback for flutter_notification_listener
@pragma('vm:entry-point')
void _onNotificationData(NotificationEvent event) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationSyncService().handleNotificationEvent(
      packageName: event.packageName ?? '',
      title: event.title ?? '',
      body: event.message ?? event.text ?? '',
    );
  } catch (_) {
    // Swallowed safely to protect the Android process from native isolate crashes
  }
}

class NotificationSyncService {
  final TransactionRepository _repository;

  NotificationSyncService([TransactionRepository? repository])
      : _repository = repository ?? TransactionRepository();

  /// Processes an incoming notification event
  Future<bool> handleNotificationEvent({
    required String packageName,
    required String title,
    required String body,
  }) async {
    try {
      if (!allowedBankPackages.contains(packageName)) {
        return false;
      }

      final parsed = NotificationParser.parseNotification(
        packageName: packageName,
        title: title,
        body: body,
      );

      final now = DateTime.now();

      // 1. Debug Fallback: Regex failed to parse valid transaction details
      if (parsed == null) {
        final debugLog = DebugNotification(
          id: const Uuid().v4(),
          packageName: packageName,
          rawTitle: title,
          rawBody: body,
          createdAt: now,
        );
        await _repository.logDebugNotification(debugLog);
        return false;
      }

      // 2. 60-Second Deduplication Check
      final isDuplicate = await _repository.checkDuplicateRecentTransaction(parsed.amount, windowSeconds: 60);
      if (isDuplicate) {
        return false;
      }

      // 3. Create Pending Transaction
      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: '',
        accountId: 'default-acc',
        categoryId: parsed.categoryId,
        amount: -parsed.amount.abs(), // Expenses are negative
        description: parsed.merchant,
        date: now,
        createdAt: now,
        originalCurrency: parsed.currency,
        originalAmount: parsed.amount,
        isPendingReview: true,
      );

      await _repository.addTransaction(transaction);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Starts the notification listener service on Android safely
  static Future<bool> startListener() async {
    try {
      NotificationsListener.initialize(callbackHandle: _onNotificationData);

      final bool granted = await isPermissionGranted();
      if (!granted) return false;

      final bool? isRunning = await NotificationsListener.isRunning;
      if (isRunning != true) {
        await NotificationsListener.startService();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if notification permission is granted
  static Future<bool> isPermissionGranted() async {
    try {
      final bool? granted = await NotificationsListener.hasPermission;
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Directs user to Android system notification access settings screen
  static Future<void> openPermissionSettings() async {
    try {
      await NotificationsListener.openPermissionSettings();
    } catch (_) {}
  }
}
