# Release Notes — v1.23.0

## 🏦 Full ING HomeBank Multi-Line Statement Support & Romanian Date Normalization

### 🚀 ING HomeBank CSV Parser Engine (`CsvBankStatementParser`)
- **Multi-Line Sub-Detail Aggregator:** ING HomeBank exports use a multi-line format where a transaction's main row has a generic description (`Cumparare POS` or `Incasare`) and sub-details appear in subsequent rows starting with `,,,`. The parser now consolidates these sub-details to extract actual merchant and payer names:
  - `Tranzactie la: PayU*fashiondays.ro` ➔ Extracted as merchant ➔ Auto-tagged as **Shopping / Clothing**.
  - `Tranzactie la: LA STRADA-ZOOMSERI` ➔ Extracted as store ➔ Auto-tagged as **Food / Groceries**.
  - `Ordonator: LUXOFT PROFESSIONAL ROMANIA SRL` ➔ Extracted as employer ➔ Auto-tagged as **Income / Salary**.
  - `Ordonator: A.J.P.I.S. - ILFOV` ➔ Extracted as agency ➔ Auto-tagged as **Income / Grants**.
  - `Beneficiar: George Cristian Datcu` / `transfer intre conturi` ➔ Flagged as **Internal Transfer** (unselected by default).
- **Romanian Date Normalization:** Parses dates with Romanian month names (`24 iulie 2026`, `10 iulie 2026`) directly into standard ISO dates (`2026-07-24`, `2026-07-10`) instead of defaulting to current date.
- **Header & Metadata Filtering:** Filters out ING statement cover headers (`Titular cont:`, `CNP:`, `ING Bank N.V.`, signature footers) automatically.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 119/119 unit, widget, and integration tests passed!
