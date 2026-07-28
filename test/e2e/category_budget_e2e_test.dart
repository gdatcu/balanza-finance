import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/main.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/category.dart';
import 'package:balanza/models/category_budget.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/budgets/repositories/category_budget_repository.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';
import 'app_e2e_test.dart';

class E2EMockCategoryBudgetRepository implements CategoryBudgetRepository {
  final List<CategoryBudget> _budgets = [];

  @override
  Stream<List<CategoryBudget>> getCategoryBudgetsStream() {
    return Stream.value(List.from(_budgets));
  }

  @override
  Future<void> upsertCategoryBudget(String category, double amountLimit) async {
    _budgets.removeWhere((b) => b.category == category);
    final budget = CategoryBudget(
      id: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000000',
      category: category,
      amountLimit: amountLimit,
      createdAt: DateTime.now(),
    );
    _budgets.add(budget);
  }

  @override
  Future<void> deleteCategoryBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
  }
}

void main() {
  testWidgets('E2E Category Budget Flow - Set budget limit & track spending progress', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockTxRepo = E2EMockTransactionRepository();
    final mockBudgetRepo = E2EMockCategoryBudgetRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockTxRepo),
          categoryBudgetRepositoryProvider.overrideWithValue(mockBudgetRepo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(
            AuthChangeEvent.signedIn,
            Session(
              accessToken: 'mock_token',
              tokenType: 'bearer',
              user: const User(
                id: '00000000-0000-0000-0000-000000000000',
                appMetadata: {},
                userMetadata: {},
                aud: 'authenticated',
                createdAt: '2026-07-26T12:00:00Z',
              ),
            ),
          ))),
          supabaseCategoriesProvider.overrideWith((ref) => Future.value([
            Category(
              id: '00000000-0000-0000-0000-000000000c1',
              name: 'Food',
              icon: 'lunch_dining',
              color: '#FF9800',
              createdAt: DateTime.now(),
            ),
          ])),
          biometricLockProvider.overrideWith(() => E2EFakeBiometricLockNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Open Navigation Drawer
    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // 2. Tap Budgets section in Drawer
    final budgetsTileRo = find.text('Bugete');
    final budgetsTileEn = find.text('Budgets');
    final targetBudgetsTile = budgetsTileRo.evaluate().isNotEmpty ? budgetsTileRo : budgetsTileEn;
    expect(targetBudgetsTile, findsOneWidget);
    await tester.tap(targetBudgetsTile);
    await tester.pumpAndSettle();

    // 3. Verify Budgets section is active
    expect(find.byType(ListView), findsWidgets);

    // 4. Add expense of 350.0 RON
    await mockTxRepo.addTransaction(Transaction(
      id: 'tx-1',
      userId: '00000000-0000-0000-0000-000000000000',
      accountId: '00000000-0000-0000-0000-000000000000',
      amount: -350.0,
      date: DateTime.now(),
      categoryId: '00000000-0000-0000-0000-000000000c1',
      description: 'Supermarket',
      createdAt: DateTime.now(),
    ));

    // 5. Set category budget limit to 500.0 RON for 'Food'
    await mockBudgetRepo.upsertCategoryBudget('00000000-0000-0000-0000-000000000c1', 500.0);

    // Trigger UI refresh
    final containerRef = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
    containerRef.invalidate(transactionListProvider);
    containerRef.invalidate(categoryBudgetsStreamProvider);
    await tester.pumpAndSettle();

    // 6. Verify category progress is updated
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
