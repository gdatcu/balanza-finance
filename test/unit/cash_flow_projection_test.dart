import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/features/cash_flow/models/recurring_bill.dart';
import 'package:balanza/features/cash_flow/providers/cash_flow_projection_provider.dart';
import 'package:balanza/features/cash_flow/providers/recurring_bills_provider.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/models/transaction.dart';

void main() {
  group('Cash Flow Projection Unit Tests', () {
    test('RecurringBill serialization & deserialization works correctly', () {
      final bill = RecurringBill(
        id: 'bill-1',
        title: 'Chirie',
        amount: -2000.0,
        categoryId: 'cat-rent',
        dueDay: 1,
        isIncome: false,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = bill.toJson();
      expect(json['id'], 'bill-1');
      expect(json['amount'], -2000.0);
      expect(json['due_day'], 1);

      final parsed = RecurringBill.fromJson(json);
      expect(parsed.id, bill.id);
      expect(parsed.amount, bill.amount);
      expect(parsed.dueDay, bill.dueDay);
    });

    test('CashFlowSummary calculates Safe-to-Spend and daily points correctly', () async {
      final container = ProviderContainer(
        overrides: [
          recurringBillsProvider.overrideWith(
            () => _FakeRecurringBillsNotifier([
              RecurringBill(
                id: 'b-rent',
                title: 'Rent',
                amount: -2000.0,
                categoryId: 'c-rent',
                dueDay: 1,
                isIncome: false,
                isPaidThisMonth: true, // Already paid
                createdAt: DateTime(2026, 1, 1),
              ),
              RecurringBill(
                id: 'b-util',
                title: 'Utilities',
                amount: -300.0,
                categoryId: 'c-util',
                dueDay: 25,
                isIncome: false,
                isPaidThisMonth: false, // Pending
                createdAt: DateTime(2026, 1, 1),
              ),
            ]),
          ),
          transactionListProvider.overrideWith(
            (ref) => Stream.value([
              Transaction(
                id: 'tx-1',
                userId: 'user-1',
                accountId: 'acc-1',
                amount: 5000.0,
                categoryId: 'c-salary',
                date: DateTime.now(),
                description: 'Salary',
                createdAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );

      container.listen(transactionListProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));
      final summary = container.read(cashFlowProjectionProvider);

      expect(summary.currentBalance, 5000.0);
      expect(summary.totalUnpaidBills, 300.0);
      expect(summary.safeToSpendToday, 4700.0);
      expect(summary.dailyPoints.isNotEmpty, isTrue);
    });
  });
}

class _FakeRecurringBillsNotifier extends RecurringBillsNotifier {
  final List<RecurringBill> _initial;
  _FakeRecurringBillsNotifier(this._initial);

  @override
  List<RecurringBill> build() {
    return _initial;
  }
}
