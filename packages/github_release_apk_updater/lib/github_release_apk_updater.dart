import 'package:package_info_plus/package_info_plus.dart';

import 'github_release_apk_updater_platform_interface.dart';
export 'src/models.dart';
export 'src/github_api_service.dart';
export 'src/apk_downloader_service.dart';
export 'src/version_comparator.dart';

/// The main class for the GitHub Release APK Updater plugin.
///
/// This class provides high-level methods to interact with native platform
/// features like APK installation and version retrieval.
class GithubReleaseApkUpdater {
  /// Invokes the native method to get the current platform version.
  ///
  /// This is primarily used to verify the plugin connection.
  Future<String?> getPlatformVersion() {
    return GithubReleaseApkUpdaterPlatform.instance.getPlatformVersion();
  }

  /// Installs an APK from the given local [filePath].
  ///
  /// This method launches the Android native APK installer. For this to work,
  /// you must have configured a `FileProvider` in your `AndroidManifest.xml`.
  ///
  /// Throws a [PlatformException] if the installation fails or if the file
  /// path is invalid.
  Future<void> installApk(String filePath) {
    return GithubReleaseApkUpdaterPlatform.instance.installApk(filePath);
  }

  /// Retrieves the current application version from the platform.
  ///
  /// This is a convenience wrapper around `package_info_plus`.
  /// Returns a [String] representing the semantic version (e.g., "1.0.0").
  Future<String> getCurrentAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Retrieves the list of supported ABIs (CPU architectures) for the device.
  ///
  /// Returns a [List<String>] of supported ABIs (e.g., ["arm64-v8a", "armeabi-v7a"]).
  Future<List<String>?> getSupportedAbis() {
    return GithubReleaseApkUpdaterPlatform.instance.getSupportedAbis();
  }
}
