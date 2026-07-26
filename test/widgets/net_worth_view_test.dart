import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/features/net_worth/presentation/net_worth_view.dart';
import 'package:balanza/features/net_worth/providers/net_worth_provider.dart';
import 'package:balanza/features/net_worth/repositories/net_worth_repository.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {
  @override
  final auth = MockGoTrueClient();
}

class MockGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('NetWorthView renders header, list of assets/liabilities, and opening add sheet works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('net_worth_items_local', [
      '{"id":"asset-1","user_id":"u1","name":"Investment Portfolio","balance":45000.0,"type":"asset","created_at":"2026-07-26T12:00:00Z"}',
      '{"id":"liab-1","user_id":"u1","name":"Car Loan","balance":10000.0,"type":"liability","created_at":"2026-07-26T12:00:00Z"}'
    ]);
    final mockSupabase = MockSupabaseClient();
    final repo = NetWorthRepository(mockSupabase, prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          netWorthRepositoryProvider.overrideWithValue(repo),
          authProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedOut, null))),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: NetWorthView(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Net Worth'), findsAtLeastNWidgets(1));
    expect(find.text('Investment Portfolio'), findsOneWidget);
    expect(find.text('Car Loan'), findsOneWidget);

    // Tap FloatingActionButton to open add sheet
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('Add Net Worth Item'), findsOneWidget);
  });
}
