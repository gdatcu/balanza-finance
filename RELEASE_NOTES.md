# Release Notes — v1.16.1

## 🛒 Built-in Merchant Auto-Tagging & Smart Category Matching

### ⚡ Automatic Merchant Categorization
- **Root Cause Identified**:
  - Bank notifications for popular merchants (such as **Kaufland** or **Starbucks**) fell back to `Other` because built-in merchant rules had not been initialized in background notification parsing.
- **Resolution**:
  - Created `defaultTaggingRules` containing keyword rules for major merchants & services:
    - **Groceries**: Kaufland, Lidl, Carrefour, Mega Image, Profi, Auchan, Penny.
    - **Coffee & Tea**: Starbucks, 5 to go, Tucano, McCafé.
    - **Restaurants & Delivery**: McDonald's, KFC, Glovo, Tazz, Wolt.
    - **Transport**: Uber, Bolt, OMV, Petrom.
    - **Subscriptions**: Netflix, Spotify, YouTube.
    - **Shopping**: eMAG, Zara, H&M.
  - Updated `NotificationParser` and `home_view.dart` to auto-resolve merchant names dynamically. **Kaufland** automatically categorizes as **Groceries** and **Starbucks** automatically categorizes as **Coffee & Tea**!

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!
