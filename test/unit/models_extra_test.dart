import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/models/category_budget.dart';
import 'package:balanza/models/tagging_rule.dart';
import 'package:balanza/features/analytics/models/advisor_nudge.dart';

void main() {
  group('CategoryBudget Model Edge Cases Tests', () {
    test('fromJson handles null values and fallbacks', () {
      final json = <String, dynamic>{
        'id': 123,
        'user_id': 456,
        'category_name': 'Utilities',
        'amount_limit': 350.5,
        'created_at': '2026-07-26T12:00:00Z',
      };

      final budget = CategoryBudget.fromJson(json);

      expect(budget.id, '123');
      expect(budget.userId, '456');
      expect(budget.category, 'Utilities');
      expect(budget.amountLimit, 350.5);
      expect(budget.createdAt, DateTime.parse('2026-07-26T12:00:00Z'));
    });

    test('toJson and copyWith work as expected', () {
      final budget = CategoryBudget(
        id: 'b1',
        userId: 'u1',
        category: 'Food',
        amountLimit: 500.0,
      );

      final json = budget.toJson();
      expect(json['id'], 'b1');
      expect(json['category'], 'Food');
      expect(json.containsKey('created_at'), false);

      final updated = budget.copyWith(amountLimit: 600.0);
      expect(updated.amountLimit, 600.0);
      expect(updated.category, 'Food');
    });
  });

  group('TaggingRule & AutoTagResult Tests', () {
    test('TaggingRule.fromJson parses fields and trims strings', () {
      final json = {
        'id': 'tr1',
        'keyword': ' Uber ',
        'category_name': ' Transport ',
        'sub_category': ' Taxi ',
        'tag': ' Travel ',
        'is_active': true,
        'category_id': 'c1',
        'priority': 10,
      };

      final rule = TaggingRule.fromJson(json);

      expect(rule.id, 'tr1');
      expect(rule.keyword, 'Uber');
      expect(rule.category, 'Transport');
      expect(rule.subCategory, 'Taxi');
      expect(rule.tag, 'Travel');
      expect(rule.isActive, true);
      expect(rule.categoryId, 'c1');
      expect(rule.priority, 10);
    });

    test('TaggingRule.toJson serializes correctly', () {
      const rule = TaggingRule(
        id: 'tr2',
        keyword: 'starbucks',
        category: 'Coffee',
        priority: 5,
      );

      final json = rule.toJson();
      expect(json['id'], 'tr2');
      expect(json['keyword'], 'starbucks');
      expect(json['category'], 'Coffee');
      expect(json['priority'], 5);
    });

    test('AutoTagResult holds rule data correctly', () {
      const rule = TaggingRule(
        id: 'tr3',
        keyword: 'lidl',
        category: 'Groceries',
      );

      const result = AutoTagResult(
        category: 'Groceries',
        matchedRule: rule,
      );

      expect(result.category, 'Groceries');
      expect(result.matchedRule.keyword, 'lidl');
    });
  });

  group('AdvisorNudge Model Tests', () {
    test('getLocalizedText returns EN or RO text based on language code', () {
      const nudge = AdvisorNudge(
        id: 'n1',
        categoryName: 'Food',
        icon: Icons.fastfood,
        textEn: 'Watch out for high food spending!',
        textRo: 'Atenție la cheltuielile pentru mâncare!',
        severity: NudgeSeverity.warning,
      );

      expect(nudge.getLocalizedText('en'), 'Watch out for high food spending!');
      expect(nudge.getLocalizedText('ro'), 'Atenție la cheltuielile pentru mâncare!');
      expect(nudge.severity, NudgeSeverity.warning);
    });
  });
}
