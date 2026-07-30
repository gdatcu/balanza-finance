import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/features/analytics/presentation/reality_check_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RealityCheckSheet(),
        ),
      ),
    );
  }

  group('RealityCheckSheet Widget Tests', () {
    testWidgets('Renders Reality Check title and custom keypad', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Reality Check'), findsOneWidget);
      expect(find.text('0 RON'), findsOneWidget);

      // Verify custom keypad digits
      for (int i = 1; i <= 9; i++) {
        expect(find.byKey(Key('keypad_$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('keypad_.')), findsOneWidget);
      expect(find.byKey(const Key('keypad_⌫')), findsOneWidget);
    });

    testWidgets('Typing digits updates amount and reveals action buttons', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap 1, 5, 0
      await tester.tap(find.byKey(const Key('keypad_1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad_5')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad_0')));
      await tester.pump();

      expect(find.text('150 RON'), findsOneWidget);

      // Verify action buttons appear
      expect(find.text('Put it in the Wishlist'), findsOneWidget);
      expect(find.text('Walk Away'), findsOneWidget);
      expect(find.text("I'm buying it anyway"), findsOneWidget);
    });

    testWidgets('Backspace key removes last digit', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad_5')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad_0')));
      await tester.pump();

      expect(find.text('50 RON'), findsOneWidget);

      await tester.tap(find.byKey(const Key('keypad_⌫')));
      await tester.pump();

      expect(find.text('5 RON'), findsOneWidget);
    });
  });
}
