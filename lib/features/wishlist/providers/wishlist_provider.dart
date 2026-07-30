import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/wishlist_item.dart';
import '../../transactions/providers/transaction_provider.dart';

const String _kWishlistStorageKey = 'balanza_wishlist_items_v1';

class WishlistNotifier extends Notifier<List<WishlistItem>> {
  @override
  List<WishlistItem> build() {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final jsonStr = prefs.getString(_kWishlistStorageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List list = json.decode(jsonStr);
        return list.map((item) => WishlistItem.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveItems() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final jsonStr = json.encode(state.map((item) => item.toJson()).toList());
      await prefs.setString(_kWishlistStorageKey, jsonStr);
    } catch (_) {}
  }

  Future<WishlistItem> addItem(double amount, {String? title}) async {
    final newItem = WishlistItem(
      id: const Uuid().v4(),
      title: title ?? 'Pre-purchase Item',
      amount: amount,
      createdAt: DateTime.now(),
      coolingOffDays: 30,
      status: 'cooling_off',
    );

    state = [newItem, ...state];
    await _saveItems();
    return newItem;
  }

  Future<void> removeItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _saveItems();
  }

  Future<void> markBought(String id) async {
    state = state.map((item) => item.id == id ? item.copyWith(status: 'bought') : item).toList();
    await _saveItems();
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<WishlistItem>>(() {
  return WishlistNotifier();
});
