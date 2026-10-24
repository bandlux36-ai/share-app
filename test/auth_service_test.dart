import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
import 'package:share_app/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/memory_auth_storage.dart';

http.Response response(Map<String, dynamic> body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {
    'content-type': 'application/json',
    'x-supabase-api-version': '2024-01-01',
  },
);

void main() {
  SupabaseClient clientWith(
    Future<http.Response> Function(http.Request) handler,
  ) {
    final client = SupabaseClient(
      'https://example.invalid',
      'public-client-test-key',
      httpClient: MockClient(handler),
      authOptions: AuthClientOptions(
        autoRefreshToken: false,
        pkceAsyncStorage: MemoryAuthStorage(),
      ),
    );
    addTearDown(client.dispose);
    return client;
  }

  test(
    'Recovery email uses Supabase recover endpoint and explicit callback',
    () async {
      late http.Request sent;
      final client = clientWith((request) async {
        sent = request;
        return response({}, 200);
      });
      final service = SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/share-app/',
        recoveryRedirectUrl: 'https://example.invalid/share-app/?recovery=1',
      );
      await service.requestPasswordReset(' user@example.com ');
      expect(sent.method, 'POST');
      expect(sent.url.path, '/auth/v1/recover');
      expect(
        sent.url.queryParameters['redirect_to'],
        'https://example.invalid/share-app/?recovery=1',
      );
      expect((jsonDecode(sent.body) as Map)['email'], 'user@example.com');
    },
  );

  test(
    'Password update uses authenticated Supabase endpoint and completes recovery',
    () async {
      late http.Request sent;
      final user = <String, dynamic>{
        'id': 'test-user',
        'email': 'user@example.com',
        'app_metadata': {},
        'user_metadata': {},
        'created_at': '2026-01-01T00:00:00Z',
      };
      final client = clientWith((request) async {
        sent = request;
        return response(user, 200);
      });
      await client.auth.setInitialSession(
        jsonEncode({
          'access_token': 'test-access-token',
          'refresh_token': 'test-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': user,
        }),
      );
      final service = SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/share-app/',
        recoveryRedirectUrl: 'https://example.invalid/share-app/?recovery=1',
        passwordRecovery: true,
      );
      expect(service.isPasswordRecovery, isTrue);
      await service.updatePassword('Example-new-password!');
      expect(sent.method, 'PUT');
      expect(sent.url.path, '/auth/v1/user');
      expect(
        (jsonDecode(sent.body) as Map)['password'],
        'Example-new-password!',
      );
      expect(service.isPasswordRecovery, isFalse);
      expect(service.isSignedIn, isTrue);
    },
  );

  test(
    'Password grant signs in, emits a session and signs out via Supabase',
    () async {
      final requests = <http.Request>[];
      final client = clientWith((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/logout')) return http.Response('', 204);
        return response({
          'access_token': 'test-access-token',
          'refresh_token': 'test-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': {
            'id': 'test-user',
            'email': 'user@example.com',
            'app_metadata': {},
            'user_metadata': {},
            'created_at': '2026-01-01T00:00:00Z',
          },
        }, 200);
      });
      final service = SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/share-app/?code=stale',
      );
      expect(service.isSignedIn, isFalse);
      final signedIn = service.authStateChanges.firstWhere((value) => value);
      await service.signIn(email: ' user@example.com ', password: ' password ');
      expect(await signedIn, isTrue);
      expect(service.isSignedIn, isTrue);
      final request = requests.first;
      expect(request.method, 'POST');
      expect(request.url.path, '/auth/v1/token');
      expect(request.url.queryParameters['grant_type'], 'password');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['email'], 'user@example.com');
      expect(body['password'], ' password ');
      final signedOut = service.authStateChanges.firstWhere((value) => !value);
      await service.signOut();
      expect(await signedOut, isFalse);
      expect(service.isSignedIn, isFalse);
      expect(requests.last.url.path, '/auth/v1/logout');
    },
  );

  for (final entry in {
    'invalid_credentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    'email_not_confirmed': 'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.',
    'over_request_rate_limit': 'محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.',
  }.entries) {
    test('Supabase ${entry.key} becomes an Arabic error', () async {
      final client = clientWith(
        (_) async => response({
          'code': entry.key,
          'msg': 'Internal English server message',
        }, 400),
      );
      await expectLater(
        SupabaseAuthService(
          client,
          oauthRedirectUrl: 'https://example.invalid/share-app/?code=stale',
        ).signIn(email: 'user@example.com', password: 'invalid'),
        throwsA(
          isA<AuthFailure>().having((e) => e.message, 'message', entry.value),
        ),
      );
    });
  }

  test('A failed network request becomes an Arabic connection error', () async {
    final client = clientWith(
      (_) async => throw http.ClientException('Offline'),
    );
    await expectLater(
      SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/share-app/?code=stale',
      ).signIn(email: 'user@example.com', password: 'invalid'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'تعذّر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
        ),
      ),
    );
  });
  test(
    'Default recovery callback preserves Pages path without stale OAuth state',
    () async {
      late http.Request sent;
      final client = clientWith((request) async {
        sent = request;
        return response({}, 200);
      });
      final service = SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/share-app/?code=stale#stale',
      );
      await service.requestPasswordReset('user@example.com');
      expect(
        sent.url.queryParameters['redirect_to'],
        'https://example.invalid/share-app/?recovery=1',
      );
      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['code_challenge'], isNotEmpty);
      expect(body['code_challenge_method'], 's256');
      expect(body.containsKey('password'), isFalse);
    },
  );

  test('Recovery markers are recognized before PKCE callback handling', () {
    for (final uri in [
      Uri.parse('https://example.invalid/share-app/?recovery=1&code=mock'),
      Uri.parse(
        'https://example.invalid/share-app/#type=recovery&access_token=mock',
      ),
    ]) {
      expect(SupabaseConfig.isRecoveryUri(uri), isTrue);
      expect(SupabaseConfig.oauthCallbackError(uri, signedIn: false), isNull);
    }
    expect(
      SupabaseConfig.isRecoveryUri(
        Uri.parse('https://example.invalid/share-app/'),
      ),
      isFalse,
    );
  });

  for (final entry in {
    'over_email_send_rate_limit':
        'محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.',
    'flow_state_expired': 'انتهت صلاحية رابط الاستعادة. اطلب رابطًا جديدًا.',
    'otp_expired': 'انتهت صلاحية رابط الاستعادة. اطلب رابطًا جديدًا.',
  }.entries) {
    test('Recover failure ${entry.key} returns a localized error', () async {
      final client = clientWith(
        (_) async => response({
          'code': entry.key,
          'msg': 'Internal untrusted message',
        }, 400),
      );
      final service = SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/',
      );
      await expectLater(
        service.requestPasswordReset('user@example.com'),
        throwsA(
          isA<AuthFailure>().having((e) => e.message, 'message', entry.value),
        ),
      );
    });
  }

  for (final entry in {
    'weak_password': 'كلمة المرور ضعيفة. استخدم كلمة أقوى وفق متطلبات الحساب.',
    'same_password': 'اختر كلمة مرور مختلفة عن كلمة المرور الحالية.',
  }.entries) {
    test('Failed password update ${entry.key} keeps recovery active', () async {
      final user = <String, dynamic>{
        'id': 'test-user',
        'email': 'user@example.com',
        'app_metadata': {},
        'user_metadata': {},
        'created_at': '2026-01-01T00:00:00Z',
      };
      final client = clientWith(
        (_) async => response({
          'code': entry.key,
          'msg': 'Internal untrusted password error',
        }, 400),
      );
      await client.auth.setInitialSession(
        jsonEncode({
          'access_token': 'test-access-token',
          'refresh_token': 'test-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': user,
        }),
      );
      final service = SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/share-app/',
        passwordRecovery: true,
      );
      await expectLater(
        service.updatePassword('Example-new-password!'),
        throwsA(
          isA<AuthFailure>().having((e) => e.message, 'message', entry.value),
        ),
      );
      expect(service.isPasswordRecovery, isTrue);
    });
  }

  test(
    'Sign out clears a recovery state through the auth event stream',
    () async {
      final client = clientWith((_) async => http.Response('', 204));
      final service = SupabaseAuthService(
        client,
        oauthRedirectUrl: 'https://example.invalid/share-app/',
        passwordRecovery: true,
      );
      final subscription = service.authStateChanges.listen((_) {});
      addTearDown(subscription.cancel);
      await service.signOut();
      expect(service.isPasswordRecovery, isFalse);
    },
  );
}
