import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthService {
  bool get isSignedIn;
  Stream<bool> get authStateChanges;
  bool get isPasswordRecovery;
  void dismissPasswordRecovery();
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(
    this._client, {
    required this.recoveryRedirectUrl,
    bool passwordRecovery = false,
  }) : _passwordRecovery = passwordRecovery {
    authStateChanges = _client.auth.onAuthStateChange.map((event) {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        _passwordRecovery = true;
      }
      if (event.event == AuthChangeEvent.signedOut) _passwordRecovery = false;
      return event.session != null;
    });
  }

  final SupabaseClient _client;
  final String recoveryRedirectUrl;
  bool _passwordRecovery;

  @override
  late final Stream<bool> authStateChanges;

  @override
  bool get isPasswordRecovery => _passwordRecovery;

  @override
  void dismissPasswordRecovery() => _passwordRecovery = false;

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: recoveryRedirectUrl,
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> updatePassword(String password) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
      _passwordRecovery = false;
    } catch (error) {
      throw _failure(error);
    }
  }

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw _failure(error);
    }
  }

  AuthFailure _failure(Object error) {
    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const AuthFailure(
        'تعذّر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
      );
    }
    if (error is AuthException) {
      switch (error.code) {
        case 'invalid_credentials':
        case 'invalid_grant':
        case 'user_not_found':
          return const AuthFailure(
            'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
          );
        case 'email_not_confirmed':
          return const AuthFailure(
            'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.',
          );
        case 'weak_password':
          return const AuthFailure(
            'كلمة المرور ضعيفة. استخدم كلمة أقوى وفق متطلبات الحساب.',
          );
        case 'same_password':
          return const AuthFailure(
            'اختر كلمة مرور مختلفة عن كلمة المرور الحالية.',
          );
        case 'otp_expired':
        case 'flow_state_expired':
        case 'flow_state_not_found':
        case 'session_not_found':
          return const AuthFailure(
            'انتهت صلاحية رابط الاستعادة. اطلب رابطًا جديدًا.',
          );
        case 'over_request_rate_limit':
        case 'over_email_send_rate_limit':
          return const AuthFailure(
            'محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.',
          );
      }
      final status = int.tryParse(error.statusCode ?? '');
      if (status != null && status >= 500) {
        return const AuthFailure(
          'الخدمة غير متاحة مؤقتًا. حاول مرة أخرى لاحقًا.',
        );
      }
    }
    return const AuthFailure('تعذّر إتمام العملية. حاول مرة أخرى.');
  }
}
