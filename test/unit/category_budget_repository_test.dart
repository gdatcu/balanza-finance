import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/features/budgets/repositories/category_budget_repository.dart';
import 'package:balanza/models/category_budget.dart';

class MockFullBudgetRepo implements CategoryBudgetRepository {
  final List<CategoryBudget> _list = [];

  @override
  Stream<List<CategoryBudget>> getCategoryBudgetsStream() {
    return Stream.value(List.from(_list));
  }

  @override
  Future<void> upsertCategoryBudget(String category, double amountLimit) async {
    _list.removeWhere((b) => b.category == category);
    _list.add(CategoryBudget(
      id: 'b-${_list.length + 1}',
      userId: 'u1',
      category: category,
      amountLimit: amountLimit,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> deleteCategoryBudget(String id) async {
    _list.removeWhere((b) => b.id == id);
  }
}

void main() {
  group('CategoryBudgetRepository Logic Tests', () {
    late MockFullBudgetRepo repo;

    setUp(() {
      repo = MockFullBudgetRepo();
    });

    test('upsertCategoryBudget adds or updates budget', () async {
      await repo.upsertCategoryBudget('Food', 500.0);
      var items = await repo.getCategoryBudgetsStream().first;
      expect(items.length, 1);
      expect(items.first.category, 'Food');
      expect(items.first.amountLimit, 500.0);

      await repo.upsertCategoryBudget('Food', 650.0);
      items = await repo.getCategoryBudgetsStream().first;
      expect(items.length, 1);
      expect(items.first.amountLimit, 650.0);
    });

    test('deleteCategoryBudget removes budget by id', () async {
      await repo.upsertCategoryBudget('Utilities', 300.0);
      var items = await repo.getCategoryBudgetsStream().first;
      expect(items.length, 1);

      await repo.deleteCategoryBudget(items.first.id);
      items = await repo.getCategoryBudgetsStream().first;
      expect(items, isEmpty);
    });
  });
}
