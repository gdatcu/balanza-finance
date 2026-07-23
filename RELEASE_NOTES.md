# Balanza Finance v1.4.0 Release Notes

## ⚡ New Features

### 🔔 Firebase Cloud Messaging (FCM) & Push Notifications
- Integrated Firebase Cloud Messaging for cross-platform push notification support.
- Implemented `PushNotificationService` to prompt users for notification permissions on app startup or login.
- Device FCM tokens are automatically retrieved and upserted into Supabase's `user_push_tokens` table along with the device's locale language preference (`en` / `ro`) for targeted localized messaging.

---

## 🛠️ Critical Fixes & Improvements

### 🔐 CI/CD Keystore Automation
- Configured encrypted base64 signing key injection via **GitHub Repository Secrets** (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`) for clean automated GitHub Actions release packaging.

### 🎨 UI & Framework Compatibility
- **Material Drawer Wrapper**: Wrapped navigation drawer in `Material` widget to resolve Flutter 3.33+ background tile assertion issues.
- **Analysis Clean-Up**: Resolved code deprecation warnings across view components (`0 issues found` on static analysis).
