import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Rebuild when authentication state changes (e.g. login/logout)
    ref.watch(authProvider);

    const defaultLang = 'en';

    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId != null) {
        _loadFromSupabase(client, currentUserId);
      }
    } catch (_) {
      // Gracefully handle uninitialized Supabase in test suites
    }

    return const Locale(defaultLang);
  }

  Future<void> _loadFromSupabase(SupabaseClient client, String userId) async {
    try {
      final response = await client
          .from('user_preferences')
          .select('language_code')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['language_code'] != null) {
        state = Locale(response['language_code'] as String);
      }
    } catch (_) {
      // Gracefully catch database missing table errors before user runs SQL console script
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);

    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId != null) {
        await client.from('user_preferences').upsert({
          'user_id': currentUserId,
          'language_code': languageCode,
        }, onConflict: 'user_id');
      }
    } catch (_) {
      // Gracefully handle db/network offline or uninitialized state
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});
