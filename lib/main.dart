import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Capture the marker before the SDK consumes the recovery callback URL.
  final passwordRecovery = SupabaseConfig.isRecoveryUri(Uri.base);
  await SupabaseConfig.initialize();
  runApp(
    ShareApp(
      authService: SupabaseAuthService(
        Supabase.instance.client,
        recoveryRedirectUrl: SupabaseConfig.recoveryRedirectUrl,
        passwordRecovery: passwordRecovery,
      ),
    ),
  );
}
