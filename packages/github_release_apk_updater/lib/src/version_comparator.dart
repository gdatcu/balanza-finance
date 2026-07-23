/// A utility class for comparing semantic version strings.
///
/// This class helps determine if a new version is available by comparing
/// the current app version with a version retrieved from a remote source.
class VersionComparator {
  /// Compares two semantic version strings.
  ///
  /// Returns `true` if [serverVersion] is strictly newer than [currentVersion].
  ///
  /// The expected format is "X.Y.Z" where X, Y, and Z are integers.
  /// If a part cannot be parsed as an integer, it defaults to 0.
  bool isNewerVersion(String serverVersion, String currentVersion) {
    // Implementation...
    try {
      final serverVersions = serverVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final currentVersions = currentVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      for (int i = 0; i < serverVersions.length; i++) {
        if (i >= currentVersions.length) return true;
        if (serverVersions[i] > currentVersions[i]) {
          return true;
        }
        if (serverVersions[i] < currentVersions[i]) {
          return false;
        }
      }
      return false; // They are equal or server version is shorter and parts matched.
    } catch (e) {
      // In case of unexpected parsing errors safely assume no new version.
      return false;
    }
  }
}
