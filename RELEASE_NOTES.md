# Release Notes — v1.18.0

## ⚡ Pre-Purchase "Reality Check" Calculator & Dynamic Time Cost Engine

### ⚡ Pre-Purchase Reality Check Tool
- **Stark Time-to-Value Overlay:** Pre-purchase behavioral intervention calculator converting monetary amounts into life hours or work days (e.g., *"That costs you 12.5 hours of your life"* or *"1.6 work days"*).
- **Custom Keypad:** Ultra-fast custom numeric keypad (0-9, `.`, `⌫`) for rapid friction-free input.
- **Intervention Action Buttons:**
  - **Put it in the Wishlist** (Primary Restrictive): Triggers cooling-off reflection.
  - **Walk Away** (Secondary Neutral): Clears input and closes screen.
  - **I'm buying it anyway** (Subtle Muted): Opens transaction input pre-filled with the amount.
- **Dashboard & Drawer Access:** Prominent FAB on main Dashboard and navigation drawer access.

### ⏱ Dynamic Time-Cost Engine
- **Exact Monthly Working Days:** Dynamic calculation of working days (Mon-Fri) for any calendar month using `WorkingDaysCalculator`.
- **Daily Working Hours Setting:** Configurable setting in Settings view (default `8.0` hours/day).
- **Zero-Income Safe:** Prevents division-by-zero errors when income is 0.

### 🌐 Localization
- Complete English (EN) and Romanian (RO) translations.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 111/111 unit, widget, and E2E tests passed!
