# Balanza Finance v1.10.3 Release Notes

## 🐛 Bug Fixes

### 🎯 Fixed Double-Counting Bug in Category Spending Calculation
- Resolved a critical issue in `categoryBudgetProgressProvider` where transaction amounts were double-counted across multiple map keys (`catObj.id`, `rawCatId`), causing a single 1000 RON transaction to display as 2000 RON spent in the Category Budget progress card.
- Standardized category spending accumulation strictly by canonical category ID (`catObj.id`).

### ⚡ Real-Time Category Budget Reflection
- Added `ref.invalidate(categoryBudgetsStreamProvider);` immediately following budget `upsert` and `delete` operations in `CategoryBudgetInputSheet`.
- Newly added, edited, or deleted category budgets now update on the Dashboard in real time without requiring a manual page refresh.

### 🎨 Visual Progress Bars & Bottom Sheet Budget Editor
- Upgraded the **Budgets** section (`ToshlSection.budgets`) on the Dashboard with visual progress bars:
  - 🟢 **Green** (`#10B981`): 0% – 75% used
  - 🟡 **Yellow/Orange** (`#F59E0B`): 75% – 99% used
  - 🔴 **Red** (`#FF7A5A`): 100%+ used (Over budget)
- Added explicit spending math (e.g. `350 / 500 RON`) with multi-currency support.
- Built interactive `CategoryBudgetInputSheet` bottom sheet to set or update category limits with localized category selectors.

### 💡 Wealth Advisor Integration
- Enhanced `wealth_advisor_provider.dart` to evaluate category spending against user-configured category budget limits.
- Automatically triggers localized EN/RO **Notice (80% Warning)** and **Budget Alert (100% Over Budget)** nudges.
