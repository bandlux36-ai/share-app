import 'package:flutter/material.dart';

import '../../../../core/theme/share_theme.dart';
import '../../../../core/widgets/share_logo.dart';

class RecoveryLayout extends StatelessWidget {
  const RecoveryLayout({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.onBack,
  });

  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'العودة لتسجيل الدخول',
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: ShareLogo()),
                  const SizedBox(height: 28),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ShareTheme.heading,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ShareTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 30),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecoveryButton extends StatelessWidget {
  const RecoveryButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: ShareTheme.yellow,
      foregroundColor: ShareTheme.navy,
      minimumSize: const Size.fromHeight(64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    child: busy
        ? SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: ShareTheme.navy,
              semanticsLabel: label,
            ),
          )
        : Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
  );
}
