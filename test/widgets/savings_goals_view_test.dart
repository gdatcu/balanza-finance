import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/models/savings_goal.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/savings_goals/providers/savings_goal_provider.dart';
import 'package:balanza/features/savings_goals/repositories/savings_goal_repository.dart';
import 'package:balanza/features/savings_goals/presentation/savings_goals_view.dart';

class MockWidgetSavingsGoalRepository implements SavingsGoalRepository {
  final List<SavingsGoal> _list = [];

  @override
  Future<List<SavingsGoal>> getSavingsGoals() async {
    return List.from(_list);
  }

  @override
  Future<SavingsGoal> addSavingsGoal(SavingsGoal goal) async {
    _list.add(goal);
    return goal;
  }

  @override
  Future<SavingsGoal> updateSavingsGoal(SavingsGoal goal) async {
    final idx = _list.indexWhere((g) => g.id == goal.id);
    if (idx != -1) _list[idx] = goal;
    return goal;
  }

  @override
  Future<void> deleteSavingsGoal(String id) async {
    _list.removeWhere((g) => g.id == id);
  }
}

void main() {
  testWidgets('SavingsGoalsView renders header, list, and allows adding goal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockWidgetSavingsGoalRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          savingsGoalRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SavingsGoalsView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify FAB exists
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    // 2. Open Add Goal Sheet
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // 3. Fill out goal form
    final nameField = find.byType(TextFormField).first;
    final targetField = find.byType(TextFormField).at(1);
    final currentField = find.byType(TextFormField).last;

    await tester.enterText(nameField, 'Vacation Fund');
    await tester.enterText(targetField, '4000');
    await tester.enterText(currentField, '1000');

    final submitBtn = find.byType(ElevatedButton);
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // 4. Verify Goal appears on view
    expect(find.text('Vacation Fund'), findsOneWidget);
    expect(find.text('25.0%'), findsOneWidget);
  });
}
