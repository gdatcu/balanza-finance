import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/tagging_rule.dart';

/// AsyncNotifier to fetch and cache remote tagging rules from Supabase.
class TaggingRulesNotifier extends AsyncNotifier<List<TaggingRule>> {
  @override
  Future<List<TaggingRule>> build() async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('tagging_rules')
          .select()
          .eq('is_active', true);

      final rules = (response as List)
          .map((json) => TaggingRule.fromJson(json as Map<String, dynamic>))
          .toList();

      return rules;
    } catch (_) {
      // Gracefully return empty list if table does not exist or network fails
      return <TaggingRule>[];
    }
  }

  /// Refreshes the cached tagging rules from Supabase.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;
      final response = await client
          .from('tagging_rules')
          .select()
          .eq('is_active', true);

      return (response as List)
          .map((json) => TaggingRule.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }
}

/// Provider for active tagging rules, cached in memory upon app startup.
final taggingRulesProvider =
    AsyncNotifierProvider<TaggingRulesNotifier, List<TaggingRule>>(() {
  return TaggingRulesNotifier();
});
