import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../auth/providers/auth_provider.dart';

const String kWorkingHoursPerDayKey = 'working_hours_per_day';

/// Provider for user's daily working hours setting (default: 8.0 hours/day).
final dailyWorkingHoursProvider = StreamProvider<double>((ref) {
  ref.watch(authProvider);

  final prefs = ref.watch(sharedPreferencesProvider);
  final localHours = prefs.getDouble(kWorkingHoursPerDayKey) ?? 8.0;

  try {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId != null) {
      return client
          .from('user_settings')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', currentUserId)
          .map((data) {
            if (data.isNotEmpty && data.first['working_hours_per_day'] != null) {
              final val = (data.first['working_hours_per_day'] as num).toDouble();
              prefs.setDouble(kWorkingHoursPerDayKey, val);
              return val;
            }
            return localHours;
          });
    }
  } catch (_) {
    // Gracefully handle uninitialized Supabase (e.g. in tests)
  }

  return Stream.value(localHours);
});

/// Helper function to update daily working hours in SharedPreferences and Supabase.
Future<bool> updateDailyWorkingHours(dynamic ref, double value) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final success = await prefs.setDouble(kWorkingHoursPerDayKey, value);

  try {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId != null) {
      await client.from('user_settings').upsert({
        'user_id': currentUserId,
        'working_hours_per_day': value,
      }, onConflict: 'user_id');
    }
  } catch (_) {}

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(dailyWorkingHoursProvider);
  });
  return success;
}
