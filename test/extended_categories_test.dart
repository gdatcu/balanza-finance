import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/category_budget.dart';
import 'package:balanza/features/transactions/presentation/categories_data.dart';
import 'package:balanza/features/budgets/providers/smart_budget_provider.dart';
import 'package:balanza/features/budgets/repositories/category_budget_repository.dart';
import 'package:balanza/features/analytics/providers/wealth_advisor_provider.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';

void main() {
  group('Extended Categories Data Tests', () {
    test('defaultCategories contains all 8 new lifestyle categories', () {
      final categoryNames = defaultCategories.map((c) => c.name).toList();
      expect(categoryNames, contains('clothing'));
      expect(categoryNames, contains('healthcare'));
      expect(categoryNames, contains('gadgets'));
      expect(categoryNames, contains('travel'));
      expect(categoryNames, contains('entertainment'));
      expect(categoryNames, contains('transport'));
      expect(categoryNames, contains('personal_care'));
      expect(categoryNames, contains('education'));
    });

    test('getCategoryIcon returns correct icons for new categories', () {
      expect(getCategoryIcon('checkroom'), isNotNull);
      expect(getCategoryIcon('medical_services'), isNotNull);
      expect(getCategoryIcon('devices'), isNotNull);
      expect(getCategoryIcon('flight_takeoff'), isNotNull);
      expect(getCategoryIcon('spa'), isNotNull);
      expect(getCategoryIcon('school'), isNotNull);
    });
  });

  group('SmartBudgetProvider Tests', () {
    test('Calculates suggested limits based on target percentages', () {
      final container = ProviderContainer(
        overrides: [
          transactionListProvider.overrideWithValue(AsyncData([
            Transaction(
              id: 'tx_salary',
              userId: 'u1',
              accountId: 'a1',
              categoryId: '00000000-0000-0000-0000-0000000000c5', // Salary
              amount: 10000.0,
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ])),
        ],
      );

      final suggestions = container.read(smartBudgetSuggestionsProvider);
      expect(suggestions['groceries'], 2500.0); // 25% of 10000
      expect(suggestions['transport'], 1000.0); // 10% of 10000
      expect(suggestions['clothing'], 500.0); // 5% of 10000
      expect(suggestions['entertainment'], 500.0); // 5% of 10000
      expect(suggestions['education'], 500.0); // 5% of 10000
      expect(suggestions['travel'], 500.0); // 5% of 10000
    });
  });

  group('Extended Wealth Advisor Behavioral Rules Tests', () {
    // Use a very high monthlyBudget so that the fallback category limit
    // (monthlyBudget / 3) is higher than any test expense, preventing
    // threshold_alert nudges from outranking the behavioral nudges.
    test('Time Check Nudge: Triggers when single clothing/gadget purchase > 8 hours labor', () {
      // 8000 RON monthly income -> 50 RON/hr -> 8 hours = 400 RON threshold
      // Set monthlyBudget to 100000 so fallback limit = 33333, avoiding threshold alerts
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWithValue(const AsyncData(100000.0)),
          categoryBudgetsStreamProvider.overrideWithValue(const AsyncData(<CategoryBudget>[])),
          transactionListProvider.overrideWithValue(AsyncData([
            Transaction(
              id: 'tx_salary',
              userId: 'u1',
              accountId: 'a1',
              categoryId: '00000000-0000-0000-0000-0000000000c5',
              amount: 8000.0,
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
            Transaction(
              id: 'tx_gadget',
              userId: 'u1',
              accountId: 'a1',
              categoryId: '00000000-0000-0000-0000-000000000c21', // Gadgets
              amount: -1200.0, // 24 hours of labor
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ])),
        ],
      );

      final advisorState = container.read(wealthAdvisorProvider);
      expect(advisorState, isNotNull);
      expect(advisorState!.id, 'nudge_time_cost');
      expect(advisorState.getLocalizedTitle('en'), contains('TIME CHECK'));
    });

    test('Positive Reinforcement Nudge: Triggers when education transaction logged', () {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWithValue(const AsyncData(100000.0)),
          categoryBudgetsStreamProvider.overrideWithValue(const AsyncData(<CategoryBudget>[])),
          transactionListProvider.overrideWithValue(AsyncData([
            Transaction(
              id: 'tx_course',
              userId: 'u1',
              accountId: 'a1',
              categoryId: '00000000-0000-0000-0000-000000000c26', // Education
              amount: -250.0,
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ])),
        ],
      );

      final advisorState = container.read(wealthAdvisorProvider);
      expect(advisorState, isNotNull);
      expect(advisorState!.id, 'nudge_education_self_investment');
      expect(advisorState.getLocalizedTitle('en'), contains('SELF-INVESTMENT'));
    });

    test('Sinking Fund Nudge: Triggers when travel expense > 10% of monthly income', () {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWithValue(const AsyncData(100000.0)),
          categoryBudgetsStreamProvider.overrideWithValue(const AsyncData(<CategoryBudget>[])),
          transactionListProvider.overrideWithValue(AsyncData([
            Transaction(
              id: 'tx_salary',
              userId: 'u1',
              accountId: 'a1',
              categoryId: '00000000-0000-0000-0000-0000000000c5',
              amount: 5000.0,
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
            Transaction(
              id: 'tx_flight',
              userId: 'u1',
              accountId: 'a1',
              categoryId: '00000000-0000-0000-0000-000000000c22', // Travel
              amount: -1500.0, // 30% of income (>10% threshold)
              date: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ])),
        ],
      );

      final advisorState = container.read(wealthAdvisorProvider);
      expect(advisorState, isNotNull);
      expect(advisorState!.id, 'nudge_travel_sinking_fund');
      expect(advisorState.getLocalizedTitle('en'), contains('TRAVEL SINKING FUND'));
    });
  });
}
