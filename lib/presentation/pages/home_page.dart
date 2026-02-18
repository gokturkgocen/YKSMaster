import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/drawing_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Drawing points for the canvas
  List<DrawingPoint> points = [];

  // Color scheme - soft cream/paper background with dark gray pen
  static const Color backgroundColor = Color(0xFFF5F1E8); // Cream/paper color
  static const Color penColor = Color(0xFF3A3A3A); // Dark gray
  static const Color panelColor = Colors.white;
  static const Color accentColor = Color(0xFF2E7D32); // Green for buttons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            // Left Panel - Question Area
            Expanded(flex: 1, child: _buildQuestionPanel()),

            // Right Panel - Drawing Area
            Expanded(flex: 1, child: _buildDrawingPanel()),
          ],
        ),
      ),
    );
  }

  /// Left panel with question placeholder
  Widget _buildQuestionPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG Placeholder Icon
          SvgPicture.asset(
            'assets/images/question_placeholder.svg',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 32),

          // Sample Question Text
          Text(
            'Soru Alanı',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: penColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bu alana sınav soruları ve ilgili görseller yüklenecektir.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: penColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Example question
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: penColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              'Örnek Soru:\n\nBir matematik probleminin çözüm adımları burada gösterilecektir. Öğrenci sağ taraftaki çizim alanını kullanarak kendi çözümünü yapabilecektir.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: penColor, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Right panel with drawing canvas
  Widget _buildDrawingPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Drawing Canvas
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                points.add(DrawingPoint(offset: details.localPosition));
              });
            },
            onPanUpdate: (details) {
              setState(() {
                points.add(DrawingPoint(offset: details.localPosition));
              });
            },
            onPanEnd: (details) {
              setState(() {
                points.add(DrawingPoint(offset: null));
              });
            },
            child: CustomPaint(
              painter: DrawingPainter(
                points: points,
                strokeColor: penColor,
                strokeWidth: 3.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // Clear Button
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _clearDrawing,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.clear, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Temizle',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Watermark text at bottom
          Positioned(
            bottom: 16,
            right: 16,
            child: Text(
              'Çizim Alanı',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: penColor.withValues(alpha: 0.3),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clear all drawing points
  void _clearDrawing() {
    setState(() {
      points.clear();
    });
  }
}
