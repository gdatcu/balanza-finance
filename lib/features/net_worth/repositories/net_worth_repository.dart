import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/net_worth_item.dart';

class NetWorthRepository {
  final SupabaseClient _client;
  final SharedPreferences? _prefs;
  bool _useLocalFallback = false;

  NetWorthRepository([SupabaseClient? client, SharedPreferences? prefs])
      : _client = client ?? Supabase.instance.client,
        _prefs = prefs {
    if (_prefs != null) {
      _useLocalFallback = _prefs.getBool('net_worth_supabase_broken') ?? false;
    }
  }

  // In-memory fallback list in case SharedPreferences or Supabase fails
  static final List<NetWorthItem> _inMemoryFallback = [];

  void _setLocalFallbackActive() {
    _useLocalFallback = true;
    if (_prefs != null) {
      _prefs.setBool('net_worth_supabase_broken', true);
    }
  }

  List<NetWorthItem> _readLocal() {
    if (_prefs != null) {
      final raw = _prefs.getStringList('net_worth_items_local');
      if (raw != null) {
        try {
          final parsed = raw
              .map((s) => NetWorthItem.fromJson(Map<String, dynamic>.from(jsonDecode(s))))
              .toList();
          _inMemoryFallback.clear();
          _inMemoryFallback.addAll(parsed);
          return parsed;
        } catch (_) {}
      }
    }
    return _inMemoryFallback;
  }

  Future<List<NetWorthItem>> getNetWorthItems() async {
    if (_client.auth.currentUser == null) {
      _useLocalFallback = false;
      return _readLocal();
    }

    if (_useLocalFallback) {
      return _readLocal();
    }

    try {
      final response = await _client
          .from('net_worth_items')
          .select()
          .order('created_at', ascending: false);

      _useLocalFallback = false;
      if (_prefs != null) {
        await _prefs.setBool('net_worth_supabase_broken', false);
      }

      final remoteItems = (response as List)
          .map((json) => NetWorthItem.fromJson(json as Map<String, dynamic>))
          .toList();

      if (_prefs != null) {
        final raw = _prefs.getStringList('net_worth_items_local');
        if (raw != null && raw.isNotEmpty) {
          final localItems = raw
              .map((s) => NetWorthItem.fromJson(Map<String, dynamic>.from(jsonDecode(s))))
              .toList();

          for (final item in localItems) {
            try {
              final currentUserId = _client.auth.currentUser?.id;
              final updated = currentUserId != null ? item.copyWith(userId: currentUserId) : item;
              final payload = updated.toJson();
              if (payload['id'] == null ||
                  !payload['id'].toString().contains('-') ||
                  payload['id'].toString().length != 36) {
                payload.remove('id');
              }
              await _client.from('net_worth_items').insert(payload);
            } catch (_) {}
          }
          await _prefs.remove('net_worth_items_local');
          return getNetWorthItems();
        }
      }

      return remoteItems;
    } catch (_) {
      _setLocalFallbackActive();
      return _readLocal();
    }
  }

  Future<NetWorthItem> addNetWorthItem(NetWorthItem item) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      _inMemoryFallback.add(item);
      _saveLocal();
      return item;
    }

    final updated = item.copyWith(userId: currentUserId);

    if (_useLocalFallback) {
      _inMemoryFallback.add(updated);
      _saveLocal();
      return updated;
    }

    try {
      final payload = updated.toJson();
      if (payload['id'] == null ||
          !payload['id'].toString().contains('-') ||
          payload['id'].toString().length != 36) {
        payload.remove('id');
      }

      final response = await _client
          .from('net_worth_items')
          .insert(payload)
          .select()
          .single();
      return NetWorthItem.fromJson(response);
    } catch (_) {
      _setLocalFallbackActive();
      _inMemoryFallback.add(updated);
      _saveLocal();
      return updated;
    }
  }

  Future<NetWorthItem> updateNetWorthItem(NetWorthItem item) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || _useLocalFallback) {
      final idx = _inMemoryFallback.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        _inMemoryFallback[idx] = item;
        _saveLocal();
      }
      return item;
    }

    final updated = item.copyWith(userId: currentUserId);

    try {
      final response = await _client
          .from('net_worth_items')
          .update(updated.toJson())
          .eq('id', item.id)
          .select()
          .single();
      return NetWorthItem.fromJson(response);
    } catch (_) {
      _setLocalFallbackActive();
      final idx = _inMemoryFallback.indexWhere((x) => x.id == updated.id);
      if (idx != -1) {
        _inMemoryFallback[idx] = updated;
        _saveLocal();
      }
      return updated;
    }
  }

  Future<void> deleteNetWorthItem(String id) async {
    if (_client.auth.currentUser == null || _useLocalFallback) {
      _inMemoryFallback.removeWhere((x) => x.id == id);
      _saveLocal();
      return;
    }

    try {
      await _client.from('net_worth_items').delete().eq('id', id);
    } catch (_) {
      _setLocalFallbackActive();
      _inMemoryFallback.removeWhere((x) => x.id == id);
      _saveLocal();
    }
  }

  void _saveLocal() {
    if (_prefs != null) {
      final raw = _inMemoryFallback.map((item) => jsonEncode(item.toJson())).toList();
      _prefs.setStringList('net_worth_items_local', raw);
    }
  }
}
