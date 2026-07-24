# Balanza Finance v1.6.2 Release Notes

## 🛠️ Fixes & Enhancements

### 🌐 Human-Readable Bilingual Category Localizations in Wealth Advisor Nudges
- Fixed raw enum/category keys (e.g. `COFFEE_TEA` / `coffee_tea`) appearing in Wealth Advisor banner titles and card messages.
- Updated `CategoryLocalizer` with static `getCategoryNameEn` and `getCategoryNameRo` helpers to ensure category names are rendered as human-readable, properly formatted strings across both languages:
  - ☕ EN: **`Coffee & Tea`** / **`COFFEE & TEA`** | RO: **`Cafea & Ceai`** / **`CAFEA & CEAI`**
  - 🛒 EN: **`Shopping`** / **`SHOPPING`** | RO: **`Cumpărături`** / **`CUMPĂRĂTURI`**
  - 🏦 EN: **`Credit & Loans`** / **`CREDIT & LOANS`** | RO: **`Rate & Credite`** / **`RATE & CREDITE`**
