# Release Notes — v1.14.3

## 🐛 Critical Android Manifest Service Fix

### 🛡️ Remove Invalid Legacy Service Declaration in AndroidManifest.xml
- **Root Cause**:
  - Removed an invalid, non-existent legacy service tag (`com.cachet.flutter_notification_listener.NotificationListener`) from `android/app/src/main/AndroidManifest.xml`.
  - Android OS attempted to instantiate this non-existent class whenever Notification Access was enabled, triggering an unhandled native `ClassNotFoundException` that crashed the app process immediately on launch (`balanza closed because this app has a bug`).
- **Resolution**:
  - `flutter_notification_listener`'s valid native service (`im.nian.flutter_notification_listener.NotificationsListenerService`) is now automatically merged by Gradle without conflicts, completely fixing the startup and permission crash.

---

## ✨ Features (v1.14.0)

### 🏦 Zero-API Bank Sync via Android Notification Listener ("Pending Inbox")
- **Automated Banking Notification Interceptor**:
  - Automatically captures and parses push notifications from major banking apps and digital wallets: **Revolut** (`com.revolut.office`), **BCR (George)** (`ro.bcr.georgego`), **Salt Bank** (`ro.salt.bank`), **ING** (`ro.ing.mobile.banking`), and **Google Wallet** (`com.google.android.apps.walletnfcrel`).
- **Robust Notification Parsing Engine**:
  - `NotificationParser` utility with diacritic cleaning (`ă->a`, `ș->s`, `ț->t`), European (`1.250,50`) vs US (`1,250.50`) number parsing, and merchant auto-tagging.
- **60-Second Deduplication**:
  - Built-in deduplication engine discards duplicate transactions logged within 60 seconds.
- **Interactive Pending Inbox Banner**:
  - Dashboard banner displaying pending notifications for review with `Dismissible` swipe gestures (Swipe Right = Approve, Swipe Left = Reject, Tap = Edit).

---

## 🧪 Verification
- Verified **`flutter analyze` (0 issues found)**.
