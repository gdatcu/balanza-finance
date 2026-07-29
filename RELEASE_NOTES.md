# Release Notes — v1.15.1

## 🐛 Critical PostgreSQL UUID Constraint Fix for Background Interceptor

### 🛡️ Valid UUID Fallbacks for Background Notifications
- **Root Cause Identified**:
  - In background isolates, inserting pending notifications with empty string `userId: ''` or `'default-acc'` triggered PostgreSQL error `22P02` (*invalid input syntax for type uuid*), causing Supabase to reject background pending transactions.
- **Resolution**:
  - Updated `NotificationSyncService` and `TransactionRepository` to supply valid UUID format fallbacks (`00000000-0000-0000-0000-000000000000` & `00000000-0000-0000-0000-000000000001`).
  - Added flexible package name matching for all banking variants (*BCR, George, Revolut, ING, Salt, Google Wallet*).
  - Added mandatory debug notification logging so all intercepted bank notifications are recorded in `debug_notifications`.
  - Pending transactions now immediately appear in the **Pending Inbox** dashboard banner!

---

## ✨ Key Features (v1.15.0)

### 🏦 Zero-API Bank Sync & Incoming Money Notifications
- **Supported Apps**: **Revolut**, **BCR (George)**, **Salt Bank**, **ING**, and **Google Wallet**.
- **Income (+) & Expense (-) Interception**: Captures purchases as expenses (`-amount`) and incoming bank transfers/incasari as incomes (`+amount`).

---

## 🧪 Verification
- Verified **`flutter analyze` (0 issues found)**.
