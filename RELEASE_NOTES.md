# Balanza Finance v1.3.0 Release Notes

## ⚡ What's New

### 🔄 Realtime Automatic Database Sync
- Transactions and monthly budget limits now stream live updates directly from Supabase PostgreSQL in real-time.
- Visual charts and summaries refresh instantly across devices without needing to reopen the app.

### 📱 Manual Pull-to-Refresh Gesture
- Added smooth Pull-to-Refresh support to the main financial dashboard.
- Swipe down on any transaction list to manually re-sync your financial data on demand.

### 🤖 CI/CD Release Automation
- Fully automated build and release deployment via GitHub Actions.
- Automated static analysis and test validation on every pull request and release build.

---

## 🛠️ Enhancements & Performance Fixes
- **Wealth Advisor**: Improved budget threshold evaluation and reactivity for over-budget and category warnings.
- **State Management**: Upgraded Riverpod `StreamProvider` architecture for seamless data updates.
- **In-App Updater**: Patched plugin SDK dependencies for reliable background and manual app updates on Android 7.0+ (API 24-36).
