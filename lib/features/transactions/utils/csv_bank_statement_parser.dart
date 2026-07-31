import '../../../models/category.dart';
import '../../../models/tagging_rule.dart';
import 'transaction_parser.dart';

/// Representation of a parsed transaction line from a CSV bank statement.
class ParsedCsvTransaction {
  final DateTime date;
  final String description;
  final double amount; // negative for expense, positive for income
  final String currency;
  final String? categoryId;
  final String? subcategoryId;
  final String? matchedMerchant;
  final bool isIncome;

  const ParsedCsvTransaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.currency,
    this.categoryId,
    this.subcategoryId,
    this.matchedMerchant,
    required this.isIncome,
  });

  ParsedCsvTransaction copyWith({
    DateTime? date,
    String? description,
    double? amount,
    String? currency,
    String? categoryId,
    String? subcategoryId,
    String? matchedMerchant,
    bool? isIncome,
  }) {
    return ParsedCsvTransaction(
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      matchedMerchant: matchedMerchant ?? this.matchedMerchant,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}

/// Robust zero-dependency CSV parser for bank exports (ING, BT, Revolut, BCR, Raiffeisen, Universal).
class CsvBankStatementParser {
  /// Parses raw CSV content text and auto-tags each transaction against active [rules] and [categories].
  static List<ParsedCsvTransaction> parseCsvContent({
    required String rawCsv,
    required List<TaggingRule> rules,
    required List<Category> categories,
  }) {
    final lines = rawCsv.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [];

    // Auto-detect delimiter: comma or semicolon
    final firstLine = lines.first;
    final delimiter = firstLine.split(';').length > firstLine.split(',').length ? ';' : ',';

    // Tokenize lines while handling quotes
    final rows = lines.map((line) => _tokenizeRow(line, delimiter)).toList();
    if (rows.isEmpty) return [];

    // Find header index and column map
    final headerIndex = _findHeaderRowIndex(rows);
    if (headerIndex == -1 || headerIndex >= rows.length) {
      // Fallback: process rows without headers
      return _parseRowsWithoutHeader(rows, rules, categories);
    }

    final headers = rows[headerIndex].map((h) => h.toLowerCase().trim()).toList();

    int dateCol = _findColumn(headers, [
      'transaction completion date',
      'data tranzactiei',
      'data tranzactie',
      'completion date',
      'started date',
      'date',
      'data',
    ]);
    int descCol = _findColumn(headers, [
      "transaction's details",
      'transaction details',
      'details',
      'descriere',
      'description',
      'detalii',
      'detalii tranzactie',
      'merchant',
      'beneficiar',
      'narrative',
    ]);

    int debitCol = _findColumn(headers, ['debit (amount)', 'debit', 'cheltuiala', 'suma debit', 'outflow']);
    int creditCol = _findColumn(headers, ['credit (amount)', 'credit', 'venit', 'suma credit', 'inflow']);
    int amtCol = _findColumn(headers, ['amount', 'suma', 'valoare', 'suma (ron)', 'suma (eur)']);
    int currCol = _findColumn(headers, ['currency', 'moneda', 'valuta']);
    int typeCol = _findColumn(headers, ['type', 'tip', 'tip tranzactie']);

    if (dateCol == -1) dateCol = 0;
    if (descCol == -1) descCol = headers.length > 1 ? 1 : 0;

    final results = <ParsedCsvTransaction>[];

    for (int i = headerIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= dateCol || row.length <= descCol) continue;

      final rawDate = row[dateCol].trim();
      var rawDesc = row[descCol].trim();
      final rawCurr = (currCol != -1 && currCol < row.length) ? row[currCol].trim().toUpperCase() : 'RON';
      final rawType = (typeCol != -1 && typeCol < row.length) ? row[typeCol].trim().toLowerCase() : '';

      if (rawDate.isEmpty || rawDesc.isEmpty) continue;

      // Extract cleaner description if 'Locatie:' is present (e.g. BCR statements)
      if (rawDesc.contains('Locatie:')) {
        final locIndex = rawDesc.indexOf('Locatie:');
        final afterLoc = rawDesc.substring(locIndex + 8).trim();
        final endIdx = afterLoc.indexOf('. Data_Ora:');
        if (endIdx != -1) {
          rawDesc = afterLoc.substring(0, endIdx).trim();
        } else {
          rawDesc = afterLoc;
        }
      }

      // Determine amount from debit/credit columns or single amount column
      double parsedAmt = 0.0;

      if (debitCol != -1 && creditCol != -1 && row.length > debitCol && row.length > creditCol) {
        final debitStr = row[debitCol].trim();
        final creditStr = row[creditCol].trim();
        final debitVal = _parseAmount(debitStr, '');
        final creditVal = _parseAmount(creditStr, '');

        if (debitVal > 0) {
          parsedAmt = -debitVal.abs();
        } else if (creditVal > 0) {
          parsedAmt = creditVal.abs();
        }
      } else if (amtCol != -1 && row.length > amtCol) {
        final rawAmt = row[amtCol].trim();
        parsedAmt = _parseAmount(rawAmt, rawType);
      }

      if (parsedAmt == 0) continue;

      final date = _parseDate(rawDate);
      final isIncome = parsedAmt > 0;
      final currency = rawCurr.isEmpty ? 'RON' : rawCurr;

      // Auto-tag against tagging rules
      String? categoryId;
      String? subcategoryId;
      String? matchedMerchant;

      final tagResult = TransactionParser.parseText(rawDesc, rules);
      if (tagResult != null) {
        matchedMerchant = tagResult.matchedRule.keyword;
        final matchedCat = CategoryMatcher.findMatchingCategory(
          result: tagResult,
          categories: categories,
        );

        if (matchedCat.isSubcategory) {
          subcategoryId = matchedCat.id;
          categoryId = matchedCat.parentId;
        } else {
          categoryId = matchedCat.id;
          if (tagResult.subCategory != null && tagResult.subCategory!.isNotEmpty) {
            final subMatch = categories.firstWhere(
              (c) => c.parentId == categoryId && (c.name.toLowerCase() == tagResult.subCategory!.toLowerCase() || c.id == tagResult.subCategory),
              orElse: () => matchedCat,
            );
            if (subMatch.isSubcategory) {
              subcategoryId = subMatch.id;
            }
          }
        }
      }

      results.add(
        ParsedCsvTransaction(
          date: date,
          description: rawDesc,
          amount: parsedAmt,
          currency: currency,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          matchedMerchant: matchedMerchant,
          isIncome: isIncome,
        ),
      );
    }

    return results;
  }

  static List<String> _tokenizeRow(String line, String delimiter) {
    final tokens = <String>[];
    final sb = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == delimiter && !inQuotes) {
        tokens.add(sb.toString().replaceAll('"', '').trim());
        sb.clear();
      } else {
        sb.write(char);
      }
    }
    tokens.add(sb.toString().replaceAll('"', '').trim());
    return tokens;
  }

  static int _findHeaderRowIndex(List<List<String>> rows) {
    for (int i = 0; i < rows.length && i < 10; i++) {
      final line = rows[i].join(' ').toLowerCase();
      if (line.contains('date') || line.contains('data') || line.contains('amount') || line.contains('suma') || line.contains('descriere')) {
        return i;
      }
    }
    return -1;
  }

  static int _findColumn(List<String> headers, List<String> candidates) {
    for (final cand in candidates) {
      final index = headers.indexWhere((h) => h.contains(cand));
      if (index != -1) return index;
    }
    return -1;
  }

  static DateTime _parseDate(String raw) {
    final clean = raw.replaceAll('/', '-').replaceAll('.', '-');
    final parts = clean.split(RegExp(r'[\s\-T]'));
    if (parts.isEmpty) return DateTime.now();

    try {
      // Try YYYY-MM-DD
      if (parts[0].length == 4) {
        return DateTime.parse(parts[0]);
      }
      // Try DD-MM-YYYY
      if (parts.length >= 3 && parts[2].length == 4) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}

    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  static double _parseAmount(String raw, String type) {
    var clean = raw.replaceAll(' ', '').replaceAll('RON', '').replaceAll('EUR', '');
    // Handle European number formats (1.234,56 -> 1234.56)
    if (clean.contains(',') && clean.contains('.')) {
      if (clean.lastIndexOf(',') > clean.lastIndexOf('.')) {
        clean = clean.replaceAll('.', '').replaceAll(',', '.');
      } else {
        clean = clean.replaceAll(',', '');
      }
    } else if (clean.contains(',')) {
      clean = clean.replaceAll(',', '.');
    }

    final parsed = double.tryParse(clean) ?? 0.0;
    if (type.contains('cheltuiala') || type.contains('debit') || type.contains('out') || type.contains('expense')) {
      return -parsed.abs();
    }
    if (type.contains('venit') || type.contains('credit') || type.contains('in') || type.contains('income')) {
      return parsed.abs();
    }

    return parsed;
  }

  static List<ParsedCsvTransaction> _parseRowsWithoutHeader(
    List<List<String>> rows,
    List<TaggingRule> rules,
    List<Category> categories,
  ) {
    final results = <ParsedCsvTransaction>[];
    for (final row in rows) {
      if (row.length < 2) continue;
      final date = _parseDate(row[0]);
      final desc = row[1];
      final amt = row.length > 2 ? _parseAmount(row[2], '') : -10.0;
      if (amt == 0) continue;

      results.add(
        ParsedCsvTransaction(
          date: date,
          description: desc,
          amount: amt,
          currency: 'RON',
          isIncome: amt > 0,
        ),
      );
    }
    return results;
  }
}
