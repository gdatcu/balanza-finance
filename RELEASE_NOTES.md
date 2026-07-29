# Release Notes — v1.15.9

## 🚀 Complete Restoration of Historical & Database Transactions

### ⚡ PostgREST Query Clean-up
- **Root Cause Fixed**:
  - An invalid PostgREST `.or(...)` filter was causing database queries to return an error, which defaulted to an empty list on the Dashboard.
- **Resolution**:
  - Cleaned up the query in `TransactionRepository` to use standard, reliable database fetches combined with Dart memory filtering (`!tx.isPendingReview`).
  - All your historical transactions stored in your Supabase database are now fetched and rendered on the Dashboard!

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
