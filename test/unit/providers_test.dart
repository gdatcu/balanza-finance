import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/transactions/providers/exchange_rate_provider.dart';
import 'package:balanza/features/transactions/providers/tagging_rules_provider.dart';
import 'package:balanza/features/net_worth/providers/net_worth_provider.dart';
import 'package:balanza/features/net_worth/repositories/net_worth_repository.dart';
import 'package:balanza/features/settings/providers/locale_provider.dart';
import 'package:balanza/features/settings/providers/updater_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';
import 'package:balanza/models/net_worth_item.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/core/utils/default_tagging_rules.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {
  @override
  final auth = MockGoTrueClient();
}

class MockGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => null;
}

void main() {
  group('Exchange Rate Provider Tests', () {
    test('returns valid exchange rate', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rate = await container.read(exchangeRateProvider.future);
      expect(rate, greaterThan(0));
    });
  });

  group('Tagging Rules Provider Tests', () {
    test('TaggingRulesNotifier returns default tagging rules when Supabase not initialized', () async {
      final notifier = TaggingRulesNotifier();
      final rules = await notifier.build();
      expect(rules.length, defaultTaggingRules.length);
      expect(rules.any((r) => r.keyword == 'uber'), isTrue);
      expect(rules.any((r) => r.keyword == 'froo'), isTrue);
      expect(rules.any((r) => r.keyword == 'catena'), isTrue);
    });
  });

  group('NetWorth Provider Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'net_worth_items_local': [
          '{"id":"nw1","user_id":"u1","name":"Savings","balance":5000.0,"type":"asset","created_at":"2026-07-21T10:00:00.000Z"}'
        ]
      });
      final prefs = await SharedPreferences.getInstance();
      final mockSupabase = MockSupabaseClient();
      final mockRepo = NetWorthRepository(mockSupabase, prefs);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          netWorthRepositoryProvider.overrideWithValue(mockRepo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedOut, null))),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads initial net worth items from SharedPreferences', () async {
      await pumpEventQueue();
      final items = await container.read(netWorthListProvider.future);
      expect(items.length, 1);
      expect(items.first.name, 'Savings');
      expect(items.first.balance, 5000.0);
    });

    test('Add, update, and delete net worth item updates state', () async {
      final notifier = container.read(netWorthListProvider.notifier);

      final newItem = NetWorthItem(
        id: 'nw2',
        userId: 'u1',
        name: 'Car Loan',
        balance: 12000.0,
        type: NetWorthType.liability,
        createdAt: DateTime.now(),
      );

      await notifier.add(newItem);
      var items = await container.read(netWorthListProvider.future);
      expect(items.length, 2);

      final updatedItem = newItem.copyWith(balance: 11000.0);
      await notifier.updateItem(updatedItem);
      items = await container.read(netWorthListProvider.future);
      expect(items.firstWhere((i) => i.id == 'nw2').balance, 11000.0);

      await notifier.delete('nw1');
      items = await container.read(netWorthListProvider.future);
      expect(items.length, 1);
      expect(items.first.id, 'nw2');
    });
  });

  group('LocaleProvider Tests', () {
    test('defaults to English and allows setting locale', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedOut, null))),
        ],
      );
      addTearDown(container.dispose);

      final localeNotifier = container.read(localeProvider.notifier);
      expect(container.read(localeProvider), const Locale('en'));

      localeNotifier.setLocale('ro');
      expect(container.read(localeProvider), const Locale('ro'));
    });
  });

  group('BiometricLockProvider Tests', () {
    test('toggles lock state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(biometricLockProvider.notifier);
      expect(container.read(biometricLockProvider), true);

      notifier.setLocked(false);
      expect(container.read(biometricLockProvider), false);
    });
  });

  group('UpdaterProvider & Service Tests', () {
    test('instantiates UpdaterService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final updater = container.read(updaterProvider);
      expect(updater, isA<UpdaterService>());
    });
  });
}
