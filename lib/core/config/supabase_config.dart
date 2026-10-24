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
    await Supabase.initialize(url: url, publishableKey: publishableKey);
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
    const configured = String.fromEnvironment('PASSWORD_RESET_REDIRECT_URL');
    final base = configured.isNotEmpty
        ? Uri.parse(configured)
        : kIsWeb
        ? Uri.base.resolve('.')
        : Uri.parse('https://bandlux36-ai.github.io/share-app/');
    return redirectUri(base, queryParameters: {'recovery': '1'}).toString();
  }

  static String get googleRedirectUrl {
    const configured = String.fromEnvironment('GOOGLE_AUTH_REDIRECT_URL');
    final base = configured.isNotEmpty
        ? Uri.parse(configured)
        : kIsWeb
        ? Uri.base.resolve('.')
        : Uri.parse('https://bandlux36-ai.github.io/share-app/');
    return redirectUri(base).toString();
  }

  static String? googleCallbackError(Uri callback, {required bool signedIn}) {
    if (isRecoveryUri(callback)) return null;
    var fragment = <String, String>{};
    try {
      fragment = Uri.splitQueryString(callback.fragment);
    } on FormatException {
      /* Never display raw callback parameters. */
    }
    final params = {...fragment, ...callback.queryParameters};
    if (params['error'] == 'access_denied') {
      return 'تم إلغاء تسجيل الدخول بـGoogle. يمكنك المحاولة مرة أخرى.';
    }
    if (params.containsKey('error') ||
        params.containsKey('error_code') ||
        (!signedIn &&
            (params.containsKey('code') ||
                params.containsKey('access_token')))) {
      return 'تعذّر إكمال تسجيل الدخول بـGoogle. حاول مرة أخرى.';
    }
    return null;
  }
}
