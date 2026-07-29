# Release Notes — v1.15.5

## 🔒 Android 11+ Package Visibility Sandbox & Notification Delivery Fix

### 🛡️ Android 11/12/13/14/15 Package Queries Permission
- **Root Cause Identified**:
  - On Android 11+ (API 30+), Android's Package Visibility Sandbox restricts apps from inspecting or receiving notification events from un-queried external app packages.
- **Resolution**:
  - Added `<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />` and explicit `<queries>` declarations for **BCR George** (`ro.bcr.georgego`), **Revolut** (`com.revolut.office`), **ING** (`ro.ing.mobile.banking`), **Salt Bank** (`ro.salt.bank`), and **Google Wallet** (`com.google.android.apps.walletnfcrel`) in `AndroidManifest.xml`.
  - Android OS now delivers live bank notification events directly to Balanza Finance!

### 📱 Samsung One UI Battery Optimization Instructions
- To ensure Samsung One UI / Xiaomi does not kill background sync:
  - Open **Phone Settings ⚙️ -> Apps -> Balanza -> Battery -> Select "Unrestricted"**.

---

## 🧪 Verification
- **`flutter analyze`**: 0 issues found!
