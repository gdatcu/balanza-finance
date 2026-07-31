# Release Notes — v1.22.1

## 🚀 Enhanced BCR George Statement Support & Improved Column Detection

### 🏦 BCR George CSV Parser Enhancements (`CsvBankStatementParser`)
- **Dual-Column Debit/Credit Support:** Fixed parser support for BCR George statement exports that split transactions across `Debit (amount)` and `Credit (amount)` columns.
- **Accurate Date Extraction:** Prioritized `Transaction completion date` over statement generation headers (`Issuing date of the statement`), eliminating incorrect date assignments.
- **Location & Merchant Extraction:** Cleansed BCR description strings (extracting store names from `"Locatie: ..."` blocks), enabling instant auto-tagging for:
  - **Froo** → Food / Groceries
  - **Carrefour** → Food / Groceries
  - **Mega Image** → Food / Groceries
  - **Kaufland** → Food / Groceries
  - **Golden Coffe** → Food / Coffee & Tea
  - **MOL** → Transport / Fuel & Gas
  - **Fashion Days / PayU** → Shopping / Clothing
  - **Vodafone / PayU** → Utilities / Mobile Phone
  - **PPC Energie** → Utilities / Electricity

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 118/118 unit, widget, and integration tests passed!
