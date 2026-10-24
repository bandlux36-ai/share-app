import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_app/app.dart';
import 'support/fake_auth_service.dart';

void main() {
  for (final confirm in [true, false]) {
    testWidgets(
      'Signup validates consent and handles email confirmation: $confirm',
      (tester) async {
        final auth = FakeAuthService()..confirmEmail = confirm;
        addTearDown(auth.dispose);
        await tester.pumpWidget(ShareApp(authService: auth));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('إنشاء حساب جديد'));
        await tester.tap(find.text('إنشاء حساب جديد'));
        await tester.pumpAndSettle();
        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'Person');
        await tester.enterText(fields.at(1), 'person@example.com');
        await tester.enterText(fields.at(2), 'Strong-password-123');
        await tester.enterText(fields.at(3), 'Strong-password-123');
        final submit = find.text('إنشاء الحساب');
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(auth.signUpCalls, 0);
        await tester.ensureVisible(find.byType(CheckboxListTile));
        await tester.tap(find.byType(CheckboxListTile));
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(auth.signUpCalls, 1);
        expect(
          find.text(
            confirm
                ? 'تحقق من بريدك الإلكتروني لإكمال إنشاء الحساب، ثم عد لتسجيل الدخول.'
                : 'مرحبًا بك في شير',
          ),
          findsOneWidget,
        );
      },
    );
  }
}
