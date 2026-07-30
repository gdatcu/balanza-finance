import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/core/utils/notification_parser.dart';

void main() {
  group('NotificationParser - Hybrid Multi-Bank & Catch-All Engine Tests', () {
    test('Parses Revolut expense correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'com.revolut.office',
        title: 'Revolut',
        body: 'Spent RON 45.00 at Starbucks.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 45.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'Starbucks');
      expect(res.isIncome, false);
      expect(res.categoryId, isNotNull);
    });

    test('Parses Revolut currency-prefixed income correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'com.revolut.office',
        title: 'Revolut',
        body: 'You received RON10 Payment received from Datcu George Cristian.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 10.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'Datcu George Cristian');
      expect(res.isIncome, true);
    });

    test('Parses BCR transfer sent correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'ro.bcr.georgego',
        title: 'Info plati',
        body: '💸 Ai trimis 10 RON din contul George Standard catre George Datcu in 29/07/2026',
      );
      expect(res, isNotNull);
      expect(res!.amount, 10.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'George Datcu');
      expect(res.isIncome, false);
    });

    test('Parses BCR income received correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'ro.bcr.georgego',
        title: 'Info incasari',
        body: 'Ai primit 250.00 RON de la Popescu Ion in 28/07/2026',
      );
      expect(res, isNotNull);
      expect(res!.amount, 250.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'Popescu Ion');
      expect(res.isIncome, true);
    });

    test('Parses ING HomeBank POS expense correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'ro.ing.mobile.banking',
        title: 'Plata card',
        body: 'Plata cu cardul in valoare de 38.00 RON la STRADALE',
      );
      expect(res, isNotNull);
      expect(res!.amount, 38.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'STRADALE');
      expect(res.isIncome, false);
      expect(res.categoryId, isNotNull);
    });

    test('Parses ING HomeBank IBAN transfer received correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'ro.ing.mobile.banking',
        title: 'Incasare',
        body: 'Incasare 1500 RON de la ANEXA',
      );
      expect(res, isNotNull);
      expect(res!.amount, 1500.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'ANEXA');
      expect(res.isIncome, true);
    });

    test('Parses Google Wallet payment correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        title: 'Starbucks',
        body: 'Plată de 22,00 RON',
      );
      expect(res, isNotNull);
      expect(res!.amount, 22.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'Starbucks');
      expect(res.isIncome, false);
    });

    test('Parses Salt Bank POS payment correctly', () {
      final res = NotificationParser.parseNotification(
        packageName: 'ro.salt.bank',
        title: 'Salt Bank',
        body: 'Plata 51 RON la Pranzo',
      );
      expect(res, isNotNull);
      expect(res!.amount, 51.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'Pranzo');
      expect(res.isIncome, false);
    });

    test('Parses BT Pay payment via generic fallback', () {
      final res = NotificationParser.parseNotification(
        packageName: 'com.bancatransilvania.bft',
        title: 'BT Pay',
        body: 'Ai platit 15 RON la Kaufland',
      );
      expect(res, isNotNull);
      expect(res!.amount, 15.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'Kaufland');
      expect(res.isIncome, false);
    });

    test('Universal Financial Catch-All Engine extracts unknown notification format without dropping', () {
      final res = NotificationParser.parseNotification(
        packageName: 'com.unknown.bank',
        title: 'Notificare Tranzactie',
        body: 'Confirmat transfer intern 400.00 RON procesat cu succes',
      );
      expect(res, isNotNull);
      expect(res!.amount, 400.0);
      expect(res.currency, 'RON');
      expect(res.merchant, 'Notificare Tranzactie');
    });
  });
}
