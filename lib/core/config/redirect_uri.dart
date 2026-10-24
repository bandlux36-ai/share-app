/// Rebuild an auth redirect without retaining tokens or empty URL delimiters.
Uri redirectUri(
  Uri source, {
  Map<String, String>? queryParameters,
  String? fragment,
}) {
  return Uri(
    scheme: source.scheme,
    userInfo: source.userInfo,
    host: source.hasAuthority ? source.host : null,
    port: source.hasPort ? source.port : null,
    path: source.path,
    queryParameters: queryParameters?.isNotEmpty == true
        ? queryParameters
        : null,
    fragment: fragment?.isNotEmpty == true ? fragment : null,
  );
}
