/// Fallback probe used when neither `dart:io` nor `dart:html` is available.
Future<bool> plusInternetProbe({
  required List<Uri> endpoints,
  required Duration timeout,
}) async {
  return false;
}
