import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/core/utils/notification_parser.dart';

void main() {
  group('NotificationParser Unit Tests', () {
    test('removeDiacritics cleans Romanian & European characters', () {
      expect(NotificationParser.removeDiacritics('Plată la Cumpărături în Chișinău'), 'Plata la Cumparaturi in Chisinau');
      expect(NotificationParser.removeDiacritics('Ștefan cel Mare & Țara Românească'), 'Stefan cel Mare & Tara Romaneasca');
    });

    test('normalizeString collapses multiple spaces and newlines', () {
      expect(NotificationParser.normalizeString('Plata   \n   de  50 RON \n  la   Mega Image  '), 'Plata de 50 RON la Mega Image');
    });

    test('parseFinancialAmount correctly parses European and US formats', () {
      expect(NotificationParser.parseFinancialAmount('1.250,50'), equals(1250.50));
      expect(NotificationParser.parseFinancialAmount('1,250.50'), equals(1250.50));
      expect(NotificationParser.parseFinancialAmount('75,00'), equals(75.00));
      expect(NotificationParser.parseFinancialAmount('100.25'), equals(100.25));
      expect(NotificationParser.parseFinancialAmount(' 50 '), equals(50.00));
      expect(NotificationParser.parseFinancialAmount('invalid'), isNull);
    });

    test('parseNotification parses Revolut notification (EN/RO)', () {
      final resEn = NotificationParser.parseNotification(
        packageName: 'com.revolut.office',
        title: 'Revolut',
        body: 'You spent 125.50 RON at Starbucks. Sold: 450 RON',
      );
      expect(resEn, isNotNull);
      expect(resEn!.amount, equals(125.50));
      expect(resEn.currency, equals('RON'));
      expect(resEn.merchant, equals('Starbucks'));

      final resRo = NotificationParser.parseNotification(
        packageName: 'com.revolut.office',
        title: 'Revolut',
        body: 'Ai cheltuit 45,00 LEI la Carrefour Express pe 29 Iul.',
      );
      expect(resRo, isNotNull);
      expect(resRo!.amount, equals(45.00));
      expect(resRo.currency, equals('RON'));
      expect(resRo.merchant, equals('Carrefour Express'));
    });

    test('parseNotification parses BCR George notification', () {
      final res = NotificationParser.parseNotification(
        packageName: 'ro.bcr.georgego',
        title: 'George BCR',
        body: 'Plata cu cardul - 89.90 RON la Kaufland din contul RO123.',
      );
      expect(res, isNotNull);
      expect(res!.amount, equals(89.90));
      expect(res.currency, equals('RON'));
      expect(res.merchant, equals('Kaufland'));
    });

    test('parseNotification parses Google Wallet notification', () {
      final res = NotificationParser.parseNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        title: 'Uber Eats',
        body: 'Plata de 65,00 RON a fost efectuata cu succes.',
      );
      expect(res, isNotNull);
      expect(res!.amount, equals(65.00));
      expect(res.currency, equals('RON'));
      expect(res.merchant, equals('Uber Eats'));
    });

    test('parseNotification parses ING & Salt Bank notifications', () {
      final ingRes = NotificationParser.parseNotification(
        packageName: 'ro.ing.mobile.banking',
        title: 'ING Bank',
        body: 'Plata POS 150,00 RON la EMAG. Sold: 2000 RON.',
      );
      expect(ingRes, isNotNull);
      expect(ingRes!.amount, equals(150.00));
      expect(ingRes.merchant, equals('EMAG'));

      final saltRes = NotificationParser.parseNotification(
        packageName: 'ro.salt.bank',
        title: 'Salt Bank',
        body: 'Ai platit 35.00 RON la 5 To Go. Sold: 500 RON.',
      );
      expect(saltRes, isNotNull);
      expect(saltRes!.amount, equals(35.00));
      expect(saltRes.merchant, equals('5 To Go'));
    });

    test('parseNotification returns null when regex fails to match amount/merchant', () {
      final invalidRes = NotificationParser.parseNotification(
        packageName: 'com.revolut.office',
        title: 'Revolut',
        body: 'Welcome to your security update.',
      );
      expect(invalidRes, isNull);
    });
  });
}
