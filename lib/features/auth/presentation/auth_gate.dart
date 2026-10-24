import 'dart:async';

import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../platform/auth_location.dart';
import '../../home/presentation/home_screen.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authService, this.initialAuthError});

  final AuthService authService;
  final String? initialAuthError;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _signedIn;
  late final StreamSubscription<bool> _subscription;

  @override
  void initState() {
    super.initState();
    final auth = widget.authService;
    _signedIn = auth.isSignedIn;
    var initialError = widget.initialAuthError;
    if (auth.isPasswordRecovery && !_signedIn) {
      auth.dismissPasswordRecovery();
      initialError =
          'رابط الاستعادة غير صالح أو انتهت صلاحيته. اطلب رابطًا جديدًا.';
    }
    if (initialError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        clearAuthLocation();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(initialError!)));
      });
    }
    _subscription = widget.authService.authStateChanges.listen(
      (signedIn) {
        if (!mounted) return;
        setState(() => _signedIn = signedIn);
        if (!signedIn) clearAuthLocation();
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
    if (auth.isPasswordRecovery && _signedIn) {
      return ResetPasswordScreen(
        authService: auth,
        onCompleted: () {
          clearAuthLocation();
          setState(() {});
        },
      );
    }
    return _signedIn
        ? HomeScreen(authService: widget.authService)
        : LoginScreen(authService: widget.authService);
  }
}
