# Balanza Finance v1.3.1 Release Notes

## 🛠️ Critical Fixes & Improvements

### 🔐 Google Sign-In Authentication Fix
- Fixed `PlatformException(sign_in_failed, 10)` authentication error on release builds by configuring a dedicated release keystore (`upload-keystore.jks`) and adding ProGuard preservation rules for Google Play Services (`com.google.android.gms`).
- Migrated keystore signing binary and credentials to encrypted **GitHub Repository Secrets** (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`) for secure CI/CD builds.

### 🎨 UI & Framework Compatibility
- **ListTile / Material Wrapper**: Fixed Flutter 3.33+ ListTile background container assertion by wrapping navigation drawer contents in a `Material` widget.
- **Lints & Deprecations**: Resolved code deprecation warnings across view components for clean static analysis execution.

---

## ⚡ Features (Introduced in 1.3.x Series)

### 🔄 Realtime Automatic Database Sync
- Live Supabase PostgreSQL database streams for transactions and budget limits. Changes automatically sync across devices in real-time.

### 📱 Dashboard Pull-to-Refresh Gesture
- Added responsive pull-to-refresh on dashboard list views to manually force-sync transaction data on demand.

### 🤖 Automated GitHub Actions CI/CD
- Automated testing (`flutter test`), static analysis (`flutter analyze`), and release APK packaging (`app-release.apk`) on tag pushes (`v*`).
