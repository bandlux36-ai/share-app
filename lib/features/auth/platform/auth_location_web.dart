import 'dart:js_interop';
import '../../../core/config/redirect_uri.dart';

@JS('window.history.replaceState')
external void _replaceState(JSAny? state, JSString title, JSString url);

void clearAuthLocation() {
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
  final clean = redirectUri(
    uri,
    queryParameters: query.isEmpty ? null : query,
    fragment: authFragment ? '' : uri.fragment,
  );
  if (clean != uri) _replaceState(null, ''.toJS, clean.toString().toJS);
}
