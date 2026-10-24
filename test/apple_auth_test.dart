import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:share_app/app.dart';
import 'package:share_app/core/config/supabase_config.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
import 'package:share_app/features/auth/data/oauth_provider_settings.dart';
import 'package:share_app/features/auth/presentation/login_screen.dart';
import 'package:share_app/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:share_app/features/home/presentation/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/fake_auth_service.dart';

void main() {
  OAuthProviderSettings settings(http.Client transport) =>
      OAuthProviderSettings(
        provider: OAuthProvider.apple,
        supabaseUrl: 'https://example.invalid',
        publishableKey: 'public-client-test-key',
        client: transport,
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
    test('Apple availability is independent of Google: $enabled', () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/auth/v1/settings');
        expect(request.headers['apikey'], 'public-client-test-key');
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response(
          '{"external":{"apple":$enabled,"google":${!enabled}}}',
          200,
        );
      });
      addTearDown(transport.close);
      expect(await settings(transport).isEnabled(), enabled);
    });
  }

  test('Disabled Apple stays in the app without launching OAuth', () async {
    var launches = 0;
    final transport = MockClient(
      (_) async => http.Response('{"external":{"google":true}}', 200),
    );
    addTearDown(transport.close);
    final service = SupabaseAuthService(
      client(),
      recoveryRedirectUrl: 'https://example.invalid/share-app/?recovery=1',
      appleProviderEnabled: settings(transport).isEnabled,
      appleLauncher: (_) async {
        launches++;
        return true;
      },
    );
    await expectLater(
      service.signInWithApple(),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'تسجيل الدخول بـApple غير مفعّل حاليًا. يرجى المحاولة لاحقًا.',
        ),
      ),
    );
    expect(launches, 0);
  });

  for (final body in ['not-json', '{}']) {
    test(
      'Invalid Apple settings stop before opening the provider: $body',
      () async {
        final transport = MockClient((_) async => http.Response(body, 200));
        addTearDown(transport.close);
        final service = SupabaseAuthService(
          client(),
          recoveryRedirectUrl: 'https://example.invalid/share-app/',
          appleProviderEnabled: settings(transport).isEnabled,
          appleLauncher: (_) async => fail('Invalid settings must not launch'),
        );
        await expectLater(
          service.signInWithApple(),
          throwsA(
            isA<AuthFailure>().having(
              (e) => e.message,
              'message',
              'تعذّر التحقق من خدمة Apple. حاول مرة أخرى.',
            ),
          ),
        );
      },
    );
  }

  test(
    'Apple redirect keeps Pages path and drops stale recovery state',
    () async {
      String? redirect;
      final service = SupabaseAuthService(
        client(),
        recoveryRedirectUrl:
            'https://example.invalid/share-app/?recovery=1#stale',
        appleProviderEnabled: () async => true,
        appleLauncher: (url) async {
          redirect = url;
          return true;
        },
      );
      await service.signInWithApple();
      expect(redirect, 'https://example.invalid/share-app/');
      expect(service.isSignedIn, isFalse);
    },
  );

  test(
    'Apple launcher failure names Apple and honors its own redirect',
    () async {
      final service = SupabaseAuthService(
        client(),
        recoveryRedirectUrl: 'https://example.invalid/?recovery=1',
        googleRedirectUrl: 'https://example.invalid/google/',
        appleRedirectUrl: 'https://example.invalid/apple/',
        appleProviderEnabled: () async => true,
        appleLauncher: (url) async {
          expect(url, 'https://example.invalid/apple/');
          return false;
        },
      );
      await expectLater(
        service.signInWithApple(),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            'تعذّر فتح تسجيل الدخول بـApple. حاول مرة أخرى.',
          ),
        ),
      );
    },
  );

  test('OAuth callback messages do not misidentify Apple as Google', () {
    expect(
      SupabaseConfig.oauthCallbackError(
        Uri.parse(
          'https://example.invalid/?error=access_denied&error_description=private',
        ),
        signedIn: false,
      ),
      'تم إلغاء تسجيل الدخول. يمكنك المحاولة مرة أخرى.',
    );
    expect(
      SupabaseConfig.oauthCallbackError(
        Uri.parse(
          'https://example.invalid/?error=server_error&error_description=private',
        ),
        signedIn: false,
      ),
      'تعذّر إكمال تسجيل الدخول. حاول مرة أخرى.',
    );
  });

  Finder button(SocialProvider provider) => find.byWidgetPredicate(
    (widget) => widget is SocialSignInButton && widget.provider == provider,
  );

  testWidgets(
    'Apple waits for a session and blocks duplicate and competing sign-ins',
    (tester) async {
      final auth = FakeAuthService();
      addTearDown(auth.dispose);
      final pending = Completer<void>();
      auth.beforeAppleSignIn = () => pending.future;
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      final apple = button(SocialProvider.apple);
      final google = button(SocialProvider.google);
      await tester.ensureVisible(apple);
      await tester.tap(apple);
      await tester.pump();
      expect(auth.appleSignInCalls, 1);
      expect(tester.widget<SocialSignInButton>(apple).isLoading, isTrue);
      expect(tester.widget<SocialSignInButton>(apple).onPressed, isNull);
      expect(tester.widget<SocialSignInButton>(google).onPressed, isNull);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      await tester.tap(apple);
      await tester.tap(google);
      expect(auth.appleSignInCalls, 1);
      expect(auth.googleSignInCalls, 0);
      expect(auth.signInCalls, 0);
      expect(find.text('أدخل كلمة المرور'), findsNothing);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      auth.changeSession(true);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets('Apple failure leaves both providers and email available', (
    tester,
  ) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);
    auth.beforeAppleSignIn = () async =>
        throw const AuthFailure('Apple غير متاح حاليًا.');
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    final apple = button(SocialProvider.apple);
    await tester.ensureVisible(apple);
    await tester.tap(apple);
    await tester.pumpAndSettle();
    expect(find.text('Apple غير متاح حاليًا.'), findsOneWidget);
    expect(tester.widget<SocialSignInButton>(apple).isLoading, isFalse);
    expect(tester.widget<SocialSignInButton>(apple).onPressed, isNotNull);
    expect(
      tester
          .widget<SocialSignInButton>(button(SocialProvider.google))
          .onPressed,
      isNotNull,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });
}
