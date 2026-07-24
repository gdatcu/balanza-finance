import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class CategoryLocalizer {
  static String getCategoryNameEn(String name) {
    switch (name.toLowerCase()) {
      case 'food':
        return 'Food & Dining';
      case 'transport':
        return 'Transport';
      case 'rent':
        return 'Rent';
      case 'utilities':
        return 'Utilities & Bills';
      case 'entertainment':
        return 'Entertainment';
      case 'shopping':
        return 'Shopping';
      case 'salary':
        return 'Salary';
      case 'investments':
        return 'Investments';
      case 'gifts':
        return 'Gifts';
      case 'coffee_tea':
      case 'coffee & tea':
      case 'coffee':
        return 'Coffee & Tea';
      case 'restaurants':
      case 'restaurants & dining':
      case 'restaurant':
        return 'Restaurants & Dining';
      case 'pet_care':
      case 'pet care':
      case 'pets':
        return 'Pet Care';
      case 'subscriptions':
      case 'subscription':
        return 'Subscriptions';
      case 'other':
        return 'Other';
      case 'credit_installments':
      case 'credit & loans':
      case 'credit':
      case 'rate & credite':
        return 'Credit & Loans';
      case 'groceries':
      case 'cumpărături casnice':
      case 'cumparaturi casnice':
        return 'Groceries';
      case 'meal_tickets':
      case 'meal tickets':
      case 'bonuri de masă':
      case 'bonuri de masa':
        return 'Meal Tickets';
      case 'side_hustle':
      case 'side hustle':
      case 'side hustle / extra':
      case 'proiecte extra':
        return 'Side Hustle / Extra';
      case 'clothing':
      case 'clothing & fashion':
      case 'îmbrăcăminte':
      case 'imbracaminte':
        return 'Clothing & Fashion';
      case 'healthcare':
      case 'health & medical':
      case 'sănătate & farmacii':
      case 'sanatate & farmacii':
        return 'Health & Medical';
      case 'gadgets':
      case 'gadgets & tech':
      case 'electronice & it':
        return 'Gadgets & Tech';
      case 'travel':
      case 'travel & holidays':
      case 'călătorii & vacanțe':
      case 'calatorii & vacante':
        return 'Travel & Holidays';
      case 'personal_care':
      case 'personal care':
      case 'îngrijire personală':
      case 'ingrijire personala':
        return 'Personal Care';
      case 'education':
      case 'educație & dezvoltare':
      case 'educatie & dezvoltare':
        return 'Education';
      default:
        return name;
    }
  }

  static String getCategoryNameRo(String name) {
    switch (name.toLowerCase()) {
      case 'food':
        return 'Mâncare';
      case 'transport':
      case 'transport & auto':
        return 'Transport & Auto';
      case 'rent':
        return 'Chirie';
      case 'utilities':
        return 'Utilități';
      case 'entertainment':
      case 'divertisment & cultură':
      case 'divertisment & cultura':
        return 'Divertisment & Cultură';
      case 'shopping':
        return 'Cumpărături';
      case 'salary':
        return 'Salariu';
      case 'investments':
        return 'Investiții';
      case 'gifts':
        return 'Cadouri';
      case 'coffee_tea':
      case 'coffee & tea':
      case 'coffee':
        return 'Cafea & Ceai';
      case 'restaurants':
      case 'restaurants & dining':
      case 'restaurant':
        return 'Restaurante & Localuri';
      case 'pet_care':
      case 'pet care':
      case 'pets':
        return 'Îngrijire Animale';
      case 'subscriptions':
      case 'subscription':
        return 'Abonamente & Servicii';
      case 'other':
        return 'Altele';
      case 'credit_installments':
      case 'credit & loans':
      case 'credit':
      case 'rate & credite':
        return 'Rate & Credite';
      case 'groceries':
      case 'cumpărături casnice':
      case 'cumparaturi casnice':
        return 'Cumpărături Casnice';
      case 'meal_tickets':
      case 'meal tickets':
      case 'bonuri de masă':
      case 'bonuri de masa':
        return 'Bonuri de Masă';
      case 'side_hustle':
      case 'side hustle':
      case 'side hustle / extra':
      case 'proiecte extra':
        return 'Proiecte Extra';
      case 'clothing':
      case 'clothing & fashion':
      case 'îmbrăcăminte':
      case 'imbracaminte':
        return 'Îmbrăcăminte';
      case 'healthcare':
      case 'health & medical':
      case 'sănătate & farmacii':
      case 'sanatate & farmacii':
        return 'Sănătate & Farmacii';
      case 'gadgets':
      case 'gadgets & tech':
      case 'electronice & it':
        return 'Electronice & IT';
      case 'travel':
      case 'travel & holidays':
      case 'călătorii & vacanțe':
      case 'calatorii & vacante':
        return 'Călătorii & Vacanțe';
      case 'personal_care':
      case 'personal care':
      case 'îngrijire personală':
      case 'ingrijire personala':
        return 'Îngrijire Personală';
      case 'education':
      case 'educație & dezvoltare':
      case 'educatie & dezvoltare':
        return 'Educație & Dezvoltare';
      default:
        return name;
    }
  }

  static String getLocalizedName(BuildContext context, String name) {
    final localizations = AppLocalizations.of(context)!;
    switch (name.toLowerCase()) {
      case 'food':
        return localizations.categoryFood;
      case 'transport':
      case 'transport & auto':
        return localizations.categoryTransport;
      case 'rent':
        return localizations.categoryRent;
      case 'utilities':
        return localizations.categoryUtilities;
      case 'entertainment':
      case 'divertisment & cultură':
      case 'divertisment & cultura':
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
      case 'credit_installments':
      case 'credit & loans':
      case 'credit':
      case 'rate & credite':
        return localizations.categoryCreditInstallments;
      case 'groceries':
      case 'cumpărături casnice':
      case 'cumparaturi casnice':
        return localizations.categoryGroceries;
      case 'meal_tickets':
      case 'meal tickets':
      case 'bonuri de masă':
      case 'bonuri de masa':
        return localizations.categoryMealTickets;
      case 'side_hustle':
      case 'side hustle':
      case 'side hustle / extra':
      case 'proiecte extra':
        return localizations.categorySideHustle;
      case 'clothing':
      case 'clothing & fashion':
      case 'îmbrăcăminte':
      case 'imbracaminte':
        return localizations.categoryClothing;
      case 'healthcare':
      case 'health & medical':
      case 'sănătate & farmacii':
      case 'sanatate & farmacii':
        return localizations.categoryHealthcare;
      case 'gadgets':
      case 'gadgets & tech':
      case 'electronice & it':
        return localizations.categoryGadgets;
      case 'travel':
      case 'travel & holidays':
      case 'călătorii & vacanțe':
      case 'calatorii & vacante':
        return localizations.categoryTravel;
      case 'personal_care':
      case 'personal care':
      case 'îngrijire personală':
      case 'ingrijire personala':
        return localizations.categoryPersonalCare;
      case 'education':
      case 'educație & dezvoltare':
      case 'educatie & dezvoltare':
        return localizations.categoryEducation;
      default:
        return name;
    }
  }
}
