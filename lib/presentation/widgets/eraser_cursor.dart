import 'package:flutter/material.dart';

/// Eraser cursor that shows a hollow glass-style circle indicating erase area
class EraserCursor extends StatelessWidget {
  final Offset position;
  final double size;
  final bool isVisible;

  const EraserCursor({
    super.key,
    required this.position,
    required this.size,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF007AFF).withValues(alpha: 0.1),
            border: Border.all(
              color: const Color(0xFF007AFF).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
