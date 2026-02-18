import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

/// A premium, liquid glass dialog with backdrop blur and soft borders.
class GlassDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final AppTheme theme;
  final Color? accentColor;

  const GlassDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    required this.theme,
    this.accentColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    required AppTheme theme,
    Color? accentColor,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeOutCubic.transform(anim1.value);
        return Transform.scale(
          scale: 0.8 + (0.2 * curve),
          child: Opacity(
            opacity: anim1.value,
            child: GlassDialog(
              title: title,
              content: content,
              actions: actions,
              theme: theme,
              accentColor: accentColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? theme.accent;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        constraints: const BoxConstraints(maxWidth: 600),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: theme.glassBackground,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: theme.glassBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Accent Line
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            effectiveAccent.withValues(alpha: 0.8),
                            effectiveAccent.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        child: title,
                      ),
                    ),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                        child: content,
                      ),
                    ),

                    if (actions != null && actions!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
