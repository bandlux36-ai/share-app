import 'package:flutter/material.dart';

import '../../../../core/theme/share_theme.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.autofillHint,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String autofillHint;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(boxShadow: [ShareTheme.warmShadow]),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: [autofillHint],
        autocorrect: false,
        enableSuggestions: false,
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(color: ShareTheme.navy, fontSize: 16),
        decoration: InputDecoration(
          hintText: label,
          hintTextDirection: TextDirection.rtl,
          hintStyle: const TextStyle(color: ShareTheme.muted, fontSize: 16),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 23),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: Icon(icon, size: 25, color: ShareTheme.muted),
          ),
          suffixIcon: trailing,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: ShareTheme.yellow, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}
