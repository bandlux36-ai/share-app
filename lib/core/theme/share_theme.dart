import 'package:flutter/material.dart';

abstract final class ShareTheme {
  static const navy = Color(0xFF001C30);
  static const heading = Color(0xFF10163F);
  static const muted = Color(0xFF7C88AF);
  static const secondary = Color(0xFF9A9EAE);
  static const yellow = Color(0xFFFFCD50);
  static const background = Color(0xFFFFFCF6);
  static const warmShadow = BoxShadow(
    color: Color(0x18E6BA78),
    blurRadius: 24,
    offset: Offset(0, 9),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'NotoSansArabic',
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: yellow,
      primary: navy,
      surface: background,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: muted, fontSize: 15),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: navy),
  );
}
