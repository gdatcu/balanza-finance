import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart'; // for sharedPreferencesProvider
import '../../auth/providers/auth_provider.dart';
import '../../../../models/net_worth_item.dart';
import '../repositories/net_worth_repository.dart';

final netWorthRepositoryProvider = Provider<NetWorthRepository>((ref) {
  // Try to read shared preferences, fallback to null if not loaded yet
  final prefs = ref.watch(sharedPreferencesProvider);
  return NetWorthRepository(null, prefs);
});

class NetWorthListNotifier extends AsyncNotifier<List<NetWorthItem>> {
  NetWorthRepository get _repository => ref.read(netWorthRepositoryProvider);

  @override
  Future<List<NetWorthItem>> build() async {
    // Rebuild the net worth list whenever the user's authentication state changes
    ref.watch(authProvider);
    return _repository.getNetWorthItems();
  }

  Future<void> add(NetWorthItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addNetWorthItem(item);
      return _repository.getNetWorthItems();
    });
  }

  Future<void> updateItem(NetWorthItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateNetWorthItem(item);
      return _repository.getNetWorthItems();
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteNetWorthItem(id);
      return _repository.getNetWorthItems();
    });
  }
}

final netWorthListProvider =
    AsyncNotifierProvider<NetWorthListNotifier, List<NetWorthItem>>(() {
  return NetWorthListNotifier();
});
