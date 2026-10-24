import 'dart:async';

import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../platform/recovery_location.dart';
import '../../home/presentation/home_screen.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _signedIn;
  late final StreamSubscription<bool> _subscription;

  @override
  void initState() {
    super.initState();
    _signedIn = widget.authService.isSignedIn;
    _subscription = widget.authService.authStateChanges.listen(
      (signedIn) {
        if (!mounted) return;
        setState(() => _signedIn = signedIn);
        if (!signedIn) clearRecoveryLocation();
        if (signedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        }
      },
      onError: (Object error, StackTrace stack) {
        // Keep the current session view; never expose auth errors or tokens.
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authService;
    if (auth.isPasswordRecovery) {
      if (_signedIn) {
        return ResetPasswordScreen(
          authService: auth,
          onCompleted: () {
            clearRecoveryLocation();
            setState(() {});
          },
        );
      }
      return ForgotPasswordScreen(
        authService: auth,
        initialError:
            'رابط الاستعادة غير صالح أو انتهت صلاحيته. اطلب رابطًا جديدًا.',
        onBack: () {
          clearRecoveryLocation();
          auth.dismissPasswordRecovery();
          setState(() {});
        },
      );
    }
    return _signedIn
        ? HomeScreen(authService: auth)
        : LoginScreen(authService: auth);
  }
}
