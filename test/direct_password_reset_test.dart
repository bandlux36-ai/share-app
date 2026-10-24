import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_app/app.dart';
import 'package:share_app/features/auth/data/auth_service.dart';
import 'package:share_app/features/auth/presentation/password_reset_sent_screen.dart';
import 'support/fake_auth_service.dart';

void main() {
  for (final fail in [false, true]) {
    testWidgets(
      'Direct reset only confirms a successful request: failure=$fail',
      (tester) async {
        final auth = FakeAuthService();
        addTearDown(auth.dispose);
        if (fail) {
          auth.beforeReset = () async =>
              throw const AuthFailure('محاولات كثيرة.');
        }
        await tester.pumpWidget(ShareApp(authService: auth));
        await tester.pumpAndSettle();
        final link = find.text('نسيت كلمة المرور؟');
        await tester.ensureVisible(link);
        await tester.tap(link);
        await tester.pumpAndSettle();
        expect(auth.resetCalls, 0);
        expect(find.text('ضع بريدك'), findsOneWidget);
        await tester.enterText(
          find.byType(TextFormField).last,
          'test@example.com',
        );
        final send = find.text('إرسال رابط إعادة التعيين');
        await tester.ensureVisible(send);
        await tester.tap(send);
        await tester.pumpAndSettle();
        expect(auth.resetCalls, 1);
        expect(auth.resetEmail, 'test@example.com');
        expect(auth.signInCalls, 0);
        expect(
          find.byType(PasswordResetSentScreen),
          fail ? findsNothing : findsOneWidget,
        );
        if (fail) expect(find.text('محاولات كثيرة.'), findsOneWidget);
      },
    );
  }
}
