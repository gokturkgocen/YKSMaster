import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

/// Countdown timer widget for YKS exam date
class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final AppTheme theme;

  const CountdownTimer({
    super.key,
    required this.targetDate,
    required this.theme,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    setState(() {
      _remaining = widget.targetDate.difference(DateTime.now());
      if (_remaining.isNegative) {
        _remaining = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;

    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: widget.theme.isDark ? const Color(0xFF2A2825) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeUnit(days.toString(), 'Gün'),
          _buildSeparator(),
          _buildTimeUnit(hours.toString(), 'Saat'),
          _buildSeparator(),
          _buildTimeUnit(minutes.toString(), 'Dakika'),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: widget.theme.text,
            height: 1.1,
          ),
          child: Text(value),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.theme.textSecondary,
          ),
          child: Text(label),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: widget.theme.textSecondary,
        ),
      ),
    );
  }
}
