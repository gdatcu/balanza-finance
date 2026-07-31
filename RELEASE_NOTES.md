# Release Notes — v1.24.0

## 🔮 Predictive Cash Flow & Bill Calendar

### 🌟 New Features & Capabilities

1. **📊 Predictive Cash Flow Projection Chart (`fl_chart`)**
   - Plots daily projected account balances for the entire month.
   - Dual-phase line chart: Solid neon green for past actual balance ➔ Transitioning to a dashed blue line for projected future balance with amber dots marking bill due dates.

2. **💰 Safe-to-Spend Today Calculator**
   - Real-time indicator displaying how much money you can safely spend today after reserving funds for all remaining unpaid bills due before month end.

3. **📅 Recurring Bills & Income Calendar (`CashFlowView`)**
   - Manage monthly recurring bills (Rent, Utilities, Subscriptions) and recurring income (Salary).
   - 1-Tap **Paid / Unpaid** toggle switch for each bill in the active month.
   - Add, edit, or delete recurring bills via `RecurringBillInputSheet`.

4. **⚡ Compact Currency Formatter**
   - Added `CurrencyFormatter.formatCompact()` utility for clean axis labels in charts (e.g. `4.7k`, `1.2M`).

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 122/122 unit, widget, and integration tests passed!
