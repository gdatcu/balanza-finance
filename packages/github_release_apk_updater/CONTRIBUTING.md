# Contributing to github_release_apk_updater

Thank you for your interest in contributing! 🎉  
This is a Flutter plugin for Android that enables automatic app updates via GitHub Releases. Contributions of all kinds are welcome — bug fixes, new features, documentation improvements, and test coverage.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Making Changes](#making-changes)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting a Pull Request](#submitting-a-pull-request)
- [Reporting Bugs](#reporting-bugs)
- [Requesting Features](#requesting-features)

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

---

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/github_release_apk_updater.git
   cd github_release_apk_updater
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/dozmaz/github_release_apk_updater.git
   ```

---

## Development Setup

### Prerequisites

| Tool           | Minimum Version  |
| -------------- | ---------------- |
| Flutter SDK    | ≥ 3.3.0          |
| Dart SDK       | ≥ 3.11.3         |
| Android SDK    | API 21+          |
| Java / JDK     | 17+              |

### Install Dependencies

```bash
flutter pub get
```

### Run the Example App

Connect an Android device (or emulator) and run:

```bash
cd example
flutter pub get
flutter run
```

> **Note**: The example app requires a real or emulated Android device. This plugin is Android-only.

---

## Project Structure

```
github_release_apk_updater/
├── android/                  # Kotlin Android plugin implementation
│   └── src/main/kotlin/...   # GithubReleaseApkUpdaterPlugin.kt
├── lib/
│   ├── github_release_apk_updater.dart          # Public API entry point
│   ├── github_release_apk_updater_method_channel.dart
│   ├── github_release_apk_updater_platform_interface.dart
│   └── src/
│       ├── apk_downloader_service.dart          # APK download logic
│       ├── github_api_service.dart              # GitHub API calls
│       ├── version_comparator.dart              # Semver comparison
│       └── models/                              # Data models
├── test/                     # Unit & widget tests
├── example/                  # Full example Flutter app
├── CHANGELOG.md
├── pubspec.yaml
└── README.md
```

---

## Making Changes

### Branching Strategy

Create a feature branch from `main`:

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/your-bug-description
```

**Branch naming conventions:**

| Prefix    | Use case                         |
| --------- | -------------------------------- |
| `feat/`   | New features                     |
| `fix/`    | Bug fixes                        |
| `docs/`   | Documentation only changes       |
| `test/`   | Adding or improving tests        |
| `chore/`  | Maintenance, dependency updates  |
| `refactor/` | Code restructuring (no feature change) |

---

## Coding Standards

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- Add **doc comments** (`///`) to all public APIs.
- Run `dart format .` before committing.
- Run `flutter analyze` and resolve all warnings/errors before submitting.
- Keep methods focused and testable — avoid large monolithic functions.
- Do **not** expose API tokens or credentials in logs. Use `debugPrint` for development output, never for sensitive data.

---

## Testing

All contributions must maintain or improve test coverage.

### Running Tests

```bash
# Unit tests
flutter test

# With coverage
flutter test --coverage
```

### Writing Tests

- Place tests under `test/` mirroring the `lib/src/` structure.
- Use `mockito` (already a dev dependency) for mocking `Dio` and platform channels.
- Add regression tests for any bug you fix.

### Build Verification

```bash
# Verify a debug APK builds without errors
flutter build apk --debug
```

---

## Submitting a Pull Request

1. **Sync with upstream** before opening a PR:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Ensure all checks pass locally**:
   ```bash
   dart format .
   flutter analyze
   flutter test
   flutter build apk --debug
   ```

3. **Push your branch** and open a Pull Request against `main`.

4. **Fill in the PR template** completely — describe the problem, the approach, and how to test it.

5. **Link related issues** using keywords like `Closes #42` or `Fixes #17` in the PR description.

### PR Review Checklist

- [ ] Code follows Dart style guide and is formatted
- [ ] `flutter analyze` passes with no warnings
- [ ] New/changed functionality is covered by tests
- [ ] `flutter test` passes
- [ ] `flutter build apk --debug` succeeds
- [ ] `CHANGELOG.md` is updated under an `## Unreleased` section
- [ ] Public API changes include updated doc comments

---

## Reporting Bugs

Use the **Bug Report** issue template when reporting a bug. Please include:

- Plugin version (`pubspec.yaml`)
- Flutter & Dart SDK versions (`flutter --version`)
- Android device/emulator details (API level, ABI)
- A **minimal reproduction** case or code snippet
- Expected vs. actual behavior
- Relevant logs or stack traces

---

## Requesting Features

Use the **Feature Request** issue template. Good feature requests include:

- The use case or problem you're trying to solve
- Proposed API or behavior (pseudocode is fine)
- Whether you're willing to implement it yourself

---

## Questions?

Feel free to open a [Discussion](https://github.com/dozmaz/github_release_apk_updater/discussions) for general questions that are not bugs or feature requests.

---

Thank you for making `github_release_apk_updater` better! 🚀
