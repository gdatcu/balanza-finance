import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/models/tagging_rule.dart';
import 'package:balanza/features/transactions/utils/transaction_parser.dart';

void main() {
  group('TransactionParser Remote Auto-Tagging Engine Tests', () {
    final rules = [
      const TaggingRule(
        id: 'rule-1',
        keyword: 'uber',
        category: 'Transport',
        tag: 'ride',
      ),
      const TaggingRule(
        id: 'rule-2',
        keyword: 'uber eats',
        category: 'Food',
        tag: 'delivery',
      ),
      const TaggingRule(
        id: 'rule-3',
        keyword: 'starbucks',
        category: 'Coffee',
        tag: 'beverage',
      ),
      const TaggingRule(
        id: 'rule-4',
        keyword: 'inactive kw',
        category: 'Other',
        isActive: false,
      ),
    ];

    test('should match rule and convert input to lowercase', () {
      final result = TransactionParser.parseText('Paid at STARBUCKS today', rules);
      expect(result, isNotNull);
      expect(result!.category, equals('Coffee'));
      expect(result.tag, equals('beverage'));
      expect(result.matchedRule.id, equals('rule-3'));
    });

    test('should prioritize longest keyword match when multiple match', () {
      // 'uber eats' is longer than 'uber' (9 chars vs 4 chars)
      final result = TransactionParser.parseText('Order from Uber Eats', rules);
      expect(result, isNotNull);
      expect(result!.category, equals('Food'));
      expect(result.matchedRule.id, equals('rule-2'));
    });

    test('should fall back to shorter match if longer does not match', () {
      final result = TransactionParser.parseText('Trip with Uber', rules);
      expect(result, isNotNull);
      expect(result!.category, equals('Transport'));
      expect(result.matchedRule.id, equals('rule-1'));
    });

    test('should ignore inactive rules', () {
      final result = TransactionParser.parseText('Paid for inactive kw', rules);
      expect(result, isNull);
    });

    test('should return null when no rules match', () {
      final result = TransactionParser.parseText('Random unmapped text', rules);
      expect(result, isNull);
    });
  });
}
