import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_app/app.dart';
import 'support/fake_auth_service.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('Home content scrolls and navigation fits $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = FakeAuthService(signedIn: true);
      addTearDown(auth.dispose);
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      expect(find.text('منصات النشر'), findsOneWidget);
      await tester.ensureVisible(find.text('إضافة منصة'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('التنبيهات').last);
      await tester.pumpAndSettle();
      expect(find.text('لا توجد تنبيهات حتى الآن'), findsOneWidget);
      await tester.tap(find.text('الملف الشخصي'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('تسجيل الخروج'));
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      expect(auth.signOutCalls, 1);
    });
  }
  testWidgets(
    'Platform selections toggle without pretending accounts are connected',
    (tester) async {
      final auth = FakeAuthService(signedIn: true);
      addTearDown(auth.dispose);
      await tester.pumpWidget(ShareApp(authService: auth));
      await tester.pumpAndSettle();
      final facebook = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'فيسبوك',
      );
      expect(tester.widget<Semantics>(facebook).properties.selected, isTrue);
      await tester.ensureVisible(find.text('فيسبوك'));
      await tester.tap(find.text('فيسبوك'));
      await tester.pumpAndSettle();
      expect(tester.widget<Semantics>(facebook).properties.selected, isFalse);
      await tester.ensureVisible(find.text('إدارة المنصات'));
      await tester.tap(find.text('إدارة المنصات'));
      await tester.pumpAndSettle();
      expect(find.text('غير مرتبط'), findsWidgets);
      expect(auth.signOutCalls, 0);
    },
  );
}
