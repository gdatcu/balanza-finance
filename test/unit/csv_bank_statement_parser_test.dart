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

    test('Parses BCR George CSV format with Debit/Credit columns and auto-tags Froo, Carrefour & Golden Coffe', () {
      const bcrCsv = '''Issuing date of the statement,Issuing time of the statement,Starting date,End date,Currency,BNR exchange rate,Statement issued for account,Product type,Account owner,First opening accounting balance,Transaction completion date,Transaction completion hour,Transaction's details,Operation's reference,Debit (amount),Credit (amount),Total debit (amount),Total credit (amount),Final accounting balance,Blocked amounts,Available balance,Credit lines available limit
31.07.2026,13:19,01.07.2026,21.07.2026,RON,,RO14RNCB0857129143320008,Cont GEORGE 3.0,Datcu George,0,01.07.2026,18:49,"Google Pay, Tranzactie comerciant - Tranz: Ref 902646733553. Locatie: 22328650 RO CARREFOUR MK BIRUINTEI C POPESTI LE. Data_Ora: 30-06-2026 19:05:55",Ref123,19.85,0,0,0,0,0,0,0
31.07.2026,13:19,01.07.2026,21.07.2026,RON,,RO14RNCB0857129143320008,Cont GEORGE 3.0,Datcu George,0,02.07.2026,17:01,"Google Pay, Tranzactie comerciant - Tranz: Ref 902658278402. Locatie: 05573370 RO Froo Popesti Le. Data_Ora: 01-07-2026 15:41:32",Ref124,28.26,0,0,0,0,0,0,0
31.07.2026,13:19,01.07.2026,21.07.2026,RON,,RO14RNCB0857129143320008,Cont GEORGE 3.0,Datcu George,0,10.07.2026,14:43,"Referinta 260710S966095119, Plata Instant - Transfer",Ref125,0,"8,037.01",0,0,0,0,0,0''';

      final results = CsvBankStatementParser.parseCsvContent(
        rawCsv: bcrCsv,
        rules: defaultTaggingRules,
        categories: defaultCategories,
      );

      expect(results.length, 3);

      expect(results[0].date, DateTime(2026, 7, 1));
      expect(results[0].amount, -19.85);
      expect(results[0].matchedMerchant, 'carrefour');
      expect(results[0].isInternalTransfer, isFalse);
      expect(results[0].isSelected, isTrue);

      expect(results[1].date, DateTime(2026, 7, 2));
      expect(results[1].amount, -28.26);
      expect(results[1].matchedMerchant, 'froo');
      expect(results[1].isInternalTransfer, isFalse);
      expect(results[1].isSelected, isTrue);

      expect(results[2].date, DateTime(2026, 7, 10));
      expect(results[2].amount, 8037.01);
      expect(results[2].isIncome, isTrue);
      expect(results[2].isInternalTransfer, isTrue);
      expect(results[2].isSelected, isFalse);
    });

    test('Parses ING HomeBank multi-line CSV statement with Romanian dates and sub-details', () {
      const ingCsv = '''Titular cont: DL George-cristian Datcu,,,,,,,
CNP: 1930113340434,,,,,,,
Data,,,Detalii tranzactie,Debit,,Credit,Balanta
24 iulie 2026,,,Incasare,,,"9.572,00","9.572,00"
,,,Data: 24-07-2026,,,,
,,,Ordonator:LUXOFT PROFESSIONAL ROMANIA SRL,,,,
,,,Din contul:RO98CITI0000000798993054,,,,
,,,Detalii:/ROC/AVANS IULIE2026 60641000 //RFB,,,,
10 iulie 2026,,,Cumparare POS,"102,99",,,"189,01"
,,,Data finalizarii (decontarii): 10-07-2026,,,,
,,,Numar card:**** 3984,,,,
,,,Tranzactie la:PayU*fashiondays.ro  RO  ROMANIA,,,,
10 iulie 2026,,,Transfer Home'Bank,"8.037,01",,,"0,00"
,,,Beneficiar:George Cristian Datcu,,,,
,,,In contul:RO14RNCB0857129143320008,,,,
,,,Detalii:transfer intre conturi,,,,''';

      final results = CsvBankStatementParser.parseCsvContent(
        rawCsv: ingCsv,
        rules: defaultTaggingRules,
        categories: defaultCategories,
      );

      expect(results.length, 3);

      // Luxoft Salary Income
      expect(results[0].date, DateTime(2026, 7, 24));
      expect(results[0].amount, 9572.00);
      expect(results[0].isIncome, isTrue);
      expect(results[0].matchedMerchant, 'luxoft');
      expect(results[0].categoryId, '00000000-0000-0000-0000-0000000000c5');

      // Fashion Days Shopping Expense
      expect(results[1].date, DateTime(2026, 7, 10));
      expect(results[1].amount, -102.99);
      expect(results[1].matchedMerchant, 'fashiondays');
      expect(results[1].subcategoryId, '00000000-0000-0000-0000-000000000c19');

      // Internal Transfer
      expect(results[2].date, DateTime(2026, 7, 10));
      expect(results[2].amount, -8037.01);
      expect(results[2].isInternalTransfer, isTrue);
      expect(results[2].isSelected, isFalse);
    });
  });
}
