import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_app/app.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
import 'package:share_app/features/auth/presentation/login_screen.dart';
import 'package:share_app/features/home/presentation/home_screen.dart';

import 'support/fake_auth_service.dart';

Future<void> fillLogin(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).first,
    '  user@example.com  ',
  );
  await tester.enterText(find.byType(TextFormField).last, ' password ');
  await tester.ensureVisible(find.byType(ElevatedButton));
}

void main() {
  late FakeAuthService auth;
  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());

  testWidgets('Empty and malformed input never calls Auth', (tester) async {
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(auth.signInCalls, 0);
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.enterText(find.byType(TextFormField).last, '   ');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(auth.signInCalls, 0);
    expect(find.text('أدخل بريدًا إلكترونيًا صحيحًا'), findsOneWidget);
    expect(find.text('أدخل كلمة المرور'), findsOneWidget);
  });

  testWidgets('Loading blocks repeat clicks and keyboard submissions', (
    tester,
  ) async {
    final request = Completer<void>();
    auth.beforeSignIn = () => request.future;
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await fillLogin(tester);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(ElevatedButton));
    tester
        .widget<EditableText>(find.byType(EditableText).last)
        .onSubmitted
        ?.call('');
    expect(auth.signInCalls, 1);
    expect(auth.lastEmail, 'user@example.com');
    expect(auth.lastPassword, ' password ');
    request.complete();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  for (final message in [
    'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    'تعذّر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
  ]) {
    testWidgets('Failed sign in is actionable: $message', (tester) async {
      auth.beforeSignIn = () async => throw AuthFailure(message);
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      await fillLogin(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('Restored session opens Home; logout returns to login', (
    tester,
  ) async {
    auth.changeSession(true);
    final request = Completer<void>();
    auth.beforeSignOut = () => request.future;
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    expect(find.text('مرحبًا بك في شير'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(FilledButton));
    expect(auth.signOutCalls, 1);
    request.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
      isFalse,
    );
  });

  testWidgets(
    'Logout failure permits retry and external expiry returns to login',
    (tester) async {
      auth.changeSession(true);
      auth.beforeSignOut = () async =>
          throw const AuthFailure('تعذّر الاتصال بالخادم.');
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      expect(find.text('تعذّر الاتصال بالخادم.'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      auth.changeSession(false);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
}
