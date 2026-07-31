import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/features/transactions/utils/csv_bank_statement_parser.dart';
import 'package:balanza/core/utils/default_tagging_rules.dart';
import 'package:balanza/features/transactions/presentation/categories_data.dart';

void main() {
  group('CsvBankStatementParser Unit Tests', () {
    test('Parses Banca Transilvania (BT) CSV format and auto-tags Uber & Mega Image', () {
      const btCsv = '''Data;Descriere;Suma;Moneda
2026-07-21;UBER TRIP RIDE;22.50;RON
2026-07-20;MEGA IMAGE BUCURESTI;145.80;RON
2026-07-19;CATENA FARMACIE;64.00;RON''';

      final results = CsvBankStatementParser.parseCsvContent(
        rawCsv: btCsv,
        rules: defaultTaggingRules,
        categories: defaultCategories,
      );

      expect(results.length, 3);

      final uberTx = results.firstWhere((r) => r.description.contains('UBER'));
      expect(uberTx.amount, 22.50);
      expect(uberTx.matchedMerchant, 'uber');
      expect(uberTx.subcategoryId, '00000000-0000-0000-0000-00000000c24a'); // Rideshare & Taxi

      final megaTx = results.firstWhere((r) => r.description.contains('MEGA'));
      expect(megaTx.matchedMerchant, 'mega image');
      expect(megaTx.subcategoryId, '00000000-0000-0000-0000-000000000c16'); // Groceries

      final catenaTx = results.firstWhere((r) => r.description.contains('CATENA'));
      expect(catenaTx.matchedMerchant, 'catena');
      expect(catenaTx.subcategoryId, '00000000-0000-0000-0000-00000000c20a'); // Pharmacy
    });

    test('Parses Revolut CSV format with comma delimiters', () {
      const revolutCsv = '''Type,Product,Started Date,Completed Date,Description,Amount,Fee,Currency,State,Balance
CARD_PAYMENT,Current,2026-07-15 10:00:00,2026-07-15 10:01:00,Starbucks Coffee,-18.50,0.00,RON,COMPLETED,1250.00
CARD_PAYMENT,Current,2026-07-14 12:00:00,2026-07-14 12:01:00,Froo Market,-32.00,0.00,RON,COMPLETED,1268.50''';

      final results = CsvBankStatementParser.parseCsvContent(
        rawCsv: revolutCsv,
        rules: defaultTaggingRules,
        categories: defaultCategories,
      );

      expect(results.length, 2);
      expect(results[0].matchedMerchant, 'starbucks');
      expect(results[0].subcategoryId, '00000000-0000-0000-0000-000000000c10'); // Coffee & Tea

      expect(results[1].matchedMerchant, 'froo');
      expect(results[1].subcategoryId, '00000000-0000-0000-0000-000000000c16'); // Groceries
    });
  });
}
