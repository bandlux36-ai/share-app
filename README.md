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
- رابط «نسيت كلمة المرور؟» يفتح شاشة «ضع بريدك». بعد إدخال البريد والضغط على «إرسال رابط إعادة التعيين» يُطلب الرابط من Supabase وتظهر شاشة التأكيد عند نجاح الطلب. يجب السماح بعنوان https://bandlux36-ai.github.io/share-app/?recovery=1 في Supabase Redirect URLs وتهيئة البريد/SMTP وحدود الإرسال. افتح الرابط على نفس المتصفح والجهاز لإكمال PKCE وتعيين كلمة جديدة. لم يُختبر وصول رسالة إلى صندوق بريد حقيقي أثناء الاختبارات الآلية.
- استخدم حسابًا موجودًا في Supabase Auth: البريد وكلمة المرور يُرسلان عبر `signInWithPassword`. ليست هناك بيانات دخول تجريبية مضمّنة.
- Google وApple مربوطان بـSupabase OAuth؛ يتطلب كل منهما تفعيل مزوّده كما في الدليلين أدناه. إنشاء الحساب بالبريد مربوط بـSupabase مع الاسم وتأكيد كلمة المرور والموافقة؛ عند تفعيل تأكيد البريد تظهر رسالة للتحقق من البريد، وإلا تفتح الرئيسية. الشروط والأحكام وسياسة الخصوصية متاحتان داخل التطبيق بالنصوص المعتمدة، عبر روابط الموافقة في شاشة إنشاء الحساب.
- يعرض زر الدخول مؤشر تحميل ويمنع الطلبات المتكررة. أخطاء البيانات والاتصال تظهر بالعربية.
- عند نجاح الدخول تظهر `HomeScreen` برسالة ترحيب وزر خروج. يستخدم الخروج `signOut` ثم تعيد حالة الجلسة المستخدم لشاشة الدخول.
- يستعيد Supabase الجلسة المخزّنة عند تشغيل التطبيق؛ المستخدم المسجّل يدخل إلى الرئيسية مباشرة.
- المساحة الآمنة والتمرير والحد الأقصى لعرض المحتوى تدعم الشاشات المختلفة والاتجاه الأفقي ولوحة المفاتيح.

## تهيئة Supabase

ثُبّتت حزمة `supabase_flutter`، وتُهيّأ مرة واحدة قبل `runApp` في `lib/main.dart`. إعداد المشروع منفصل في `lib/core/config/supabase_config.dart`، ويستخدم عنوان المشروع وPublishable key العام المخصص لتطبيقات العميل. لا يوجد مفتاح `service_role` أو مفتاح سري في هذا الإعداد.

يمكن تجاوز القيم العامة بواسطة `--dart-define=SUPABASE_URL=...` و`--dart-define=SUPABASE_PUBLISHABLE_KEY=...`. لا تمرر مفاتيح إدارية أو سرية عبر هذه الخيارات: قيم تطبيقات العميل قابلة للاستخراج من حزمة التطبيق. صلاحيات البيانات يجب أن تظل محكومة بسياسات RLS في Supabase.

منطق المصادقة مستقل في `lib/features/auth/data/auth_service.dart`، وتتابع `AuthGate` حالة الجلسة لعرض شاشة الدخول أو الرئيسية دون إبقاء شاشة محمية في سجل الرجوع بعد الخروج. تصميم الدخول محفوظ. لا تُنشأ جداول أعمال من التطبيق. قد ينشئ Supabase حساب Auth للمستخدم عند دخوله الأول عبر Google أو Apple وفق إعدادات المشروع. إنشاء الحساب بالبريد مربوط بـSupabase مع الاسم وتأكيد كلمة المرور والموافقة؛ عند تفعيل تأكيد البريد تظهر رسالة للتحقق من البريد، وإلا تفتح الرئيسية. الشروط والأحكام وسياسة الخصوصية متاحتان داخل التطبيق بالنصوص المعتمدة، عبر روابط الموافقة في شاشة إنشاء الحساب. أضيف تصريح INTERNET لإصدار Android الأساسي.

