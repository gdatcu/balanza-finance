import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/main.dart';
import 'package:balanza/models/net_worth_item.dart';
import 'package:balanza/features/net_worth/repositories/net_worth_repository.dart';
import 'package:balanza/features/net_worth/providers/net_worth_provider.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:balanza/features/auth/providers/biometric_provider.dart';
import 'app_e2e_test.dart';

class E2EMockNetWorthRepository implements NetWorthRepository {
  final List<NetWorthItem> _items = [];

  @override
  Future<List<NetWorthItem>> getNetWorthItems() async {
    return List.from(_items);
  }

  @override
  Future<NetWorthItem> addNetWorthItem(NetWorthItem item) async {
    _items.add(item);
    return item;
  }

  @override
  Future<NetWorthItem> updateNetWorthItem(NetWorthItem item) async {
    final idx = _items.indexWhere((x) => x.id == item.id);
    if (idx != -1) _items[idx] = item;
    return item;
  }

  @override
  Future<void> deleteNetWorthItem(String id) async {
    _items.removeWhere((x) => x.id == id);
  }
}

void main() {
  testWidgets('E2E Net Worth Flow - Add Asset & Liability, verify Net Worth summary', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockTxRepo = E2EMockTransactionRepository();
    final mockNetWorthRepo = E2EMockNetWorthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(mockTxRepo),
          netWorthRepositoryProvider.overrideWithValue(mockNetWorthRepo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(
            AuthChangeEvent.signedIn,
            Session(
              accessToken: 'mock_token',
              tokenType: 'bearer',
              user: const User(
                id: '00000000-0000-0000-0000-000000000000',
                appMetadata: {},
                userMetadata: {},
                aud: 'authenticated',
                createdAt: '2026-07-26T12:00:00Z',
              ),
            ),
          ))),
          biometricLockProvider.overrideWith(() => E2EFakeBiometricLockNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Open Navigation Drawer
    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // 2. Tap Net Worth in Drawer
    final netWorthTileRo = find.text('Avere Netă');
    final netWorthTileEn = find.text('Net Worth');
    final targetTile = netWorthTileRo.evaluate().isNotEmpty ? netWorthTileRo : netWorthTileEn;
    expect(targetTile, findsOneWidget);
    await tester.tap(targetTile);
    await tester.pumpAndSettle();

    // 3. Verify Net Worth View is open
    expect(find.text('Net Worth'), findsWidgets);

    // 4. Tap FAB to add Net Worth Item
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // 5. Add Asset: "Bank Deposit", 5000.0
    final nameField = find.byType(TextFormField).first;
    final balanceField = find.byType(TextFormField).last;

    await tester.enterText(nameField, 'Bank Deposit');
    await tester.enterText(balanceField, '5000.0');

    final addBtnRo = find.text('Adaugă Element');
    final addBtnEn = find.text('Add Item');
    final targetAddBtn = addBtnRo.evaluate().isNotEmpty ? addBtnRo : addBtnEn;
    await tester.tap(targetAddBtn);
    await tester.pumpAndSettle();

    // 6. Verify Asset appears
    expect(find.text('Bank Deposit'), findsOneWidget);

    // 7. Add Liability: "Car Credit", 1200.0
    await tester.tap(fab);
    await tester.pumpAndSettle();

    final nameField2 = find.byType(TextFormField).first;
    final balanceField2 = find.byType(TextFormField).last;

    await tester.enterText(nameField2, 'Car Credit');
    await tester.enterText(balanceField2, '1200.0');

    // Switch type to Liability by tapping SwitchListTile
    final switchTile = find.byType(SwitchListTile);
    expect(switchTile, findsOneWidget);
    await tester.tap(switchTile);
    await tester.pumpAndSettle();

    final targetAddBtn2 = addBtnRo.evaluate().isNotEmpty ? addBtnRo : addBtnEn;
    await tester.tap(targetAddBtn2);
    await tester.pumpAndSettle();

    // 8. Verify Liability appears and Net Worth total balance (5000 - 1200 = 3800.00)
    expect(find.text('Car Credit'), findsOneWidget);
    expect(find.text('RON 3800.00'), findsWidgets);
  });
}
