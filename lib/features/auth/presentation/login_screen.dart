import 'package:flutter/material.dart';

import '../../../core/theme/share_theme.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/share_logo.dart';
import 'widgets/social_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _demo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _demo('مرحبًا بك في شير! هذه معاينة تجريبية دون تسجيل دخول فعلي.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, ShareTheme.background, Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Keep the reference's proportions on tall phones, and scroll on
              // compact screens, landscape, large type, or when the keyboard opens.
              final space = ((constraints.maxHeight - 730) / 7).clamp(
                0.0,
                12.0,
              );
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(20, 38 + space / 2, 20, 26),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: ShareLogo()),
                            SizedBox(height: 12 + space / 2),
                            const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'ارفع محتواك .. وانشره في كل مكان',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  color: ShareTheme.heading,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'صور، فيديوهات .. إلى جميع منصاتك بسهولة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: ShareTheme.secondary,
                              ),
                            ),
                            SizedBox(height: 30 + space / 2),
                            AuthTextField(
                              controller: _email,
                              label: 'البريد الإلكتروني',
                              icon: Icons.mail_outline_rounded,
                              autofillHint: AutofillHints.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final email = value?.trim() ?? '';
                                if (!RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(email)) {
                                  return 'أدخل بريدًا إلكترونيًا صحيحًا';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _password,
                              label: 'كلمة المرور',
                              icon: Icons.lock_outline_rounded,
                              autofillHint: AutofillHints.password,
                              obscureText: _hidePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _login(),
                              validator: (value) => (value?.isEmpty ?? true)
                                  ? 'أدخل كلمة المرور'
                                  : null,
                              trailing: IconButton(
                                tooltip: _hidePassword
                                    ? 'إظهار كلمة المرور'
                                    : 'إخفاء كلمة المرور',
                                onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: ShareTheme.muted,
                                  size: 25,
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton(
                                onPressed: () => _demo(
                                  'استعادة كلمة المرور ستتوفر لاحقًا. هذه نسخة تجريبية.',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: ShareTheme.muted,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            SizedBox(height: 8 + space),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFCD50),
                                    Color(0xFFFFD464),
                                    Color(0xFFFFCC4D),
                                  ],
                                ),
                                boxShadow: const [ShareTheme.warmShadow],
                              ),
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: ShareTheme.navy,
                                  minimumSize: const Size.fromHeight(70),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  textDirection: TextDirection.ltr,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 28,
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 27 + space / 2),
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Color(0xFFD8DBDF)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'أو',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Color(0xFFD8DBDF)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 23),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                children: [
                                  for (final provider
                                      in SocialProvider.values) ...[
                                    if (provider != SocialProvider.google)
                                      const SizedBox(width: 16),
                                    Expanded(
                                      child: SocialSignInButton(
                                        provider: provider,
                                        onPressed: () => _demo(
                                          'تسجيل الدخول بواسطة ${provider.name} تجريبي فقط.',
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: 26 + space / 2),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                const Text(
                                  'ليس لديك حساب؟',
                                  style: TextStyle(fontSize: 15),
                                ),
                                TextButton(
                                  onPressed: () => _demo(
                                    'إنشاء حساب جديد سيتوفر لاحقًا. هذه نسخة تجريبية.',
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFFFAF00),
                                  ),
                                  child: const Text(
                                    'إنشاء حساب جديد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
