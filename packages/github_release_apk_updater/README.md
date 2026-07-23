# GitHub Release APK Updater

[![pub package](https://img.shields.io/pub/v/github_release_apk_updater.svg)](https://pub.dev/packages/github_release_apk_updater)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin for Android that enables automatic updates by fetching release information directly from a GitHub repository. It handles checking for newer versions, downloading the APK, and launching the installation process. Aditionally, it provides authentication by token to use private repositories.

## Features

- **GitHub Release Integration**: Fetch latest release metadata (tag, assets, release notes).
- **Version Comparison**: Built-in semantic versioning comparison between the installed app and the GitHub release.
- **Background Downloading**: Downloads the APK to a secure local directory using `dio`.
- **Easy Installation**: Launches the Android native APK installer directly from your app.
- **Customizable UI**: Use the library headless to build your own update dialogs.

## Getting started

### Android Setup

1.  **File Provider**: You must define a `FileProvider` in your `AndroidManifest.xml` to allow the package to share the downloaded APK with the system installer.

```xml
<manifest ...>
    <application ...>
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
    </application>
</manifest>
```

2.  **File Paths**: Create `android/app/src/main/res/xml/file_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
</paths>
```

## Usage

### Create a GitHub tag and release

1.  Go to your GitHub repository and navigate to the "Releases" section.
2.  Click on "Draft a new release".
3.  Fill in the release details:
    - **Tag version**: Use semantic versioning (e.g., `v1.0.0`).
    - **Release title**: A descriptive title for the release.
    - **Description**: Add release notes or changelog information.
4.  Upload your APK file as an asset by dragging and dropping it into the "Attach binaries by dropping them here or selecting them" area.
5.  Once everything is filled out, click "Publish release" to make it available.

### Simple Update Flow

```dart
import 'package:github_release_apk_updater/github_release_apk_updater.dart';

void checkForUpdates() async {
  final updater = GithubReleaseApkUpdater();
  final apiService = GithubApiService();

  // 1. Get supported ABIs for the device
  final supportedAbis = await updater.getSupportedAbis();

  // 2. Get latest release info from GitHub
  final release = await apiService.getLatestGithubAPKRelease(
    ownerGithub: 'guido-cutipa',
    repositoryGithub: 'dummy-repo',
    apkKeyName: '', // Optional: filter by name
    supportedAbis: supportedAbis,
  );

  if (release != null) {
    // 3. Compare versions
    final currentVersion = await updater.getCurrentAppVersion();
    final isNewer = VersionComparator().isNewerVersion(
      release.version,
      currentVersion,
    );

    if (isNewer) {
      // 4. Download APK
      final downloader = ApkDownloaderService();
      final filePath = await downloader.downloadAPK(
        release.apkUrl,
        null, // optional token
        (received, total) {
          // progress callback
        },
      );

      if (filePath != null) {
        // 5. Install
        await updater.installApk(filePath);
      }
    }
  }
}
```

## Example App

- A complete example app demonstrating the usage of the `github_release_apk_updater` package can be found in the [example]
- Modify main.dart to include your GitHub repository details and run the app to see the update flow in action.
```dart
  final ownerGithub = 'guido-cutipa';
  final repositoryGithub = 'dummy-repo';
  final apkKeyName = ''; // Optional
  final supportedAbis = await _githubReleaseApkUpdaterPlugin.getSupportedAbis();
  dynamic tokenGithub; // optional: only needed for private repos
```
- Compile and run the example app on an Android device to test the update functionality.

## Additional information

- **Repository**: [https://github.com/dozmaz/github_release_apk_updater](https://github.com/dozmaz/github_release_apk_updater)
- **Issues**: [https://github.com/dozmaz/github_release_apk_updater/issues](https://github.com/dozmaz/github_release_apk_updater/issues)
- **License**: MIT
