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
  final bool isInternalTransfer;
  final bool isSelected;

  const ParsedCsvTransaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.currency,
    this.categoryId,
    this.subcategoryId,
    this.matchedMerchant,
    required this.isIncome,
    this.isInternalTransfer = false,
    this.isSelected = true,
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
    bool? isInternalTransfer,
    bool? isSelected,
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
      isInternalTransfer: isInternalTransfer ?? this.isInternalTransfer,
      isSelected: isSelected ?? this.isSelected,
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
      if (row.isEmpty) continue;

      final fullRowStr = row.join(' ').toLowerCase();
      // Skip metadata header/footer lines in ING CSVs
      if (fullRowStr.contains('titular cont:') ||
          fullRowStr.contains('cnp:') ||
          fullRowStr.contains('ing bank n.v.') ||
          fullRowStr.contains('roxana petria') ||
          fullRowStr.contains('sef serviciu') ||
          fullRowStr.contains('åef serviciu')) {
        continue;
      }

      if (row.length <= dateCol || row.length <= descCol) continue;

      var rawDate = row[dateCol].trim();
      var rawDesc = row[descCol].trim();
      final rawCurr = (currCol != -1 && currCol < row.length) ? row[currCol].trim().toUpperCase() : 'RON';
      final rawType = (typeCol != -1 && typeCol < row.length) ? row[typeCol].trim().toLowerCase() : '';

      if (rawDate.isEmpty && rawDesc.isEmpty) continue;
      if (rawDate.isEmpty) continue; // Sub-row handled in parent loop

      // ING Multi-line Sub-detail aggregation
      String merchantDetail = '';
      String ordonatorDetail = '';
      String beneficiarDetail = '';
      String extraDetails = '';

      int j = i + 1;
      while (j < rows.length) {
        final nextRow = rows[j];
        if (nextRow.length > dateCol && nextRow[dateCol].trim().isNotEmpty) {
          break; // Next transaction started
        }

        final subText = nextRow.join(' ').trim();
        final lowerSub = subText.toLowerCase();

        if (lowerSub.contains('tranzactie la:')) {
          final idx = lowerSub.indexOf('tranzactie la:');
          merchantDetail = subText.substring(idx + 14).trim();
        } else if (lowerSub.contains('ordonator:')) {
          final idx = lowerSub.indexOf('ordonator:');
          ordonatorDetail = subText.substring(idx + 10).trim();
        } else if (lowerSub.contains('beneficiar:')) {
          final idx = lowerSub.indexOf('beneficiar:');
          beneficiarDetail = subText.substring(idx + 11).trim();
        } else if (lowerSub.contains('detalii:')) {
          final idx = lowerSub.indexOf('detalii:');
          extraDetails = subText.substring(idx + 8).trim();
        }

        j++;
      }

      // Advance loop index past sub-rows
      i = j - 1;

      // Construct rich aggregated description
      final descBuffer = StringBuffer(rawDesc);
      if (merchantDetail.isNotEmpty) {
        descBuffer.write(' $merchantDetail');
      }
      if (ordonatorDetail.isNotEmpty) {
        descBuffer.write(' Ordonator: $ordonatorDetail');
      }
      if (beneficiarDetail.isNotEmpty) {
        descBuffer.write(' Beneficiar: $beneficiarDetail');
      }
      if (extraDetails.isNotEmpty) {
        descBuffer.write(' $extraDetails');
      }
      rawDesc = descBuffer.toString();

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

      final isInternalTransfer = _checkIsInternalTransfer(rawDesc);

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
          isInternalTransfer: isInternalTransfer,
          isSelected: !isInternalTransfer,
        ),
      );
    }

    return results;
  }

  static bool _checkIsInternalTransfer(String desc) {
    final clean = desc.toLowerCase().replaceAll('-', ' ');

    // Revolut exchanges, top-ups & self payments
    if (clean.contains('exchanged to') ||
        clean.contains('exchanged from') ||
        clean.contains('top up') ||
        clean.contains('topup') ||
        clean.contains('vault transfer') ||
        clean.contains('schimb valutar') ||
        clean.contains('alimentare cont') ||
        clean.contains('credit card reimbursement') ||
        clean.contains('transfer intre conturi') ||
        clean.contains('transfer economii')) {
      return true;
    }

    // Revolut self-payments with truncated name (e.g. "To George-Cristia Datcu", "Payment from DATCU GEORGE CRISTIAN")
    if ((clean.contains('datcu') && clean.contains('george')) ||
        (clean.contains('datcu') && clean.contains('cristia'))) {
      return true;
    }

    // Check Payer == Beneficiary in BCR/ING/BT statements
    if (clean.contains('platitor:') && clean.contains('beneficiar:')) {
      final platitorIdx = clean.indexOf('platitor:');
      final beneficiarIdx = clean.indexOf('beneficiar:');

      if (platitorIdx != -1 && beneficiarIdx != -1 && beneficiarIdx > platitorIdx) {
        final platitorPart = clean.substring(platitorIdx + 9, beneficiarIdx);
        final beneficiarPart = clean.substring(beneficiarIdx + 11);

        final platitorName = platitorPart.split(';').first.trim();
        final beneficiarName = beneficiarPart.split(';').first.trim();

        if (platitorName.isNotEmpty && beneficiarName.isNotEmpty) {
          final pWords = platitorName.split(RegExp(r'\s+'));
          final bWords = beneficiarName.split(RegExp(r'\s+'));
          if (pWords.isNotEmpty && bWords.isNotEmpty) {
            if (pWords[0] == bWords[0] && (pWords.length == 1 || bWords.contains(pWords[1]))) {
              return true;
            }
          }
        }
      }
    }

    if (clean.contains('transfer') || clean.contains('plata instant')) {
      return true;
    }

    return false;
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

  static final Map<String, int> _roMonths = {
    'ianuarie': 1,
    'ian': 1,
    'februarie': 2,
    'feb': 2,
    'martie': 3,
    'mar': 3,
    'aprilie': 4,
    'apr': 4,
    'mai': 5,
    'iunie': 6,
    'iun': 6,
    'iulie': 7,
    'iul': 7,
    'august': 8,
    'aug': 8,
    'septembrie': 9,
    'sep': 9,
    'octombrie': 10,
    'oct': 10,
    'noiembrie': 11,
    'noi': 11,
    'decembrie': 12,
    'dec': 12,
  };

  static DateTime _parseDate(String raw) {
    final lower = raw.trim().toLowerCase();

    // Check for Romanian month names (e.g. "24 iulie 2026", "10 iulie 2026")
    for (final entry in _roMonths.entries) {
      if (lower.contains(entry.key)) {
        final parts = lower.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]);
          final year = int.tryParse(parts[2]);
          if (day != null && year != null) {
            return DateTime(year, entry.value, day);
          }
        }
      }
    }

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
