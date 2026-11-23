/// Reachability probe for web.
///
/// Endpoint probes are often blocked by CORS from arbitrary origins, so the
/// default web probe assumes online. Prefer a custom `connectivityStream` /
/// same-origin health check when accurate offline UX is required on web.
Future<bool> plusInternetProbe({
  required List<Uri> endpoints,
  required Duration timeout,
}) async {
  return true;
}
