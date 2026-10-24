import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'redirect_uri.dart';

/// Public client configuration. Never use a service-role key in the app.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://iroqzjahasvmhtmsmsvy.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_r41O5ASs54lzeWRPC85caQ_ykR_v5-B',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
      authOptions: FlutterAuthClientOptions(detectSessionInUri: !kIsWeb),
    );
  }

  static bool isRecoveryUri(Uri uri) {
    if (uri.queryParameters['recovery'] == '1') return true;
    try {
      return Uri.splitQueryString(uri.fragment)['type'] == 'recovery';
    } on FormatException {
      return false;
    }
  }

  static String get recoveryRedirectUrl {
    final base = Uri.parse(
      _redirectUrl(const String.fromEnvironment('PASSWORD_RESET_REDIRECT_URL')),
    );
    return redirectUri(
      base,
      queryParameters: const {'recovery': '1'},
    ).toString();
  }

  static String get oauthRedirectUrl => _redirectUrl('');

  static String get googleRedirectUrl =>
      _redirectUrl(const String.fromEnvironment('GOOGLE_AUTH_REDIRECT_URL'));

  static String get appleRedirectUrl =>
      _redirectUrl(const String.fromEnvironment('APPLE_AUTH_REDIRECT_URL'));

  static String _redirectUrl(String configured) {
    final base = configured.isNotEmpty
        ? Uri.parse(configured)
        : kIsWeb
        ? Uri.base.resolve('.')
        : Uri.parse('https://bandlux36-ai.github.io/share-app/');
    return redirectUri(base).toString();
  }

  static String? oauthCallbackError(Uri callback, {required bool signedIn}) {
    if (isRecoveryUri(callback)) return null;
    var fragment = <String, String>{};
    try {
      fragment = Uri.splitQueryString(callback.fragment);
    } on FormatException {
      /* Never display raw callback parameters. */
    }
    final params = {...fragment, ...callback.queryParameters};
    if ([
      'otp_expired',
      'flow_state_expired',
      'flow_state_not_found',
    ].contains(params['error_code'])) {
      return 'رابط الاستعادة غير صالح أو انتهت صلاحيته. اطلب رابطًا جديدًا.';
    }
    if (params['error'] == 'access_denied') {
      return 'تم إلغاء تسجيل الدخول. يمكنك المحاولة مرة أخرى.';
    }
    if (params.containsKey('error') ||
        params.containsKey('error_code') ||
        (!signedIn &&
            (params.containsKey('code') ||
                params.containsKey('access_token')))) {
      return 'تعذّر إكمال تسجيل الدخول. حاول مرة أخرى.';
    }
    return null;
  }
}
