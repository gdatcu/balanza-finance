# Release Notes — v1.20.0

## 🔖 Cooling-Off Wishlist & Supabase Schema Fallback

### 🔖 Cooling-Off Wishlist Feature (`WishlistView`)
- **Cooling-Off Reflection Screen:** Dedicated Wishlist screen displaying pre-purchase items undergoing reflection.
- **Countdown Badge:** 30-day countdown timer badge per item (`"30 days left in cooling-off"`).
- **Time Cost Calculation:** Displays exact work hours represented by each wishlist item.
- **Action Buttons:**
  - **Buy Now:** Opens transaction sheet pre-filled with the amount and converts item.
  - **I Don't Need It (Saved!):** Discards item with money saved confirmation.
- **Reality Check Direct Integration:** Tapping *"Put it in the Wishlist"* in Reality Check saves the item and opens your Wishlist directly.
- **Navigation Drawer Access:** Added dedicated Wishlist entry in navigation drawer.

### 🛡 Supabase Schema Fallback
- **PGRST204 Graceful Error Handling:** `TransactionRepository` automatically catches missing `emotional_status` column errors on Supabase REST API and retries without `emotional_status`, preventing error SnackBars when database migrations haven't run yet.

### 🌐 Localization
- Complete English (EN) and Romanian (RO) translations.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 114/114 unit, widget, and E2E tests passed!
