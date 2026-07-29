# Release Notes — v1.15.7

## 🚀 Approved Transactions Retention & Display Fix

### 📈 Instant Display in Budget & Lists
- **Root Cause Fixed**:
  - When approving a pending transaction, if local storage was cleared before remote database sync finished (or if foreign key constraints occurred), the transaction disappeared from view.
- **Resolution**:
  - Added `_localApprovedTransactions` store in `TransactionRepository`.
  - When a transaction is approved (or swiped right), it is marked `isPendingReview = false` and stored in `_localApprovedTransactions`.
  - Both `getTransactions()` and `getTransactionsStream()` merge local approved transactions with remote database queries, guaranteeing approved transactions immediately appear under **Expenses** / **Incomes** on the Dashboard!

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
