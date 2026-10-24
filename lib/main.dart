import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'features/auth/platform/auth_location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/data/oauth_provider_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Capture recovery state and OAuth errors before the SDK consumes the URL.
  final callback = Uri.base;
  var passwordRecovery = SupabaseConfig.isRecoveryUri(callback);
  await SupabaseConfig.initialize();
  String? callbackError;
  if (kIsWeb) {
    var fragment = <String, String>{};
    try {
      fragment = Uri.splitQueryString(callback.fragment);
    } on FormatException {
      /* Ignore invalid callback data. */
    }
    final params = {...fragment, ...callback.queryParameters};
    final hasError =
        params.containsKey('error') || params.containsKey('error_code');
    final hasSession =
        params.containsKey('code') || params.containsKey('access_token');
    if (hasSession && !hasError) {
      try {
        final response = await Supabase.instance.client.auth.getSessionFromUrl(
          callback,
        );
        passwordRecovery =
            passwordRecovery ||
            response.redirectType == 'passwordRecovery' ||
            response.redirectType == 'recovery';
      } catch (_) {
        callbackError = passwordRecovery
            ? 'رابط الاستعادة غير صالح أو انتهت صلاحيته. اطلب رابطًا جديدًا من نفس المتصفح.'
            : 'تعذّر إكمال تسجيل الدخول. حاول مرة أخرى.';
        passwordRecovery = false;
      }
      clearAuthLocation();
    }
  }
  runApp(
    ShareApp(
      initialAuthError:
          callbackError ??
          SupabaseConfig.oauthCallbackError(
            callback,
            signedIn: Supabase.instance.client.auth.currentSession != null,
          ),
      authService: SupabaseAuthService(
        Supabase.instance.client,
        oauthRedirectUrl: SupabaseConfig.oauthRedirectUrl,
        recoveryRedirectUrl: SupabaseConfig.recoveryRedirectUrl,
        passwordRecovery: passwordRecovery,
        googleRedirectUrl: SupabaseConfig.googleRedirectUrl,
        googleProviderEnabled: OAuthProviderSettings(
          provider: OAuthProvider.google,
          supabaseUrl: SupabaseConfig.url,
          publishableKey: SupabaseConfig.publishableKey,
        ).isEnabled,
        appleRedirectUrl: SupabaseConfig.appleRedirectUrl,
        appleProviderEnabled: OAuthProviderSettings(
          provider: OAuthProvider.apple,
          supabaseUrl: SupabaseConfig.url,
          publishableKey: SupabaseConfig.publishableKey,
        ).isEnabled,
      ),
    ),
  );
}
