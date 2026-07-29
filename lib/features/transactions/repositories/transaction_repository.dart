import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/transaction.dart';
import '../../../models/debug_notification.dart';
import '../presentation/categories_data.dart';

class TransactionRepository {
  final SupabaseClient? _customClient;

  TransactionRepository([SupabaseClient? client]) : _customClient = client;

  SupabaseClient? get _client {
    if (_customClient != null) return _customClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Stream<List<Transaction>> getTransactionsStream(DateTime month) {
    final client = _client;
    if (client == null) return Stream.value([]);

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);

    try {
      return client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .order('date', ascending: false)
          .map((response) => response
              .map((json) => Transaction.fromJson(json))
              .where((tx) => !tx.isPendingReview && !tx.date.isBefore(start) && !tx.date.isAfter(end))
              .toList());
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<List<Transaction>> getTransactions(DateTime month) async {
    final client = _client;
    if (client == null) return [];

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);

    try {
      final response = await client
          .from('transactions')
          .select()
          .eq('is_pending_review', false)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String())
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<Transaction>> getPendingTransactionsStream() {
    final client = _client;
    if (client == null) return Stream.value([]);

    try {
      return client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((response) => response
              .map((json) => Transaction.fromJson(json))
              .where((tx) => tx.isPendingReview)
              .toList());
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<List<Transaction>> getPendingTransactions() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('transactions')
          .select()
          .eq('is_pending_review', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> approvePendingTransaction(String id) async {
    final client = _client;
    if (client == null) return;

    try {
      await client
          .from('transactions')
          .update({'is_pending_review': false})
          .eq('id', id);
    } catch (_) {}
  }

  Future<bool> checkDuplicateRecentTransaction(double amount, {int windowSeconds = 60}) async {
    final client = _client;
    if (client == null) return false;

    try {
      final cutoff = DateTime.now().subtract(Duration(seconds: windowSeconds)).toIso8601String();
      final response = await client
          .from('transactions')
          .select()
          .gte('created_at', cutoff);

      final list = (response as List).map((json) => Transaction.fromJson(json)).toList();
      return list.any((tx) => (tx.amount.abs() - amount.abs()).abs() < 0.01);
    } catch (_) {
      return false;
    }
  }

  Future<void> logDebugNotification(DebugNotification notification) async {
    final client = _client;
    if (client == null) return;

    try {
      await client
          .from('debug_notifications')
          .insert(notification.toJson());
    } catch (_) {}
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final client = _client;
    if (client == null) return transaction;

    final currentUserId = client.auth.currentUser?.id;
    var updatedTx = transaction;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      updatedTx = updatedTx.copyWith(userId: currentUserId);
    } else if (updatedTx.userId.isEmpty) {
      updatedTx = updatedTx.copyWith(userId: '00000000-0000-0000-0000-000000000000');
    }

    if (updatedTx.accountId.isEmpty || updatedTx.accountId == 'default-acc') {
      updatedTx = updatedTx.copyWith(accountId: '00000000-0000-0000-0000-000000000001');
    }

    if (updatedTx.categoryId != null && updatedTx.categoryId!.isNotEmpty) {
      try {
        final cat = defaultCategories.firstWhere(
          (c) => c.id == updatedTx.categoryId,
        );
        await client.from('categories').upsert({
          'id': cat.id,
          'name': cat.name,
          'icon': cat.icon,
          'color': cat.color,
          if (currentUserId != null && currentUserId.isNotEmpty) 'user_id': currentUserId,
          'created_at': cat.createdAt.toIso8601String(),
        }, onConflict: 'id');
      } catch (_) {}
    }

    try {
      final response = await client
          .from('transactions')
          .insert(updatedTx.toJson())
          .select()
          .single();

      return Transaction.fromJson(response);
    } on PostgrestException catch (e) {
      if ((e.code == '23503' || e.code == '22P02') && updatedTx.categoryId != null) {
        final fallbackTx = updatedTx.copyWith(categoryId: null);
        try {
          final response = await client
              .from('transactions')
              .insert(fallbackTx.toJson())
              .select()
              .single();
          return Transaction.fromJson(response);
        } catch (_) {
          return fallbackTx;
        }
      }
      return updatedTx;
    } catch (_) {
      return updatedTx;
    }
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    final client = _client;
    if (client == null) return transaction;

    final currentUserId = client.auth.currentUser?.id;
    final updatedTx = currentUserId != null
        ? transaction.copyWith(userId: currentUserId)
        : transaction;

    if (updatedTx.categoryId != null) {
      try {
        final cat = defaultCategories.firstWhere(
          (c) => c.id == updatedTx.categoryId,
        );
        await client.from('categories').upsert({
          'id': cat.id,
          'name': cat.name,
          'icon': cat.icon,
          'color': cat.color,
          if (currentUserId != null) 'user_id': currentUserId,
          'created_at': cat.createdAt.toIso8601String(),
        }, onConflict: 'id');
      } catch (_) {}
    }

    try {
      final response = await client
          .from('transactions')
          .update(updatedTx.toJson())
          .eq('id', updatedTx.id)
          .select()
          .single();

      return Transaction.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23503' && updatedTx.categoryId != null) {
        final fallbackTx = updatedTx.copyWith(categoryId: null);
        final response = await client
            .from('transactions')
            .update(fallbackTx.toJson())
            .eq('id', fallbackTx.id)
            .select()
            .single();
        return Transaction.fromJson(response);
      }
      return updatedTx;
    } catch (_) {
      return updatedTx;
    }
  }

  Future<void> deleteTransaction(String id) async {
    final client = _client;
    if (client == null) return;

    try {
      await client
          .from('transactions')
          .delete()
          .eq('id', id);
    } catch (_) {}
  }
}
