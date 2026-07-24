# Balanza Finance v1.6.0 Release Notes

## ⚡ New Features

### 💰 Income vs. Expense Category Schema & Direction (`isIncome`)
- Explicit cash flow direction classification added to `Category` model (`isIncome` boolean flag).
- Expanded category schema with new vital categories:
  - 🏦 **`credit_installments`** (Rate & Credite | Expense)
  - 🛒 **`groceries`** (Cumpărături Casnice | Expense)
  - 💡 **`utilities`** (Utilități & Facturi | Expense)
  - 🎫 **`meal_tickets`** (Bonuri de Masă | Income)
  - 💰 **`salary`** (Salariu | Income)
  - 🚀 **`side_hustle`** (Proiecte Extra | Income)

### 🧠 Advanced Wealth Advisor Cross-Category Rules
- Integrated 3 new behavioral nudges:
  - 🏦 **Debt-to-Income Rule** (`nudge_debt_to_income`): Triggers when credit & loan installments exceed 30% of primary income (`salary` + `side_hustle`).
  - 🍽️ **Food Ratio Rule** (`nudge_food_ratio`): Triggers when restaurant spending exceeds 50% of home grocery purchases.
  - 🎫 **Ticket Allocation Rule** (`nudge_ticket_allocation`): Advises users logging meal tickets to restrict ticket usage strictly to groceries to preserve liquid cash.

### 🌐 Complete Bilingual Localization (EN / RO)
- Added localizations for all new categories across English and Romanian dictionaries (`CategoryLocalizer`).

### 🎨 Smart UI Dropdowns & Dynamic Dashboard Filtering
- Transaction input modal dynamically switches dropdown categories based on Income vs. Expense selection.
- Dashboard filter chips updated with income and expense category tags.

---

## 🛠️ Critical Fixes & Improvements

### 🧪 Automated Testing & Code Quality
- Expanded automated unit test suite (`39/39 tests passed`).
- Static analysis clean (`0 issues found`).