نطاق مشروع Supabase هو `iroqzjahasvmhtmsmsvy.supabase.co`؛ حُفظ السماح به في مسودة إعدادات البيئة، مع الإبقاء على نطاق تنزيل Flutter الحالي.

## تسجيل الدخول بـGoogle

زر Google يبدأ تدفق OAuth عبر Supabase مع PKCE، ويحافظ على مسار GitHub Pages عند الرجوع. يظهر تحميل أثناء التحقق وفتح الخدمة، وتُمنع النقرات المتكررة. إذا كان المزود غير مفعّل تظهر رسالة عربية بدل ترك المستخدم في صفحة خطأ خارجية. نجاح الرجوع يعرض HomeScreen، وإلغاء الدخول يعرض رسالة عربية دون كشف معلمات الرابط.

يلزم إنشاء Web OAuth Client في Google Cloud وإدخال Client ID وClient Secret في إعداد Google داخل Supabase فقط. لا يحتاج التطبيق إلى Google Client Secret ولا يُحفظ في GitHub. راجع [دليل إعداد Google](docs/GOOGLE_SIGN_IN.md) للعناوين الدقيقة وخطوات التفعيل.

مزوّد Google مفعّل في لوحة Supabase، وتم التحقق من نجاح الدخول يدويًا. الاختبارات الآلية تستخدم OAuth محاكى ولا تسجّل الدخول بحساب Google حقيقي.

## تسجيل الدخول بـApple

زر Apple يستخدم Supabase OAuth مع PKCE ويحافظ على مسار `/share-app/` عند الرجوع. يتحقق أولًا من تفعيل Apple في الإعداد العام؛ عند تعطيله يعرض رسالة عربية ويبقى في الصفحة. يتوقف تكرار الطلبات والدخول بالبريد أو Google أثناء فتح Apple، وتعرض الجلسة الناجحة الصفحة الرئيسية بالطريقة نفسها.

الكود جاهز للويب، لكن Apple غير مفعّل حاليًا في المشروع. التفعيل يتطلب عضوية Apple Developer مدفوعة وإعداد Services ID ومفتاح توقيع وClient Secret داخل Supabase. لم تُستكمل متطلبات حساب المطوّر بعد، لذا لم يُختبر دخول Apple فعلي. لا تحفظ ملف `.p8` أو Client Secret في Flutter أو GitHub؛ يُجدّد Client Secret قبل انتهاء صلاحيته (ستة أشهر كحد أقصى). راجع [دليل إعداد Apple](docs/APPLE_SIGN_IN.md).

يمكن تخصيص عنوان الرجوع العام عبر `APPLE_AUTH_REDIRECT_URL` عند البناء؛ الافتراضي على الويب هو أصل الصفحة ومسارها دون معلمات أو fragment. مسار iOS/Android الأصلي وSign in with Apple الأصلي يحتاجان إعدادًا منفصلًا؛ الكود الحالي لا يضيف entitlement أو native Apple SDK. اختبارات Apple تستخدم استجابات OAuth محاكاة دون حساب Apple حقيقي.

## تنظيم الملفات

```text
lib/
  main.dart
  app.dart
  core/config/supabase_config.dart
  core/config/redirect_uri.dart
  core/theme/share_theme.dart
  core/widgets/share_logo.dart
  features/auth/data/auth_service.dart
  features/auth/data/oauth_provider_settings.dart
  features/auth/platform/auth_location.dart
  features/auth/platform/auth_location_stub.dart
  features/auth/platform/auth_location_web.dart
  features/auth/presentation/
    auth_gate.dart
    login_screen.dart
    widgets/
      auth_text_field.dart
      social_sign_in_button.dart
  features/home/presentation/home_screen.dart
assets/fonts/                 # Noto Sans Arabic وترخيص OFL
test/login_screen_test.dart   # RTL والحقول والأزرار والأحجام المختلفة
test/auth_flow_test.dart      # التحميل والتحقق والجلسة والدخول والخروج
test/auth_service_test.dart   # طلبات Supabase وترجمة أخطاء الخادم والاتصال
test/google_auth_test.dart    # مزود Google والتحميل وأخطاء OAuth
test/apple_auth_test.dart     # مزود Apple ومنع الطلبات المتزامنة والرجوع
android/                     # Android / Kotlin
ios/                         # iOS / Swift
web/                         # معاينة المتصفح
```

