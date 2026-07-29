# Release Notes — v1.14.4

## 🐛 Fix Notification Listener Visibility in Android Settings

### 🛡️ Add Official Plugin Service & Receiver to AndroidManifest.xml
- **Root Cause**:
  - `balanza` disappeared from Android's **Notification Access** settings list because Android OS requires an explicit `<service>` tag with `android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"` and `<action android:name="android.service.notification.NotificationListenerService"/>`.
- **Resolution**:
  - Configured the official package service (`im.zoe.labs.flutter_notification_listener.NotificationsHandlerService`) and `RebootBroadcastReceiver` in `android/app/src/main/AndroidManifest.xml`.
  - Added Android 13/14 foreground service & notification permissions (`WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE_SPECIAL_USE`).
  - `balanza` now correctly appears in Android's **Notification Access** settings screen and allows toggling permission without crashing or disappearing!

---

## ✨ Features (v1.14.0)

### 🏦 Zero-API Bank Sync via Android Notification Listener ("Pending Inbox")
- **Automated Banking Notification Interceptor**:
  - Automatically captures and parses push notifications from major banking apps and digital wallets: **Revolut** (`com.revolut.office`), **BCR (George)** (`ro.bcr.georgego`), **Salt Bank** (`ro.salt.bank`), **ING** (`ro.ing.mobile.banking`), and **Google Wallet** (`com.google.android.apps.walletnfcrel`).
- **Robust Notification Parsing Engine**:
  - `NotificationParser` utility with diacritic cleaning (`ă->a`, `ș->s`, `ț->t`), European (`1.250,50`) vs US (`1,250.50`) number parsing, and merchant auto-tagging.
- **60-Second Deduplication**:
  - Discards duplicate transactions logged within 60 seconds.
- **Interactive Pending Inbox Banner**:
  - Dashboard banner displaying pending notifications for review with `Dismissible` swipe gestures (Swipe Right = Approve, Swipe Left = Reject, Tap = Edit).

---

## 🧪 Verification
- Verified **`flutter analyze` (0 issues found)**.
