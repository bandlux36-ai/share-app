import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_app/app.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
import 'package:share_app/features/auth/presentation/login_screen.dart';
import 'package:share_app/features/auth/presentation/reset_password_screen.dart';
import 'package:share_app/features/home/presentation/home_screen.dart';

import 'support/fake_auth_service.dart';

void main() {
  late FakeAuthService auth;
  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());

  Future<void> enterPassword(
    WidgetTester tester,
    String password,
    String confirmation,
  ) async {
    await tester.enterText(find.byType(TextFormField).first, password);
    await tester.enterText(find.byType(TextFormField).last, confirmation);
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.widgetWithText(FilledButton, 'حفظ كلمة المرور');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Recovery session selects reset destination without showing Home',
    (tester) async {
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(LoginScreen));
      unawaited(
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                const Scaffold(body: Text('Temporary confirmation route')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Temporary confirmation route'), findsOneWidget);
      auth.beginRecovery();
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('Temporary confirmation route'), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
    },
  );

  testWidgets(
    'Cold start reset validates strength and confirmation then updates password',
    (tester) async {
      auth.beginRecovery();
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      await enterPassword(tester, 'short', 'different');
      await save(tester);
      expect(find.text('استخدم كلمة مرور من 8 أحرف على الأقل'), findsOneWidget);
      expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
      expect(auth.updateCalls, 0);
      await enterPassword(tester, 'new-password-123', 'new-password-123');
      await save(tester);
      expect(auth.updateCalls, 1);
      expect(auth.updatedPassword, 'new-password-123');
      expect(auth.isPasswordRecovery, isFalse);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('تم تغيير كلمة المرور بنجاح.'), findsOneWidget);
    },
  );

  testWidgets(
    'Expired recovery marker returns to login with a localized error',
    (tester) async {
      auth.recovering = true;
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(
        find.text(
          'رابط الاستعادة غير صالح أو انتهت صلاحيته. اطلب رابطًا جديدًا.',
        ),
        findsOneWidget,
      );
      expect(auth.isPasswordRecovery, isFalse);
    },
  );

  testWidgets('Cancelling password reset signs out rather than exposing Home', (
    tester,
  ) async {
    auth.beginRecovery();
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(TextButton, 'العودة لتسجيل الدخول'),
    );
    await tester.tap(find.widgetWithText(TextButton, 'العودة لتسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 1);
    expect(auth.isSignedIn, isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('Failed cancellation keeps reset visible and offers a retry', (
    tester,
  ) async {
    auth.beginRecovery();
    auth.beforeSignOut = () async =>
        throw const AuthFailure('تعذّر الاتصال بالخادم.');
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(TextButton, 'العودة لتسجيل الدخول'),
    );
    await tester.tap(find.widgetWithText(TextButton, 'العودة لتسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('تعذّر الاتصال بالخادم.'), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(auth.isSignedIn, isTrue);
    auth.beforeSignOut = null;
    await tester.tap(find.widgetWithText(TextButton, 'العودة لتسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Password update failures remain on reset and can retry', (
    tester,
  ) async {
    auth.beginRecovery();
    auth.beforeUpdate = () async =>
        throw const AuthFailure('اختر كلمة مرور مختلفة.');
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await enterPassword(tester, 'new-password-123', 'new-password-123');
    await save(tester);
    expect(find.text('اختر كلمة مرور مختلفة.'), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(auth.isPasswordRecovery, isTrue);
    auth.beforeUpdate = null;
    await save(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets(
    'Pending password update prevents a second update and cancellation',
    (tester) async {
      auth.beginRecovery();
      final pending = Completer<void>();
      auth.beforeUpdate = () => pending.future;
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      await enterPassword(tester, 'new-password-123', 'new-password-123');
      final button = find.byType(FilledButton);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      expect(auth.updateCalls, 1);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'العودة لتسجيل الدخول'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(button);
      expect(auth.updateCalls, 1);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  for (final size in const [Size(320, 568), Size(844, 390)]) {
    testWidgets('Reset destination scrolls without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      auth.beginRecovery();
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('حفظ كلمة المرور'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });
  }
}
