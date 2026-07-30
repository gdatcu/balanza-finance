# Release Notes — v1.17.3

## ⚡ PostgREST Date String Fix & Realtime Cross-Device Synchronization

### 🌐 PostgREST String Date Query & Timezone Fix
- **Root Cause Identified**:
  - Transactions saved with ISO 8601 UTC timestamps (ending in `'Z'`, e.g. `2026-07-30T15:14:00.000Z`) were being filtered out by PostgREST PostgreSQL queries using `.lte('date', '2026-07-31T23:59:59.999')` because lexicographical string sorting considers `'Z'` (ASCII 90) greater than `'9'` (ASCII 57).
  - Consequently, Web and Mobile apps querying Supabase received empty results for current-month transactions.
- **Resolution**:
  - Updated `TransactionRepository.getTransactions()` to fetch recent transactions using `.select().order('date', ascending: false).limit(500)`.
  - Applied robust Dart memory date filtering (`tx.date.year == month.year && tx.date.month == month.month`) on parsed `DateTime` objects.
  - Transactions added on any device (e.g., Mobile `Kaufland -55 RON`, `Starbucks -22 RON`) now populate **instantly in real time** on Web (`localhost`) and all connected devices!

---

## 🧪 Verification
- **`flutter test`**: **120/120 tests passed (100%)**!
- **`flutter analyze`**: **0 issues found**!
