import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'github_release_apk_updater_platform_interface.dart';

/// An implementation of [GithubReleaseApkUpdaterPlatform] that uses method channels.
class MethodChannelGithubReleaseApkUpdater
    extends GithubReleaseApkUpdaterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('github_release_apk_updater');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> installApk(String filePath) async {
    try {
      await methodChannel.invokeMethod('installApk', {'filePath': filePath});
    } on PlatformException catch (e) {
      debugPrint('Error triggering installation: ${e.message}');
    } catch (e) {
      debugPrint('Error triggering installation: $e');
    }
  }

  @override
  Future<List<String>?> getSupportedAbis() async {
    final abis = await methodChannel.invokeListMethod<String>(
      'getSupportedAbis',
    );
    return abis;
  }
}
