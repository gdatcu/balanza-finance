# Release Notes — v1.15.2

## 🚀 Critical Fix: Background User Session & Notification Extraction

### 🔐 Authenticated Session Persistence for Background Interceptor
- **User Session Binding**:
  - Saved `last_authenticated_user_id` to persistent storage (`SharedPreferences`) on login and app launch.
  - The background notification service now retrieves the active user's ID, ensuring intercepted bank transactions are inserted under the logged-in user's account.
- **Auto-Claiming Unassigned Transactions**:
  - Added an automatic claiming mechanism (`claimUnassignedPendingTransactions`) on app launch to transfer any unassigned background pending transactions directly to the logged-in user.

### 📱 Robust Android Notification Extraction
- **Multi-Field Extraction**:
  - Added `extractTitle` and `extractBody` helpers to parse `text`, `message`, `bigText`, `subText`, and `summaryText` directly from the raw Android notification bundle.
  - Eliminates empty body issues caused by null/empty field fallbacks.

### 🔄 Refined Deduplication
- Added merchant/description validation to deduplication checks to prevent false positives when testing consecutive identical amounts.

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
