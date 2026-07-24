# Release Notes — v1.11.0

## ✨ New Features

### Extended Discretionary & Lifestyle Categories
- Added **8 new financial categories** for comprehensive expense tracking:
  - 👕 **Clothing & Fashion** (Îmbrăcăminte)
  - 💊 **Health & Medical** (Sănătate & Farmacii)
  - 💻 **Gadgets & Tech** (Electronice & IT)
  - ✈️ **Travel & Holidays** (Călătorii & Vacanțe)
  - 🎭 **Entertainment** (Divertisment & Cultură)
  - 🚗 **Transport & Auto** (Transport & Auto)
  - 🧴 **Personal Care** (Îngrijire Personală)
  - 📚 **Education** (Educație & Dezvoltare)
- Full **EN/RO localization** for all new categories.
- New categories appear in transaction forms, budget setup, and dashboard charts.

### Smart Budget Suggestion Engine
- New `SmartBudgetProvider` with target maximum budget percentages per category:
  - Groceries 25%, Rent 30%, Utilities 10%, Transport 10%, Credit Installments 15%, Clothing/Entertainment/Healthcare/Gadgets/Travel/Personal Care/Education 5% each, Coffee & Tea 3%, Restaurants 8%, Subscriptions 3%.
- Automatically calculates suggested budget limits based on user income.

### 3 New Wealth Advisor Behavioral Rules
- **⏱ Time Cost Rule**: Alerts when a single Clothing or Gadgets purchase exceeds 8 hours of labor (hourlyRate = monthlyIncome / 160). Helps visualize expenses in work-hours.
- **🎓 Positive Reinforcement (Education)**: Congratulates the user when an Education transaction is logged — investing in learning is the highest-return asset.
- **✈️ Travel Sinking Fund Rule**: Suggests creating a dedicated monthly travel sinking fund when travel expenses exceed 10% of monthly income.

## 🧪 Testing
- Added comprehensive unit tests for:
  - Extended category data model validation (all 8 categories present with correct icons).
  - Smart budget percentage calculations.
  - All 3 new Wealth Advisor behavioral rules with proper provider isolation.
- All **48 tests passing**, `flutter analyze` clean with 0 issues.

## 🏗 Backend / Architecture
- New file: `lib/features/budgets/providers/smart_budget_provider.dart`
- Updated: `wealth_advisor_provider.dart` with 3 new behavioral nudge rules.
- Fixed duplicate localization keys (`categoryEntertainment`, `categoryTransport`) that were already defined in earlier entries.
