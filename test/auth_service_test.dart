import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
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
}
