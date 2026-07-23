import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final SupabaseClient _supabaseClient;
  FirebaseMessaging? _firebaseMessaging;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  PushNotificationService({
    SupabaseClient? supabaseClient,
    FirebaseMessaging? firebaseMessaging,
  }) : _supabaseClient = supabaseClient ?? Supabase.instance.client {
    if (firebaseMessaging != null) {
      _firebaseMessaging = firebaseMessaging;
    } else {
      try {
        if (Firebase.apps.isNotEmpty) {
          _firebaseMessaging = FirebaseMessaging.instance;
        }
      } catch (e) {
        if (kDebugMode) {
          print('PushNotificationService FirebaseMessaging instance warning: $e');
        }
      }
    }
  }

  /// Request notification permissions from the user.
  Future<NotificationSettings?> requestPermission() async {
    final fm = _firebaseMessaging;
    if (fm == null) return null;
    try {
      return await fm.requestPermission(
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
    final fm = _firebaseMessaging;
    if (fm == null) return null;
    try {
      return await fm.getToken();
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
    if (_firebaseMessaging == null) return false;

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
      if (user != null && _firebaseMessaging != null) {
        await requestPermission();
        await syncTokenToSupabase(user.id);
      }
    });

    final fm = _firebaseMessaging;
    if (fm != null) {
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = fm.onTokenRefresh.listen((newToken) async {
        final currentUserId = _supabaseClient.auth.currentUser?.id;
        if (currentUserId != null) {
          await syncTokenToSupabase(currentUserId);
        }
      });
    }
  }

  void dispose() {
    _authSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
  }
}
