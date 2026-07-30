import '../../features/transactions/utils/transaction_parser.dart';
import '../../models/tagging_rule.dart';
import 'default_tagging_rules.dart';

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
        r'(?:spent|paid|ai cheltuit|ai platit)\s+(?:RON|EUR|LEI|USD|GBP)?\s*([\d.,\s]+)\s*(RON|EUR|LEI|USD|GBP)?\s+(?:at|to|la)\s+(.*?)(?=\s*sold|\s*pe\s+\d{1,2}|\.$|$)',
        caseSensitive: false,
      );
      final revIncomeRegex = RegExp(
        r'(?:ai primit|you received|received|payment received)\s+(?:RON|EUR|LEI|USD|GBP)?\s*([\d.,\s]+)?\s*(RON|EUR|LEI|USD|GBP)?.*?(?:de la|from)\s+(.*?)(?=\s*in contul|\.|\.$|$)',
        caseSensitive: false,
      );

      final expMatch = revExpenseRegex.firstMatch(combined);
      if (expMatch != null) {
        rawAmount = expMatch.group(1);
        currency = (expMatch.group(2) ?? 'RON').toUpperCase();
        merchant = expMatch.group(3)?.trim();
        isIncome = false;
      } else {
        final incMatch = revIncomeRegex.firstMatch(combined);
        if (incMatch != null) {
          rawAmount = incMatch.group(1);
          if (rawAmount == null || rawAmount.isEmpty) {
            final amtMatch = RegExp(r'([\d.,]+)\s*(RON|EUR|LEI|USD|GBP)|(RON|EUR|LEI|USD|GBP)\s*([\d.,]+)', caseSensitive: false).firstMatch(combined);
            if (amtMatch != null) {
              rawAmount = amtMatch.group(1) ?? amtMatch.group(4);
              currency = (amtMatch.group(2) ?? amtMatch.group(3) ?? 'RON').toUpperCase();
            }
          } else {
            currency = (incMatch.group(2) ?? 'RON').toUpperCase();
          }
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
        r'(?:plata|cumparare|pos|ai platit|ai trimis|info plati).*?-?\s*([\d.,\s]+)\s*(RON|LEI|EUR)\s+(?:la|catre|din contul.*?\s+catre)\s+(.*?)(?=\s+in\s+\d{1,2}\/|\s*din contul|\s*sold|\.$|$)',
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
        r'(?:ai primit|incasare|received|transfer de la)\s+(?:RON|LEI|EUR|USD|GBP)?\s*([\d.,\s]+)\s*(RON|LEI|EUR|USD|GBP)?\s+(?:de la|from)\s+([A-Za-z0-9\s._-]+)',
        caseSensitive: false,
      );
      final genericExpenseRegex = RegExp(
        r'(?:plata|cumparare|paid|spent|ai platit|ai trimis)?\s*([\d.,\s]+)\s*(RON|LEI|EUR|USD|GBP)\s+(?:la|at|catre|to)\s+([A-Za-z0-9\s._-]+)',
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

    // 7. Universal Financial Catch-All Engine (Zero-Drop Guarantee)
    if (rawAmount == null || merchant == null || merchant.isEmpty) {
      final amountRegex = RegExp(
        r'(?:([\d]+(?:[.,][\d]{1,2})?)\s*(RON|EUR|LEI|USD|GBP))|(?:(RON|EUR|LEI|USD|GBP)\s*([\d]+(?:[.,][\d]{1,2})?))',
        caseSensitive: false,
      );

      final amtMatch = amountRegex.firstMatch(combined);
      if (amtMatch != null) {
        rawAmount = amtMatch.group(1) ?? amtMatch.group(4);
        currency = (amtMatch.group(2) ?? amtMatch.group(3) ?? 'RON').toUpperCase();

        final lower = combined.toLowerCase();
        isIncome = lower.contains('primit') ||
            lower.contains('incasare') ||
            lower.contains('received') ||
            lower.contains('from') ||
            lower.contains('de la') ||
            lower.contains('inflow') ||
            lower.contains('depus');

        if (normalizedTitle.isNotEmpty && !normalizedTitle.contains('http') && normalizedTitle.length < 40) {
          merchant = normalizedTitle;
        } else {
          merchant = _getFallbackBankName(packageName);
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
    final activeRules = (rules != null && rules.isNotEmpty) ? rules : defaultTaggingRules;
    final tagResult = TransactionParser.parseText(merchant, activeRules);
    categoryId = tagResult?.categoryId;

    if (categoryId == null) {
      if (isIncome) {
        categoryId = '00000000-0000-0000-0000-0000000000c5'; // Salary / Income
      } else {
        categoryId = '00000000-0000-0000-0000-000000000c14'; // Other / Expense
      }
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

  static String _getFallbackBankName(String packageName) {
    switch (packageName) {
      case 'com.revolut.office':
        return 'Revolut';
      case 'ro.bcr.georgego':
        return 'BCR George';
      case 'ro.ing.mobile.banking':
        return 'ING HomeBank';
      case 'ro.salt.bank':
        return 'Salt Bank';
      case 'com.google.android.apps.walletnfcrel':
      case 'com.google.android.gms':
        return 'Google Wallet';
      case 'com.bancatransilvania.bft':
      case 'ro.bancatransilvania.btpay':
        return 'BT Pay';
      case 'ro.raiffeisen.smartmobile':
        return 'Raiffeisen';
      case 'ro.cec.mobile':
        return 'CEC Bank';
      case 'ro.unicredit.mobile':
        return 'UniCredit Bank';
      case 'com.transferwise.android':
        return 'Wise';
      case 'com.curvecard':
        return 'Curve';
      default:
        return 'Bank Transaction';
    }
  }
}
