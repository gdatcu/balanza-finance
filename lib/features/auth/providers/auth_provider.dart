import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider that exposes the Supabase authentication state stream.
final authProvider = StreamProvider<AuthState>((ref) {
  final stream = Supabase.instance.client.auth.onAuthStateChange;
  stream.listen((data) async {
    final userId = data.session?.user.id ?? Supabase.instance.client.auth.currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_authenticated_user_id', userId);
      } catch (_) {}
    }
  });
  return stream;
});
