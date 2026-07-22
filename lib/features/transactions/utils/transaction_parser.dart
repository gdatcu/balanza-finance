import '../../../models/tagging_rule.dart';

/// Utility class to parse transaction input text against cached remote tagging rules.
class TransactionParser {
  /// Evaluates [inputText] against active [rules].
  /// Converts input to lowercase and matches against rule keywords.
  /// Prioritizes the longest matching keyword rule.
  /// Returns [AutoTagResult] if a match is found, or null if no rule matches.
  static AutoTagResult? parseText(String inputText, List<TaggingRule> rules) {
    final cleanInput = inputText.trim().toLowerCase();
    if (cleanInput.isEmpty || rules.isEmpty) return null;

    // Filter active rules and sort by keyword length descending (longest keyword wins)
    final sortedRules = rules
        .where((rule) => rule.isActive && rule.keyword.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.keyword.length.compareTo(a.keyword.length));

    for (final rule in sortedRules) {
      if (cleanInput.contains(rule.keyword.toLowerCase())) {
        return AutoTagResult(
          category: rule.category,
          categoryId: rule.categoryId,
          subCategory: rule.subCategory,
          tag: rule.tag,
          matchedRule: rule,
        );
      }
    }

    return null;
  }
}
