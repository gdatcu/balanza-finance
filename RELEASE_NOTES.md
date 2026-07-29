# Release Notes — v1.13.1

## ✨ New Features

### 🎯 Savings Goals & Target Tracker ("Pus la Ciorap")
- Introduced a dedicated Savings Goals module to track financial targets (e.g. Emergency Fund, Vacation 2026, New Laptop, Investment target):
  - **Custom Target Cards**: Define goal title, target amount, current saved balance, badge color, and target date.
  - **Progress Visualizations**: Animated circular/linear completion bars with real-time percentage indicators.
  - **Account & Transaction Integration**: Depositing into a goal deducts funds from a selected user account (e.g. *Main Checking*) and records a ledger transaction (`-amount`), while withdrawing credits funds back (`+amount`).
  - **Localized Ledger Descriptions**: Transaction entries are automatically tagged with localized descriptions (`"Saved to Goal: {Title}"` / `"Pus la ciorap: {Title}"` and `"Withdrawn from Goal: {Title}"` / `"Retras din ciorap: {Title}"`).
  - **Offline-First Persistence**: Powered by Supabase PostgreSQL integration with transparent `SharedPreferences` local fallback for offline usage.
  - **Navigation & Localization**: Accessible directly from the main Navigation Drawer with full English (EN) and Romanian (RO) translations.

## 🧪 Comprehensive Test Suite Expansion
- Expanded automated test coverage from 48 to **101 passing tests**:
  - Added E2E flows for **Net Worth**, **Category Budgets**, **Locale Switcher**, and **Savings Goals**.
  - Added integration tests for repository offline fallback mechanisms (`NetWorthRepository`, `SavingsGoalRepository`).
  - Added interactive widget tests for Dashboard Donut Chart & Burn Rate Gauge.
- Verified that **`flutter test` passes 100% cleanly (101/101 tests)** and **`flutter analyze` has 0 issues**.
