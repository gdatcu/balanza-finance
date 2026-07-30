# Release Notes — v1.16.2

## ⚡ Instant UI Refresh & Enhanced BCR / Revolut Notification Interception

### 📱 Instant UI Refresh Fix
- **Root Cause Identified**:
  - When saving a new transaction (e.g. Starbucks), state invalidations were not triggered immediately, requiring a page refresh for the transaction to appear.
- **Resolution**:
  - Added immediate Riverpod state invalidation calls on transaction creation, update, and deletion in `TransactionInputSheet` and `TransactionDetailsScreen`.
  - Added hybrid realtime multi-device sync in `TransactionRepository`. New transactions render **instantly**!

### 🏦 Expanded BCR & Revolut Parser Regexes
- **BCR George**: Added support for transfer notifications (`Ai trimis [amount] RON ... catre [recipient]`).
- **Revolut**: Added support for currency-prefixed income notifications (`You received RON10 Payment received from [sender]`).

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
