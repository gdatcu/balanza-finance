# Project Agent Rules
- Architecture: Feature-based folder structure
- State management: Provider or Riverpod
- Backend: Supabase (PostgreSQL)
- UI: Use `fl_chart` for all data visualizations

# Project Architecture: Personal Finance App

This document outlines the zero-cost technology stack and architecture decisions for building an Android personal finance application, emphasizing relational data integrity and rich data visualization.

## 1. Frontend Architecture

| Component | Technology | Rationale |
| :---- | :---- | :---- |
| Framework | Flutter (Dart) | High-performance custom UI rendering, essential for the chart-heavy requirements of a finance app. Allows for a future iOS build at no extra cost. |
| Chart Library | fl_chart | Open-source and highly customizable for pie, bar, and line charts. |
| IDE | Android Studio / VS Code | 100% free and natively supports Flutter development. |

## 2. Backend & Database

| Component | Technology | Rationale |
| :---- | :---- | :---- |
| Database Platform | Supabase | Free tier (50,000 MAU, 500MB DB space). Open-source Firebase alternative. |
| Database Type | PostgreSQL | Relational database structure is mandatory for financial ledger integrity (prevents floating-point/sync anomalies seen in NoSQL). |

## 3. Design & Planning

> * **Prototyping:** Figma (Free tier for collaborative design)  
> * **Iconography:** Material Design Icons (native to Flutter)

## 4. Version Control & CI/CD

> * **Code Hosting:** GitHub (Free private repositories)  
> * **Build Automation:** GitHub Actions (Automated Android .apk generation)

## 5. Initial Development Roadmap

> 1. **Database Schema Design:** Map out SQL tables for Users, Accounts, Categories, and Transactions.  
> 2. **Core CRUD Operations:** Build basic Flutter interfaces to add, read, update, and delete expenses connected to the Supabase backend.  
> 3. **Auth & State Management:** Implement Supabase Authentication and setup Flutter state management (e.g., Riverpod or Provider).  
> 4. **Budgets & Mathematics:** Implement logic for monthly expense aggregation and budget comparisons.  
> 5. **Data Visualization:** Integrate  
>    fl_chart to build interactive visual reports.

## 6. Release Process (In-App Auto-Updater)

The app uses `github_release_apk_updater` (local path dep in `packages/`) to check for and install updates via GitHub Releases. Follow these steps exactly for every new release:

### Step 1 — Bump the version
In `pubspec.yaml`, increment the `version` field:
```yaml
version: 1.2.0+3  # format: semver+buildNumber
```
The `versionName` (e.g. `1.2.0`) is what the updater compares against GitHub release tags.

### Step 2 — Build the signed release APK
```powershell
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```
Output: `build\app\outputs\flutter-apk\app-release.apk`

### Step 3 — Commit and push
```powershell
git add .
git commit -m "chore(release): bump version to 1.2.0"
git push
```

### Step 4 — Create a GitHub Release
1. Go to `https://github.com/gdatcu/balanza-finance/releases/new`
2. Set the **tag** to match the version exactly: `v1.2.0`
3. Set the **release title** to `Balanza Finance v1.2.0`
4. Upload `app-release.apk` as a release **asset**
5. Publish the release

### How users receive the update
- On next app launch, `UpdaterService` (in `lib/features/settings/providers/updater_provider.dart`) fetches the latest GitHub release tag.
- If the remote tag is newer, a localized dialog is shown (EN/RO).
- The user taps **Actualizează** → APK downloads with a progress bar → native Android installer opens.

### Important Notes
- The `packages/github_release_apk_updater` directory is a **git submodule** (embedded repo). Its `build.gradle.kts` has been patched to work with the project's Kotlin/Gradle versions — do not re-clone it without re-applying the patches.
- `minSdk` is fixed at **24** (Android 7.0+) due to the updater plugin requirement.
- `compileSdk` is fixed at **36** and `ndkVersion` at **27.0.12077973**.
