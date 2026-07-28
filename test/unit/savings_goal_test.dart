import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/models/savings_goal.dart';
import 'package:balanza/features/savings_goals/repositories/savings_goal_repository.dart';

class MockSupabaseClientForSavings extends Fake implements SupabaseClient {
  @override
  final auth = MockGoTrueClientForSavings();
}

class MockGoTrueClientForSavings extends Fake implements GoTrueClient {
  @override
  User? get currentUser => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SavingsGoal Model Unit Tests', () {
    test('SavingsGoal progress calculations work correctly', () {
      final goal = SavingsGoal(
        id: 'goal-1',
        userId: 'u1',
        title: 'Emergency Fund',
        targetAmount: 10000.0,
        currentAmount: 2500.0,
        createdAt: DateTime.now(),
      );

      expect(goal.progressPercentage, equals(25.0));
      expect(goal.remainingAmount, equals(7500.0));
      expect(goal.isCompleted, isFalse);

      final completedGoal = goal.copyWith(currentAmount: 10000.0);
      expect(completedGoal.progressPercentage, equals(100.0));
      expect(completedGoal.remainingAmount, equals(0.0));
      expect(completedGoal.isCompleted, isTrue);
    });

    test('SavingsGoal serialization & deserialization works', () {
      final now = DateTime.now();
      final goal = SavingsGoal(
        id: 'goal-2',
        userId: 'u2',
        title: 'Vacation',
        targetAmount: 5000.0,
        currentAmount: 1500.0,
        color: '#FF7A5A',
        createdAt: now,
      );

      final json = goal.toJson();
      expect(json['title'], equals('Vacation'));
      expect(json['target_amount'], equals(5000.0));
      expect(json['current_amount'], equals(1500.0));

      final parsed = SavingsGoal.fromJson(json);
      expect(parsed.id, equals('goal-2'));
      expect(parsed.title, equals('Vacation'));
      expect(parsed.targetAmount, equals(5000.0));
      expect(parsed.currentAmount, equals(1500.0));
      expect(parsed.color, equals('#FF7A5A'));
    });
  });

  group('SavingsGoalRepository Offline Fallback Integration Tests', () {
    late SharedPreferences prefs;
    late SavingsGoalRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      repository = SavingsGoalRepository(MockSupabaseClientForSavings(), prefs);
    });

    test('addSavingsGoal & getSavingsGoals persist offline data', () async {
      final now = DateTime.now();
      final newGoal = SavingsGoal(
        id: 'sg-add-1',
        userId: 'user-1',
        title: 'New Laptop',
        targetAmount: 8000.0,
        currentAmount: 2000.0,
        createdAt: now,
      );

      await repository.addSavingsGoal(newGoal);

      final goals = await repository.getSavingsGoals();
      expect(goals.any((g) => g.id == 'sg-add-1'), isTrue);
    });

    test('updateSavingsGoal updates goal balance offline', () async {
      final now = DateTime.now();
      final goal = SavingsGoal(
        id: 'sg-upd-1',
        userId: 'user-1',
        title: 'Car Fund',
        targetAmount: 15000.0,
        currentAmount: 5000.0,
        createdAt: now,
      );

      await repository.addSavingsGoal(goal);
      final updated = goal.copyWith(currentAmount: 7500.0);
      await repository.updateSavingsGoal(updated);

      final goals = await repository.getSavingsGoals();
      final found = goals.firstWhere((g) => g.id == 'sg-upd-1');
      expect(found.currentAmount, equals(7500.0));
    });

    test('deleteSavingsGoal removes goal offline', () async {
      final now = DateTime.now();
      final goal = SavingsGoal(
        id: 'sg-del-1',
        userId: 'user-1',
        title: 'Temp Goal',
        targetAmount: 1000.0,
        createdAt: now,
      );

      await repository.addSavingsGoal(goal);
      final before = await repository.getSavingsGoals();
      expect(before.any((g) => g.id == 'sg-del-1'), isTrue);

      await repository.deleteSavingsGoal('sg-del-1');
      final after = await repository.getSavingsGoals();
      expect(after.any((g) => g.id == 'sg-del-1'), isFalse);
    });
  });
}
