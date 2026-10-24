# إعداد تسجيل الدخول عبر Google

زر Google يستخدم Supabase OAuth مع PKCE، ويعود إلى نفس أصل موقع شير ومساره `/share-app/`. بعد نجاح تبادل الرمز تعرض AuthGate شاشة HomeScreen، وتبقى الجلسة قابلة للاستعادة كما في الدخول بالبريد. قبل فتح صفحة Google يقرأ التطبيق إعداد المزود العام؛ إذا كان معطلًا يعرض رسالة عربية ويبقى في شاشة الدخول.

## 1. Google Cloud

افتح https://console.cloud.google.com/auth/clients واختر مشروعك أو أنشئ مشروعًا.

جهّز Branding وAudience لتطبيق Google Auth، ثم أنشئ OAuth Client من نوع **Web application**.

في **Authorized JavaScript origins** أضف:

```text
https://bandlux36-ai.github.io
```

في **Authorized redirect URIs** أضف عنوان callback الخاص بـSupabase بالضبط:

```text
https://iroqzjahasvmhtmsmsvy.supabase.co/auth/v1/callback
```

إذا كان تطبيق Google في وضع Testing، أضف حسابات التجربة في Audience → Test users. للسماح لمستخدمين آخرين اضبط حالة النشر ومتطلبات Google المناسبة لتطبيقك.

## 2. Supabase

افتح https://supabase.com/dashboard/project/iroqzjahasvmhtmsmsvy/auth/providers ثم اختر Google.

فعّل المزود، وانسخ Client ID وClient Secret من Google إلى حقولهما في Supabase ثم احفظ. **Client Secret يبقى داخل Supabase فقط**؛ لا تضعه في Flutter أو GitHub أو المحادثة. لا يحتاج هذا التدفق إلى مفاتيح Google في GitHub Actions.

من Authentication → URL Configuration أبقِ Site URL على:

```text
https://bandlux36-ai.github.io/share-app/
```

وأضف العنوان نفسه إلى Redirect URLs، مع الاحتفاظ بعنوان استعادة كلمة المرور الموجود سابقًا. عنوان Supabase callback يُضاف في Google Cloud، وعنوان موقع شير يُضاف في Supabase؛ لكل منهما مكانه.

## 3. التجربة

بعد نجاح نشر GitHub Actions، حدّث الموقع واضغط Google. اختر حسابك في Google وأكمل الموافقة؛ يجب أن تعود إلى HomeScreen. جرّب تحديث الصفحة ثم تسجيل الخروج. الإلغاء أو فشل الرجوع يعرض رسالة عربية، دون كشف أو تسجيل معلمات الرابط.

لم تُنفّذ اختبارات تلقائية بحساب Google حقيقي. اختبارات الكود والمتصفح تستخدم حسابات واستجابات محاكاة، ولا تستخدم بريد الاختبار أو كلمة مروره المحفوظين في البيئة.

زر Apple ما زال تجريبيًا؛ أُزيل زرا Facebook وX من شاشة الدخول. لنسخ iOS/Android يلزم إعداد Deep Links/Universal Links وعنوان رجوع مناسب؛ يمكن تحديده وقت البناء بـ`GOOGLE_AUTH_REDIRECT_URL`. إعداد نسخة الويب الحالية لا يكمل إعداد روابط تطبيقات الجوال تلقائيًا.
