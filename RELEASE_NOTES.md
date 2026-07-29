# Release Notes — v1.15.0

## ✨ New Feature: Incoming Bank Transfers & Income Notifications Support ("Info Încasări")

### 🏦 Support for Incoming Money & Bank Transfers
- **BCR George ("Info incasari")**:
  - Added dedicated parsing for BCR incoming transfer notifications (e.g. `Info incasari 🥳🥳 Ai primit 28.94 RON in contul George Platinum de la Datcu George Cristian...`).
  - Automatically identifies sender name, amount, currency, and marks transaction as an **Income (+)**.
- **Revolut Income Notifications**:
  - Added support for Revolut incoming transfers (`Ai primit X RON de la Y`, `X sent you Y RON`).
- **ING & Salt Bank Income Notifications**:
  - Added support for ING and Salt Bank incoming transfers (`Incasare X RON de la Y`, `Ai primit X RON de la Y`).
- **Income (+) vs Expense (-) Routing**:
  - Incoming money is tagged with `isIncome = true` and logged with a positive amount (`+amount`), while purchases are logged with a negative amount (`-amount`).
  - Appears in the **Pending Inbox** dashboard banner with a positive green amount (`+28.94 RON`).

---

## 🧪 Verification
- Verified **`flutter test` (118/118 tests passed)** including new unit test cases for BCR income notifications.
- Verified **`flutter analyze` (0 issues found)**.
