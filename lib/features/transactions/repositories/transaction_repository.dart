import 'dart:async';
import 'package:flutter/foundation.dart';
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

  static final List<Transaction> _localApprovedTransactions = [];
  static final List<Transaction> _localPendingTransactions = [];
  static final List<DebugNotification> _localDebugLogs = [];

  Stream<List<Transaction>> getTransactionsStream(DateTime month) async* {
    yield await getTransactions(month);

    final client = _client;
    if (client == null) return;

    final controller = StreamController<List<Transaction>>();

    StreamSubscription? realtimeSub;
    try {
      realtimeSub = client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .order('date', ascending: false)
          .listen((_) async {
        if (!controller.isClosed) {
          controller.add(await getTransactions(month));
        }
      });
    } catch (_) {}

    final timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!controller.isClosed) {
        controller.add(await getTransactions(month));
      }
    });

    try {
      await for (final data in controller.stream) {
        yield data;
      }
    } finally {
      realtimeSub?.cancel();
      timer.cancel();
      controller.close();
    }
  }

  Future<List<Transaction>> getTransactions(DateTime month) async {
    final client = _client;
    if (client != null) {
      await _syncLocalTransactionsToSupabase();
      await claimUnassignedPendingTransactions();

      try {
        final response = await client
            .from('transactions')
            .select()
            .order('date', ascending: false)
            .limit(500);

        final remote = (response as List)
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .where((tx) => !tx.isPendingReview && tx.date.year == month.year && tx.date.month == month.month)
            .toList();

        for (final r in remote) {
          _localApprovedTransactions.removeWhere((tx) => tx.id == r.id);
          _localApprovedTransactions.add(r);
        }

        final resultList = <Transaction>[...remote];
        for (final localTx in _localApprovedTransactions) {
          if (!localTx.isPendingReview &&
              localTx.date.year == month.year &&
              localTx.date.month == month.month &&
              !resultList.any((r) => r.id == localTx.id)) {
            resultList.add(localTx);
          }
        }

        resultList.sort((a, b) => b.date.compareTo(a.date));
        return resultList;
      } catch (e) {
        debugPrint('TransactionRepository.getTransactions error: $e');
      }
    }

    final List<Transaction> result = _localApprovedTransactions.where((tx) {
      return !tx.isPendingReview && tx.date.year == month.year && tx.date.month == month.month;
    }).toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<void> _syncLocalTransactionsToSupabase() async {
    final client = _client;
    if (client == null) return;

    final currentUserId = client.auth.currentUser?.id;
    final targetUserId = (currentUserId != null && currentUserId.isNotEmpty)
        ? currentUserId
        : '00000000-0000-0000-0000-000000000000';

    for (final tx in List<Transaction>.from(_localApprovedTransactions)) {
      try {
        var updatedTx = tx;
        if (updatedTx.userId.isEmpty || updatedTx.userId == '00000000-0000-0000-0000-000000000000') {
          updatedTx = updatedTx.copyWith(userId: targetUserId);
        }
        if (updatedTx.accountId.isEmpty || updatedTx.accountId == 'default-acc') {
          updatedTx = updatedTx.copyWith(accountId: '00000000-0000-0000-0000-000000000001');
        }

        try {
          await client.from('accounts').upsert({
            'id': updatedTx.accountId,
            'name': 'Main Account',
            'type': 'checking',
            'balance': 0.0,
            'currency': 'RON',
            if (targetUserId.isNotEmpty) 'user_id': targetUserId,
            'created_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');
        } catch (_) {}

        await client.from('transactions').upsert(updatedTx.toDbJson(), onConflict: 'id');
      } catch (e) {
        debugPrint('_syncLocalTransactionsToSupabase error: $e');
      }
    }
  }

  Future<void> claimUnassignedPendingTransactions() async {
    final client = _client;
    if (client == null) return;

    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId.isEmpty) return;

    try {
      await client
          .from('transactions')
          .update({'user_id': currentUserId})
          .eq('user_id', '00000000-0000-0000-0000-000000000000');
    } catch (_) {}
  }

  Stream<List<Transaction>> getPendingTransactionsStream() async* {
    yield await getPendingTransactions();

    final client = _client;
    if (client == null) return;

    final controller = StreamController<List<Transaction>>();

    StreamSubscription? realtimeSub;
    try {
      realtimeSub = client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .listen((_) async {
        if (!controller.isClosed) {
          controller.add(await getPendingTransactions());
        }
      });
    } catch (_) {}

    final timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!controller.isClosed) {
        controller.add(await getPendingTransactions());
      }
    });

    try {
      await for (final data in controller.stream) {
        yield data;
      }
    } finally {
      realtimeSub?.cancel();
      timer.cancel();
      controller.close();
    }
  }

  Future<List<Transaction>> getPendingTransactions() async {
    final List<Transaction> result = List.from(_localPendingTransactions);

    final client = _client;
    if (client != null) {
      await claimUnassignedPendingTransactions();

      try {
        final response = await client
            .from('transactions')
            .select()
            .eq('is_pending_review', true)
            .order('created_at', ascending: false);

        final remote = (response as List)
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();

        for (final r in remote) {
          if (!result.any((tx) => tx.id == r.id)) {
            result.add(r);
          }
        }
      } catch (_) {}
    }

    return result;
  }

  Future<void> approvePendingTransaction(String id) async {
    Transaction? found;
    final index = _localPendingTransactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      found = _localPendingTransactions.removeAt(index);
    }

    if (found == null) {
      final client = _client;
      if (client != null) {
        try {
          final response = await client
              .from('transactions')
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response != null) {
            found = Transaction.fromJson(response);
          }
        } catch (_) {}
      }
    }

    if (found != null) {
      final approvedTx = found.copyWith(isPendingReview: false);
      _localApprovedTransactions.removeWhere((tx) => tx.id == approvedTx.id);
      _localApprovedTransactions.insert(0, approvedTx);

      final client = _client;
      if (client != null) {
        try {
          await client
              .from('transactions')
              .update({'is_pending_review': false})
              .eq('id', id);
        } catch (_) {
          await addTransaction(approvedTx);
        }
      }
    }
  }

  Future<bool> checkDuplicateRecentTransaction(
    double amount, {
    String? merchant,
    int windowSeconds = 60,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(seconds: windowSeconds));
    final hasLocalDuplicate = _localPendingTransactions.any((tx) =>
        tx.createdAt.isAfter(cutoff) &&
        (tx.amount.abs() - amount.abs()).abs() < 0.01 &&
        (merchant == null || tx.description == merchant));

    if (hasLocalDuplicate) return true;

    final client = _client;
    if (client == null) return false;

    try {
      final response = await client
          .from('transactions')
          .select()
          .gte('created_at', cutoff.toIso8601String());

      final list = (response as List).map((json) => Transaction.fromJson(json)).toList();
      return list.any((tx) =>
          (tx.amount.abs() - amount.abs()).abs() < 0.01 &&
          (merchant == null || tx.description == merchant));
    } catch (_) {
      return false;
    }
  }

  Future<void> logDebugNotification(DebugNotification notification) async {
    _localDebugLogs.insert(0, notification);
    if (_localDebugLogs.length > 50) {
      _localDebugLogs.removeLast();
    }

    final client = _client;
    if (client == null) return;

    try {
      await client
          .from('debug_notifications')
          .insert(notification.toJson());
    } catch (_) {}
  }

  Future<List<DebugNotification>> getDebugNotifications() async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client
            .from('debug_notifications')
            .select()
            .order('created_at', ascending: false)
            .limit(20);
        final remote = (response as List)
            .map((json) => DebugNotification.fromJson(json as Map<String, dynamic>))
            .toList();
        if (remote.isNotEmpty) return remote;
      } catch (_) {}
    }
    return List.from(_localDebugLogs);
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    var updatedTx = transaction;
    if (updatedTx.isPendingReview) {
      _localPendingTransactions.removeWhere((t) => t.id == updatedTx.id);
      _localPendingTransactions.insert(0, updatedTx);
    } else {
      _localApprovedTransactions.removeWhere((t) => t.id == updatedTx.id);
      _localApprovedTransactions.insert(0, updatedTx);
    }

    final client = _client;
    if (client == null) return updatedTx;

    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      updatedTx = updatedTx.copyWith(userId: currentUserId);
    } else if (updatedTx.userId.isEmpty) {
      updatedTx = updatedTx.copyWith(userId: '00000000-0000-0000-0000-000000000000');
    }

    if (updatedTx.accountId.isEmpty || updatedTx.accountId == 'default-acc') {
      updatedTx = updatedTx.copyWith(accountId: '00000000-0000-0000-0000-000000000001');
    }

    try {
      await client.from('accounts').upsert({
        'id': updatedTx.accountId,
        'name': 'Main Account',
        'type': 'checking',
        'balance': 0.0,
        'currency': 'RON',
        if (currentUserId != null && currentUserId.isNotEmpty) 'user_id': currentUserId,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (_) {}

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
          .insert(updatedTx.toDbJson())
          .select()
          .single();

      final saved = Transaction.fromJson(response);
      if (saved.isPendingReview) {
        _localPendingTransactions.removeWhere((t) => t.id == saved.id);
        _localPendingTransactions.insert(0, saved);
      } else {
        _localApprovedTransactions.removeWhere((t) => t.id == saved.id);
        _localApprovedTransactions.insert(0, saved);
      }
      return saved;
    } on PostgrestException catch (e) {
      if ((e.code == '23503' || e.code == '22P02') && updatedTx.categoryId != null) {
        final fallbackTx = updatedTx.copyWith(categoryId: null);
        try {
          final response = await client
              .from('transactions')
              .insert(fallbackTx.toDbJson())
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
    final index = _localApprovedTransactions.indexWhere((tx) => tx.id == transaction.id);
    if (index != -1) {
      _localApprovedTransactions[index] = transaction;
    } else {
      _localApprovedTransactions.insert(0, transaction);
    }

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
    _localPendingTransactions.removeWhere((tx) => tx.id == id);
    _localApprovedTransactions.removeWhere((tx) => tx.id == id);
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
