import 'package:flutter/material.dart';

import '../../../../core/theme/share_theme.dart';

/// Temporary typographic logo. Replace this widget with the official SVG asset.
class ShareLogo extends StatelessWidget {
  const ShareLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'شعار شير',
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: 270,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                left: 126,
                child: Transform.rotate(
                  angle: -0.5,
                  child: const Icon(
                    Icons.send_rounded,
                    textDirection: TextDirection.ltr,
                    size: 49,
                    color: ShareTheme.yellow,
                  ),
                ),
              ),
              const Positioned(
                bottom: -10,
                child: Text(
                  'شير',
                  style: TextStyle(
                    fontSize: 96,
                    height: 1.5,
                    fontWeight: FontWeight.w900,
                    color: ShareTheme.navy,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 44,
                child: Transform.rotate(
                  angle: -0.5,
                  child: const Icon(
                    Icons.water_drop_rounded,
                    size: 22,
                    color: ShareTheme.yellow,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 44,
                child: Transform.rotate(
                  angle: 0.5,
                  child: const Icon(
                    Icons.water_drop_rounded,
                    size: 22,
                    color: ShareTheme.yellow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
