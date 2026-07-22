import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final exchangeRateProvider = FutureProvider<double>((ref) async {
  try {
    final response = await http.get(Uri.parse('https://api.frankfurter.dev/v1/latest?from=EUR&to=RON'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      return (rates['RON'] as num).toDouble();
    }
  } catch (_) {}
  return 4.97; // Fallback rate if offline or API fails
});
