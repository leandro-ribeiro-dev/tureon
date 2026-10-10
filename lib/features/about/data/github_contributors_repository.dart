import 'dart:convert';
import 'dart:io';

import '../domain/github_contributor.dart';

class GitHubContributorsRepository {
  static const _pageSize = 100;
  static const _timeout = Duration(seconds: 15);

  Future<List<GitHubContributor>> listContributors(String repository) async {
    final parts = repository.split('/');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
      throw ArgumentError.value(
        repository,
        'repository',
        'Expected owner/name',
      );
    }

    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final byLogin = <String, GitHubContributor>{};
      for (var page = 1; ; page++) {
        final uri = Uri.https(
          'api.github.com',
          '/repos/${parts[0]}/${parts[1]}/contributors',
          {'per_page': '$_pageSize', 'page': '$page'},
        );
        final request = await client.getUrl(uri).timeout(_timeout);
        request.headers
          ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
          ..set(HttpHeaders.userAgentHeader, 'Tureon');
        final response = await request.close().timeout(_timeout);
        if (response.statusCode != HttpStatus.ok) {
          throw GitHubContributorsException(response.statusCode);
        }

        final body = await utf8.decoder.bind(response).join().timeout(_timeout);
        final decoded = jsonDecode(body);
        if (decoded is! List<Object?>) {
          throw const FormatException('Unexpected contributors response.');
        }
        for (final item in decoded.whereType<Map<String, Object?>>()) {
          if (item['type'] != 'User') continue;
          final contributor = _parseContributor(item);
          byLogin[contributor.login.toLowerCase()] = contributor;
        }
        if (decoded.length < _pageSize) break;
      }

      final result = byLogin.values.toList()
        ..sort(
          (a, b) => a.login.toLowerCase().compareTo(b.login.toLowerCase()),
        );
      return result;
    } finally {
      client.close(force: true);
    }
  }
}

GitHubContributor _parseContributor(Map<String, Object?> json) {
  final login = json['login'];
  final profileUrl = json['html_url'];
  final avatarUrl = json['avatar_url'];
  if (login is! String || profileUrl is! String || avatarUrl is! String) {
    throw const FormatException('Contributor data is incomplete.');
  }
  return GitHubContributor(
    login: login,
    profileUrl: profileUrl,
    avatarUrl: avatarUrl,
  );
}

class GitHubContributorsException implements Exception {
  const GitHubContributorsException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'GitHub returned HTTP $statusCode.';
}
