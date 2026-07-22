import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/analytics/models/advisor_nudge.dart';
import 'package:balanza/features/analytics/providers/wealth_advisor_provider.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';

void main() {
  group('Phase 21: Universal Wealth Advisor Behavioral Nudges Tests', () {
    test('Over-budget alert threshold trigger (>= 100%)', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith(() => _MockBudgetNotifier(300.0)),
          transactionListProvider.overrideWith(
            () => _MockTransactionNotifier([
              Transaction(
                id: 'tx-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-0000000000c1', // Food
                amount: -350.0,
                description: 'Supermarket purchase',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      await container.read(transactionListProvider.future);

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.severity, equals(NudgeSeverity.alert));
      expect(nudge.textEn, contains('Budget Alert'));
      expect(nudge.textRo, contains('Alertă de Buget'));
    });

    test('Warning zone threshold trigger (80% - 99%)', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith(() => _MockBudgetNotifier(300.0)),
          transactionListProvider.overrideWith(
            () => _MockTransactionNotifier([
              Transaction(
                id: 'tx-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-0000000000c1', // Food
                amount: -90.0, // 90 RON spent out of 100 RON category budget (90%)
                description: 'Grocery shopping',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      await container.read(transactionListProvider.future);

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.severity, equals(NudgeSeverity.warning));
      expect(nudge.textEn, contains('Notice: You have used 90%'));
      expect(nudge.textRo, contains('Atenție: Ai consumat 90%'));
    });

    test('Behavioral Nudge: Transport Taxi / Rideshare trigger', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith(() => _MockBudgetNotifier(1000.0)),
          transactionListProvider.overrideWith(
            () => _MockTransactionNotifier([
              Transaction(
                id: 'tx-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-0000000000c2', // Transport
                amount: -45.0,
                description: 'Uber ride home',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      await container.read(transactionListProvider.future);

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.textEn, contains('Taking a taxi is convenient'));
      expect(nudge.textRo, contains('Să iei un taxi este comod'));
    });

    test('Behavioral Nudge: Food Delivery trigger', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith(() => _MockBudgetNotifier(1000.0)),
          transactionListProvider.overrideWith(
            () => _MockTransactionNotifier([
              Transaction(
                id: 'tx-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-0000000000c1', // Food
                amount: -60.0,
                description: 'Uber Eats dinner',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      await container.read(transactionListProvider.future);

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.textEn, contains('Dining out is a nice reward'));
      expect(nudge.textRo, contains('Să mănânci în oraș e o răsplată plăcută'));
    });

    test('Dismissing a nudge hides it from provider', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith(() => _MockBudgetNotifier(1000.0)),
          transactionListProvider.overrideWith(
            () => _MockTransactionNotifier([
              Transaction(
                id: 'tx-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-0000000000c1',
                amount: -60.0,
                description: 'Uber Eats dinner',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      await container.read(transactionListProvider.future);

      var nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);

      container.read(dismissedNudgesProvider.notifier).dismiss(nudge!.id);

      var updatedNudge = container.read(wealthAdvisorProvider);
      expect(updatedNudge?.id, isNot(equals(nudge.id)));
    });
  });
}

class _MockTransactionNotifier extends TransactionListNotifier {
  final List<Transaction> _mockTransactions;
  _MockTransactionNotifier(this._mockTransactions);

  @override
  Future<List<Transaction>> build() async => _mockTransactions;
}

class _MockBudgetNotifier extends MonthlyBudgetNotifier {
  final double _initialBudget;
  _MockBudgetNotifier(this._initialBudget);

  @override
  double build() => _initialBudget;
}
