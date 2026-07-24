# Balanza Finance v1.10.1 Release Notes

## 🛠️ Fixes & Enhancements

### 🧹 Static Analysis & CI Fix
- Added `// ignore: deprecated_member_use` annotation to `category_budget_input_sheet.dart` form field properties to ensure compatibility across older and newer Flutter SDKs during GitHub Actions automated CI builds.

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
