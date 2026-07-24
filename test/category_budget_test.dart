import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/models/category_budget.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/budgets/providers/category_budget_progress_provider.dart';
import 'package:balanza/features/budgets/repositories/category_budget_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';

void main() {
  group('CategoryBudget Model Tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'b1',
        'user_id': 'u1',
        'category': 'groceries',
        'amount_limit': 500.0,
        'created_at': '2026-07-24T10:00:00Z',
      };

      final budget = CategoryBudget.fromJson(json);
      expect(budget.id, 'b1');
      expect(budget.userId, 'u1');
      expect(budget.category, 'groceries');
      expect(budget.amountLimit, 500.0);
    });

    test('toJson returns correct map', () {
      const budget = CategoryBudget(
        id: 'b1',
        userId: 'u1',
        category: 'groceries',
        amountLimit: 500.0,
      );

      final map = budget.toJson();
      expect(map['id'], 'b1');
      expect(map['user_id'], 'u1');
      expect(map['category'], 'groceries');
      expect(map['amount_limit'], 500.0);
    });
  });

  group('CategoryBudgetProgressProvider Tests', () {
    test('Calculates current spent and percentage used correctly', () {
      final container = ProviderContainer(
        overrides: [
          transactionListProvider.overrideWithValue(AsyncData([
            Transaction(
              id: 't1',
              userId: 'u1',
              accountId: 'a1',
              categoryId: 'groceries',
              amount: -350.0,
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ])),
          categoryBudgetsStreamProvider.overrideWithValue(const AsyncData([
            CategoryBudget(
              id: 'b1',
              userId: 'u1',
              category: 'groceries',
              amountLimit: 500.0,
            ),
          ])),
        ],
      );

      final progress = container.read(categoryBudgetProgressProvider);
      expect(progress.length, 1);
      expect(progress.first.category.name, 'groceries');
      expect(progress.first.currentSpent, 350.0);
      expect(progress.first.amountLimit, 500.0);
      expect(progress.first.percentageUsed, 70.0);
      expect(progress.first.isSafe, true);
      expect(progress.first.isWarning, false);
      expect(progress.first.isOverBudget, false);
    });
  });
}
