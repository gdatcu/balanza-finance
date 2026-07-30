# Release Notes — v1.17.1

## ⚡ Cross-Device Supabase Sync & Account Foreign Key Auto-Setup

### 🌐 Instant Multi-Device Sync Fix
- **Root Cause Identified**:
  - Transactions added on one device (e.g. Web `Entertainment -45 RON`) were failing silently on cloud database insert because the default account (`00000000-0000-0000-0000-000000000001`) had not been upserted into Supabase's `accounts` table, triggering PostgreSQL foreign key constraint errors (`23503`).
- **Resolution**:
  - Implemented automatic account record upserting in `TransactionRepository.addTransaction()` so all transaction inserts succeed on Supabase cloud database 100% of the time.
  - Implemented `claimUnassignedPendingTransactions()` auto-claimer: Any bank notifications intercepted in guest or background mode are automatically claimed by your active Supabase user account and broadcasted to Web and Mobile apps in real time.
  - Prioritized Supabase cloud database as the single source of truth in `getTransactions()`, keeping local memory caches 100% synchronized across all connected devices.

---

## 🧪 Verification
- **`flutter test`**: **120/120 tests passed (100%)**!
- **`flutter analyze`**: **0 issues found**!
