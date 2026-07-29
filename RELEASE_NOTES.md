# Release Notes — v1.16.0

## 🏷️ Intelligent Income & Expense Auto-Categorization

### 💡 Income Default Category Fix
- **Root Cause Identified**:
  - Previously, when an incoming transfer (e.g. BCR, Revolut) arrived without a specific merchant rule, `categoryId` was left null and the UI fell back to index 0 of `defaultCategories`, which was **Food**.
- **Resolution**:
  - `NotificationParser` and `home_view.dart` now intelligently assign:
    - **Income Transactions** (`isIncome == true`): Defaults to **Salary / Income** (`c5`).
    - **Expense Transactions** (`isIncome == false`): Defaults to **Other / Expense** (`c14`).

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
