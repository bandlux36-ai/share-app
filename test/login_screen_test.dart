import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_app/app.dart';
import 'package:share_app/features/auth/presentation/widgets/social_sign_in_button.dart';

import 'support/fake_auth_service.dart';

void main() {
  late FakeAuthService auth;
  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());
  testWidgets('390x844 layout keeps RTL controls and footer visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();

    final email = tester.getRect(find.byType(TextFormField).first);
    expect(
      tester.getCenter(find.byIcon(Icons.mail_outline_rounded)).dx,
      greaterThan(email.center.dx),
    );
    expect(
      tester.getCenter(find.byIcon(Icons.lock_outline_rounded)).dx,
      greaterThan(email.center.dx),
    );
    expect(
      tester.getCenter(find.byIcon(Icons.visibility_outlined)).dx,
      lessThan(email.center.dx),
    );
    for (final button in find.byType(SocialSignInButton).evaluate()) {
      final size = tester.getSize(find.byWidget(button.widget));
      expect(size.width, closeTo(size.height, 0.01));
    }
    expect(
      tester.getBottomRight(find.text('إنشاء حساب جديد')).dy,
      lessThanOrEqualTo(844),
    );
  });

  testWidgets('Arabic RTL screen and all four demo providers are present', (
    tester,
  ) async {
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();

    expect(find.text('ارفع محتواك .. وانشره في كل مكان'), findsOneWidget);
    expect(find.byType(SocialSignInButton), findsNWidgets(4));
    expect(
      Directionality.of(tester.element(find.byType(Form))),
      TextDirection.rtl,
    );
  });

  testWidgets('Password visibility can be toggled in both directions', (
    tester,
  ) async {
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    final password = find.byType(TextFormField).last;
    expect(tester.widget<TextFormField>(password).controller, isNotNull);
    expect(
      tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
      isTrue,
    );

    await tester.ensureVisible(find.byTooltip('إظهار كلمة المرور'));
    await tester.tap(find.byTooltip('إظهار كلمة المرور'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
      isFalse,
    );
    await tester.tap(find.byTooltip('إخفاء كلمة المرور'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
      isTrue,
    );
  });

  testWidgets('Login validates input and opens Home on success', (
    tester,
  ) async {
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(ElevatedButton, 'تسجيل الدخول');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('أدخل بريدًا إلكترونيًا صحيحًا'), findsOneWidget);
    expect(find.text('أدخل كلمة المرور'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'demo-password');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('مرحبًا بك في شير'), findsOneWidget);
  });

  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(430, 932),
    Size(844, 390),
  ]) {
    testWidgets('Scrollable layout fits $size with no overflow', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('إنشاء حساب جديد'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('إنشاء حساب جديد'));
      await tester.pumpAndSettle();
      expect(
        find.text('إنشاء حساب جديد سيتوفر لاحقًا. هذه نسخة تجريبية.'),
        findsOneWidget,
      );
    });
  }

  testWidgets('Large text and keyboard remain scrollable', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(ShareApp(authService: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextFormField).last);
    await tester.tap(find.byType(TextFormField).last);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'تسجيل الدخول'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
