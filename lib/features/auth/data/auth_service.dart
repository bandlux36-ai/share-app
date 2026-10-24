import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/redirect_uri.dart';

abstract interface class AuthService {
  bool get isSignedIn;
  Stream<bool> get authStateChanges;
  bool get isPasswordRecovery;
  void dismissPasswordRecovery();
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signIn({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(
    this._client, {
    required this.oauthRedirectUrl,
    String? recoveryRedirectUrl,
    bool passwordRecovery = false,
    String? googleRedirectUrl,
    Future<bool> Function()? googleProviderEnabled,
    Future<bool> Function(String redirectUrl)? googleLauncher,
    String? appleRedirectUrl,
    Future<bool> Function()? appleProviderEnabled,
    Future<bool> Function(String redirectUrl)? appleLauncher,
  }) : recoveryRedirectUrl =
           recoveryRedirectUrl ??
           redirectUri(
             Uri.parse(oauthRedirectUrl),
             queryParameters: const {'recovery': '1'},
           ).toString(),
       _passwordRecovery = passwordRecovery,
       _googleRedirectUrl = googleRedirectUrl,
       _googleProviderEnabled = googleProviderEnabled,
       _googleLauncher = googleLauncher,
       _appleRedirectUrl = appleRedirectUrl,
       _appleProviderEnabled = appleProviderEnabled,
       _appleLauncher = appleLauncher {
    authStateChanges = _client.auth.onAuthStateChange.map((event) {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        _passwordRecovery = true;
      }
      if (event.event == AuthChangeEvent.signedOut) _passwordRecovery = false;
      return event.session != null;
    });
  }

  final SupabaseClient _client;
  final String oauthRedirectUrl;
  final String recoveryRedirectUrl;
  bool _passwordRecovery;
  final String? _googleRedirectUrl;
  final Future<bool> Function()? _googleProviderEnabled;
  final Future<bool> Function(String redirectUrl)? _googleLauncher;

  final String? _appleRedirectUrl;
  final Future<bool> Function()? _appleProviderEnabled;
  final Future<bool> Function(String redirectUrl)? _appleLauncher;

  @override
  Future<void> signInWithGoogle() => _signInWithOAuth(
    provider: OAuthProvider.google,
    label: 'Google',
    redirectUrl: _googleRedirectUrl,
    providerEnabled: _googleProviderEnabled,
    launcher: _googleLauncher,
    queryParams: const {'prompt': 'select_account'},
  );

  @override
  Future<void> signInWithApple() => _signInWithOAuth(
    provider: OAuthProvider.apple,
    label: 'Apple',
    redirectUrl: _appleRedirectUrl,
    providerEnabled: _appleProviderEnabled,
    launcher: _appleLauncher,
  );

  Future<void> _signInWithOAuth({
    required OAuthProvider provider,
    required String label,
    String? redirectUrl,
    Future<bool> Function()? providerEnabled,
    Future<bool> Function(String redirectUrl)? launcher,
    Map<String, String>? queryParams,
  }) async {
    try {
      if (providerEnabled != null && !await providerEnabled()) {
        throw AuthFailure(
          'تسجيل الدخول بـ$label غير مفعّل حاليًا. يرجى المحاولة لاحقًا.',
        );
      }
      final redirect =
          redirectUrl ?? redirectUri(Uri.parse(oauthRedirectUrl)).toString();
      final opened = launcher != null
          ? await launcher(redirect)
          : await _client.auth.signInWithOAuth(
              provider,
              redirectTo: redirect,
              queryParams: queryParams,
            );
      if (!opened) {
        throw AuthFailure('تعذّر فتح تسجيل الدخول بـ$label. حاول مرة أخرى.');
      }
    } on AuthException catch (error) {
      if (error.code == 'provider_disabled' ||
          error.code == 'unsupported_provider') {
        throw AuthFailure(
          'تسجيل الدخول بـ$label غير مفعّل حاليًا. يرجى المحاولة لاحقًا.',
        );
      }
      throw _failure(error);
    } catch (error) {
      throw _failure(error);
    }
  }

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
      throw _failure(error, recovery: true);
    }
  }

  @override
  Future<void> updatePassword(String password) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
      _passwordRecovery = false;
    } catch (error) {
      throw _failure(error, recovery: true);
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
      _passwordRecovery = false;
    } catch (error) {
      throw _failure(error);
    }
  }

  AuthFailure _failure(Object error, {bool recovery = false}) {
    if (error is AuthFailure) return error;
    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const AuthFailure(
        'تعذّر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
      );
    }
    if (error is AuthException) {
      switch (error.code) {
        case 'provider_disabled':
        case 'unsupported_provider':
          return const AuthFailure(
            'طريقة تسجيل الدخول غير مفعّلة حاليًا. يرجى المحاولة لاحقًا.',
          );
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
          return AuthFailure(
            recovery
                ? 'انتهت صلاحية رابط الاستعادة. اطلب رابطًا جديدًا.'
                : 'انتهت صلاحية جلسة الدخول. حاول تسجيل الدخول مرة أخرى.',
          );
        case 'over_email_send_rate_limit':
        case 'over_request_rate_limit':
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
