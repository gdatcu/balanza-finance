import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/features/net_worth/repositories/net_worth_repository.dart';
import 'package:balanza/models/net_worth_item.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {
  @override
  final auth = MockGoTrueClient();
}

class MockGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => null;
}

void main() {
  group('NetWorthRepository Offline & Local Fallback Tests', () {
    test('handles unauthenticated or offline local storage gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final mockSupabase = MockSupabaseClient();

      final repo = NetWorthRepository(mockSupabase, prefs);

      // Verify empty initial list
      var items = await repo.getNetWorthItems();
      expect(items, isEmpty);

      // Add item in fallback mode
      final newItem = NetWorthItem(
        id: 'nw-100',
        userId: 'u1',
        name: 'House Asset',
        balance: 300000.0,
        type: NetWorthType.asset,
        createdAt: DateTime.now(),
      );

      final added = await repo.addNetWorthItem(newItem);
      expect(added.id, 'nw-100');

      items = await repo.getNetWorthItems();
      expect(items.length, 1);
      expect(items.first.name, 'House Asset');

      // Update item
      final updated = newItem.copyWith(balance: 320000.0);
      await repo.updateNetWorthItem(updated);
      items = await repo.getNetWorthItems();
      expect(items.first.balance, 320000.0);

      // Delete item
      await repo.deleteNetWorthItem('nw-100');
      items = await repo.getNetWorthItems();
      expect(items, isEmpty);
    });
  });
}
