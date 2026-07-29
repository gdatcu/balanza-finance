import '../../features/transactions/utils/transaction_parser.dart';
import '../../models/tagging_rule.dart';

class ParsedBankNotification {
  final double amount;
  final String currency;
  final String merchant;
  final String packageName;
  final String? categoryId;
  final bool isIncome;

  const ParsedBankNotification({
    required this.amount,
    required this.currency,
    required this.merchant,
    required this.packageName,
    this.categoryId,
    this.isIncome = false,
  });
}

class NotificationParser {
  /// Removes diacritics from strings (e.g. ă->a, ș->s, ț->t, â->a, î->i)
  static String removeDiacritics(String input) {
    var str = input;
    const map = {
      'ă': 'a', 'Ă': 'A',
      'â': 'a', 'Â': 'A',
      'î': 'i', 'Î': 'I',
      'ș': 's', 'Ș': 'S',
      'ş': 's', 'Ş': 'S',
      'ț': 't', 'Ț': 'T',
      'ţ': 't', 'Ţ': 'T',
      'é': 'e', 'è': 'e', 'ê': 'e',
      'ö': 'o', 'ó': 'o', 'ő': 'o',
      'ü': 'u', 'ú': 'u', 'ű': 'u',
    };
    map.forEach((key, val) {
      str = str.replaceAll(key, val);
    });
    return str;
  }

