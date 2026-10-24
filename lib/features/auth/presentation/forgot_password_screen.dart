import 'package:flutter/material.dart';

import '../../../core/theme/share_theme.dart';
import '../data/auth_service.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/recovery_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.authService,
    this.initialEmail = '',
    this.initialError,
    this.onBack,
  });

  final AuthService authService;
  final String initialEmail;
  final String? initialError;
  final VoidCallback? onBack;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  bool _sent = false;
  late String? _error = widget.initialError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.authService.requestPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AuthFailure
              ? error.message
              : 'تعذّر إرسال رابط الاستعادة. حاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _back() =>
      widget.onBack != null ? widget.onBack!() : Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) => RecoveryLayout(
    title: 'نسيت كلمة المرور؟',
    description:
        'لا تقلق، أدخل بريدك الإلكتروني وسنرسل لك رابطًا لتعيين كلمة مرور جديدة.',
    onBack: _back,
    child: _sent
        ? Column(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: ShareTheme.navy,
                size: 54,
              ),
              const SizedBox(height: 18),
              const Text(
                'تحقّق من بريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ShareTheme.navy,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'إذا كان البريد مسجّلًا لدينا، فستصلك رسالة تحتوي على رابط الاستعادة. تحقّق أيضًا من البريد غير الهام، وافتح الرابط في نفس المتصفح الذي أرسلت منه الطلب.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _back,
                child: const Text('العودة لتسجيل الدخول'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _sent = false;
                  _error = null;
                }),
                child: const Text('استخدام بريد آخر'),
              ),
            ],
          )
        : Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                AuthTextField(
                  controller: _email,
                  label: 'البريد الإلكتروني',
                  icon: Icons.mail_outline_rounded,
                  autofillHint: AutofillHints.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _send(),
                  validator: (value) =>
                      RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(value?.trim() ?? '')
                      ? null
                      : 'أدخل بريدًا إلكترونيًا صحيحًا',
                ),
                const SizedBox(height: 24),
                RecoveryButton(
                  label: 'إرسال رابط الاستعادة',
                  busy: _busy,
                  onPressed: _send,
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: _back,
                  child: const Text('العودة لتسجيل الدخول'),
                ),
              ],
            ),
          ),
  );
}
