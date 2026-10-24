import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SocialProvider { google, apple }

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  String get name => switch (provider) {
    SocialProvider.google => 'Google',
    SocialProvider.apple => 'Apple',
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12001C30),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Semantics(
            button: true,
            enabled: onPressed != null,
            liveRegion: isLoading,
            label: isLoading ? 'جارٍ فتح $name' : 'تسجيل الدخول بواسطة $name',
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: ExcludeSemantics(
                  child: isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : _icon(),
                ),
              ),
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
