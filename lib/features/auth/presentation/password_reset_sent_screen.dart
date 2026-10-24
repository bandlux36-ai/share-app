import 'package:flutter/material.dart';
import '../../../core/theme/share_theme.dart';
import '../../../core/widgets/share_logo.dart';

class PasswordResetSentScreen extends StatelessWidget {
  const PasswordResetSentScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const ShareLogo(),
                const SizedBox(height: 32),
                const SizedBox(
                  height: 170,
                  width: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF7DF),
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 160, height: 160),
                      ),
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 130,
                        color: ShareTheme.yellow,
                      ),
                      Positioned(
                        right: 10,
                        bottom: 5,
                        child: CircleAvatar(
                          radius: 29,
                          backgroundColor: Color(0xFF43C753),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 43,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'تم إرسال رابط إعادة\nتعيين كلمة المرور',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                    color: ShareTheme.navy,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'إذا كان بريدك الإلكتروني مسجّلًا في شير، فستصلك رسالة تحتوي على رابط لإعادة تعيين كلمة المرور.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.9,
                    color: ShareTheme.muted,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        color: ShareTheme.yellow,
                        size: 30,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'يرجى التحقق من بريدك الوارد، وإذا لم تجده، تأكد من مجلد الرسائل غير المرغوب فيها (Spam).',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.8,
                            color: ShareTheme.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShareTheme.yellow,
                      foregroundColor: ShareTheme.navy,
                      minimumSize: const Size.fromHeight(64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'العودة إلى تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
