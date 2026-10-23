import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/share_theme.dart';

enum SocialProvider { google, apple, facebook, x }

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;

  String get name => switch (provider) {
    SocialProvider.google => 'Google',
    SocialProvider.apple => 'Apple',
    SocialProvider.facebook => 'Facebook',
    SocialProvider.x => 'X',
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [ShareTheme.warmShadow],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Semantics(
            button: true,
            label: 'تسجيل الدخول بواسطة $name',
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(child: ExcludeSemantics(child: _icon())),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon() => switch (provider) {
    SocialProvider.google => const CustomPaint(
      size: Size.square(32),
      painter: _GoogleMarkPainter(),
    ),
    SocialProvider.apple => const Icon(
      Icons.apple,
      size: 40,
      color: Colors.black,
    ),
    SocialProvider.facebook => Container(
      width: 34,
      height: 34,
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        color: Color(0xFF087AFF),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'f',
        style: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 37,
          fontWeight: FontWeight.w800,
          height: 1,
          color: Colors.white,
        ),
      ),
    ),
    SocialProvider.x => const CustomPaint(
      size: Size(29, 32),
      painter: _XMarkPainter(),
    ),
  };
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5;
    final arc = rect.deflate(3.5);
    // Four color segments keep the demo independent of remote image services.
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arc, 0, math.pi / 3, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arc, math.pi / 3, math.pi / 2, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arc, math.pi * 5 / 6, math.pi / 3, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arc, math.pi * 7 / 6, math.pi * 0.57, false, paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width - 0.5, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GoogleMarkPainter oldDelegate) => false;
}

class _XMarkPainter extends CustomPainter {
  const _XMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(1, 0)
      ..lineTo(9, 0)
      ..lineTo(28, 32)
      ..lineTo(20, 32)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
    canvas.drawLine(
      const Offset(27, 0),
      const Offset(1, 32),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      const Offset(5, 2),
      const Offset(24, 30),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_XMarkPainter oldDelegate) => false;
}
