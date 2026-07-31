# Release Notes — v1.22.2

## 🤖 Smart Auto-Tagging Fallback & Internal Transfer Filtering

### ⚡ Auto-Tagging Fallback Engine Fix
- **Merged Rule Fallbacks:** Combined remote Supabase rules with default fallback rules (`defaultTaggingRules`) so auto-tagging functions 100% of the time, even when stream providers are loading or offline.
- **Location Prefix Cleaner:** Automatically strips location codes (e.g. `0450PRPR RO`, `22328650 RO`, `05573370 RO`) before matching merchant keywords.

### 🔄 Automatic Internal Transfer Detection & Filtering
- **Smart Money Movement Filter:** Automatically detects internal bank transfers, card reimbursements, self-payments, and round-ups (e.g., *Platitor: Datcu George... Beneficiar: Datcu George*, *Transfer intre conturi*, *Alimentare cont*).
- **Auto-Unselect:** Flags internal transfers with a `[Internal Transfer]` badge and **unselects them by default** so they do not bloat monthly spending budgets.

### 🎛️ Preview List Tabs & Bulk Actions
- **Filter Tabs:** Toggle between `All`, `Spending & Income Only`, and `Transfers`.
- **Bulk Action Toolbar:**
  - `Select All` / `Deselect All`
  - `Uncheck Internal Transfers` (1-click unchecks all non-budget money movements)
  - `Discard Selected Items` (Bulk remove checked items from preview)
- **Checkbox Selection & Counter:** Dynamic action button displaying exact approved item count: `Import (X) Selected`.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 118/118 unit, widget, and integration tests passed!
