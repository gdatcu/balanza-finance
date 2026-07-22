import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/tagging_rule.dart';

/// AsyncNotifier to fetch and cache remote tagging rules from Supabase.
class TaggingRulesNotifier extends AsyncNotifier<List<TaggingRule>> {
  static const List<TaggingRule> defaultFallbackRules = [
    TaggingRule(id: 'default-1', keyword: 'uber eats', category: 'Food', tag: 'delivery'),
    TaggingRule(id: 'default-2', keyword: 'uber', category: 'Transport', tag: 'ride'),
    TaggingRule(id: 'default-3', keyword: 'bolt', category: 'Transport', tag: 'ride'),
    TaggingRule(id: 'default-4', keyword: 'starbucks', category: 'Food', tag: 'coffee'),
    TaggingRule(id: 'default-5', keyword: 'lidl', category: 'Food', tag: 'groceries'),
    TaggingRule(id: 'default-6', keyword: 'kaufland', category: 'Food', tag: 'groceries'),
    TaggingRule(id: 'default-7', keyword: 'mega image', category: 'Food', tag: 'groceries'),
    TaggingRule(id: 'default-8', keyword: 'netflix', category: 'Entertainment', tag: 'subscription'),
    TaggingRule(id: 'default-9', keyword: 'digi', category: 'Utilities', tag: 'internet'),
    TaggingRule(id: 'default-10', keyword: 'enel', category: 'Utilities', tag: 'electricity'),
    TaggingRule(id: 'default-11', keyword: 'salariu', category: 'Salary', tag: 'income'),
  ];

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

      if (rules.isEmpty) {
        return defaultFallbackRules;
      }

      return rules;
    } catch (_) {
      // Return default fallback rules if table does not exist or network fails
      return defaultFallbackRules;
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
