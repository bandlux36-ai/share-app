import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/data/oauth_provider_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Capture the marker before the SDK consumes the recovery callback URL.
  final callback = Uri.base;
  final passwordRecovery = SupabaseConfig.isRecoveryUri(callback);
  await SupabaseConfig.initialize();
  runApp(
    ShareApp(
      initialAuthError: SupabaseConfig.oauthCallbackError(
        callback,
        signedIn: Supabase.instance.client.auth.currentSession != null,
      ),
      authService: SupabaseAuthService(
        Supabase.instance.client,
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
