# Release Notes — v1.15.8

## 📜 Historical Database Transactions Display Restoration

### 🛠️ Null/False Query Filter Fix
- **Root Cause Identified**:
  - In previous builds, querying non-pending transactions used `.eq('is_pending_review', false)`.
  - In SQL/PostgREST, rows where `is_pending_review` was `NULL` (such as historical transactions logged before the pending feature addition) were excluded by `.eq(...)`.
- **Resolution**:
  - Updated database query to `.or('is_pending_review.eq.false,is_pending_review.is.null')` in `TransactionRepository`.
  - All your historical transactions, past spending, and newly approved transactions are now displayed on your Dashboard!

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
