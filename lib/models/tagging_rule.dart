class TaggingRule {
  final String id;
  final String keyword;
  final String category;
  final String? subCategory;
  final String? tag;
  final bool isActive;
  final String? categoryId;

  const TaggingRule({
    required this.id,
    required this.keyword,
    required this.category,
    this.subCategory,
    this.tag,
    this.isActive = true,
    this.categoryId,
  });

  factory TaggingRule.fromJson(Map<String, dynamic> json) {
    return TaggingRule(
      id: json['id']?.toString() ?? '',
      keyword: json['keyword'] as String? ?? '',
      category: json['category'] as String? ?? json['category_name'] as String? ?? '',
      subCategory: json['sub_category'] as String? ?? json['subcategory'] as String?,
      tag: json['tag'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      categoryId: json['category_id'] as String?,
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
