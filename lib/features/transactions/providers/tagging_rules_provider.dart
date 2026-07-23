import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/tagging_rule.dart';

/// AsyncNotifier to fetch and cache remote tagging rules from Supabase.
class TaggingRulesNotifier extends AsyncNotifier<List<TaggingRule>> {
  static const List<TaggingRule> defaultFallbackRules = [
    TaggingRule(id: 'default-1', keyword: 'uber eats', category: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11', tag: 'delivery'),
    TaggingRule(id: 'default-2', keyword: 'uber', category: 'Transport', tag: 'ride'),
    TaggingRule(id: 'default-3', keyword: 'bolt', category: 'Transport', tag: 'ride'),
    TaggingRule(id: 'default-4', keyword: 'starbucks', category: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10', tag: 'coffee'),
    TaggingRule(id: 'default-5', keyword: '5togo', category: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10', tag: 'coffee'),
    TaggingRule(id: 'default-6', keyword: 'lidl', category: 'Food', tag: 'groceries'),
    TaggingRule(id: 'default-7', keyword: 'kaufland', category: 'Food', tag: 'groceries'),
    TaggingRule(id: 'default-8', keyword: 'mega image', category: 'Food', tag: 'groceries'),
    TaggingRule(id: 'default-9', keyword: 'netflix', category: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13', tag: 'subscription'),
    TaggingRule(id: 'default-10', keyword: 'spotify', category: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13', tag: 'subscription'),
    TaggingRule(id: 'default-11', keyword: 'animax', category: 'pet_care', categoryId: '00000000-0000-0000-0000-000000000c12', tag: 'pet'),
    TaggingRule(id: 'default-12', keyword: 'zooplus', category: 'pet_care', categoryId: '00000000-0000-0000-0000-000000000c12', tag: 'pet'),
    TaggingRule(id: 'default-13', keyword: 'trattoria', category: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11', tag: 'dining'),
    TaggingRule(id: 'default-14', keyword: 'digi', category: 'Utilities', tag: 'internet'),
    TaggingRule(id: 'default-15', keyword: 'enel', category: 'Utilities', tag: 'electricity'),
    TaggingRule(id: 'default-16', keyword: 'salariu', category: 'Salary', tag: 'income'),
    TaggingRule(id: 'default-17', keyword: 'altele', category: 'other', categoryId: '00000000-0000-0000-0000-000000000c14', tag: 'other'),
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