  /// Normalizes input string: removes diacritics and replaces multiple spaces/newlines with a single space.
  static String normalizeString(String input) {
    final clean = removeDiacritics(input);
    return clean.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Financial amount cleaner utility
  /// Detects European formatting (1.250,50) vs US formatting (1,250.50)
  static double? parseFinancialAmount(String raw) {
    final cleaned = raw.replaceAll(' ', '').trim();
    if (cleaned.isEmpty) return null;

    final lastDot = cleaned.lastIndexOf('.');
    final lastComma = cleaned.lastIndexOf(',');

    String normalized;
    if (lastComma != -1 && lastComma > lastDot) {
      // European format: 1.250,50 -> remove dots, replace comma with dot
      normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (lastDot != -1 && lastDot > lastComma) {
      // US format: 1,250.50 -> remove commas
      normalized = cleaned.replaceAll(',', '');
    } else if (lastComma != -1 && lastDot == -1) {
      // Simple decimal comma: 75,50 -> 75.50
      normalized = cleaned.replaceAll(',', '.');
    } else {
      normalized = cleaned;
    }

    final parsed = double.tryParse(normalized);
    return parsed?.abs();
  }

  /// Parses banking app notifications into structured financial data
  static ParsedBankNotification? parseNotification({
    required String packageName,
    required String title,
    required String body,
    List<TaggingRule>? rules,
  }) {
    final normalizedTitle = normalizeString(title);
    final normalizedBody = normalizeString(body);
    final combined = '$normalizedTitle $normalizedBody';

    String? rawAmount;
    String currency = 'RON';
    String? merchant;
    bool isIncome = false;

    // 1. Revolut (com.revolut.office)
    if (packageName == 'com.revolut.office') {
      final revExpenseRegex = RegExp(
        r'(?:spent|ai cheltuit)\s+([\d.,\s]+)\s*(RON|EUR|LEI|USD|GBP)\s+(?:at|la)\s+(.*?)(?=\s*sold|\s*pe\s+\d{1,2}|\.$|$)',
        caseSensitive: false,
      );
      final revIncomeRegex = RegExp(
        r'(?:ai primit|you received|received)\s+([\d.,\s]+)\s*(RON|EUR|LEI|USD|GBP)\s+(?:de la|from)\s+(.*?)(?=\s*in contul|\.$|$)',
        caseSensitive: false,
      );

      final expMatch = revExpenseRegex.firstMatch(combined);
      if (expMatch != null) {
        rawAmount = expMatch.group(1);
        currency = expMatch.group(2)?.toUpperCase() ?? 'RON';
        merchant = expMatch.group(3)?.trim();
        isIncome = false;
      } else {
        final incMatch = revIncomeRegex.firstMatch(combined);
        if (incMatch != null) {
          rawAmount = incMatch.group(1);
          currency = incMatch.group(2)?.toUpperCase() ?? 'RON';
          merchant = incMatch.group(3)?.trim();
          isIncome = true;
        }
      }
    }

    // 2. BCR George (ro.bcr.georgego)
    if (merchant == null && packageName == 'ro.bcr.georgego') {
      final bcrIncomeRegex = RegExp(
        r'(?:ai primit|incasare|info incasari)\s+.*?([\d.,\s]+)\s*(RON|LEI|EUR)\s+(?:in contul.*?\s+de la|de la)\s+(.*?)(?=\s+in\s+\d{1,2}\/|\s*sold|\.$|$)',
        caseSensitive: false,
      );
      final bcrExpenseRegex = RegExp(
        r'(?:plata|cumparare|pos|ai platit).*?-?\s*([\d.,\s]+)\s*(RON|LEI|EUR)\s+la\s+(.*?)(?=\s*din contul|\s*sold|\.$|$)',
        caseSensitive: false,
      );

      final incMatch = bcrIncomeRegex.firstMatch(combined);
      if (incMatch != null) {
        rawAmount = incMatch.group(1);
        currency = incMatch.group(2)?.toUpperCase() ?? 'RON';
        merchant = incMatch.group(3)?.trim();
        isIncome = true;
      } else {
        final expMatch = bcrExpenseRegex.firstMatch(combined);
        if (expMatch != null) {
          rawAmount = expMatch.group(1);
          currency = expMatch.group(2)?.toUpperCase() ?? 'RON';
          merchant = expMatch.group(3)?.trim();
          isIncome = false;
        }
      }
    }

    // 3. Google Wallet (com.google.android.apps.walletnfcrel)
    if (merchant == null && packageName == 'com.google.android.apps.walletnfcrel') {
      final walletRegex = RegExp(
        r'(?:plata de|payment of|suma de)\s+([\d.,\s]+)\s*(RON|LEI|EUR)',
        caseSensitive: false,
      );
      final match = walletRegex.firstMatch(normalizedBody);
      if (match != null) {
        rawAmount = match.group(1);
        currency = match.group(2)?.toUpperCase() ?? 'RON';
        merchant = normalizedTitle.isNotEmpty ? normalizedTitle : 'Google Wallet Merchant';
        isIncome = false;
      }
    }

    // 4. ING Mobile Banking (ro.ing.mobile.banking)
    if (merchant == null && packageName == 'ro.ing.mobile.banking') {
      final ingIncomeRegex = RegExp(
        r'(?:incasare|ai primit)\s+.*?([\d.,\s]+)\s*(RON|LEI|EUR)\s+de la\s+(.*?)(?=\s*sold|\.$|$)',
        caseSensitive: false,
      );
      final ingExpenseRegex = RegExp(
        r'(?:plata|cumparare|pos)\s+.*?([\d.,\s]+)\s*(RON|LEI|EUR)\s+la\s+(.*?)(?=\s*sold|\.$|$)',
        caseSensitive: false,
      );

      final incMatch = ingIncomeRegex.firstMatch(combined);
      if (incMatch != null) {
        rawAmount = incMatch.group(1);
        currency = incMatch.group(2)?.toUpperCase() ?? 'RON';
        merchant = incMatch.group(3)?.trim();
        isIncome = true;
      } else {
        final expMatch = ingExpenseRegex.firstMatch(combined);
        if (expMatch != null) {
          rawAmount = expMatch.group(1);
          currency = expMatch.group(2)?.toUpperCase() ?? 'RON';
          merchant = expMatch.group(3)?.trim();
          isIncome = false;
        }
      }
    }

    // 5. Salt Bank (ro.salt.bank)
    if (merchant == null && packageName == 'ro.salt.bank') {
      final saltIncomeRegex = RegExp(
        r'(?:incasare|ai primit)\s+([\d.,\s]+)\s*(RON|LEI|EUR)\s+de la\s+(.*?)(?=\s*sold|\.$|$)',
        caseSensitive: false,
      );
      final saltExpenseRegex = RegExp(
        r'(?:plata|tranzactie|ai platit)\s+([\d.,\s]+)\s*(RON|LEI|EUR)\s+la\s+(.*?)(?=\s*sold|\.$|$)',
        caseSensitive: false,
      );

      final incMatch = saltIncomeRegex.firstMatch(combined);
      if (incMatch != null) {
        rawAmount = incMatch.group(1);
        currency = incMatch.group(2)?.toUpperCase() ?? 'RON';
        merchant = incMatch.group(3)?.trim();
        isIncome = true;
      } else {
        final expMatch = saltExpenseRegex.firstMatch(combined);
        if (expMatch != null) {
          rawAmount = expMatch.group(1);
          currency = expMatch.group(2)?.toUpperCase() ?? 'RON';
          merchant = expMatch.group(3)?.trim();
          isIncome = false;
        }
      }
    }

    // 6. Generic Fallback Regex for allowed bank packages
    if (merchant == null) {
      final genericIncomeRegex = RegExp(
        r'(?:ai primit|incasare|received)\s+([\d.,\s]+)\s*(RON|LEI|EUR|USD)\s+(?:de la|from)\s+([A-Za-z0-9\s._-]+)',
        caseSensitive: false,
      );
      final genericExpenseRegex = RegExp(
        r'([\d.,\s]+)\s*(RON|LEI|EUR|USD)\s+(?:la|at)\s+([A-Za-z0-9\s._-]+)',
        caseSensitive: false,
      );

      final incMatch = genericIncomeRegex.firstMatch(combined);
      if (incMatch != null) {
        rawAmount = incMatch.group(1);
        currency = incMatch.group(2)?.toUpperCase() ?? 'RON';
        merchant = incMatch.group(3)?.trim();
        isIncome = true;
      } else {
        final expMatch = genericExpenseRegex.firstMatch(combined);
        if (expMatch != null) {
          rawAmount = expMatch.group(1);
          currency = expMatch.group(2)?.toUpperCase() ?? 'RON';
          merchant = expMatch.group(3)?.trim();
          isIncome = false;
        }
      }
    }

    if (rawAmount == null || merchant == null || merchant.isEmpty) {
      return null;
    }

    // Clean trailing dots or punctuation from merchant name
    merchant = merchant.replaceAll(RegExp(r'[.\s]+$'), '').trim();
    if (merchant.isEmpty) return null;

    final double? parsedAmount = parseFinancialAmount(rawAmount);
    if (parsedAmount == null || parsedAmount <= 0) {
      return null;
    }

    if (currency == 'LEI') currency = 'RON';

    // Auto-Tagging Merchant
    String? categoryId;
    if (rules != null && rules.isNotEmpty) {
      final tagResult = TransactionParser.parseText(merchant, rules);
      categoryId = tagResult?.categoryId;
    }

    return ParsedBankNotification(
      amount: parsedAmount,
      currency: currency,
      merchant: merchant,
      packageName: packageName,
      categoryId: categoryId,
      isIncome: isIncome,
    );
  }
}
