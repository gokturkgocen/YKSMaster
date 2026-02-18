import 'dart:ui';
import 'package:flutter/material.dart';

/// iOS 26 Glass-style pen settings popup with frosted glass effect
class PenSettingsPopup extends StatefulWidget {
  final Color currentColor;
  final double currentWidth;
  final Function(Color) onColorChanged;
  final Function(double) onWidthChanged;
  final VoidCallback onClose;

  const PenSettingsPopup({
    super.key,
    required this.currentColor,
    required this.currentWidth,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onClose,
  });

  // Modern color palette
  static const List<Color> colorPalette = [
    Color(0xFF1A1A1A), // Black
    Color(0xFF64748B), // Slate
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFFBBF24), // Amber
    Color(0xFF22C55E), // Green
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Colors.white, // White
  ];

  static const List<double> widthOptions = [1.5, 2.5, 4.0, 6.0, 10.0];

  @override
  State<PenSettingsPopup> createState() => _PenSettingsPopupState();

  /// Show the popup centered on screen with glass effect
  static void show({
    required BuildContext context,
    required Color currentColor,
    required double currentWidth,
    required Function(Color) onColorChanged,
    required Function(double) onWidthChanged,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: PenSettingsPopup(
            currentColor: currentColor,
            currentWidth: currentWidth,
            onColorChanged: onColorChanged,
            onWidthChanged: onWidthChanged,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class _PenSettingsPopupState extends State<PenSettingsPopup> {
  late Color _selectedColor;
  late double _selectedWidth;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
    _selectedWidth = widget.currentWidth;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.70),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kalem',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.4,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Color section
              const Text(
                'RENK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // Color grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: PenSettingsPopup.colorPalette.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = color);
                      widget.onColorChanged(color);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(
                              alpha: isSelected ? 0.5 : 0.25,
                            ),
                            blurRadius: isSelected ? 12 : 6,
                            offset: const Offset(0, 3),
                          ),
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: _getContrastColor(color),
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Width section
              const Text(
                'KALINLIK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // Width options with preview line
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: PenSettingsPopup.widthOptions.map((width) {
                    final isSelected = (width - _selectedWidth).abs() < 0.1;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedWidth = width);
                        widget.onWidthChanged(width);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor.withValues(alpha: 0.5)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: width * 2.5,
                            height: width * 2.5,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Preview line
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(200, 30),
                    painter: _PreviewLinePainter(
                      color: _selectedColor,
                      strokeWidth: _selectedWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Preview line painter with smooth curve
class _PreviewLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _PreviewLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(20, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width - 20,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PreviewLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
