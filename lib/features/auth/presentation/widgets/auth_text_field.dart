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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10001C30),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
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
        style: const TextStyle(color: ShareTheme.navy, fontSize: 17),
        decoration: InputDecoration(
          hintText: label,
          hintTextDirection: TextDirection.rtl,
          hintStyle: const TextStyle(color: ShareTheme.muted, fontSize: 17),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 26,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
            child: Icon(icon, size: 27, color: ShareTheme.muted),
          ),
          suffixIcon: trailing == null
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: trailing,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: ShareTheme.yellow, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}
