import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// A service responsible for downloading APK files from a URL.
///
/// This service handles the file transfer from a remote server (like GitHub)
/// to the device's external storage directory.
class ApkDownloaderService {
  final Dio _dio;

  /// Creates an [ApkDownloaderService] instance.
  ///
  /// Optionally takes a [Dio] instance for customized network configurations.
  ApkDownloaderService({Dio? dio}) : _dio = dio ?? Dio();

  /// Downloads an APK from the specified [url] to the device's external storage.
  ///
  /// Parameters:
  /// - [url]: The direct download URL of the APK asset.
  /// - [tokenGithub]: An optional authentication token for downloading from private repos.
  /// - [onProgress]: A callback function to track the download progress.
  ///
  /// Returns the local [String] file path of the downloaded APK package,
  /// or `null` if the download fails.
  Future<String?> downloadAPK(
    String url,
    String? tokenGithub,
    Function(int received, int total)? onProgress,
  ) async {
    // Implementation...
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint('Cannot get external storage directory');
        return null;
      }
      final headers = <String, String>{'Accept': 'application/octet-stream'};
      if (tokenGithub != null && tokenGithub.isNotEmpty) {
        headers['Authorization'] = 'Bearer $tokenGithub';
      }

      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;
      final filePath = '${directory.path}/$filename';

      debugPrint('Downloading APK from: $url');
      debugPrint('Downloading APK to: $filePath');

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(headers: headers, followRedirects: true),
      );

      return filePath;
    } on DioException catch (e) {
      debugPrint('DioException downloading APK: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error downloading APK: $e');
      return null;
    }
  }
}
