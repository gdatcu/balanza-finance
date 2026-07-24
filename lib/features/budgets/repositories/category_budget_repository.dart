import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/category_budget.dart';

final categoryBudgetRepositoryProvider = Provider<CategoryBudgetRepository>((ref) {
  return CategoryBudgetRepository(Supabase.instance.client);
});

final categoryBudgetsStreamProvider = StreamProvider<List<CategoryBudget>>((ref) {
  final repo = ref.watch(categoryBudgetRepositoryProvider);
  return repo.getCategoryBudgetsStream();
});

class CategoryBudgetRepository {
  final SupabaseClient _client;

  CategoryBudgetRepository(this._client);

  Stream<List<CategoryBudget>> getCategoryBudgetsStream() {
    final user = _client.auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _client
        .from('category_budgets')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .map((data) => data.map((json) => CategoryBudget.fromJson(json)).toList());
  }

  Future<void> upsertCategoryBudget(String category, double amountLimit) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('category_budgets').upsert(
      {
        'user_id': user.id,
        'category': category,
        'amount_limit': amountLimit,
      },
      onConflict: 'user_id,category',
    );
  }

  Future<void> deleteCategoryBudget(String id) async {
    await _client.from('category_budgets').delete().eq('id', id);
  }
}
