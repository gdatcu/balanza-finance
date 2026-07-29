# Release Notes — v1.14.1

## 🐛 Bug Fixes & Stability Improvements

### 🛡️ Android Background Isolate & Notification Listener Crash Protection
- **Isolate Exception Safety**:
  - Wrapped background notification isolate callbacks (`_onNotificationData` & `handleNotificationEvent`) in exception-safe try/catch handlers.
- **Null-Safe Supabase Client Handling**:
  - Refactored `TransactionRepository` to gracefully handle uninitialized `Supabase.instance` when invoked from Android background notification listener isolates, preventing native process crashes (`balanza closed because this app has a bug`).
- **Permission Pre-Check**:
  - `NotificationSyncService.startListener()` now checks permission state before initializing background listener service.

---

## ✨ Features (from v1.14.0)

### 🏦 Zero-API Bank Sync via Android Notification Listener ("Pending Inbox")
- **Automated Banking Notification Interceptor**:
  - Automatically captures and parses push notifications from major banking apps and digital wallets: **Revolut** (`com.revolut.office`), **BCR (George)** (`ro.bcr.georgego`), **Salt Bank** (`ro.salt.bank`), **ING** (`ro.ing.mobile.banking`), and **Google Wallet** (`com.google.android.apps.walletnfcrel`).
- **Robust Notification Parsing Engine**:
  - `NotificationParser` utility with diacritic cleaning (`ă->a`, `ș->s`, `ț->t`), European (`1.250,50`) vs US (`1,250.50`) number parsing, and merchant auto-tagging.
- **60-Second Deduplication**:
  - Built-in deduplication engine discards duplicate transactions logged within 60 seconds (preventing double entries from Google Wallet + Bank notification pairs).
- **Interactive Pending Inbox Banner**:
  - Dashboard banner displaying pending notifications for review with `Dismissible` swipe gestures (Swipe Right = Approve, Swipe Left = Reject, Tap = Edit).

---

## 🧪 Verification
- Verified **`flutter test` (118/118 tests passed)** and **`flutter analyze` (0 issues found)**.
