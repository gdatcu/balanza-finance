# ⚖️ Balanza Finance

**Balanza Finance** is a modern, high-performance personal finance Android application built with **Flutter**, **Riverpod**, and **Supabase (PostgreSQL)**. It gives users complete control over their money through real-time expense tracking, net worth aggregation, interactive data visualizations, and multi-language support.

---

## ✨ Features

- **💰 Expense & Income Tracking:** Quickly log transactions, categorize spending, and filter by date, account, or category.
- **📈 Net Worth & Accounts:** Aggregated view of your total financial status across multiple cash, bank, savings, and credit accounts.
- **📊 Interactive Analytics:** Rich chart visualisations (pie/donut breakdowns and trend lines) powered by `fl_chart`.
- **🔒 Biometric & Secure Auth:** Supabase PostgreSQL backend authentication combined with Android biometric (Fingerprint/Face Unlock) local authentication.
- **🌍 Internationalization (i18n):** Full native localization in **English** and **Romanian** (`en` / `ro`).
- **🔄 Auto-Updater:** Built-in in-app updater that automatically detects and installs new releases directly from GitHub Releases.
- **🎨 Modern UI:** Sleek, responsive Material 3 design with dark mode support.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology | Rationale |
| :--- | :--- | :--- |
| **Frontend Framework** | [Flutter](https://flutter.dev) (Dart) | High-performance, cross-platform UI rendering |
| **State Management** | [Riverpod](https://riverpod.dev) | Declarative, compile-safe state management |
| **Backend & Database** | [Supabase](https://supabase.com) (PostgreSQL) | Relational database ensuring strict financial ledger integrity |
| **Data Visualization** | [fl_chart](https://pub.dev/packages/fl_chart) | Customizable pie, bar, and line chart engine |
| **Biometric Auth** | [local_auth](https://pub.dev/packages/local_auth) | Local device biometric verification |
| **Auto-Updater** | `github_release_apk_updater` | In-app APK updates directly from GitHub Releases |

---

## 📦 Installation & Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.8.1` or newer)
- [Android Studio](https://developer.android.com/studio) or VS Code with Flutter extension
- JDK 17+

### 1. Clone the repository
```bash
git clone https://github.com/gdatcu/balanza-finance.git
cd balanza-finance
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run locally
```bash
flutter run
```

---

## 🚀 Building & Releasing

To build a signed release APK:

```powershell
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

The output binary will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License

This project is private and intended for personal finance management.
