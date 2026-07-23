import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final SupabaseClient _supabaseClient;
  final FirebaseMessaging _firebaseMessaging;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  PushNotificationService({
    SupabaseClient? supabaseClient,
    FirebaseMessaging? firebaseMessaging,
  })  : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  /// Request notification permissions from the user.
  Future<NotificationSettings?> requestPermission() async {
    try {
      return await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('PushNotificationService permission error: $e');
      }
      return null;
    }
  }

  /// Retrieve the current FCM token.
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('PushNotificationService getToken error: $e');
      }
      return null;
    }
  }

  /// Upsert the retrieved FCM token into the user_push_tokens Supabase table.
  /// Captures device's current locale (e.g., 'en' or 'ro') using PlatformDispatcher.
  Future<bool> syncTokenToSupabase([String? customUserId]) async {
    final userId = customUserId ?? _supabaseClient.auth.currentUser?.id;
    if (userId == null) return false;

    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    final languageCode = PlatformDispatcher.instance.locale.languageCode.isNotEmpty
        ? PlatformDispatcher.instance.locale.languageCode
        : 'en';

    try {
      await _supabaseClient.from('user_push_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
        'language': languageCode,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'fcm_token');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('PushNotificationService sync error: $e');
      }
      return false;
    }
  }

  /// Listens to Supabase auth state change and triggers token sync when user is authenticated.
  void initializeAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user ?? _supabaseClient.auth.currentUser;
      if (user != null) {
        await requestPermission();
        await syncTokenToSupabase(user.id);
      }
    });

    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      if (currentUserId != null) {
        await syncTokenToSupabase(currentUserId);
      }
    });
  }

  void dispose() {
    _authSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
  }
}
