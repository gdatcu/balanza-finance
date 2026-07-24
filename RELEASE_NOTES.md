# Release Notes — v1.12.0

## ✨ New Features

### Dashboard Data Visualizations & Toggle
- Added interactive and visual charting components at the top of the Overview tab:
  - **📊 Category Donut Chart (Breakdown)**: Groups current month's expenses by category with matching theme colors. Supports touch interactivity, expanding the touched slice and updating the center display with the category's name, total amount, and percentage contribution.
  - **🔥 Burn Rate Gauge (Cash Flow Health)**: Horizontal progress bar representing monthly expenses relative to total income. Color-coded dynamically (Green <= 50%, Orange 50-80%, Red > 80%). Displays real-time burn rate percentage and remaining safe to spend / overspent amount.
  - **Animated Switcher Toggle**: Underlined Cupertino segmented control toggle to switch between Breakdown and Burn Rate views with a smooth cross-fade animation.

## 🐛 Bug Fixes & Polish
- **Wealth Advisor Thresholds**: Gated budget alerts/warnings/safe zone insights to only evaluate categories that have user-configured limits, preventing spurious "Ritm Excelent" notifications for unset categories.
- **UI Overflow Prevention**: Wrapped category name items in flat transaction rows inside flexible widgets to handle long category names (e.g. *Îmbrăcăminte* / *Educație & Dezvoltare*) without right-side Layout RenderFlex overflows.

## 🧪 Testing & CI/CD
- Adjusted test viewport heights in `widget_test.dart` to ensure list items remain within layout view bounds when charts are prepended.
- Verified that all **48 tests pass** cleanly and `flutter analyze` has **0 issues**.
- Tagged and updated repository release version.
