import 'dart:async';
import 'dart:io';

/// Reachability probe for VM / mobile / desktop (`dart:io`).
Future<bool> plusInternetProbe({
  required List<Uri> endpoints,
  required Duration timeout,
}) async {
  for (final endpoint in endpoints) {
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = timeout;
      final request = await client.getUrl(endpoint).timeout(timeout);
      request.followRedirects = false;
      final response = await request.close().timeout(timeout);
      // Drain so the connection can close cleanly.
      await response.drain<void>().timeout(timeout);
      final code = response.statusCode;
      if (code >= 200 && code < 400) {
        return true;
      }
    } on Object {
      // Try the next endpoint.
    } finally {
      client?.close(force: true);
    }
  }
  return false;
}
