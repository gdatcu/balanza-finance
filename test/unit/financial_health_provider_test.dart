import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/net_worth_item.dart';
import 'package:balanza/features/analytics/providers/financial_health_provider.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/net_worth/providers/net_worth_provider.dart';

class FakeNetWorthNotifier extends NetWorthListNotifier {
  final List<NetWorthItem> _items;
  FakeNetWorthNotifier(this._items);

  @override
  Future<List<NetWorthItem>> build() async => _items;
}

void main() {
  group('FinancialHealthProvider Unit Tests', () {
    test('Calculates score and recommendations for healthy financial profile', () async {
      final now = DateTime.now();
      final container = ProviderContainer(
        overrides: [
          transactionListProvider.overrideWithValue(AsyncData([
            Transaction(
              id: 'tx_salary',
              userId: 'u1',
              accountId: 'a1',
              amount: 10000.0,
              date: now,
              createdAt: now,
            ),
            Transaction(
              id: 'tx_rent',
              userId: 'u1',
              accountId: 'a1',
              amount: -2500.0,
              date: now,
              createdAt: now,
            ),
          ])),
          netWorthListProvider.overrideWith(() => FakeNetWorthNotifier([
            NetWorthItem(
              id: 'nw_savings',
              userId: 'u1',
              name: 'Emergency Fund',
              balance: 30000.0,
              type: NetWorthType.asset,
              createdAt: now,
            ),
          ])),
        ],
      );

      await container.read(netWorthListProvider.future);
      final health = container.read(financialHealthProvider);
      expect(health.overallScore, greaterThanOrEqualTo(70));
      expect(health.level, anyOf('Good', 'Excellent'));
      expect(health.savingsRate, greaterThan(50));
      expect(health.emergencyMonths, greaterThanOrEqualTo(6));
    });
  });
}
