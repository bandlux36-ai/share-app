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

[لقطة الشاشة مع الأصل الرسومي المشترك — 390×844](screenshots/login-logo-final.png)

## تسجيل الدخول

- الحقول تدعم البريد وكلمة المرور وإظهارها وإخفاءها، مع تحقق محلي بسيط.
- استخدم حسابًا موجودًا في Supabase Auth: البريد وكلمة المرور يُرسلان عبر `signInWithPassword`. ليست هناك بيانات دخول تجريبية مضمّنة.
- أزرار المنصات وإنشاء الحساب تعرض رسائل توضيحية فقط. استعادة كلمة المرور مرتبطة بـSupabase.
- يعرض زر الدخول مؤشر تحميل ويمنع الطلبات المتكررة. أخطاء البيانات والاتصال تظهر بالعربية.
- عند نجاح الدخول تظهر `HomeScreen` برسالة ترحيب وزر خروج. يستخدم الخروج `signOut` ثم تعيد حالة الجلسة المستخدم لشاشة الدخول.
- يستعيد Supabase الجلسة المخزّنة عند تشغيل التطبيق؛ المستخدم المسجّل يدخل إلى الرئيسية مباشرة.
- المساحة الآمنة والتمرير والحد الأقصى لعرض المحتوى تدعم الشاشات المختلفة والاتجاه الأفقي ولوحة المفاتيح.

## تهيئة Supabase

ثُبّتت حزمة `supabase_flutter`، وتُهيّأ مرة واحدة قبل `runApp` في `lib/main.dart`. إعداد المشروع منفصل في `lib/core/config/supabase_config.dart`، ويستخدم عنوان المشروع وPublishable key العام المخصص لتطبيقات العميل. لا يوجد مفتاح `service_role` أو مفتاح سري في هذا الإعداد.

يمكن تجاوز القيم العامة بواسطة `--dart-define=SUPABASE_URL=...` و`--dart-define=SUPABASE_PUBLISHABLE_KEY=...`. لا تمرر مفاتيح إدارية أو سرية عبر هذه الخيارات: قيم تطبيقات العميل قابلة للاستخراج من حزمة التطبيق. صلاحيات البيانات يجب أن تظل محكومة بسياسات RLS في Supabase.

منطق المصادقة مستقل في `lib/features/auth/data/auth_service.dart`، وتتابع `AuthGate` حالة الجلسة لعرض شاشة الدخول أو الرئيسية دون إبقاء شاشة محمية في سجل الرجوع بعد الخروج. تصميم الدخول محفوظ. لا تُنشأ حسابات أو جداول تلقائيًا. Google وApple وFacebook وX وإنشاء الحساب تظل أزرارًا تجريبية. أضيف تصريح INTERNET لإصدار Android الأساسي.

نطاق مشروع Supabase هو `iroqzjahasvmhtmsmsvy.supabase.co`؛ حُفظ السماح به في مسودة إعدادات البيئة، مع الإبقاء على نطاق تنزيل Flutter الحالي.

## استعادة كلمة المرور

اضغط «نسيت كلمة المرور؟» وأدخل البريد. تستدعي الخدمة `resetPasswordForEmail` مع مؤشر تحميل، ورسالة نجاح عامة لا تكشف إن كان الحساب موجودًا. رابط الاستعادة يفتح شاشة كلمة مرور جديدة وتأكيدها؛ عند الحفظ تُستخدم `updateUser(UserAttributes(password: ...))`، ثم تظهر الرئيسية. الإلغاء يسجّل خروج جلسة الاستعادة. لا تُرسل كلمة المرور الجديدة في رسائل البريد ولا تُسجّل في logs.

قبل الاستخدام الفعلي، من **Supabase → Authentication → URL Configuration → Redirect URLs** أضف الرابط التالي بالضبط:

```text
https://bandlux36-ai.github.io/share-app/?recovery=1
```

يُبنى رابط الرجوع تلقائيًا من أصل صفحة الويب ومسارها، بما يدعم `/share-app/`. يمكن تخصيصه عبر `--dart-define=PASSWORD_RESET_REDIRECT_URL=...` مع إضافته إلى قائمة Supabase المسموحة أيضًا. يستخدم التدفق PKCE، لذا افتح رسالة الاستعادة في المتصفح والجهاز اللذين طلبت منهما الرابط. لا تُدخل رابطًا يحتوي على code أو token في الإعدادات.

