/// Represents a GitHub release asset that contains an APK.
///
/// This model is used to store the version information, download URL,
/// and release notes for a specific GitHub release.
class GithubAPKRelease {
  /// The semantic version of the release (e.g., "1.0.0").
  final String version;

  /// The direct API download URL for the APK asset.
  final String apkUrl;

  /// The body/notes of the GitHub release.
  final String releaseNote;

  GithubAPKRelease({
    required this.version,
    required this.apkUrl,
    required this.releaseNote,
  });

  /// Factory constructor to create a [GithubAPKRelease] from a GitHub API JSON response.
  ///
  /// The [apkKey] parameter is used to filter assets by name if the release
  /// contains multiple APK files. If empty, it returns the first APK found.
  ///
  /// The [supportedAbis] parameter is an optional list of CPU architectures
  /// supported by the device, used to find an architecture-specific APK.
  ///
  /// Throws an [Exception] if no APK asset is found.
  factory GithubAPKRelease.fromJson(
    Map<String, dynamic> json,
    String apkKey, {
    List<String>? supportedAbis,
  }) {
    final tagName = json['tag_name'] as String;
    final body = json['body'] as String? ?? '';
    final version = tagName.startsWith('v.')
        ? tagName.substring(2)
        : tagName.startsWith('v')
        ? tagName.substring(1)
        : tagName;

    final assets = json['assets'] as List<dynamic>? ?? [];
    String? apkUrl;

    // 1. Try to find an APK that matches one of the supported ABIs
    if (supportedAbis != null && supportedAbis.isNotEmpty) {
      for (final abi in supportedAbis) {
        for (final asset in assets) {
          final String name = asset['name'] as String;
          // use asset['url'] instead asset['browser_download_url'] to use token for download
          final String url = asset['url'] as String;

          if (name.endsWith('.apk') && name.contains(abi)) {
            // If apkKey is provided, it must also match
            if (apkKey.isEmpty || name.contains(apkKey)) {
              apkUrl = url;
              break;
            }
          }
        }
        if (apkUrl != null) break;
      }
    }

    // 2. Fallback: Try to find an APK that matches the apkKey (if no ABI found)
    if (apkUrl == null) {
      const knownAbis = [
        'arm64-v8a',
        'armeabi-v7a',
        'armeabi',
        'x86_64',
        'x86',
        'mips64',
        'mips',
      ];

      // Try to find a "generic" APK first (one that doesn't contain any known ABI in its name)
      for (final asset in assets) {
        final String name = asset['name'] as String;
        final String url =
            (asset['browser_download_url'] ?? asset['url']) as String;

        if (name.endsWith('.apk')) {
          final containsAbi = knownAbis.any((abi) => name.contains(abi));
          if (!containsAbi && (apkKey.isEmpty || name.contains(apkKey))) {
            apkUrl = url;
            break;
          }
        }
      }

      // If still no APK found, pick the first one that matches apkKey
      if (apkUrl == null) {
        for (final asset in assets) {
          final String name = asset['name'] as String;
          final String url =
              (asset['browser_download_url'] ?? asset['url']) as String;

          if (name.endsWith('.apk')) {
            if (apkKey.isEmpty || name.contains(apkKey)) {
              apkUrl = url;
              break;
            }
          }
        }
      }
    }

    if (apkUrl == null) {
      throw Exception('APK asset not found for key: $apkKey');
    }

    return GithubAPKRelease(
      version: version,
      apkUrl: apkUrl,
      releaseNote: body,
    );
  }
}
