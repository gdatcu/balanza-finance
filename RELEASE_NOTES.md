# Release Notes — v1.17.0

## 🛡️ Combined Hybrid Engine: 100% Bank Notification Capture & Universal Catch-All Engine

### 🏦 Expanded Multi-Bank & Payment App Support
- **Full Package Whitelisting**: Added native support for **Revolut**, **BCR George**, **ING HomeBank**, **Google Wallet / Google Pay**, **Salt Bank**, **BT Pay (Banca Transilvania)**, **Raiffeisen Smart Mobile**, **CEC Bank**, **UniCredit Bank**, **Wise**, and **Curve**.
- **Native Transaction Scenarios**:
  - **Revolut**: Card payments, P2P transfers sent (`sent X to Y`), P2P transfers received (`received X from Y`, `You received RON10 Payment received from Y`), ATM withdrawals, Vault deposits.
  - **BCR George**: POS card payments, George transfers sent (`Ai trimis X RON catre Y`), transfers received (`Ai primit X RON de la Y`), recurring bills.
  - **ING HomeBank**: Card POS (`Plata cu cardul in valoare de X RON la Y`), IBAN transfers sent, IBAN transfers received (`Incasare X RON de la Y`), instant payments.
  - **Google Wallet / Pay**: Contactless POS payments (`Plată de X RON la Y`), in-app purchases.
  - **Salt Bank, BT Pay, Raiffeisen, CEC, UniCredit, Wise, Curve**: Complete card & transfer regexes.

### 🎯 Universal Financial Catch-All Engine (Zero-Drop Guarantee)
- If an exact merchant regex fails on a new or unexpected notification format, **the transaction is NEVER dropped**.
- The Universal Engine automatically extracts monetary amounts (`RON`, `EUR`, `LEI`, `USD`, `GBP`), detects transaction direction (Income vs. Expense), and routes the transaction into your **Pending Inbox** with the bank name as merchant for **1-tap approval**.

---

## 🧪 Verification
- **`flutter test`**: **120/120 tests passed (100%)**!
- **`flutter analyze`**: **0 issues found**!
