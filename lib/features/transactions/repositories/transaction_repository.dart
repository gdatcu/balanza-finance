import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/transaction.dart';

class TransactionRepository {
  final SupabaseClient _client;

  TransactionRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Stream<List<Transaction>> getTransactionsStream(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);

    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((response) => response
            .map((json) => Transaction.fromJson(json))
            .where((tx) => !tx.date.isBefore(start) && !tx.date.isAfter(end))
            .toList());
  }

  Future<List<Transaction>> getTransactions(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);

    final response = await _client
        .from('transactions')
        .select()
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: false);

    return (response as List)
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final currentUserId = _client.auth.currentUser?.id;
    final updatedTx = currentUserId != null
        ? transaction.copyWith(userId: currentUserId)
        : transaction;

    final response = await _client
        .from('transactions')
        .insert(updatedTx.toJson())
        .select()
        .single();

    return Transaction.fromJson(response);
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    final response = await _client
        .from('transactions')
        .update(transaction.toJson())
        .eq('id', transaction.id)
        .select()
        .single();

    return Transaction.fromJson(response);
  }

  Future<void> deleteTransaction(String id) async {
    await _client
        .from('transactions')
        .delete()
        .eq('id', id);
  }
}
