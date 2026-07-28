import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/models/net_worth_item.dart';
import 'package:balanza/features/net_worth/repositories/net_worth_repository.dart';

class MockSupabaseClientForIntegration extends Fake implements SupabaseClient {
  @override
  final auth = MockGoTrueClientForIntegration();
}

class MockGoTrueClientForIntegration extends Fake implements GoTrueClient {
  @override
  User? get currentUser => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetWorthRepository Offline Fallback Integration Tests', () {
    late SharedPreferences prefs;
    late NetWorthRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      repository = NetWorthRepository(MockSupabaseClientForIntegration(), prefs);
    });

    test('getNetWorthItems reads list from local fallback', () async {
      final items = await repository.getNetWorthItems();
      expect(items, isA<List<NetWorthItem>>());
    });

    test('addNetWorthItem saves to local SharedPreferences fallback', () async {
      final now = DateTime.now();
      final newItem = NetWorthItem(
        id: 'net-add-1',
        userId: 'user-1',
        name: 'Emergency Fund',
        balance: 10000.0,
        type: NetWorthType.asset,
        createdAt: now,
      );

      final added = await repository.addNetWorthItem(newItem);
      expect(added.name, equals('Emergency Fund'));

      final list = await repository.getNetWorthItems();
      expect(list.any((x) => x.id == 'net-add-1'), isTrue);
    });

    test('updateNetWorthItem modifies local item correctly', () async {
      final now = DateTime.now();
      final item = NetWorthItem(
        id: 'net-upd-1',
        userId: 'user-1',
        name: 'Car Debt',
        balance: 5000.0,
        type: NetWorthType.liability,
        createdAt: now,
      );

      await repository.addNetWorthItem(item);

      final updatedItem = item.copyWith(balance: 4000.0);
      await repository.updateNetWorthItem(updatedItem);

      final list = await repository.getNetWorthItems();
      final found = list.firstWhere((x) => x.id == 'net-upd-1');
      expect(found.balance, equals(4000.0));
    });

    test('deleteNetWorthItem removes item from local storage', () async {
      final now = DateTime.now();
      final item1 = NetWorthItem(
        id: 'net-del-1',
        userId: 'user-1',
        name: 'Item 1',
        balance: 100.0,
        type: NetWorthType.asset,
        createdAt: now,
      );

      await repository.addNetWorthItem(item1);
      final listBefore = await repository.getNetWorthItems();
      expect(listBefore.any((x) => x.id == 'net-del-1'), isTrue);

      await repository.deleteNetWorthItem('net-del-1');

      final listAfter = await repository.getNetWorthItems();
      expect(listAfter.any((x) => x.id == 'net-del-1'), isFalse);
    });
  });
}
