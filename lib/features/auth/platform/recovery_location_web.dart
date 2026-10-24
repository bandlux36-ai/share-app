import 'dart:js_interop';

@JS('window.history.replaceState')
external void _replaceState(JSAny? state, JSString title, JSString url);

void clearRecoveryLocation() {
  final uri = Uri.base;
  final query = Map<String, String>.of(uri.queryParameters);
  for (final key in [
    'recovery',
    'code',
    'error',
    'error_code',
    'error_description',
  ]) {
    query.remove(key);
  }
  final authFragment =
      uri.fragment.contains('access_token=') ||
      uri.fragment.contains('refresh_token=') ||
      uri.fragment.contains('type=recovery');
  final clean = uri.replace(
    queryParameters: query.isEmpty ? null : query,
    query: query.isEmpty ? '' : null,
    fragment: authFragment ? '' : uri.fragment,
  );
  if (clean != uri) _replaceState(null, ''.toJS, clean.toString().toJS);
}
