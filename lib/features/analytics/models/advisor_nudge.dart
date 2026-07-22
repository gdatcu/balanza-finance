import 'package:flutter/material.dart';

enum NudgeSeverity {
  safe,
  warning,
  alert,
  info,
}

class AdvisorNudge {
  final String id;
  final String categoryName;
  final IconData icon;
  final String textEn;
  final String textRo;
  final NudgeSeverity severity;

  const AdvisorNudge({
    required this.id,
    required this.categoryName,
    required this.icon,
    required this.textEn,
    required this.textRo,
    this.severity = NudgeSeverity.info,
  });

  String getLocalizedText(String languageCode) {
    return languageCode == 'ro' ? textRo : textEn;
  }
}
