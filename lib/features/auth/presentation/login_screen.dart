import 'package:flutter/material.dart';

import '../../../core/theme/share_theme.dart';
import '../data/auth_service.dart';
import 'widgets/auth_text_field.dart';
import '../../../core/widgets/share_logo.dart';
import 'widgets/social_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _signingIn = false;
  SocialProvider? _socialSigningIn;
  bool get _busy => _signingIn || _socialSigningIn != null;

  Future<void> _socialLogin(SocialProvider provider) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _socialSigningIn = provider);
    try {
      switch (provider) {
        case SocialProvider.google:
          await widget.authService.signInWithGoogle();
        case SocialProvider.apple:
          await widget.authService.signInWithApple();
      }
    } catch (error) {
      if (mounted) {
        final label = provider == SocialProvider.apple ? 'Apple' : 'Google';
        _demo(
          error is AuthFailure
              ? error.message
              : 'تعذّر تسجيل الدخول بـ$label. حاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _socialSigningIn = null);
    }
  }

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

  Future<void> _login() async {
    if (_busy || !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _signingIn = true);
    try {
      await widget.authService.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );
    } catch (error) {
      if (!mounted) return;
      _demo(
        error is AuthFailure
            ? error.message
            : 'تعذّر تسجيل الدخول. حاول مرة أخرى.',
      );
    } finally {
      if (mounted) setState(() => _signingIn = false);
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
                            SizedBox(height: 24 + space / 2),
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
                              validator: (value) =>
                                  (value?.trim().isEmpty ?? true)
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
                            SizedBox(height: 24 + space),
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
                                onPressed: _busy ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: ShareTheme.navy,
                                  minimumSize: const Size.fromHeight(70),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: _signingIn
                                    ? const SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: ShareTheme.navy,
                                          semanticsLabel: 'جارٍ تسجيل الدخول',
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              child: LayoutBuilder(
                                builder: (context, socialConstraints) => Center(
                                  child: SizedBox(
                                    width:
                                        (socialConstraints.maxWidth - 16) / 2,
                                    child: Row(
                                      children: [
                                        for (final provider
                                            in SocialProvider.values) ...[
                                          if (provider != SocialProvider.google)
                                            const SizedBox(width: 16),
                                          Expanded(
                                            child: SocialSignInButton(
                                              provider: provider,
                                              isLoading:
                                                  _socialSigningIn == provider,
                                              onPressed: _busy
                                                  ? null
                                                  : () =>
                                                        _socialLogin(provider),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 18 + space / 2),
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
