import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:balanza/l10n/app_localizations.dart';

class UpdaterService {
  final GithubReleaseApkUpdater _updater = GithubReleaseApkUpdater();
  final GithubApiService _apiService = GithubApiService();
  final ApkDownloaderService _downloader = ApkDownloaderService();

  Future<void> checkForUpdates(BuildContext context) async {
    // Only support Android platform for updates
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final supportedAbis = await _updater.getSupportedAbis();
      final release = await _apiService.getLatestGithubAPKRelease(
        ownerGithub: 'gdatcu',
        repositoryGithub: 'balanza-finance',
        apkKeyName: '',
        supportedAbis: supportedAbis,
      );

      if (release != null) {
        final currentVersion = await _updater.getCurrentAppVersion();
        final isNewer = VersionComparator().isNewerVersion(
          release.version,
          currentVersion,
        );

        if (isNewer && context.mounted) {
          _showUpdateDialog(context, release.version, release.apkUrl);
        }
      }
    } catch (_) {
      // Fail silently if offline or API limits hit
    }
  }

  void _showUpdateDialog(BuildContext context, String newVersion, String apkUrl) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.updateAvailableTitle),
          content: Text(localizations.updateAvailableMessage(newVersion)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadAndInstall(context, apkUrl);
              },
              child: Text(localizations.updateInstallButton),
            ),
          ],
        );
      },
    );
  }

  void _downloadAndInstall(BuildContext context, String apkUrl) {
    final localizations = AppLocalizations.of(context)!;
    final progressNotifier = ValueNotifier<double>(0.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (context, progress, child) {
            return AlertDialog(
              title: Text(localizations.downloadingUpdate),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 16),
                  Text('${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            );
          },
        );
      },
    );

    Future.microtask(() async {
      try {
        final filePath = await _downloader.downloadAPK(
          apkUrl,
          null, // No github token required for public repos
          (received, total) {
            if (total > 0) {
              progressNotifier.value = received / total;
            }
          },
        );

        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss progress dialog
        }

        if (filePath != null) {
          await _updater.installApk(filePath);
        }
      } catch (_) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss progress dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download update.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}

final updaterProvider = Provider<UpdaterService>((ref) {
  return UpdaterService();
});
