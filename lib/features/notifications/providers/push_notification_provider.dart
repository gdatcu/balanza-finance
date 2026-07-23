import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/features/notifications/services/push_notification_service.dart';

/// Provider for PushNotificationService instance.
final pushNotificationServiceProvider = Provider<PushNotificationService?>((ref) {
  try {
    final service = PushNotificationService();
    service.initializeAuthListener();
    ref.onDispose(() => service.dispose());
    return service;
  } catch (e) {
    if (kDebugMode) {
      print('pushNotificationServiceProvider initialization error: $e');
    }
    return null;
  }
});
