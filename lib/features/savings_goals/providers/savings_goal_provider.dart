import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../models/savings_goal.dart';
import '../repositories/savings_goal_repository.dart';

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SavingsGoalRepository(null, prefs);
});

class SavingsGoalListNotifier extends AsyncNotifier<List<SavingsGoal>> {
  SavingsGoalRepository get _repository => ref.read(savingsGoalRepositoryProvider);

  @override
  Future<List<SavingsGoal>> build() async {
    ref.watch(authProvider);
    return _repository.getSavingsGoals();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addSavingsGoal(goal);
      return _repository.getSavingsGoals();
    });
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateSavingsGoal(goal);
      return _repository.getSavingsGoals();
    });
  }

  Future<void> deposit(String goalId, double amount) async {
    final currentList = state.value ?? [];
    final idx = currentList.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final goal = currentList[idx];
      final updated = goal.copyWith(currentAmount: goal.currentAmount + amount);
      await updateGoal(updated);
    }
  }

  Future<void> withdraw(String goalId, double amount) async {
    final currentList = state.value ?? [];
    final idx = currentList.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final goal = currentList[idx];
      final newAmt = (goal.currentAmount - amount).clamp(0.0, double.infinity);
      final updated = goal.copyWith(currentAmount: newAmt);
      await updateGoal(updated);
    }
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteSavingsGoal(id);
      return _repository.getSavingsGoals();
    });
  }
}

final savingsGoalListProvider =
    AsyncNotifierProvider<SavingsGoalListNotifier, List<SavingsGoal>>(() {
  return SavingsGoalListNotifier();
});
