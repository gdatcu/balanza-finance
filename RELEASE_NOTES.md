# Balanza Finance v1.7.0 Release Notes

## ⚡ New Features

### 📄 Interactive Transaction Details Screen (`TransactionDetailsScreen`)
- Added a dedicated, read-only transaction detail view showing Amount, Category Badge/Name, Date, Type (Income vs. Expense), Account, and Notes.
- Integrated currency conversion display when transactions are recorded in foreign currencies (e.g. `EUR`).

### ✏️ Edit Transaction Functionality
- Upgraded `TransactionInputSheet` to accept an existing transaction for pre-filling controllers and state variables.
- Added **Edit** action in AppBar of `TransactionDetailsScreen` to edit transactions in real time.
- Integrated `updateTransaction` in `TransactionRepository` and `TransactionNotifier` for live Supabase database sync.

### 🗑️ Delete Transaction Functionality with Confirmation Dialog
- Added **Delete** action in AppBar of `TransactionDetailsScreen` with an interactive localized confirmation dialog.
- Executes `deleteTransaction` in Supabase and returns cleanly to the Dashboard with feedback snackbars.

### 🌐 Complete EN / RO Localization Setup
- Added localization dictionary strings for `transactionDetails`, `edit`, `delete`, `editTransaction`, `transactionUpdatedSuccessfully`, and `noNote` across English and Romanian.
