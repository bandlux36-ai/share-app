import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../../home/presentation/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: authService.authStateChanges,
      initialData: authService.isSignedIn,
      builder: (context, snapshot) => snapshot.data == true
          ? HomeScreen(authService: authService)
          : LoginScreen(authService: authService),
    );
  }
}
