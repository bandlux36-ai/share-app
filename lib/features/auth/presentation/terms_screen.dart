import 'package:flutter/material.dart';
import '../../../core/theme/share_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const sections = [
    (
      '1. استخدام التطبيق',
      'باستخدامك لتطبيق شير، فإنك توافق على استخدامه للأغراض المشروعة فقط، وعدم استخدامه في أي نشاط مخالف للأنظمة أو يضر بالمستخدمين أو بالخدمات المرتبطة بالتطبيق.',
    ),
    (
      '2. مسؤولية المحتوى',
      'يتحمل المستخدم كامل المسؤولية عن الصور والفيديوهات والنصوص والملفات التي يرفعها أو ينشرها من خلال شير، ويجب أن يمتلك حقوق استخدامها ونشرها وألا تنتهك حقوق الآخرين.',
    ),
    (
      '3. الحساب وأمان البيانات',
      'يتحمل المستخدم مسؤولية المحافظة على سرية بيانات تسجيل الدخول الخاصة به، ويلتزم بإبلاغ شير عند الاشتباه في استخدام غير مصرح به لحسابه.',
    ),
    (
      '4. الخدمات والمنصات الخارجية',
      'قد يرتبط شير بمنصات وخدمات خارجية مثل شبكات التواصل الاجتماعي. ويخضع استخدام تلك الخدمات لشروط وسياسات كل منصة، ولا يضمن شير استمرار توفر أي خدمة خارجية أو عدم تغييرها.',
    ),
    (
      '5. تعليق أو إيقاف الحساب',
      'يحق لإدارة شير تعليق أو إيقاف أي حساب يسيء استخدام التطبيق أو يخالف هذه الشروط أو الأنظمة المعمول بها، مع الاحتفاظ بحق تحديث شروط الاستخدام عند الحاجة وإبلاغ المستخدم بالتغييرات الجوهرية.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الشروط والأحكام')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final section in sections) ...[
                  Text(
                    section.$1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ShareTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    section.$2,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.9,
                      color: ShareTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