يجب أن تكون خدمة البريد في Supabase مهيأة لإرسال الرسائل إلى المستخدمين؛ راجع SMTP وحدود الإرسال والبريد غير الهام إن لم تصل الرسالة. لم يرسل الاختبار أي رسالة بريد حقيقية ولم يغيّر كلمة مرور حساب فعلي.

الشاشات تعمل على Flutter، لكن مسار روابط الاستعادة الحالي مهيأ للويب. تفعيل الرجوع إلى تطبيق iOS/Android المثبّت يتطلب إعداد Deep Links/Universal Links للمنصتين وعنوان redirect مناسبًا في بناء الجوال.

[معاينة نسيت كلمة المرور](screenshots/forgot-password.png) · [معاينة تعيين كلمة مرور جديدة](screenshots/reset-password.png)

## تنظيم الملفات

```text
lib/
  main.dart
  app.dart
  core/config/supabase_config.dart
  core/theme/share_theme.dart
  core/widgets/share_logo.dart
  features/auth/data/auth_service.dart
  features/auth/presentation/
    auth_gate.dart
    login_screen.dart
    forgot_password_screen.dart
    reset_password_screen.dart
    widgets/
      auth_text_field.dart
      recovery_layout.dart
      social_sign_in_button.dart
  features/home/presentation/home_screen.dart
assets/fonts/                 # Noto Sans Arabic وترخيص OFL
test/login_screen_test.dart   # RTL والحقول والأزرار والأحجام المختلفة
test/auth_flow_test.dart      # التحميل والتحقق والجلسة والدخول والخروج
test/auth_service_test.dart   # طلبات Supabase وترجمة أخطاء الخادم والاتصال
test/password_recovery_test.dart # طلب الاستعادة والرابط وتأكيد كلمة المرور
android/                     # Android / Kotlin
ios/                         # iOS / Swift
web/                         # معاينة المتصفح
```

الشعار العلوي وزخارفه أصل PNG شفاف مستقل في `assets/branding/share-logo.png`، أُنشئ استنادًا إلى الصورة المرجعية لتقريب شكل الحروف والنقاط والطائرة والزخارف الذهبية. لا يعتمد على نص أو أيقونات Flutter. تستخدمه شاشة الدخول عبر المكوّن المشترك `lib/core/widgets/share_logo.dart`، ويجب استخدام هذا المكوّن نفسه في جميع الشاشات القادمة. هذه إعادة إنشاء بصري وليست ملف الشعار الأصلي؛ يمكن استبدال الأصل الرسومي عند توفره دون تغيير تخطيط الشاشة. علامات Google وFacebook وX مرسومة محليًا كبدائل تجريبية، وApple من Material Icons. أيقونات التطبيق عند التثبيت ما زالت أيقونات Flutter الافتراضية.

خط Noto Sans Arabic وخط Roboto الاحتياطي مضمنان محليًا من Google Fonts تحت رخصة OFL، ولا يحتاجان تحميلًا وقت التشغيل.

## حالة التحقق في البيئة السحابية

نجح `flutter analyze` دون ملاحظات، ونجحت الاختبارات الـ33. أمر بناء الويب: `flutter build web --release --no-web-resources-cdn`. تغطي الاختبارات RTL وإظهار كلمة المرور والتحقق المحلي وإرسال النموذج وأحجام شاشات متعددة وتكبير النص ولوحة المفاتيح، إضافة إلى طلبات المصادقة والجلسة ورسائل الخطأ. اختبارات الدخول والخروج تستخدم خدمة اختبارية أو Supabase SDK مع خادم HTTP محاكى، ولا تسجّل الدخول بحساب إنتاجي ولا تنشئ حسابات. جرى أيضًا فحص المتصفح مع استجابات Auth محاكاة: الدخول، واستعادة الجلسة بعد تحديث الصفحة، والخروج، وبقاء حالة الخروج بعد تحديث جديد. لقطة الدخول بقيت مطابقة للصورة السابقة.

لم يُختبر بناء Android أو iOS: لا يوجد Android SDK في هذه البيئة، وبناء iOS يتطلب macOS وXcode. لا تحتاج الشاشة أي أسرار. حُفظت إضافة `storage.googleapis.com` لسياسة الشبكة لتنزيل أدوات Flutter.

ملف `pubspec.lock` مرفق لتثبيت إصدارات التبعيات. استخدم `flutter pub get --enforce-lockfile` في الإعدادات اللاحقة، وحدّث التبعيات عمدًا عند الحاجة.
