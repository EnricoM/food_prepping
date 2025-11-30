import 'package:http/http.dart' as http;

/// Shared HTTP utilities for recipe parsing and domain discovery.
class HttpUtils {
  /// Default header candidates for HTTP requests.
  static const List<Map<String, String>> defaultHeaderCandidates = [
    {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9,nl;q=0.8',
    },
    {
      'User-Agent': 'curl/8.5.0',
      'Accept': '*/*',
    },
  ];

  /// Simplified header candidates for domain discovery (no Accept-Language).
  static const List<Map<String, String>> discoveryHeaderCandidates = [
    {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
    },
    {
      'User-Agent': 'curl/8.5.0',
      'Accept': '*/*',
    },
  ];

  /// Extracts cookie header value from Set-Cookie header.
  static String? cookieHeaderFromSetCookie(String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) {
      return null;
    }
    final matches = RegExp(r'([^=,\s]+=[^;]+)').allMatches(setCookie);
    final values =
        matches.map((match) => match.group(0)).whereType<String>().toList();
    if (values.isEmpty) {
      return null;
    }
    return values.join('; ');
  }

  /// Checks if a status code indicates we should retry with cookies.
  static bool shouldRetryWithCookies(int statusCode) =>
      statusCode == 401 || statusCode == 403 || statusCode == 503;

  /// Fetches cookies from the root path of a domain.
  static Future<String?> fetchHostCookies(
    http.Client client,
    Uri uri,
    Map<String, String> headers,
    Duration timeout,
  ) async {
    final rootUri = uri.replace(path: '/');
    try {
      final retryHeaders = Map<String, String>.from(headers)
        ..remove('Accept-Encoding');
      final response =
          await client.get(rootUri, headers: retryHeaders).timeout(timeout);
      return cookieHeaderFromSetCookie(response.headers['set-cookie']);
    } catch (_) {
      return null;
    }
  }
}

