# Release Notes — v1.23.1

## ⚡ Revolut Statement Truncated Name Normalization & Digital Services Auto-Tagging

### 🔄 Revolut Internal Transfer & Self-Payment Detection
- **Truncated Name Normalization:** Revolut statement exports truncate contact names (e.g. `To George-Cristia Datcu` missing the `n` at the end). The internal transfer engine now normalizes name tokens and hyphens so all self-transfers are accurately detected and unselected by default.
- **Top-Ups & Currency Exchanges:** Automatically detects and excludes `Exchanged to RON`, `Exchanged to EUR`, `Top-up by *`, and `Payment from DATCU GEORGE CRISTIAN` from monthly spending calculations.

### 🏷️ New Digital Services Auto-Tagging Rules
- Added rule auto-tagging support for:
  - **Google One** ➔ Subscriptions (`00000000-0000-0000-0000-000000000c13`)
  - **Scaled Agile** ➔ Tech & Education (`00000000-0000-0000-0000-000000000c21`)
  - **ChatGPT / OpenAI** ➔ Subscriptions (`00000000-0000-0000-0000-000000000c13`)
  - **Apple.com / iCloud** ➔ Subscriptions (`00000000-0000-0000-0000-000000000c13`)

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 120/120 unit, widget, and integration tests passed!
