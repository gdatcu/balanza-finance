# Release Notes — v1.15.6

## 🎯 Instant Local Pending Inbox Storage & User ID Association

### 📦 In-Memory Local Pending Inbox Storage
- **Guaranteed Local Display**:
  - Added `_localPendingTransactions` fallback cache to `TransactionRepository`.
  - Every simulated or real bank notification is now saved locally immediately, ensuring pending transactions appear in the **Pending Inbox** banner on the Dashboard under all network and database conditions.

### 👤 Active User Association
- **Direct Auth User Lookup**:
  - Updated `NotificationSyncService` to fetch active Supabase `currentUser.id` directly before falling back to `SharedPreferences`.

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
