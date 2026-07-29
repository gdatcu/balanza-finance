import 'package:flutter/widgets.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final title = NotificationSyncService.extractTitle(event);
    final body = NotificationSyncService.extractBody(event);
    final pkg = event.packageName ?? '';

    await NotificationSyncService().handleNotificationEvent(
      packageName: pkg,
      title: title,
      body: body,
    );
  } catch (_) {
    // Swallowed safely to protect the Android process from native isolate crashes
  }
}

class NotificationSyncService {
  final TransactionRepository _repository;

  NotificationSyncService([TransactionRepository? repository])
      : _repository = repository ?? TransactionRepository();

  /// Extracts title safely from NotificationEvent
  static String extractTitle(NotificationEvent event) {
    if (event.title != null && event.title!.trim().isNotEmpty) {
      return event.title!.trim();
    }
    final raw = event.raw;
    if (raw is Map) {
      final t = raw['title'] ?? raw['subText'] ?? raw['summaryText'];
      if (t != null && t.toString().trim().isNotEmpty) return t.toString().trim();
    }
    return '';
  }

  /// Extracts full body text safely from NotificationEvent
  static String extractBody(NotificationEvent event) {
    final raw = event.raw;
    String body = '';

    if (raw is Map) {
      final parts = <String>[];
      if (raw['text'] != null && raw['text'].toString().trim().isNotEmpty) {
        parts.add(raw['text'].toString().trim());
      }
      if (raw['message'] != null && raw['message'].toString().trim().isNotEmpty) {
        parts.add(raw['message'].toString().trim());
      }
      if (raw['bigText'] != null && raw['bigText'].toString().trim().isNotEmpty) {
        parts.add(raw['bigText'].toString().trim());
      }
      if (raw['summaryText'] != null && raw['summaryText'].toString().trim().isNotEmpty) {
        parts.add(raw['summaryText'].toString().trim());
      }
      if (parts.isNotEmpty) {
        body = parts.join(' ');
      }
    }

    if (body.isEmpty) {
      if (event.text != null && event.text!.trim().isNotEmpty) {
        body = event.text!.trim();
      } else if (event.message != null && event.message!.trim().isNotEmpty) {
        body = event.message!.trim();
      }
    }
    return body;
  }

  static bool isAllowedPackage(String pkg) {
    if (allowedBankPackages.contains(pkg)) return true;
    final lower = pkg.toLowerCase();
    return lower.contains('revolut') ||
        lower.contains('bcr') ||
        lower.contains('george') ||
        lower.contains('salt') ||
        lower.contains('ing') ||
        lower.contains('wallet');
  }

  /// Processes an incoming notification event
  Future<bool> handleNotificationEvent({
    required String packageName,
    required String title,
    required String body,
  }) async {
    try {
      if (!isAllowedPackage(packageName)) {
        return false;
      }

      final parsed = NotificationParser.parseNotification(
        packageName: packageName,
        title: title,
        body: body,
      );

      final now = DateTime.now();

      // Always log notification to debug_notifications table for auditing
      final debugLog = DebugNotification(
        id: const Uuid().v4(),
        packageName: packageName,
        rawTitle: title,
        rawBody: body,
        createdAt: now,
      );
      await _repository.logDebugNotification(debugLog);

      // 1. Debug Fallback: Regex failed to parse valid transaction details
      if (parsed == null) {
        return false;
      }

      // 2. 60-Second Deduplication Check
      final isDuplicate = await _repository.checkDuplicateRecentTransaction(
        parsed.amount,
        merchant: parsed.merchant,
        windowSeconds: 60,
      );
      if (isDuplicate) {
        return false;
      }

      // Read last authenticated user ID if available
      String userId = '00000000-0000-0000-0000-000000000000';
      try {
        final prefs = await SharedPreferences.getInstance();
        final storedId = prefs.getString('last_authenticated_user_id');
        if (storedId != null && storedId.isNotEmpty) {
          userId = storedId;
        }
      } catch (_) {}

      // 3. Create Pending Transaction with valid user ID
      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: userId,
        accountId: '00000000-0000-0000-0000-000000000001',
        categoryId: parsed.categoryId,
        amount: parsed.isIncome ? parsed.amount.abs() : -parsed.amount.abs(),
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
