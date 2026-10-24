import 'package:flutter/material.dart';
import '../../../core/theme/share_theme.dart';
import '../../../core/widgets/share_logo.dart';
import '../data/auth_service.dart';
import 'widgets/auth_text_field.dart';
import 'terms_screen.dart';
import 'widgets/recovery_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.authService});
  final AuthService authService;
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true,
      _hideConfirm = true,
      _agree = false,
      _busy = false,
      _sent = false;
  String? _error;
  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    if (!_agree) {
      setState(
        () => _error = 'يرجى الموافقة على الشروط والأحكام وسياسة الخصوصية.',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final signedIn = await widget.authService.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      _password.clear();
      _confirm.clear();
      if (!mounted) return;
      if (signedIn) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() => _sent = true);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is AuthFailure
              ? e.message
              : 'تعذّر إنشاء الحساب. حاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _passwordField(TextEditingController controller, bool confirmation) =>
      AuthTextField(
        controller: controller,
        label: confirmation ? 'تأكيد كلمة المرور' : 'كلمة المرور',
        icon: Icons.lock_outline_rounded,
        autofillHint: AutofillHints.newPassword,
        obscureText: confirmation ? _hideConfirm : _hide,
        textInputAction: confirmation
            ? TextInputAction.done
            : TextInputAction.next,
        onSubmitted: confirmation ? (_) => _submit() : null,
        validator: (v) => confirmation
            ? (v != _password.text || (v?.isEmpty ?? true)
                  ? 'كلمتا المرور غير متطابقتين'
                  : null)
            : ((v?.length ?? 0) < 8 ? 'استخدم 8 أحرف على الأقل' : null),
        trailing: IconButton(
          tooltip: (confirmation ? _hideConfirm : _hide)
              ? 'إظهار ${confirmation ? 'تأكيد كلمة المرور' : 'كلمة المرور'}'
              : 'إخفاء ${confirmation ? 'تأكيد كلمة المرور' : 'كلمة المرور'}',
          onPressed: () => setState(() {
            if (confirmation) {
              _hideConfirm = !_hideConfirm;
            } else {
              _hide = !_hide;
            }
          }),
          icon: Icon(
            (confirmation ? _hideConfirm : _hide)
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: ShareTheme.muted,
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        tooltip: 'العودة لتسجيل الدخول',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: ShareLogo()),
                    const SizedBox(height: 24),
                    const Text(
                      'إنشاء حساب جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: ShareTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'ابدأ رحلتك مع شير وشارك محتواك بكل سهولة',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: ShareTheme.muted),
                    ),
                    const SizedBox(height: 28),
                    if (_sent) ...[
                      const Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color: ShareTheme.yellow,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'تحقق من بريدك الإلكتروني لإكمال إنشاء الحساب، ثم عد لتسجيل الدخول.',
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 1.8, fontSize: 17),
                      ),
                      const SizedBox(height: 24),
                      RecoveryButton(
                        label: 'العودة إلى تسجيل الدخول',
                        busy: false,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ] else ...[
                      AuthTextField(
                        controller: _name,
                        label: 'الاسم',
                        icon: Icons.person_outline_rounded,
                        autofillHint: AutofillHints.name,
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'أدخل اسمك' : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _email,
                        label: 'البريد الإلكتروني',
                        icon: Icons.mail_outline_rounded,
                        autofillHint: AutofillHints.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(v?.trim() ?? '')
                            ? null
                            : 'أدخل بريدًا إلكترونيًا صحيحًا',
                      ),
                      const SizedBox(height: 16),
                      _passwordField(_password, false),
                      const SizedBox(height: 16),
                      _passwordField(_confirm, true),
                      const SizedBox(height: 30),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: ShareTheme.yellow,
                        checkColor: ShareTheme.navy,
                        value: _agree,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _agree = v ?? false),
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'أوافق على ',
                              style: TextStyle(
                                fontSize: 13,
                                color: ShareTheme.muted,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => const TermsScreen(),
                                ),
                              ),
                              child: const Text(
                                'الشروط والأحكام',
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              'و',
                              style: TextStyle(
                                fontSize: 13,
                                color: ShareTheme.muted,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'سياسة الخصوصية غير متاحة حاليًا.',
                                      ),
                                    ),
                                  ),
                              child: const Text(
                                'سياسة الخصوصية',
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      RecoveryButton(
                        label: 'إنشاء الحساب',
                        busy: _busy,
                        onPressed: _submit,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
