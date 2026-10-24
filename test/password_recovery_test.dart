import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_app/app.dart';
import 'package:share_app/core/config/supabase_config.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
import 'package:share_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:share_app/features/auth/presentation/login_screen.dart';
import 'package:share_app/features/auth/presentation/reset_password_screen.dart';
import 'package:share_app/features/home/presentation/home_screen.dart';

import 'support/fake_auth_service.dart';

void main() {
  late FakeAuthService auth;
  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());

  Future<void> openForgot(WidgetTester tester) async {
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('نسيت كلمة المرور؟'));
    await tester.ensureVisible(find.text('نسيت كلمة المرور؟'));
    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pumpAndSettle();
  }

  test(
    'Recovery marker survives PKCE callbacks without needing token logging',
    () {
      expect(
        SupabaseConfig.isRecoveryUri(
          Uri.parse('https://example.invalid/share-app/?recovery=1&code=dummy'),
        ),
        isTrue,
      );
      expect(
        SupabaseConfig.isRecoveryUri(
          Uri.parse('https://example.invalid/#type=recovery'),
        ),
        isTrue,
      );
      expect(
        SupabaseConfig.isRecoveryUri(Uri.parse('https://example.invalid/')),
        isFalse,
      );
      expect(
        SupabaseConfig.isRecoveryUri(
          Uri.parse('https://example.invalid/?code=dummy'),
        ),
        isFalse,
      );
    },
  );

  testWidgets('Forgot link opens the screen and rejects invalid email', (
    tester,
  ) async {
    await openForgot(tester);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    await tester.ensureVisible(find.text('إرسال رابط الاستعادة'));
    await tester.tap(find.text('إرسال رابط الاستعادة'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل بريدًا إلكترونيًا صحيحًا'), findsOneWidget);
    expect(auth.resetCalls, 0);
  });

  testWidgets(
    'Request is single-flight and success does not reveal account existence',
    (tester) async {
      final pending = Completer<void>();
      auth.beforeReset = () => pending.future;
      await openForgot(tester);
      await tester.enterText(find.byType(TextFormField), ' user@example.com ');
      await tester.ensureVisible(find.text('إرسال رابط الاستعادة'));
      await tester.tap(find.text('إرسال رابط الاستعادة'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      tester
          .widget<EditableText>(find.byType(EditableText))
          .onSubmitted
          ?.call('');
      expect(auth.resetCalls, 1);
      expect(auth.resetEmail, 'user@example.com');
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.text('تحقّق من بريدك الإلكتروني'), findsOneWidget);
      expect(
        find.textContaining('إذا كان البريد مسجّلًا لدينا'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('العودة لتسجيل الدخول'));
      await tester.tap(find.text('العودة لتسجيل الدخول'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets('Request errors are Arabic and permit retry', (tester) async {
    auth.beforeReset = () async =>
        throw const AuthFailure('تعذّر الاتصال بالخادم.');
    await openForgot(tester);
    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.ensureVisible(find.text('إرسال رابط الاستعادة'));
    await tester.tap(find.text('إرسال رابط الاستعادة'));
    await tester.pumpAndSettle();
    expect(find.text('تعذّر الاتصال بالخادم.'), findsOneWidget);
    auth.beforeReset = null;
    await tester.ensureVisible(find.text('إرسال رابط الاستعادة'));
    await tester.tap(find.text('إرسال رابط الاستعادة'));
    await tester.pumpAndSettle();
    expect(find.text('تحقّق من بريدك الإلكتروني'), findsOneWidget);
    expect(auth.resetCalls, 2);
  });

  testWidgets(
    'Recovery session closes transient routes and shows reset, not Home',
    (tester) async {
      await openForgot(tester);
      auth.beginRecovery();
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
    },
  );

  testWidgets('Cold-start recovery validates confirmation then updates once', (
    tester,
  ) async {
    auth.beginRecovery();
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'short');
    await tester.enterText(fields.last, 'different');
    await tester.ensureVisible(find.text('حفظ كلمة المرور'));
    await tester.tap(find.text('حفظ كلمة المرور'));
    await tester.pumpAndSettle();
    expect(find.text('استخدم كلمة مرور من 8 أحرف على الأقل'), findsOneWidget);
    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    expect(auth.updateCalls, 0);
    await tester.enterText(fields.first, 'Example-new-password!');
    await tester.enterText(fields.last, 'Example-new-password!');
    final pending = Completer<void>();
    auth.beforeUpdate = () => pending.future;
    await tester.ensureVisible(find.text('حفظ كلمة المرور'));
    await tester.ensureVisible(find.text('حفظ كلمة المرور'));
    await tester.tap(find.text('حفظ كلمة المرور'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    tester
        .widget<EditableText>(find.byType(EditableText).last)
        .onSubmitted
        ?.call('');
    expect(auth.updateCalls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(auth.updatedPassword, 'Example-new-password!');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('تم تغيير كلمة المرور بنجاح.'), findsOneWidget);
  });

  testWidgets('Expired link offers a new request and return to Login', (
    tester,
  ) async {
    auth.recovering = true;
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    expect(find.textContaining('رابط الاستعادة غير صالح'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    await tester.ensureVisible(find.text('العودة لتسجيل الدخول'));
    await tester.tap(find.text('العودة لتسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Cancel recovery signs out instead of allowing Home access', (
    tester,
  ) async {
    auth.beginRecovery();
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('العودة لتسجيل الدخول'));
    await tester.tap(find.text('العودة لتسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 1);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Weak-password server failure keeps reset screen available', (
    tester,
  ) async {
    auth.beginRecovery();
    auth.beforeUpdate = () async =>
        throw const AuthFailure('كلمة المرور ضعيفة.');
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Example-password!',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'Example-password!',
    );
    await tester.ensureVisible(find.text('حفظ كلمة المرور'));
    await tester.tap(find.text('حفظ كلمة المرور'));
    await tester.pumpAndSettle();
    expect(find.text('كلمة المرور ضعيفة.'), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  for (final reset in [false, true]) {
    testWidgets('Recovery layout scrolls on compact phones: reset=$reset', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.4;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      if (reset) auth.beginRecovery();
      if (reset) {
        await tester.pumpWidget(ShareApp(authService: auth));
        await tester.pumpAndSettle();
      } else {
        await openForgot(tester);
      }
      await tester.ensureVisible(
        find.text(reset ? 'حفظ كلمة المرور' : 'إرسال رابط الاستعادة'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