الشعار العلوي وزخارفه أصل PNG شفاف مستقل في `assets/branding/share-logo.png`، أُنشئ استنادًا إلى الصورة المرجعية لتقريب شكل الحروف والنقاط والطائرة والزخارف الذهبية. لا يعتمد على نص أو أيقونات Flutter. تستخدمه شاشة الدخول عبر المكوّن المشترك `lib/core/widgets/share_logo.dart`، ويجب استخدام هذا المكوّن نفسه في جميع الشاشات القادمة. هذه إعادة إنشاء بصري وليست ملف الشعار الأصلي؛ يمكن استبدال الأصل الرسومي عند توفره دون تغيير تخطيط الشاشة. علامة Google مرسومة محليًا، وApple من Material Icons. تظهر في شاشة الدخول أزرار Google وApple فقط. أيقونات التطبيق عند التثبيت ما زالت أيقونات Flutter الافتراضية.

خط Noto Sans Arabic وخط Roboto الاحتياطي مضمنان محليًا من Google Fonts تحت رخصة OFL، ولا يحتاجان تحميلًا وقت التشغيل.

## حالة التحقق في البيئة السحابية

نجح `flutter analyze` دون ملاحظات، ونجحت الاختبارات. أمر بناء الويب: `flutter build web --release --no-web-resources-cdn`. تغطي الاختبارات RTL وإظهار كلمة المرور والتحقق المحلي وإرسال النموذج وأحجام شاشات متعددة وتكبير النص ولوحة المفاتيح، إضافة إلى طلبات المصادقة والجلسة ورسائل الخطأ. اختبارات الدخول والخروج تستخدم خدمة اختبارية أو Supabase SDK مع خادم HTTP محاكى، ولا تسجّل الدخول بحساب إنتاجي ولا تنشئ حسابات. جرى أيضًا فحص المتصفح مع استجابات Auth محاكاة: الدخول، واستعادة الجلسة بعد تحديث الصفحة، والخروج، وبقاء حالة الخروج بعد تحديث جديد. فحص Google وApple يحاكي مسار OAuth مع PKCE ويشمل إلغاء الدخول والمزوّد المعطّل، دون تسجيل الدخول إلى حساب خارجي حقيقي. تُعرض أزرار Google وApple فقط في صف وسط الشاشة، مع الحفاظ على حجم الأزرار وبقية التنسيق.

لم يُختبر بناء Android أو iOS: لا يوجد Android SDK في هذه البيئة، وبناء iOS يتطلب macOS وXcode. لا تحتاج الشاشة أي أسرار. حُفظت إضافة `storage.googleapis.com` لسياسة الشبكة لتنزيل أدوات Flutter.

ملف `pubspec.lock` مرفق لتثبيت إصدارات التبعيات. استخدم `flutter pub get --enforce-lockfile` في الإعدادات اللاحقة، وحدّث التبعيات عمدًا عند الحاجة.

## الواجهة الرئيسية

[معاينة الشاشة الرئيسية](screenshots/home-screen.png)

بعد تسجيل الدخول تظهر واجهة المحتوى بثلاث بطاقات اختيار، وشبكة 11 منصة، وتنقل الرئيسية/شير/التنبيهات/الملف الشخصي. يمكن اختيار صورة (حتى 10 ميجابايت) أو فيديو (حتى 100 ميجابايت) من الجهاز؛ الصور تُعاين محليًا والفيديو يظهر باسمه. اختيار الملفات لا يرفعها إلى خادم. علامات الاختيار تحدد أهداف النشر فقط؛ الحسابات الخارجية غير مربوطة، ولا يوجد نشر فعلي بعد. تعرض إدارة المنصات حالة «غير مرتبط»، وتوضح شاشة المعاينة ذلك. تسجيل الخروج متاح من قائمة الحساب ومن الملف الشخصي.

تستخدم علامات المنصات حزمة `font_awesome_flutter` محليًا، واختيار الملفات حزمة `file_selector`.
