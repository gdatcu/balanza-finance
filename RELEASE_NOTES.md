# Release Notes — v1.19.0

## 🤦 "Regret Index" Emotional Tagging & Time-Burn Calendar

### 🤦 Regret Index Emotional Tagging
- **Transaction Emotion Capture:** Capture purchase emotions directly on transaction creation/editing (*"Worth it 🔥"* vs *"Regret 🤦"*).
- **Data Model:** Added `emotional_status` field to transactions (`'worth_it'`, `'regret'`, `'neutral'`).

### 📅 Time-Burn Calendar (`TimeBurnCalendarView`)
- **Regret Threshold Math:** Automatically flags days where regret spending exceeds 50% of the daily wage (`isRegretDay = true`).
- **Header Summary Metric:** Displays total working days spent on regretted purchases (*"You spent X working days this month on things you regret"*).
- **Toxic Visual Taint:** Regret days feature a dark red background (`0xFF7F1D1D`), coral red border, and 🤦 emoji overlay. Accepted burned days display a muted crossed-out design.
- **Day Tap Detail Sheet:** Shows exact regret breakdown upon tapping a calendar day.

### 🌐 Localization
- Complete English (EN) and Romanian (RO) translations.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 113/113 unit, widget, and E2E tests passed!
