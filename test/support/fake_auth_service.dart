import 'dart:async';

import 'package:share_app/features/auth/data/auth_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({bool signedIn = false}) : _signedIn = signedIn;

  bool _signedIn;
  final _changes = StreamController<bool>.broadcast(sync: true);
  Future<void> Function()? beforeSignIn;
  Future<void> Function()? beforeSignOut;
  int signInCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;
  Future<void> Function()? beforeGoogleSignIn;
  int googleSignInCalls = 0;
  Future<void> Function()? beforeAppleSignIn;
  int appleSignInCalls = 0;

  @override
  Future<void> signInWithApple() async {
    appleSignInCalls++;
    await beforeAppleSignIn?.call();
  }

  @override
  Future<void> signInWithGoogle() async {
    googleSignInCalls++;
    await beforeGoogleSignIn?.call();
  }

  @override
  bool get isSignedIn => _signedIn;
  @override
  Stream<bool> get authStateChanges => _changes.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    await beforeSignIn?.call();
    changeSession(true);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    await beforeSignOut?.call();
    changeSession(false);
  }

  void changeSession(bool signedIn) {
    _signedIn = signedIn;
    _changes.add(signedIn);
  }

  Future<void> dispose() => _changes.close();
}
