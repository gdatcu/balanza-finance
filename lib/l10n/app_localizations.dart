import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Balanza Finance'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal ledger with ease'**
  String get appTagline;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get byDate;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @advisor.
  ///
  /// In en, this message translates to:
  /// **'Advisor'**
  String get advisor;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @configureBudget.
  ///
  /// In en, this message translates to:
  /// **'Configure Budget'**
  String get configureBudget;

  /// No description provided for @configureBudgetHelp.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit to keep your spending in check. Charts and warning indicators will adjust to this value.'**
  String get configureBudgetHelp;

  /// No description provided for @enterBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter budget amount'**
  String get enterBudgetAmount;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimit;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get saveBudget;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilities;

  /// No description provided for @overallNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Overall Net Worth'**
  String get overallNetWorth;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @addNetWorthItem.
  ///
  /// In en, this message translates to:
  /// **'Add Net Worth Item'**
  String get addNetWorthItem;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Bank Account, Car loan)'**
  String get nameFieldLabel;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (RON)'**
  String get amountFieldLabel;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @noAssetsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No assets recorded'**
  String get noAssetsRecorded;

  /// No description provided for @noLiabilitiesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No liabilities recorded'**
  String get noLiabilitiesRecorded;

  /// No description provided for @typeAsset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get typeAsset;

  /// No description provided for @typeLiability.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get typeLiability;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @typeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get typeIncome;

  /// No description provided for @typeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get typeExpense;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get noteOptional;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseEnterValidPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get pleaseEnterValidPositiveNumber;

  /// No description provided for @transactionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully!'**
  String get transactionAddedSuccessfully;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteTransactionTitle;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get confirmDeleteTransaction;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCategoryTransactions.
  ///
  /// In en, this message translates to:
  /// **'No categories with transactions in this section.'**
  String get noCategoryTransactions;

  /// No description provided for @pleaseEnterBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a budget amount'**
  String get pleaseEnterBudgetAmount;

  /// No description provided for @budgetUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully!'**
  String get budgetUpdatedSuccessfully;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @unexpectedErrorSignIn.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during sign in.'**
  String get unexpectedErrorSignIn;

  /// No description provided for @unexpectedErrorRegistration.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during registration.'**
  String get unexpectedErrorRegistration;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Check your email for validation or sign in.'**
  String get registrationSuccessful;

  /// No description provided for @registrationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Registration submitted successfully.'**
  String get registrationSubmitted;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @financialInsight.
  ///
  /// In en, this message translates to:
  /// **'Financial Insight'**
  String get financialInsight;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get categoryInvestments;

  /// No description provided for @categoryGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryGifts;

  /// No description provided for @insightNetWorthGrew.
  ///
  /// In en, this message translates to:
  /// **'Excellent work. Your net worth grew by {amount} RON this month. Why it matters: This is the ultimate metric of financial momentum. Every positive increase means you are actively buying back your future time and building a permanent safety net.'**
  String insightNetWorthGrew(String amount);

  /// No description provided for @insightHighSurplus.
  ///
  /// In en, this message translates to:
  /// **'Outstanding! You saved {percentage}% of your income this month. Why it matters: A high savings rate creates a compounding capital surplus, buying you control over your future time.'**
  String insightHighSurplus(String percentage);

  /// No description provided for @insightHighExpenseWarning.
  ///
  /// In en, this message translates to:
  /// **'You have utilized {percentage}% of your budget. Why it matters: Small daily leaks sink great ships. Reeling in discretionary spending now prevents a deficit and keeps your wealth-building engine running.'**
  String insightHighExpenseWarning(String percentage);

  /// No description provided for @insightOnTrackBudget.
  ///
  /// In en, this message translates to:
  /// **'You are at {percentage}% of your {budget} budget. On track for a strong surplus. Why it matters: Consistently beating your budget prevents lifestyle creep and builds the cash runway needed to take calculated risks.'**
  String insightOnTrackBudget(String percentage, String budget);

  /// No description provided for @insightDefault.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking your transactions to gain control over your money. Why it matters: Consistent monitoring is the first step toward optimization and financial freedom.'**
  String get insightDefault;

  /// No description provided for @insightLoading.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your finances... Why it matters: Patience and continuous tracking are key to understanding your long-term wealth trajectory.'**
  String get insightLoading;

  /// No description provided for @incomeByCategory.
  ///
  /// In en, this message translates to:
  /// **'Income by Category'**
  String get incomeByCategory;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @noIncomeData.
  ///
  /// In en, this message translates to:
  /// **'No income data to display yet.'**
  String get noIncomeData;

  /// No description provided for @noExpenseData.
  ///
  /// In en, this message translates to:
  /// **'No expense data to display yet.'**
  String get noExpenseData;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @noIncomesYet.
  ///
  /// In en, this message translates to:
  /// **'No incomes yet'**
  String get noIncomesYet;

  /// No description provided for @noTransactionDataYet.
  ///
  /// In en, this message translates to:
  /// **'No transaction data yet'**
  String get noTransactionDataYet;

  /// No description provided for @tapToRecordFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button to record your first transaction.'**
  String get tapToRecordFirstTransaction;

  /// No description provided for @biometricAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to view your financial data'**
  String get biometricAuthReason;

  /// No description provided for @lockScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Balanza Secure Lock'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access is restricted. Please authenticate to continue.'**
  String get lockScreenSubtitle;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of Balanza Finance ({version}) is available. Would you like to download and install it now?'**
  String updateAvailableMessage(String version);

  /// No description provided for @updateInstallButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateInstallButton;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get downloadingUpdate;

  /// No description provided for @autoTaggedMessage.
  ///
  /// In en, this message translates to:
  /// **'Auto-tagged as {category} based on remote rules.'**
  String autoTaggedMessage(String category);

  /// No description provided for @categoryCoffeeTea.
  ///
  /// In en, this message translates to:
  /// **'Coffee & Tea'**
  String get categoryCoffeeTea;

  /// No description provided for @categoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants & Dining'**
  String get categoryRestaurants;

  /// No description provided for @categoryPetCare.
  ///
  /// In en, this message translates to:
  /// **'Pet Care'**
  String get categoryPetCare;

  /// No description provided for @categorySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get categorySubscriptions;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @categoryCreditInstallments.
  ///
  /// In en, this message translates to:
  /// **'Credit & Loans'**
  String get categoryCreditInstallments;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryMealTickets.
  ///
  /// In en, this message translates to:
  /// **'Meal Tickets'**
  String get categoryMealTickets;

  /// No description provided for @categorySideHustle.
  ///
  /// In en, this message translates to:
  /// **'Side Hustle / Extra'**
  String get categorySideHustle;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @transactionUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully!'**
  String get transactionUpdatedSuccessfully;

  /// No description provided for @noNote.
  ///
  /// In en, this message translates to:
  /// **'No note provided'**
  String get noNote;

  /// No description provided for @setCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Category Budget'**
  String get setCategoryBudget;

  /// No description provided for @editCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Category Budget'**
  String get editCategoryBudget;

  /// No description provided for @categoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Category Budget'**
  String get categoryBudget;

  /// No description provided for @noCategoryBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No category budgets configured yet. Set a budget to track spending pacing!'**
  String get noCategoryBudgetsYet;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget?'**
  String get deleteBudgetTitle;

  /// No description provided for @confirmDeleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this category budget limit?'**
  String get confirmDeleteBudget;

  /// No description provided for @addCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'+ Add Category Budget'**
  String get addCategoryBudget;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
