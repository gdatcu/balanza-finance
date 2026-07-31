import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurring_bill.dart';
import '../../transactions/providers/transaction_provider.dart';

const String _kRecurringBillsStorageKey = 'balanza_recurring_bills_v1';

final List<RecurringBill> defaultRecurringBills = [
  RecurringBill(
    id: 'bill-rent',
    title: 'Chirie / Rent',
    amount: -2000.0,
    categoryId: '00000000-0000-0000-0000-0000000000c3', // Rent
    dueDay: 1,
    isIncome: false,
    createdAt: DateTime(2026, 1, 1),
  ),
  RecurringBill(
    id: 'bill-salary',
    title: 'Salariu / Salary',
    amount: 8000.0,
    categoryId: '00000000-0000-0000-0000-0000000000c5', // Salary
    dueDay: 10,
    isIncome: true,
    createdAt: DateTime(2026, 1, 1),
  ),
  RecurringBill(
    id: 'bill-utilities',
    title: 'Utilități / Electricity',
    amount: -250.0,
    categoryId: '00000000-0000-0000-0000-0000000000c4', // Utilities
    dueDay: 15,
    isIncome: false,
    createdAt: DateTime(2026, 1, 1),
  ),
  RecurringBill(
    id: 'bill-netflix',
    title: 'Netflix Subscription',
    amount: -55.0,
    categoryId: '00000000-0000-0000-0000-0000000000c6', // Entertainment
    subcategoryId: '00000000-0000-0000-0000-000000000c13',
    dueDay: 20,
    isIncome: false,
    createdAt: DateTime(2026, 1, 1),
  ),
];

class RecurringBillsNotifier extends Notifier<List<RecurringBill>> {
  @override
  List<RecurringBill> build() {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final jsonStr = prefs.getString(_kRecurringBillsStorageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List list = json.decode(jsonStr);
        return list.map((item) => RecurringBill.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return defaultRecurringBills;
  }

  Future<void> _saveItems() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final jsonStr = json.encode(state.map((item) => item.toJson()).toList());
      await prefs.setString(_kRecurringBillsStorageKey, jsonStr);
    } catch (_) {}
  }

  Future<void> addBill(RecurringBill bill) async {
    state = [...state, bill];
    await _saveItems();
  }

  Future<void> updateBill(RecurringBill updatedBill) async {
    state = state.map((b) => b.id == updatedBill.id ? updatedBill : b).toList();
    await _saveItems();
  }

  Future<void> deleteBill(String id) async {
    state = state.where((b) => b.id != id).toList();
    await _saveItems();
  }

  Future<void> togglePaidThisMonth(String id) async {
    state = state.map((b) {
      if (b.id == id) {
        final newPaid = !b.isPaidThisMonth;
        return b.copyWith(
          isPaidThisMonth: newPaid,
          lastPaidDate: newPaid ? DateTime.now() : b.lastPaidDate,
        );
      }
      return b;
    }).toList();
    await _saveItems();
  }
}

final recurringBillsProvider = NotifierProvider<RecurringBillsNotifier, List<RecurringBill>>(() {
  return RecurringBillsNotifier();
});
