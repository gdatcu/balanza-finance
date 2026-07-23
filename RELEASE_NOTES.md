# Balanza Finance v1.5.0 Release Notes

## ⚡ New Features

### ☕ Category Schema Expansion
- Introduced 5 new spending categories across Balanza Finance: `coffee_tea` (☕ Coffee & Tea), `restaurants` (🍽️ Restaurants & Dining), `pet_care` (🐾 Pet Care), `subscriptions` (🔄 Subscriptions), and `other` (📦 Other).
- Integrated curated theme colors and Material icons for all new spending categories.

### 🌐 Complete EN / RO Localization Setup
- Full bilingual dictionary updates (English / Romanian) across all category labels, transaction forms, notifications, and analytics views.
- Updated `CategoryLocalizer` for seamless localized category string formatting.

### 🧠 Riverpod Wealth Advisor Behavioral Nudges
- Added 4 data-driven behavioral nudges to the Wealth Advisor engine:
  - **`coffee_tea` Frequency Trigger** (>15 tx/month): Highlights the "Latte Factor" to boost annual savings.
  - **`restaurants` Ratio Trigger** (>15% total spending): Encourages meal-prep vs. delivery balance.
  - **`subscriptions` Pruning Trigger** (>5 recurring items in 30 days): Prompts audit and cancellation of unused subscriptions.
  - **`other` Uncategorized Trigger** (>20% total spending): Prompts tagging transactions to eliminate budget blind spots.

### 🏷️ Auto-Tagging Engine Integration
- Enhanced client-side transaction description parsing against local fallback and remote Supabase `tagging_rules`.
- Smart auto-tagging feedback snackbars with localized category names.

### 🎨 Dashboard & Interactive UI Upgrades
- Added interactive category filter chips on the Dashboard for real-time transaction and category breakdown filtering.
- Enhanced transaction rows and category pie chart breakdown lists with custom category icon badges and theme colors.

---

## 🛠️ Critical Fixes & Improvements

### 🧪 Automated Testing
- Expanded test suite with unit tests in `wealth_advisor_test.dart` for all 4 new behavioral nudges (`36/36 tests passed`).
