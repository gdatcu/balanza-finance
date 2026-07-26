import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/features/budgets/presentation/category_budget_input_sheet.dart';
import 'package:balanza/features/budgets/repositories/category_budget_repository.dart';
import 'package:balanza/models/category_budget.dart';

class MockBudgetRepoSheet implements CategoryBudgetRepository {
  bool upserted = false;
  bool deleted = false;

  @override
  Future<void> upsertCategoryBudget(String category, double amountLimit) async {
    upserted = true;
  }

  @override
  Future<void> deleteCategoryBudget(String id) async {
    deleted = true;
  }

  @override
  Stream<List<CategoryBudget>> getCategoryBudgetsStream() => Stream.value([]);
}

void main() {
  testWidgets('CategoryBudgetInputSheet allows setting a new budget', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = MockBudgetRepoSheet();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryBudgetRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: CategoryBudgetInputSheet(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Set Category Budget'), findsOneWidget);

    final amountField = find.byType(TextFormField);
    await tester.enterText(amountField, '750');
    await tester.pump();

    final saveButton = find.text('Save Budget');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(mockRepo.upserted, true);
  });

  testWidgets('CategoryBudgetInputSheet allows editing and deleting existing budget', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = MockBudgetRepoSheet();

    const existingBudget = CategoryBudget(
      id: 'b-1',
      userId: 'u1',
      category: 'Food',
      amountLimit: 500.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryBudgetRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: CategoryBudgetInputSheet(budgetToEdit: existingBudget),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Category Budget'), findsOneWidget);

    final deleteButton = find.text('Delete').first;
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final confirmBtn = find.widgetWithText(TextButton, 'Delete').last;
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(mockRepo.deleted, true);
  });
}
