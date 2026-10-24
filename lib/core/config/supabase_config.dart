import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

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
    return base
        .replace(queryParameters: {'recovery': '1'}, fragment: '')
        .toString();
  }
}
