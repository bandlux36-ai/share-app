import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../../../core/theme/share_theme.dart';
import '../../../core/widgets/share_logo.dart';
import 'password_reset_sent_screen.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/recovery_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.authService,
    this.initialEmail = '',
  });
  final AuthService authService;
  final String initialEmail;
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  bool _busy = false;
  String? _error;
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
      if (!mounted || widget.authService.isSignedIn) return;
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(builder: (_) => const PasswordResetSentScreen()),
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is AuthFailure
              ? e.message
              : 'تعذّر إرسال الرابط. حاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: ShareLogo()),
                  const SizedBox(height: 32),
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    color: ShareTheme.yellow,
                    size: 130,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ضع بريدك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: ShareTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'أدخل البريد الإلكتروني المسجل في شير لنرسل لك رابط إعادة تعيين كلمة المرور.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.8,
                      color: ShareTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 28),
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
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  RecoveryButton(
                    label: 'إرسال رابط إعادة التعيين',
                    busy: _busy,
                    onPressed: _send,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      foregroundColor: ShareTheme.navy,
                      side: const BorderSide(color: ShareTheme.yellow),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'العودة إلى تسجيل الدخول',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
