// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Balanza Finance';

  @override
  String get appTagline => 'Manage your personal ledger with ease';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get budgets => 'Budgets';

  @override
  String get byDate => 'By Date';

  @override
  String get byCategory => 'By Category';

  @override
  String get overview => 'Overview';

  @override
  String get advisor => 'Advisor';

  @override
  String get settings => 'Settings';

  @override
  String get configureBudget => 'Configure Budget';

  @override
  String get configureBudgetHelp =>
      'Set a monthly limit to keep your spending in check. Charts and warning indicators will adjust to this value.';

  @override
  String get enterBudgetAmount => 'Enter budget amount';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get saveBudget => 'Save Budget';

  @override
  String get logOut => 'Log Out';

  @override
  String get language => 'Language';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get assets => 'Assets';

  @override
  String get liabilities => 'Liabilities';

  @override
  String get overallNetWorth => 'Overall Net Worth';

  @override
  String get totalAssets => 'Total Assets';

  @override
  String get addNetWorthItem => 'Add Net Worth Item';

  @override
  String get name => 'Name';

  @override
  String get nameFieldLabel => 'Name (e.g. Bank Account, Car loan)';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get amount => 'Amount';

  @override
  String get amountFieldLabel => 'Amount (RON)';

  @override
  String get addItem => 'Add Item';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get confirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get noAssetsRecorded => 'No assets recorded';

  @override
  String get noLiabilitiesRecorded => 'No liabilities recorded';

  @override
  String get typeAsset => 'Asset';

  @override
  String get typeLiability => 'Liability';

  @override
  String get type => 'Type';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeExpense => 'Expense';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get spent => 'Spent';

  @override
  String get noteOptional => 'Note (Optional)';

  @override
  String get date => 'Date';

  @override
  String get category => 'Category';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Please enter a valid positive number';

  @override
  String get transactionAddedSuccessfully => 'Transaction added successfully!';

  @override
  String get deleteTransactionTitle => 'Delete Transaction?';

  @override
  String get confirmDeleteTransaction =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get retry => 'Retry';

  @override
  String get noCategoryTransactions =>
      'No categories with transactions in this section.';

  @override
  String get pleaseEnterBudgetAmount => 'Please enter a budget amount';

  @override
  String get budgetUpdatedSuccessfully => 'Budget updated successfully!';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get unexpectedErrorSignIn =>
      'An unexpected error occurred during sign in.';

  @override
  String get unexpectedErrorRegistration =>
      'An unexpected error occurred during registration.';

  @override
  String get registrationSuccessful =>
      'Registration successful! Check your email for validation or sign in.';

  @override
  String get registrationSubmitted => 'Registration submitted successfully.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get financialInsight => 'Financial Insight';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryInvestments => 'Investments';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String insightNetWorthGrew(String amount) {
    return 'Excellent work. Your net worth grew by $amount RON this month. Why it matters: This is the ultimate metric of financial momentum. Every positive increase means you are actively buying back your future time and building a permanent safety net.';
  }

  @override
  String insightHighSurplus(String percentage) {
    return 'Outstanding! You saved $percentage% of your income this month. Why it matters: A high savings rate creates a compounding capital surplus, buying you control over your future time.';
  }

  @override
  String insightHighExpenseWarning(String percentage) {
    return 'You have utilized $percentage% of your budget. Why it matters: Small daily leaks sink great ships. Reeling in discretionary spending now prevents a deficit and keeps your wealth-building engine running.';
  }

  @override
  String insightOnTrackBudget(String percentage, String budget) {
    return 'You are at $percentage% of your $budget budget. On track for a strong surplus. Why it matters: Consistently beating your budget prevents lifestyle creep and builds the cash runway needed to take calculated risks.';
  }

  @override
  String get insightDefault =>
      'Keep tracking your transactions to gain control over your money. Why it matters: Consistent monitoring is the first step toward optimization and financial freedom.';

  @override
  String get insightLoading =>
      'Analyzing your finances... Why it matters: Patience and continuous tracking are key to understanding your long-term wealth trajectory.';

  @override
  String get incomeByCategory => 'Income by Category';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get noIncomeData => 'No income data to display yet.';

  @override
  String get noExpenseData => 'No expense data to display yet.';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get noIncomesYet => 'No incomes yet';

  @override
  String get noTransactionDataYet => 'No transaction data yet';

  @override
  String get tapToRecordFirstTransaction =>
      'Tap the \'+\' button to record your first transaction.';

  @override
  String get biometricAuthReason =>
      'Please authenticate to view your financial data';

  @override
  String get lockScreenTitle => 'Balanza Secure Lock';

  @override
  String get lockScreenSubtitle =>
      'Access is restricted. Please authenticate to continue.';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String updateAvailableMessage(String version) {
    return 'A new version of Balanza Finance ($version) is available. Would you like to download and install it now?';
  }

  @override
  String get updateInstallButton => 'Update';

  @override
  String get downloadingUpdate => 'Downloading update...';

  @override
  String autoTaggedMessage(String category) {
    return 'Auto-tagged as $category based on remote rules.';
  }

  @override
  String get categoryCoffeeTea => 'Coffee & Tea';

  @override
  String get categoryRestaurants => 'Restaurants & Dining';

  @override
  String get categoryPetCare => 'Pet Care';

  @override
  String get categorySubscriptions => 'Subscriptions';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryCreditInstallments => 'Credit & Loans';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryMealTickets => 'Meal Tickets';

  @override
  String get categorySideHustle => 'Side Hustle / Extra';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get edit => 'Edit';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get transactionUpdatedSuccessfully =>
      'Transaction updated successfully!';

  @override
  String get noNote => 'No note provided';

  @override
  String get setCategoryBudget => 'Set Category Budget';

  @override
  String get editCategoryBudget => 'Edit Category Budget';

  @override
  String get categoryBudget => 'Category Budget';

  @override
  String get noCategoryBudgetsYet =>
      'No category budgets configured yet. Set a budget to track spending pacing!';

  @override
  String get deleteBudgetTitle => 'Delete Budget?';

  @override
  String get confirmDeleteBudget =>
      'Are you sure you want to remove this category budget limit?';

  @override
  String get addCategoryBudget => 'Add Category Budget';

  @override
  String get categoryClothing => 'Clothing & Fashion';

  @override
  String get categoryHealthcare => 'Health & Medical';

  @override
  String get categoryGadgets => 'Gadgets & Tech';

  @override
  String get categoryTravel => 'Travel & Holidays';

  @override
  String get categoryPersonalCare => 'Personal Care';

  @override
  String get categoryEducation => 'Education';
}
