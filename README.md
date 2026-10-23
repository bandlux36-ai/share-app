# شير | Share

تطبيق Flutter بواجهة عربية RTL لتجربة شاشة تسجيل الدخول اعتمادًا على الصورة المرجعية. يدعم الكود المشترك iOS وAndroid، وأضيف Web لتسهيل معاينة التصميم.

## التشغيل والمعاينة

يتطلب Flutter **3.47.8 stable** أو إصدارًا أحدث متوافقًا، وAndroid SDK لمحاكي Android، أو macOS وXcode لمحاكي iPhone. ملفات المنصات مبنية من قوالب Flutter الرسمية لهذا الإصدار.

```bash
cd /workspace/share-app
export PATH="/workspace/flutter-sdk/bin:$PATH"
export PUB_CACHE=/workspace/.pub-cache
export XDG_CONFIG_HOME=/workspace/.config
export FLUTTER_SUPPRESS_ANALYTICS=true
export DASH__SUPPRESS_ANALYTICS=true
export CHROME_EXECUTABLE=/usr/bin/chromium
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <device-id>
```

خارج البيئة السحابية، انتقل إلى مجلد المستودع واستخدم Flutter المثبت على جهازك؛ أسطر متغيرات البيئة أعلاه خاصة بالبيئة السحابية.

للمعاينة في Chrome على جهازك:

```bash
flutter run -d chrome --no-web-resources-cdn
```

اختر محاكي هاتف من أدوات المطور في المتصفح. أحجام مقترحة: `390×844` و`430×932` و`360×800`. للمعاينة الداخلية في البيئة السحابية يمكن تشغيل `flutter run -d web-server --no-web-resources-cdn --web-hostname 0.0.0.0 --web-port 8080`؛ لا توفر واجهة إعداد البيئة رابط معاينة ويب. خيار `--no-web-resources-cdn` يجعل موارد الرسم محلية دون الاعتماد على CDN خارجي.

## معاينة التصميم

[لقطة شاشة الإصدار الثاني — 390×844](screenshots/login-screen-v2.png)

## السلوك التجريبي

- الحقول تدعم البريد وكلمة المرور وإظهارها وإخفاءها، مع تحقق محلي بسيط.
- جرّب `demo@example.com` وأي كلمة مرور غير فارغة؛ يظهر إشعار تجريبي فقط.
- أزرار المنصات واستعادة كلمة المرور وإنشاء الحساب تعرض رسائل توضيحية فقط.
- لا توجد قاعدة بيانات أو اتصالات تسجيل دخول أو مفاتيح سرية مطلوبة.
- المساحة الآمنة والتمرير والحد الأقصى لعرض المحتوى تدعم الشاشات المختلفة والاتجاه الأفقي ولوحة المفاتيح.

## تنظيم الملفات

```text
lib/
  main.dart
  app.dart
  core/theme/share_theme.dart
  features/auth/presentation/
    login_screen.dart
    widgets/
      share_logo.dart
      auth_text_field.dart
      social_sign_in_button.dart
assets/fonts/                 # Noto Sans Arabic وترخيص OFL
test/login_screen_test.dart   # RTL والحقول والأزرار والأحجام المختلفة
android/                     # Android / Kotlin
ios/                         # iOS / Swift
web/                         # معاينة المتصفح
```

الشعار العلوي **بديل كتابي مؤقت** وليس ملف الشعار الأصلي. لاستبداله عدّل `ShareLogo` وأضف أصل SVG/PNG معتمدًا. علامات Google وFacebook وX مرسومة محليًا كبدائل تجريبية، وApple من Material Icons. أيقونات التطبيق عند التثبيت ما زالت أيقونات Flutter الافتراضية.

خط Noto Sans Arabic وخط Roboto الاحتياطي مضمنان محليًا من Google Fonts تحت رخصة OFL، ولا يحتاجان تحميلًا وقت التشغيل.

## حالة التحقق في البيئة السحابية

نجح `flutter analyze` دون ملاحظات، ونجحت اختبارات الواجهة التسعة. أمر بناء الويب: `flutter build web --release --no-web-resources-cdn`. تغطي الاختبارات RTL وإظهار كلمة المرور والتحقق المحلي وإرسال النموذج وأحجام شاشات متعددة وتكبير النص ولوحة المفاتيح.

لم يُختبر بناء Android أو iOS: لا يوجد Android SDK في هذه البيئة، وبناء iOS يتطلب macOS وXcode. لا تحتاج الشاشة أي أسرار. حُفظت إضافة `storage.googleapis.com` لسياسة الشبكة لتنزيل أدوات Flutter.

ملف `pubspec.lock` مرفق لتثبيت إصدارات التبعيات. استخدم `flutter pub get --enforce-lockfile` في الإعدادات اللاحقة، وحدّث التبعيات عمدًا عند الحاجة.
