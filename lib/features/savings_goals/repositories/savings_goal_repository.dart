import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/savings_goal.dart';

class SavingsGoalRepository {
  final SupabaseClient _client;
  final SharedPreferences? _prefs;
  bool _useLocalFallback = false;

  SavingsGoalRepository([SupabaseClient? client, SharedPreferences? prefs])
      : _client = client ?? Supabase.instance.client,
        _prefs = prefs {
    if (_prefs != null) {
      _useLocalFallback = _prefs.getBool('savings_goals_supabase_broken') ?? false;
    }
  }

  static final List<SavingsGoal> _inMemoryFallback = [];

  void _setLocalFallbackActive() {
    _useLocalFallback = true;
    if (_prefs != null) {
      _prefs.setBool('savings_goals_supabase_broken', true);
    }
  }

  List<SavingsGoal> _readLocal() {
    if (_prefs != null) {
      final raw = _prefs.getStringList('savings_goals_local');
      if (raw != null) {
        try {
          final parsed = raw
              .map((s) => SavingsGoal.fromJson(Map<String, dynamic>.from(jsonDecode(s))))
              .toList();
          _inMemoryFallback.clear();
          _inMemoryFallback.addAll(parsed);
          return parsed;
        } catch (_) {}
      }
    }
    return List.from(_inMemoryFallback);
  }

  void _saveLocal() {
    if (_prefs != null) {
      final raw = _inMemoryFallback.map((g) => jsonEncode(g.toJson())).toList();
      _prefs.setStringList('savings_goals_local', raw);
    }
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    if (_client.auth.currentUser == null) {
      _useLocalFallback = false;
      return _readLocal();
    }

    if (_useLocalFallback) {
      return _readLocal();
    }

    try {
      final response = await _client
          .from('savings_goals')
          .select()
          .order('created_at', ascending: false);

      _useLocalFallback = false;
      if (_prefs != null) {
        await _prefs.setBool('savings_goals_supabase_broken', false);
      }

      final remoteGoals = (response as List)
          .map((json) => SavingsGoal.fromJson(json as Map<String, dynamic>))
          .toList();

      return remoteGoals;
    } catch (_) {
      _setLocalFallbackActive();
      return _readLocal();
    }
  }

  Future<SavingsGoal> addSavingsGoal(SavingsGoal goal) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      _inMemoryFallback.add(goal);
      _saveLocal();
      return goal;
    }

    final updated = goal.copyWith(userId: currentUserId);

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
          .from('savings_goals')
          .insert(payload)
          .select()
          .single();
      return SavingsGoal.fromJson(response);
    } catch (_) {
      _setLocalFallbackActive();
      _inMemoryFallback.add(updated);
      _saveLocal();
      return updated;
    }
  }

  Future<SavingsGoal> updateSavingsGoal(SavingsGoal goal) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || _useLocalFallback) {
      final idx = _inMemoryFallback.indexWhere((g) => g.id == goal.id);
      if (idx != -1) {
        _inMemoryFallback[idx] = goal;
        _saveLocal();
      }
      return goal;
    }

    final updated = goal.copyWith(userId: currentUserId);

    try {
      final response = await _client
          .from('savings_goals')
          .update(updated.toJson())
          .eq('id', goal.id)
          .select()
          .single();
      return SavingsGoal.fromJson(response);
    } catch (_) {
      _setLocalFallbackActive();
      final idx = _inMemoryFallback.indexWhere((g) => g.id == updated.id);
      if (idx != -1) {
        _inMemoryFallback[idx] = updated;
        _saveLocal();
      }
      return updated;
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    if (_client.auth.currentUser == null || _useLocalFallback) {
      _inMemoryFallback.removeWhere((g) => g.id == id);
      _saveLocal();
      return;
    }

    try {
      await _client.from('savings_goals').delete().eq('id', id);
    } catch (_) {
      _setLocalFallbackActive();
      _inMemoryFallback.removeWhere((g) => g.id == id);
      _saveLocal();
    }
  }
}
