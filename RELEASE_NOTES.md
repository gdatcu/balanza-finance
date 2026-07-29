# Release Notes — v1.14.0

## ✨ New Features

### 🏦 Zero-API Bank Sync via Android Notification Listener ("Pending Inbox")
- **Automated Banking Notification Interceptor**:
  - Automatically captures and parses push notifications from major banking apps and digital wallets: **Revolut** (`com.revolut.office`), **BCR (George)** (`ro.bcr.georgego`), **Salt Bank** (`ro.salt.bank`), **ING** (`ro.ing.mobile.banking`), and **Google Wallet** (`com.google.android.apps.walletnfcrel`).
- **Robust Notification Parsing Engine**:
  - `NotificationParser` utility with diacritic cleaning (`ă->a`, `ș->s`, `ț->t`), European (`1.250,50`) vs US (`1,250.50`) number parsing, and merchant auto-tagging.
- **60-Second Deduplication**:
  - Built-in deduplication engine discards duplicate transactions logged within 60 seconds (preventing double entries from Google Wallet + Bank notification pairs).
- **Debug Fallback Logging**:
  - Unparsed allowed bank notifications are stored in a dedicated `debug_notifications` table for diagnostics.
- **Interactive Pending Inbox Banner**:
  - Dashboard banner displaying pending notifications for review with `Dismissible` swipe gestures:
    - **Swipe Right**: Approves transaction into active budget and triggers Wealth Advisor behavioral nudges.
    - **Swipe Left**: Rejects and hard deletes pending item.
    - **Tap**: Opens standard transaction editor to refine category or amount before approving.
- **Native Android Permission Integration**:
  - Added native Android notification listener permission (`BIND_NOTIFICATION_LISTENER_SERVICE`) with a direct **"Bank Auto-Sync"** card in Settings.

### ⏱️ Dynamic Monthly Working Days Time-Cost Engine
- **`WorkingDaysCalculator` Utility**:
  - Dynamically calculates the exact number of weekdays (Monday–Friday) per calendar month (e.g. 23 days in July 2026, 21 days in Feb 2024 leap year).
- **Daily Working Hours Setting**:
  - Added user configurable `dailyWorkingHours` (default 8.0 hrs/day) in Settings.
- **Dynamic Hourly Rate Calculation**:
  - Computes hourly wage dynamically based on working days and daily working hours (safely guarded against 0 income).

### 💡 Uncategorized Expense 12-Hour Rule Behavioral Nudge
- **Actionable 12-Hour Rule Nudge**:
  - Intercepts `other`/`uncategorized` expenses costing $>12$ working hours.
  - Displays localized nudge text (EN/RO) with an actionable **"Categorize Now"** / **"Categorisește Acum"** button opening the transaction input sheet directly.

---

## 🧪 Comprehensive Test Suite Expansion
- Expanded test coverage from 101 to **118 passing tests**:
  - Added `test/unit/notification_parser_test.dart` (8/8 tests passed).
  - Added `test/unit/notification_sync_service_test.dart` (4/4 tests passed).
  - Added working days calculator tests and 12-hour rule behavioral nudge tests.
- Verified **`flutter test` (118/118 tests passed)** and **`flutter analyze` (0 issues found)**.
