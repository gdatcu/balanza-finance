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
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(300.0)),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
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

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.severity, equals(NudgeSeverity.alert));
      expect(nudge.textEn, contains('Budget Alert'));
      expect(nudge.textRo, contains('Alertă de Buget'));
    });

    test('Warning zone threshold trigger (80% - 99%)', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(300.0)),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
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

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.severity, equals(NudgeSeverity.warning));
      expect(nudge.textEn, contains('Notice: You have used 90%'));
      expect(nudge.textRo, contains('Atenție: Ai consumat 90%'));
    });

    test('Behavioral Nudge: Transport Taxi / Rideshare trigger', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(1000.0)),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
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

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.textEn, contains('Taking a taxi is convenient'));
      expect(nudge.textRo, contains('Să iei un taxi este comod'));
    });

    test('Behavioral Nudge: Food Delivery trigger', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(1000.0)),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
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

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.textEn, contains('Dining out is a nice reward'));
      expect(nudge.textRo, contains('Să mănănci în oraș'));
    });

    test('Behavioral Nudge: coffee_tea high frequency trigger (>15 tx)', () async {
      final transactions = List.generate(
        16,
        (index) => Transaction(
          id: 'tx-coffee-$index',
          userId: 'user-1',
          accountId: 'acc-1',
          categoryId: '00000000-0000-0000-0000-000000000c10', // coffee_tea
          amount: -12.0,
          description: 'Espresso #$index',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(10000.0)),
          transactionListProvider.overrideWith((ref) => Stream.value(transactions)),
        ],
      );

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.id, equals('nudge_coffee_tea_frequency'));
      expect(nudge.textEn, contains('Latte Factor'));
      expect(nudge.textRo, contains('Factorul Latte'));
    });

    test('Behavioral Nudge: restaurants spending ratio trigger (>15%)', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(10000.0)),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
              Transaction(
                id: 'tx-rest-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-000000000c11', // restaurants
                amount: -250.0, // 250 out of 1000 total spending = 25% (> 15%)
                description: 'Fancy Steakhouse',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
              Transaction(
                id: 'tx-other-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-0000000000c3', // Rent
                amount: -750.0,
                description: 'Monthly rent',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.id, equals('nudge_restaurants_ratio'));
      expect(nudge.textEn, contains('15% of your total spending'));
      expect(nudge.textRo, contains('15% din cheltuielile tale'));
    });

    test('Behavioral Nudge: subscriptions item count trigger (>5 items)', () async {
      final transactions = List.generate(
        6,
        (index) => Transaction(
          id: 'tx-sub-$index',
          userId: 'user-1',
          accountId: 'acc-1',
          categoryId: '00000000-0000-0000-0000-000000000c13', // subscriptions
          amount: -20.0,
          description: 'Subscription #$index',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(10000.0)),
          transactionListProvider.overrideWith((ref) => Stream.value(transactions)),
        ],
      );

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.id, equals('nudge_subscriptions_pruning'));
      expect(nudge.textEn, contains('5 recurring subscription charges'));
      expect(nudge.textRo, contains('5 taxe de abonament'));
    });

    test('Behavioral Nudge: uncategorized / other spending trigger (>20%)', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(10000.0)),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
              Transaction(
                id: 'tx-other-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-000000000c14', // other
                amount: -300.0, // 300 out of 1000 = 30% (> 20%)
                description: 'Misc expense',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
              Transaction(
                id: 'tx-rent-1',
                userId: 'user-1',
                accountId: 'acc-1',
                categoryId: '00000000-0000-0000-0000-0000000000c3', // Rent
                amount: -700.0,
                description: 'Monthly rent',
                date: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      final nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);
      expect(nudge!.id, equals('nudge_other_uncategorized'));
      expect(nudge.textEn, contains('20% of your total spending'));
      expect(nudge.textRo, contains('20% din cheltuielile tale'));
    });

    test('Dismissing a nudge hides it from provider', () async {
      final container = ProviderContainer(
        overrides: [
          monthlyBudgetProvider.overrideWith((ref) => Stream.value(1000.0)),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
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

      container.listen(transactionListProvider, (prev, next) {});
      container.listen(monthlyBudgetProvider, (prev, next) {});
      await pumpEventQueue();

      var nudge = container.read(wealthAdvisorProvider);
      expect(nudge, isNotNull);

      container.read(dismissedNudgesProvider.notifier).dismiss(nudge!.id);

      var updatedNudge = container.read(wealthAdvisorProvider);
      expect(updatedNudge?.id, isNot(equals(nudge.id)));
    });
  });
}
