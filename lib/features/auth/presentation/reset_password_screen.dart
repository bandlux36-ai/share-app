import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/recovery_layout.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.authService,
    required this.onCompleted,
  });
  final AuthService authService;
  final VoidCallback onCompleted;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hide = true;
  bool _hideConfirmation = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.authService.updatePassword(_password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح.')),
      );
      widget.onCompleted();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AuthFailure
              ? error.message
              : 'تعذّر تغيير كلمة المرور. حاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.authService.signOut();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AuthFailure
              ? error.message
              : 'تعذّر تسجيل الخروج. حاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => RecoveryLayout(
    title: 'تعيين كلمة مرور جديدة',
    description: 'اختر كلمة مرور من 8 أحرف على الأقل، ثم أعد كتابتها للتأكيد.',
    onBack: _cancel,
    child: Form(
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: 18),
          ],
          AuthTextField(
            controller: _password,
            label: 'كلمة المرور الجديدة',
            icon: Icons.lock_outline_rounded,
            autofillHint: AutofillHints.newPassword,
            obscureText: _hide,
            trailing: IconButton(
              tooltip: _hide ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
              onPressed: () => setState(() => _hide = !_hide),
              icon: Icon(
                _hide
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) =>
                (value?.trim().isEmpty ?? true) || (value?.length ?? 0) < 8
                ? 'استخدم كلمة مرور من 8 أحرف على الأقل'
                : null,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _confirmation,
            label: 'تأكيد كلمة المرور',
            icon: Icons.lock_outline_rounded,
            autofillHint: AutofillHints.newPassword,
            obscureText: _hideConfirmation,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            trailing: IconButton(
              tooltip: _hideConfirmation ? 'إظهار التأكيد' : 'إخفاء التأكيد',
              onPressed: () =>
                  setState(() => _hideConfirmation = !_hideConfirmation),
              icon: Icon(
                _hideConfirmation
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) =>
                value == _password.text ? null : 'كلمتا المرور غير متطابقتين',
          ),
          const SizedBox(height: 24),
          RecoveryButton(
            label: 'حفظ كلمة المرور',
            busy: _busy,
            onPressed: _save,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: _busy ? null : _cancel,
            child: const Text('العودة لتسجيل الدخول'),
          ),
        ],
      ),
    ),
  );
}
