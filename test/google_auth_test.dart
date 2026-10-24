import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:share_app/app.dart';
import 'package:share_app/core/config/supabase_config.dart';
import 'package:share_app/core/config/redirect_uri.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
import 'package:share_app/features/auth/data/oauth_provider_settings.dart';
import 'package:share_app/features/auth/presentation/login_screen.dart';
import 'package:share_app/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:share_app/features/home/presentation/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/fake_auth_service.dart';

void main() {
  test('Auth redirects omit stale and empty query and fragment delimiters', () {
    final source = Uri.parse(
      'https://example.invalid/share-app/?code=mock#stale',
    );
    expect(
      redirectUri(source).toString(),
      'https://example.invalid/share-app/',
    );
    expect(
      redirectUri(source, queryParameters: {'view': 'signin'}).toString(),
      'https://example.invalid/share-app/?view=signin',
    );
  });
  OAuthProviderSettings settings(http.Client client) => OAuthProviderSettings(
    provider: OAuthProvider.google,
    supabaseUrl: 'https://example.invalid',
    publishableKey: 'public-client-test-key',
    client: client,
  );

  SupabaseClient client() {
    final client = SupabaseClient(
      'https://example.invalid',
      'public-client-test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(client.dispose);
    return client;
  }

  for (final enabled in [true, false]) {
    test(
      'Public settings correctly report Google availability: $enabled',
      () async {
        final transport = MockClient((request) async {
          expect(request.url.path, '/auth/v1/settings');
          expect(request.headers['apikey'], 'public-client-test-key');
          expect(request.headers.containsKey('authorization'), isFalse);
          return http.Response('{"external":{"google":$enabled}}', 200);
        });
        addTearDown(transport.close);
        expect(await settings(transport).isEnabled(), enabled);
      },
    );
  }

  test(
    'Disabled Google never launches an external authentication page',
    () async {
      var launches = 0;
      final service = SupabaseAuthService(
        client(),
        oauthRedirectUrl: 'https://example.invalid/share-app/?code=stale',
        googleProviderEnabled: () async => false,
        googleLauncher: (_) async {
          launches++;
          return true;
        },
      );
      await expectLater(
        service.signInWithGoogle(),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            'تسجيل الدخول بـGoogle غير مفعّل حاليًا. يرجى المحاولة لاحقًا.',
          ),
        ),
      );
      expect(launches, 0);
    },
  );

  test(
    'Google redirect preserves Pages path and drops stale callback parameters',
    () async {
      String? redirect;
      final service = SupabaseAuthService(
        client(),
        oauthRedirectUrl: 'https://example.invalid/share-app/?code=stale',
        googleProviderEnabled: () async => true,
        googleLauncher: (value) async {
          redirect = value;
          return true;
        },
      );
      await service.signInWithGoogle();
      expect(redirect, 'https://example.invalid/share-app/');
      expect(service.isSignedIn, isFalse);
    },
  );

  test('A blocked launcher returns an actionable Arabic error', () async {
    final service = SupabaseAuthService(
      client(),
      oauthRedirectUrl: 'https://example.invalid/',
      googleProviderEnabled: () async => true,
      googleLauncher: (_) async => false,
    );
    await expectLater(
      service.signInWithGoogle(),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'تعذّر فتح تسجيل الدخول بـGoogle. حاول مرة أخرى.',
        ),
      ),
    );
  });

  test('Provider network failures do not redirect away from the app', () async {
    final transport = MockClient(
      (_) async => throw http.ClientException('Offline'),
    );
    addTearDown(transport.close);
    final service = SupabaseAuthService(
      client(),
      oauthRedirectUrl: 'https://example.invalid/',
      googleProviderEnabled: settings(transport).isEnabled,
      googleLauncher: (_) async => fail('Must not launch when preflight fails'),
    );
    await expectLater(
      service.signInWithGoogle(),
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
    'Callback errors are localized without exposing provider descriptions',
    () {
      final uri = Uri.parse(
        'https://example.invalid/share-app/?error=access_denied&error_description=untrusted',
      );
      expect(
        SupabaseConfig.oauthCallbackError(uri, signedIn: false),
        'تم إلغاء تسجيل الدخول. يمكنك المحاولة مرة أخرى.',
      );
      final code = Uri.parse(
        'https://example.invalid/share-app/?code=mock-code',
      );
      expect(
        SupabaseConfig.oauthCallbackError(code, signedIn: false),
        isNotNull,
      );
      expect(SupabaseConfig.oauthCallbackError(code, signedIn: true), isNull);
    },
  );

  testWidgets(
    'Google needs no password and blocks duplicate launches until ready',
    (tester) async {
      final auth = FakeAuthService();
      addTearDown(auth.dispose);
      final pending = Completer<void>();
      auth.beforeGoogleSignIn = () => pending.future;
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      final google = find.byWidgetPredicate(
        (widget) =>
            widget is SocialSignInButton &&
            widget.provider == SocialProvider.google,
      );
      await tester.ensureVisible(google);
      await tester.tap(google);
      await tester.pump();
      expect(auth.googleSignInCalls, 1);
      expect(tester.widget<SocialSignInButton>(google).onPressed, isNull);
      expect(tester.widget<SocialSignInButton>(google).isLoading, isTrue);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      await tester.tap(google);
      expect(auth.googleSignInCalls, 1);
      expect(find.text('أدخل كلمة المرور'), findsNothing);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      auth.changeSession(true);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Google errors keep login available and Apple remains independent',
    (tester) async {
      final auth = FakeAuthService();
      addTearDown(auth.dispose);
      auth.beforeGoogleSignIn = () async =>
          throw const AuthFailure('Google غير متاح حاليًا.');
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      final google = find.byWidgetPredicate(
        (widget) =>
            widget is SocialSignInButton &&
            widget.provider == SocialProvider.google,
      );
      await tester.ensureVisible(google);
      await tester.tap(google);
      await tester.pumpAndSettle();
      expect(find.text('Google غير متاح حاليًا.'), findsOneWidget);
      expect(tester.widget<SocialSignInButton>(google).onPressed, isNotNull);
      final apple = find.byWidgetPredicate(
        (widget) =>
            widget is SocialSignInButton &&
            widget.provider == SocialProvider.apple,
      );
      await tester.tap(apple);
      await tester.pumpAndSettle();
      expect(find.text('تسجيل الدخول بواسطة apple تجريبي فقط.'), findsNothing);
      expect(auth.googleSignInCalls, 1);
      expect(auth.appleSignInCalls, 1);
    },
  );

  testWidgets('Cancelled OAuth callback shows an Arabic message on login', (
    tester,
  ) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      ShareApp(
        authService: auth,
        initialAuthError: 'تم إلغاء تسجيل الدخول. يمكنك المحاولة مرة أخرى.',
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('تم إلغاء تسجيل الدخول. يمكنك المحاولة مرة أخرى.'),
      findsOneWidget,
    );
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
