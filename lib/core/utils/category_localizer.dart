import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class CategoryLocalizer {
  static String getLocalizedName(BuildContext context, String name) {
    final localizations = AppLocalizations.of(context)!;
    switch (name.toLowerCase()) {
      case 'food':
        return localizations.categoryFood;
      case 'transport':
        return localizations.categoryTransport;
      case 'rent':
        return localizations.categoryRent;
      case 'utilities':
        return localizations.categoryUtilities;
      case 'entertainment':
        return localizations.categoryEntertainment;
      case 'shopping':
        return localizations.categoryShopping;
      case 'salary':
        return localizations.categorySalary;
      case 'investments':
        return localizations.categoryInvestments;
      case 'gifts':
        return localizations.categoryGifts;
      case 'coffee_tea':
      case 'coffee & tea':
      case 'coffee':
        return localizations.categoryCoffeeTea;
      case 'restaurants':
      case 'restaurants & dining':
      case 'restaurant':
        return localizations.categoryRestaurants;
      case 'pet_care':
      case 'pet care':
      case 'pets':
        return localizations.categoryPetCare;
      case 'subscriptions':
      case 'subscription':
        return localizations.categorySubscriptions;
      case 'other':
        return localizations.categoryOther;
      default:
        return name;
    }
  }
}
