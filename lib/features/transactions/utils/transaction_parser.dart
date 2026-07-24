import '../../../models/tagging_rule.dart';
import '../../../models/category.dart';

/// Utility class to parse transaction input text against cached remote tagging rules.
class TransactionParser {
  /// Evaluates [inputText] against active [rules].
  /// Converts input to lowercase and matches against rule keywords.
  /// Prioritizes higher priority rules first, then longest matching keyword.
  /// Returns [AutoTagResult] if a match is found, or null if no rule matches.
  static AutoTagResult? parseText(String inputText, List<TaggingRule> rules) {
    final cleanInput = inputText.trim().toLowerCase();
    if (cleanInput.isEmpty || rules.isEmpty) return null;

    // Filter active rules and sort by priority descending, then keyword length descending
    final sortedRules = rules
        .where((rule) => rule.isActive && rule.keyword.trim().isNotEmpty)
        .toList()
      ..sort((a, b) {
        final prioComp = b.priority.compareTo(a.priority);
        if (prioComp != 0) return prioComp;
        return b.keyword.length.compareTo(a.keyword.length);
      });

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

/// Helper class to resolve AutoTagResult category/subCategory strings to a concrete Category object.
class CategoryMatcher {
  static Category findMatchingCategory({
    required AutoTagResult result,
    required List<Category> categories,
  }) {
    final ruleCatId = result.categoryId;
    if (ruleCatId != null && ruleCatId.isNotEmpty) {
      final matchById = categories.firstWhere(
        (c) => c.id == ruleCatId,
        orElse: () => Category(id: '', name: '', createdAt: DateTime.now()),
      );
      if (matchById.id.isNotEmpty) return matchById;
    }

    final catStr = result.category.trim().toLowerCase();
    final subCatStr = (result.subCategory ?? '').trim().toLowerCase();
    final tagStr = (result.tag ?? '').trim().toLowerCase();

    // 1. Direct exact category name match
    for (final c in categories) {
      if (c.name.toLowerCase() == catStr) return c;
    }

    // 2. Subcategory & legacy category mapping overrides
    if (catStr == 'food' || catStr == 'mâncare') {
      if (subCatStr.contains('coffee') || tagStr.contains('coffee')) {
        return _findByName(categories, 'coffee_tea');
      }
      if (subCatStr.contains('grocer') || tagStr.contains('grocer')) {
        return _findByName(categories, 'groceries');
      }
      if (subCatStr.contains('delivery') || subCatStr.contains('fast food') || subCatStr.contains('dining') || subCatStr.contains('restaurant')) {
        return _findByName(categories, 'restaurants');
      }
      return _findByName(categories, 'food');
    }

    if (catStr == 'income') {
      if (subCatStr.contains('employment') || subCatStr.contains('salary')) {
        return _findByName(categories, 'salary');
      }
      return _findByName(categories, 'side_hustle');
    }

    if (catStr == 'health') {
      return _findByName(categories, 'other');
    }

    if (catStr == 'entertainment') {
      if (subCatStr.contains('subscription') || tagStr.contains('subscription')) {
        return _findByName(categories, 'subscriptions');
      }
      return _findByName(categories, 'entertainment');
    }

    // 3. Fallback partial matching
    for (final c in categories) {
      final nameLower = c.name.toLowerCase();
      if (nameLower.contains(catStr) || catStr.contains(nameLower)) return c;
    }

    return categories.first;
  }

  static Category _findByName(List<Category> categories, String targetName) {
    return categories.firstWhere(
      (c) => c.name.toLowerCase() == targetName,
      orElse: () => categories.first,
    );
  }
}
