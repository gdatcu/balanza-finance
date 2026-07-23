import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

/// A service that interacts with the GitHub REST API.
///
/// This service is responsible for fetching release metadata from a specific
/// repository on GitHub.
class GithubApiService {
  final Dio _dio;

  /// Creates a [GithubApiService] instance.
  ///
  /// Optionally takes a [Dio] instance for customized network configurations.
  GithubApiService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches the latest release information from the specified GitHub repository.
  ///
  /// Parameters:
  /// - [ownerGithub]: The username or organization that owns the repository.
  /// - [repositoryGithub]: The name of the repository.
  /// - [apkKeyName]: A string used to identify the correct APK asset if multiple
  ///   assets exist in the release.
  /// - [tokenGithub]: An optional personal access token for authenticating
  ///   with the GitHub API (useful for private repositories or higher rate limits).
  /// - [supportedAbis]: A list of supported ABIs for the APK.
  ///
  /// Returns a [GithubAPKRelease] if a release is found, or `null` if the
  /// request fails or no release exists.
  Future<GithubAPKRelease?> getLatestGithubAPKRelease({
    required String ownerGithub,
    required String repositoryGithub,
    required String apkKeyName,
    String? tokenGithub,
    List<String>? supportedAbis,
  }) async {
    // Implementation...
    try {
      final url =
          'https://api.github.com/repos/$ownerGithub/$repositoryGithub/releases/latest';
      final headers = <String, String>{
        'Accept': 'application/vnd.github.v3+json',
      };

      if (tokenGithub != null && tokenGithub.isNotEmpty) {
        headers['Authorization'] = 'Bearer $tokenGithub';
      }

      final response = await _dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return GithubAPKRelease.fromJson(
          data,
          apkKeyName,
          supportedAbis: supportedAbis,
        );
      } else {
        debugPrint(
          'Failed to load release from github API. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'DioException fetching release info from GitHub: ${e.message}',
      );
    } catch (e) {
      debugPrint('Error fetching release info from GitHub: $e');
    }
    return null;
  }
}
