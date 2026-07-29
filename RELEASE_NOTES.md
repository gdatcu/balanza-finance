# Release Notes — v1.15.4

## 🚀 Instant Pending Inbox & Audit Log Resiliency

### ⚡ Instant Pending Inbox Updates
- **Hybrid Polling Stream**:
  - Upgraded `getPendingTransactionsStream()` to a hybrid polling stream (`async*` generator with 2-second interval).
  - Guarantees pending transactions instantly appear in the **Pending Inbox** banner on the Dashboard without relying on Supabase Realtime WebSocket configurations.

### 📜 Resilient Local & Remote Notification Audit Log
- **Local Fallback Storage**:
  - Added in-memory & local fallback caching for `logDebugNotification` in `TransactionRepository`.
  - Captures and displays all received bank notifications in the **Bank Sync Diagnostics 🐛** audit log, even if offline or if database insertion fails.

### 🌐 Expanded Revolut Notification Regex
- Added support for English Revolut notifications matching `Paid [amount] [currency] to [merchant]` (e.g., `Paid 45.00 RON to Starbucks`).

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
