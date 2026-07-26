import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/core/utils/currency_formatter.dart';
import 'package:balanza/core/utils/category_localizer.dart';
import 'package:balanza/l10n/app_localizations.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats positive amounts correctly', () {
      expect(CurrencyFormatter.format(123.456), 'RON 123.46');
      expect(CurrencyFormatter.format(0.0), 'RON 0.00');
      expect(CurrencyFormatter.format(1000), 'RON 1000.00');
    });

    test('formats negative amounts correctly', () {
      expect(CurrencyFormatter.format(-45.5), '-RON 45.50');
      expect(CurrencyFormatter.format(-0.01), '-RON 0.01');
    });
  });

  group('CategoryLocalizer Direct Methods Tests', () {
    test('getCategoryNameEn maps predefined English names and handles fallbacks', () {
      expect(CategoryLocalizer.getCategoryNameEn('food'), 'Food & Dining');
      expect(CategoryLocalizer.getCategoryNameEn('transport'), 'Transport');
      expect(CategoryLocalizer.getCategoryNameEn('rent'), 'Rent');
      expect(CategoryLocalizer.getCategoryNameEn('utilities'), 'Utilities & Bills');
      expect(CategoryLocalizer.getCategoryNameEn('entertainment'), 'Entertainment');
      expect(CategoryLocalizer.getCategoryNameEn('shopping'), 'Shopping');
      expect(CategoryLocalizer.getCategoryNameEn('salary'), 'Salary');
      expect(CategoryLocalizer.getCategoryNameEn('investments'), 'Investments');
      expect(CategoryLocalizer.getCategoryNameEn('gifts'), 'Gifts');
      expect(CategoryLocalizer.getCategoryNameEn('coffee'), 'Coffee & Tea');
      expect(CategoryLocalizer.getCategoryNameEn('restaurant'), 'Restaurants & Dining');
      expect(CategoryLocalizer.getCategoryNameEn('pets'), 'Pet Care');
      expect(CategoryLocalizer.getCategoryNameEn('subscription'), 'Subscriptions');
      expect(CategoryLocalizer.getCategoryNameEn('other'), 'Other');
      expect(CategoryLocalizer.getCategoryNameEn('credit'), 'Credit & Loans');
      expect(CategoryLocalizer.getCategoryNameEn('groceries'), 'Groceries');
      expect(CategoryLocalizer.getCategoryNameEn('meal_tickets'), 'Meal Tickets');
      expect(CategoryLocalizer.getCategoryNameEn('side_hustle'), 'Side Hustle / Extra');
      expect(CategoryLocalizer.getCategoryNameEn('clothing'), 'Clothing & Fashion');
      expect(CategoryLocalizer.getCategoryNameEn('healthcare'), 'Health & Medical');
      expect(CategoryLocalizer.getCategoryNameEn('gadgets'), 'Gadgets & Tech');
      expect(CategoryLocalizer.getCategoryNameEn('travel'), 'Travel & Holidays');
      expect(CategoryLocalizer.getCategoryNameEn('personal_care'), 'Personal Care');
      expect(CategoryLocalizer.getCategoryNameEn('education'), 'Education');
      expect(CategoryLocalizer.getCategoryNameEn('Unknown Category'), 'Unknown Category');
    });

    test('getCategoryNameRo maps predefined Romanian names and handles fallbacks', () {
      expect(CategoryLocalizer.getCategoryNameRo('food'), 'Mâncare');
      expect(CategoryLocalizer.getCategoryNameRo('transport'), 'Transport & Auto');
      expect(CategoryLocalizer.getCategoryNameRo('rent'), 'Chirie');
      expect(CategoryLocalizer.getCategoryNameRo('utilities'), 'Utilități');
      expect(CategoryLocalizer.getCategoryNameRo('entertainment'), 'Divertisment & Cultură');
      expect(CategoryLocalizer.getCategoryNameRo('shopping'), 'Cumpărături');
      expect(CategoryLocalizer.getCategoryNameRo('salary'), 'Salariu');
      expect(CategoryLocalizer.getCategoryNameRo('investments'), 'Investiții');
      expect(CategoryLocalizer.getCategoryNameRo('gifts'), 'Cadouri');
      expect(CategoryLocalizer.getCategoryNameRo('coffee'), 'Cafea & Ceai');
      expect(CategoryLocalizer.getCategoryNameRo('restaurant'), 'Restaurante & Localuri');
      expect(CategoryLocalizer.getCategoryNameRo('pets'), 'Îngrijire Animale');
      expect(CategoryLocalizer.getCategoryNameRo('subscription'), 'Abonamente & Servicii');
      expect(CategoryLocalizer.getCategoryNameRo('other'), 'Altele');
      expect(CategoryLocalizer.getCategoryNameRo('credit'), 'Rate & Credite');
      expect(CategoryLocalizer.getCategoryNameRo('groceries'), 'Cumpărături Casnice');
      expect(CategoryLocalizer.getCategoryNameRo('meal_tickets'), 'Bonuri de Masă');
      expect(CategoryLocalizer.getCategoryNameRo('side_hustle'), 'Proiecte Extra');
      expect(CategoryLocalizer.getCategoryNameRo('clothing'), 'Îmbrăcăminte');
      expect(CategoryLocalizer.getCategoryNameRo('healthcare'), 'Sănătate & Farmacii');
      expect(CategoryLocalizer.getCategoryNameRo('gadgets'), 'Electronice & IT');
      expect(CategoryLocalizer.getCategoryNameRo('travel'), 'Călătorii & Vacanțe');
      expect(CategoryLocalizer.getCategoryNameRo('personal_care'), 'Îngrijire Personală');
      expect(CategoryLocalizer.getCategoryNameRo('education'), 'Educație & Dezvoltare');
      expect(CategoryLocalizer.getCategoryNameRo('Custom Item'), 'Custom Item');
    });

    testWidgets('getLocalizedName maps correctly using BuildContext', (WidgetTester tester) async {
      late String foodEn;
      late String foodRo;
      late String customResult;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              foodEn = CategoryLocalizer.getLocalizedName(context, 'food');
              customResult = CategoryLocalizer.getLocalizedName(context, 'Custom Name');
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foodEn, isNotEmpty);
      expect(customResult, 'Custom Name');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ro'),
          home: Builder(
            builder: (context) {
              foodRo = CategoryLocalizer.getLocalizedName(context, 'food');
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foodRo, isNotEmpty);
    });
  });
}
