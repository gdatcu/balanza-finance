# Balanza Finance v1.10.0 Release Notes

## ⚡ New Features

### 📊 Category-Specific Monthly Budgets & Spending Progress Engine
- Created `CategoryBudget` data model mapping to Supabase `category_budgets` table (`id`, `user_id`, `category`, `amount_limit`).
- Implemented `CategoryBudgetRepository` and `categoryBudgetsStreamProvider` supporting `upsertCategoryBudget(category, amountLimit)` and `deleteCategoryBudget(id)`.
- Created combined `categoryBudgetProgressProvider` that calculates monthly category spending, budget limits, and percentage used.

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
