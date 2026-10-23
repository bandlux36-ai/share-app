import 'package:flutter/material.dart';

/// Reference-based transparent artwork, including the gold decorations.
class ShareLogo extends StatelessWidget {
  const ShareLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'شعار شير',
      image: true,
      child: ExcludeSemantics(
        child: Image.asset(
          'assets/branding/share-logo.png',
          width: 270,
          height: 140,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
