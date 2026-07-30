import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/settings/providers/user_settings_provider.dart';
import 'package:balanza/features/analytics/presentation/time_burn_calendar_view.dart';

class MockSelectedMonthNotifier extends SelectedMonthNotifier {
  @override
  DateTime build() => DateTime(2026, 7, 1);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final incomeTx = Transaction(
    id: 'tx-inc',
    userId: 'u1',
    accountId: 'a1',
    amount: 9200.0, // 9,200 RON income => 23 working days * 8h = 184h => 50 RON/h => 400 RON/day wage
    date: DateTime(2026, 7, 1),
    createdAt: DateTime(2026, 7, 1),
  );

  final regretTx = Transaction(
    id: 'tx-regret',
    userId: 'u1',
    accountId: 'a1',
    amount: -300.0, // 300 RON regret > 50% of 400 RON daily wage
    description: 'Impulse Shopping',
    date: DateTime(2026, 7, 10),
    createdAt: DateTime(2026, 7, 10),
    emotionalStatus: 'regret',
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        selectedMonthProvider.overrideWith(() => MockSelectedMonthNotifier()),
        transactionListProvider.overrideWithValue(AsyncValue.data([incomeTx, regretTx])),
        dailyWorkingHoursProvider.overrideWithValue(const AsyncValue.data(8.0)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimeBurnCalendarView(),
      ),
    );
  }

  group('TimeBurnCalendarView Widget Tests', () {
    testWidgets('Renders Time-Burn Calendar header and regret summary metric', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Time-Burn Calendar'), findsOneWidget);
      expect(find.textContaining('You spent 0.8 working days this month on things you regret'), findsOneWidget);
      expect(find.text('🤦'), findsOneWidget);
    });

    testWidgets('Tapping a Regret Day cell opens bottom sheet with regret warning', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap cell with day 10
      final day10Finder = find.text('10');
      expect(day10Finder, findsOneWidget);
      await tester.tap(day10Finder);
      await tester.pumpAndSettle();

      expect(find.textContaining('You worked this day and regretted'), findsOneWidget);
      expect(find.text('Impulse Shopping'), findsOneWidget);
      expect(find.text('Regret 🤦'), findsOneWidget);
    });
  });
}
