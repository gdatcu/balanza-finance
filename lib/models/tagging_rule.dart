class TaggingRule {
  final String id;
  final String keyword;
  final String category;
  final String? subCategory;
  final String? tag;
  final bool isActive;
  final String? categoryId;
  final int priority;

  const TaggingRule({
    required this.id,
    required this.keyword,
    required this.category,
    this.subCategory,
    this.tag,
    this.isActive = true,
    this.categoryId,
    this.priority = 5,
  });

  factory TaggingRule.fromJson(Map<String, dynamic> json) {
    final rawCat = json['category'] as String? ?? json['category_name'] as String? ?? '';
    final rawSub = json['sub_category'] as String? ?? json['subcategory'] as String?;
    final rawTag = json['tag'] as String?;

    return TaggingRule(
      id: json['id']?.toString() ?? '',
      keyword: (json['keyword'] as String? ?? '').trim(),
      category: rawCat.trim(),
      subCategory: rawSub?.trim(),
      tag: rawTag?.trim(),
      isActive: json['is_active'] as bool? ?? true,
      categoryId: json['category_id'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'category': category,
      'sub_category': subCategory,
      'tag': tag,
      'is_active': isActive,
      'category_id': categoryId,
      'priority': priority,
    };
  }
}

class AutoTagResult {
  final String category;
  final String? categoryId;
  final String? subCategory;
  final String? tag;
  final TaggingRule matchedRule;

  const AutoTagResult({
    required this.category,
    this.categoryId,
    this.subCategory,
    this.tag,
    required this.matchedRule,
  });
}
