# Release Notes — v1.17.2

## ⚡ Multi-Device Realtime Cloud Synchronization Engine

### 🌐 Cross-Device Sync & Unauthenticated Session Handling
- **Root Cause Identified**:
  - When running the app on Web (or a new session), if the user is unauthenticated or has local-only transactions (e.g. `Entertainment -45 RON`), they remained stored in local RAM and were not synced to Supabase Cloud DB.
- **Resolution**:
  - Implemented `_syncLocalTransactionsToSupabase()` background sync engine: automatically uploads any unsynced local transactions to Supabase Cloud DB on every sync cycle.
  - Implemented Ground Truth Cloud Sync in `getTransactions()`: fetches all Cloud DB records, merges them with local transactions, and broadcasts the unified transaction stream to Web, Android, and iOS devices in real time.
  - Resolved Chrome hot-reload / stale instance state synchronization across devices.

---

## 🧪 Verification
- **`flutter test`**: **120/120 tests passed (100%)**!
- **`flutter analyze`**: **0 issues found**!
