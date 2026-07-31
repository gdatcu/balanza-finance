# Release Notes — v1.22.0

## 🏦 Bank CSV Importer & Financial Health Score (0–100)

### 🏦 Bank CSV Statement Importer (`CsvImportSheet`)
- **Multi-Bank Export Parser:** Zero-dependency CSV parser (`CsvBankStatementParser`) supporting comma `,` and semicolon `;` delimited bank statements from:
  - **Banca Transilvania (BT)**
  - **Revolut**
  - **ING Bank**
  - **BCR / George**
  - **Raiffeisen Bank**
  - **Universal CSV format**
- **Automated Merchant Auto-Tagging:** Every imported line is automatically passed through Balanza's Auto-Tagging engine to pre-assign Category and Subcategory chips (e.g. *Uber* → Transport / Rideshare Taxi, *Mega Image* → Food / Groceries, *Catena* → Healthcare / Pharmacy).
- **Interactive Review & Edit:** Review, modify category/subcategory dropdowns, or exclude individual lines before confirming bulk import.
- **Drawer Access:** Added *"Import Bank CSV"* entry in navigation drawer.

### 🩺 Financial Health Score (0–100) (`FinancialHealthCard`)
- **Dynamic 0–100 Fitness Index:** Real-time health meter calculated across 4 core financial pillars:
  1. **Savings Rate Score (0–30 pts):** % of income saved per month.
  2. **Budget Pacing Score (0–25 pts):** Spending velocity relative to calendar day.
  3. **Emergency Buffer Score (0–25 pts):** Months of living expenses covered by net liquid assets.
  4. **Debt-to-Income Score (0–20 pts):** Debt installment obligations vs total income.
- **Actionable Recommendations:** Targeted tips to boost score (e.g. *"Build 3-6 Month Emergency Fund"*, *"Slow Down Budget Velocity"*).
- **Dashboard Integration:** Displayed on the main Overview dashboard.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 117/117 unit, widget, and integration tests passed!
