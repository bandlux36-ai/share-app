# إعداد تسجيل الدخول عبر Apple

زر Apple مربوط بتدفق Supabase OAuth للويب مع PKCE، ويعود إلى موقع شير ثم يعرض الرئيسية عند نجاح الجلسة. يستخدم إعداد المزود العام لإظهار رسالة عربية إذا كان Apple معطّلًا، ويحافظ على تنسيق شاشة الدخول.

الحالة الحالية: مزوّد Apple غير مفعّل في Supabase، ولم تُستكمل متطلبات حساب Apple Developer Program. الكود وحده لا يفعّل الخدمة؛ يلزم إكمال إعدادات الحساب التالية بعد الحصول على العضوية. الاشتراك قرار منفصل للمستخدم ولا ينفّذه التطبيق.

## 1. حساب Apple Developer

يلزم حساب بعضوية نشطة في [Apple Developer Program](https://developer.apple.com/programs/). افتح [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)، ثم:

1. أنشئ أو اختر **App ID**، وفعّل فيه **Sign in with Apple** بوصفه **Primary App ID**. احتفظ بـ**Team ID** الخاص بالحساب.
2. أنشئ **Services ID** خاصًا بدخول الويب؛ هذا هو **Client ID** المستخدم في Supabase. اختر معرفًا تملكه وفريدًا، ولا تستخدم مثالًا من دليل آخر كما هو.
3. داخل Services ID فعّل **Sign in with Apple → Configure**، واختر Primary App ID السابق.
4. في **Domains and Subdomains** أدخل نطاق Supabase دون `https://` أو مسار:

```text
iroqzjahasvmhtmsmsvy.supabase.co
```

في **Return URLs** أدخل عنوان الرجوع التالي بالضبط، ثم احفظ الإعدادات:

```text
https://iroqzjahasvmhtmsmsvy.supabase.co/auth/v1/callback
```

هذا النطاق وعنوان الرجوع يخصان تدفق Supabase OAuth. رابط واجهة شير النهائي يُسجّل في Supabase في الخطوة الثالثة.

## 2. إنشاء Client Secret

من [Apple Developer → Keys](https://developer.apple.com/account/resources/authkeys/list)، أنشئ مفتاحًا يدعم **Sign in with Apple** واربطه بالـPrimary App ID. احتفظ بـ**Key ID** ونزّل ملف المفتاح الخاص `.p8` واحفظه بأمان؛ لا تعتمد على إمكانية تنزيله مرة ثانية.

استخدم أداة **Apple client secret** الموجودة في [دليل Supabase الرسمي](https://supabase.com/docs/guides/auth/social-login/auth-apple#configuration-web-oauth) عبر Chrome أو Firefox. الأداة تعمل محليًا في المتصفح وفق الدليل، وتتطلب Team ID وKey ID وServices ID وملف المفتاح `.p8`. ناتج الأداة هو **Client Secret بصيغة JWT**؛ هذا ما يُلصق في Supabase، وليس محتوى ملف `.p8` نفسه.

تنتهي صلاحية Client Secret خلال مدة لا تتجاوز **ستة أشهر**. جدّده قبل انتهاء صلاحيته وحدّث القيمة في Supabase حتى يستمر تسجيل الدخول. يمكن استعمال ملف التوقيع `.p8` نفسه للتجديد ما دام صالحًا؛ لا يلزم إنشاء مفتاح توقيع جديد كل ستة أشهر.

ملف `.p8` والـClient Secret يبقيان خارج Flutter والمستودع وGitHub Actions والمحادثة. التطبيق لا يحتاج أيًا منهما.

## 3. إعداد Supabase

افتح [إعدادات Apple في المشروع](https://supabase.com/dashboard/project/iroqzjahasvmhtmsmsvy/auth/providers?provider=Apple):

1. فعّل **Sign in with Apple**.
2. في **Client IDs** أدخل **Services ID** الذي أنشأته. عند إضافة Bundle IDs مستقبلًا للدخول الأصلي على iOS، يجب أن يبقى **Services ID أول عنصر** في القائمة لدخول الويب.
3. في **Client Secret (for OAuth)** الصق JWT الناتج من الخطوة السابقة، ثم اضغط **Save**.

من **Authentication → URL Configuration** اجعل Site URL وأضف إلى Redirect URLs:

```text
https://bandlux36-ai.github.io/share-app/
```

احتفظ بروابط Google واستعادة كلمة المرور الحالية. يمكن تخصيص رجوع Apple وقت البناء بواسطة `APPLE_AUTH_REDIRECT_URL`، ويجب السماح بالرابط المخصص في Supabase أيضًا.

## 4. اختبار الويب

افتح [شير](https://bandlux36-ai.github.io/share-app/) واضغط Apple، وأكمل الدخول بحساب Apple ثم الموافقة. يجب أن تعود إلى الرئيسية، وتبقى الجلسة بعد تحديث الصفحة، ويعيدك تسجيل الخروج إلى شاشة الدخول. جرّب أيضًا إلغاء شاشة Apple وتحقق من بقاء شاشة الدخول متاحة برسالة عربية.

الاختبارات الآلية تحاكي OAuth ولا تستخدم حساب Apple حقيقيًا. لم يُختبر الدخول الإنتاجي عبر Apple قبل استكمال العضوية وإعداد المزود.

## حدود التنفيذ الحالي

هذا التنفيذ مهيأ لدخول **الويب** عبر Supabase. تسجيل الدخول الأصلي داخل تطبيق iOS/macOS يحتاج إعداد Capability وBundle ID وتدفقًا أصليًا منفصلًا باستخدام nonce و`signInWithIdToken`؛ رابط الويب لا يكمّل إعداد تطبيق الجوال تلقائيًا.

Supabase يحدد نطاقي `email` و`name` لتدفق Apple؛ لا يتطلب التطبيق تمريرهما يدويًا. لا تعتمد الواجهة على وصول الاسم الكامل: رمز هوية Apple لا يتضمن الاسم، ولا يضمن تدفق OAuth توفيره. قد يختار المستخدم **Hide My Email**؛ عند إرسال رسائل إلى عنوان Apple الوسيط يلزم إعداد مصادر البريد في **Sign in with Apple for Email Communication** واستخدام مرسل SMTP مسموح به.

## المراجع

- [Supabase: Sign in with Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [مصدر دليل Supabase الرسمي](https://github.com/supabase/supabase/blob/master/apps/docs/content/guides/auth/social-sign-in/auth-apple.mdx)
- [Apple: Configure Sign in with Apple for the web](https://developer.apple.com/help/account/capabilities/configure-sign-in-with-apple-for-the-web/)
- [مصدر إعداد نطاقات Apple في Supabase Auth](https://github.com/supabase/auth/blob/master/internal/api/provider/apple.go)
