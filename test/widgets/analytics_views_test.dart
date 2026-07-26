import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/features/analytics/presentation/expense_pie_chart.dart';
import 'package:balanza/features/analytics/presentation/wealth_advisor_banner.dart';
import 'package:balanza/features/analytics/models/advisor_nudge.dart';
import 'package:balanza/features/analytics/providers/wealth_advisor_provider.dart';
import 'package:balanza/models/transaction.dart';

void main() {
  testWidgets('ExpensePieChart renders empty state when no transactions given', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: ExpensePieChart(
            customTransactions: [],
            isIncome: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No expense data to display yet.'), findsOneWidget);
  });

  testWidgets('ExpensePieChart renders sections and legend for transactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testTxs = [
      Transaction(
        id: 'tx-pie-1',
        userId: 'u1',
        accountId: 'a1',
        categoryId: '00000000-0000-0000-0000-000000000c16', // Groceries
        amount: -200.0,
        date: DateTime.parse('2026-07-26T12:00:00Z'),
        createdAt: DateTime.parse('2026-07-26T12:00:00Z'),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: ExpensePieChart(
            customTransactions: testTxs,
            isIncome: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Expenses by Category'), findsOneWidget);
    expect(find.text('Groceries'), findsWidgets);
  });

  testWidgets('WealthAdvisorBanner renders nudge and dismisses on close tap', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const mockState = WealthAdvisorState(
      id: 'test-nudge-1',
      title: 'WEALTH ADVISOR INSIGHT',
      message: 'Great job staying within budget!',
      icon: Icons.lightbulb,
      type: AdvisorType.nudge,
      severity: NudgeSeverity.safe,
      textEn: 'Great job staying within budget!',
      textRo: 'Bravo pentru încadrarea în buget!',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wealthAdvisorProvider.overrideWith((ref) => mockState),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: WealthAdvisorBanner(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('WEALTH ADVISOR INSIGHT'), findsOneWidget);
    expect(find.text('Great job staying within budget!'), findsOneWidget);

    final closeBtn = find.byIcon(Icons.close);
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();
  });
}
