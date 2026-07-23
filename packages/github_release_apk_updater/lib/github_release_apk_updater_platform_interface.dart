import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'github_release_apk_updater_method_channel.dart';

abstract class GithubReleaseApkUpdaterPlatform extends PlatformInterface {
  /// Constructs a GithubReleaseApkUpdaterPlatform.
  GithubReleaseApkUpdaterPlatform() : super(token: _token);

  static final Object _token = Object();

  static GithubReleaseApkUpdaterPlatform _instance =
      MethodChannelGithubReleaseApkUpdater();

  /// The default instance of [GithubReleaseApkUpdaterPlatform] to use.
  ///
  /// Defaults to [MethodChannelGithubReleaseApkUpdater].
  static GithubReleaseApkUpdaterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GithubReleaseApkUpdaterPlatform] when
  /// they register themselves.
  static set instance(GithubReleaseApkUpdaterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> installApk(String filePath) {
    throw UnimplementedError('installApk() has not been implemented.');
  }

  Future<List<String>?> getSupportedAbis() {
    throw UnimplementedError('getSupportedAbis() has not been implemented.');
  }
}
