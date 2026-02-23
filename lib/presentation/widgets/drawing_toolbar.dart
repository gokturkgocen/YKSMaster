import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_path.dart';
import '../providers/theme_provider.dart';

/// Liquid Glass toolbar with dark mode support
class DrawingToolbar extends ConsumerWidget {
  final DrawingTool selectedTool;
  final VoidCallback onPenSelected;
  final VoidCallback onPointerSelected; // New callback
  final VoidCallback onEraserSelected;
  final VoidCallback onLassoSelected;
  final VoidCallback onQuestionGrid;
  final VoidCallback? onUndo;
  final bool canUndo;
  final GlobalKey? penButtonKey;

  const DrawingToolbar({
    super.key,
    required this.selectedTool,
    required this.onPenSelected,
    required this.onPointerSelected,
    required this.onEraserSelected,
    required this.onLassoSelected,
    required this.onQuestionGrid,
    this.onUndo,
    this.canUndo = false,
    this.penButtonKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      height: 56,
      decoration: BoxDecoration(
        color: theme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          // Pointer Tool
          _ToolButton(
            icon: Icons.back_hand_outlined, // Or Icons.touch_app_outlined
            isSelected: selectedTool == DrawingTool.pointer,
            onTap: onPointerSelected,
            tooltip: 'Dokunma Modu',
            theme: theme,
          ),

          const SizedBox(width: 8),

          // Pen Tool
          _ToolButton(
            key: penButtonKey,
            icon: Icons.edit_outlined,
            isSelected: selectedTool == DrawingTool.pen,
            onTap: onPenSelected,
            tooltip: 'Kalem',
            theme: theme,
          ),

          const SizedBox(width: 8),

          // Eraser Tool
          _ToolButton(
            icon: Icons.auto_fix_high_outlined,
            isSelected: selectedTool == DrawingTool.eraser,
            onTap: onEraserSelected,
            tooltip: 'Silgi',
            theme: theme,
          ),

          const SizedBox(width: 8),

          // Lasso Tool
          _ToolButton(
            icon: Icons.gesture_outlined,
            isSelected: selectedTool == DrawingTool.lasso,
            onTap: onLassoSelected,
            tooltip: 'Seçim Aracı',
            theme: theme,
          ),

          const SizedBox(width: 16),

          // Undo Button
          _ToolButton(
            icon: Icons.undo_outlined,
            isSelected: false,
            onTap: canUndo ? onUndo : null,
            tooltip: 'Geri Al',
            isDisabled: !canUndo,
            theme: theme,
          ),

          const Spacer(),

          // Dark Mode Toggle
          _ThemeToggleButton(
            isDark: theme.isDark,
            onTap: themeNotifier.toggleTheme,
          ),

          const SizedBox(width: 8),

          // Question Navigator Grid Button
          _ToolButton(
            icon: Icons.apps_rounded,
            isSelected: false,
            onTap: onQuestionGrid,
            tooltip: 'Soru Haritası',
            theme: theme,
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

/// Individual tool button with theme support
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final String tooltip;
  final bool isDestructive;
  final bool isDisabled;
  final AppTheme theme;

  const _ToolButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
    this.isDestructive = false,
    this.isDisabled = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    if (isDisabled) {
      iconColor = theme.isDark ? const Color(0xFF4B5563) : Colors.grey.shade300;
    } else if (isDestructive) {
      iconColor = Colors.red.shade400;
    } else if (isSelected) {
      iconColor = AppTheme.accentColor;
    } else {
      iconColor = theme.textSecondary;
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentColor.withValues(
                      alpha: theme.isDark ? 0.2 : 0.1,
                    )
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// Theme toggle switch - modern pill-shaped design matching dashboard
class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeToggleButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isDark ? 'Açık Mod' : 'Karanlık Mod',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTheme.transitionDuration,
          curve: AppTheme.transitionCurve,
          width: 56,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? const Color(0xFF3D3A36) : const Color(0xFFE5E7EB),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AppTheme.transitionDuration,
                curve: AppTheme.transitionCurve,
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 16,
                    color: Colors.black,
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
