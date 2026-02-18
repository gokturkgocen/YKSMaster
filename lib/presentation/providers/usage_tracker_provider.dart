import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// State holding daily usage data
class DailyUsageState {
  final int todaySeconds;
  final Map<String, int> history; // date (yyyyMMdd) -> seconds

  const DailyUsageState({this.todaySeconds = 0, this.history = const {}});

  DailyUsageState copyWith({int? todaySeconds, Map<String, int>? history}) {
    return DailyUsageState(
      todaySeconds: todaySeconds ?? this.todaySeconds,
      history: history ?? this.history,
    );
  }
}

class UsageTrackerNotifier extends StateNotifier<DailyUsageState>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _lastTickTime;
  static const String _prefix = 'usage_';

  UsageTrackerNotifier() : super(const DailyUsageState()) {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _init() async {
    await _loadHistory();
    _startTimer();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getKey(DateTime.now());
    final allKeys = prefs.getKeys().where((k) => k.startsWith(_prefix));

    Map<String, int> history = {};
    int today = 0;

    for (var key in allKeys) {
      final datePart = key.substring(_prefix.length);
      final seconds = prefs.getInt(key) ?? 0;
      history[datePart] = seconds;

      if (key == todayKey) {
        today = seconds;
      }
    }

    state = state.copyWith(todaySeconds: today, history: history);
  }

  void _startTimer() {
    _timer?.cancel();
    _lastTickTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _saveToday(); // Save on stop/pause
  }

  Future<void> _tick() async {
    final now = DateTime.now();
    final todayKey = _getKey(now);

    // Check if day changed while app was running
    if (_lastTickTime != null && _getKey(_lastTickTime!) != todayKey) {
      // Day changed! Reset todaySeconds logic handled by key change
      // But we need to update state to reflect 0 for new day
      state = state.copyWith(todaySeconds: 0);
      // Refresh history to include yesterday
      await _loadHistory();
    }
    _lastTickTime = now;

    // Increment
    state = state.copyWith(todaySeconds: state.todaySeconds + 1);

    // Persist every 10 seconds or so to avoid too much IO?
    // User asked for accuracy, let's persist every 30s or on pause.
    if (state.todaySeconds % 30 == 0) {
      _saveToday();
    }
  }

  Future<void> _saveToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = _getKey(now);
    await prefs.setInt(key, state.todaySeconds);

    // Also update history map in state for consistency
    final newHistory = Map<String, int>.from(state.history);
    newHistory[_getDateString(now)] = state.todaySeconds;
    state = state.copyWith(history: newHistory);
  }

  String _getKey(DateTime date) {
    return '$_prefix${_getDateString(date)}';
  }

  String _getDateString(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
    } else if (state == AppLifecycleState.paused) {
      _stopTimer();
    }
  }
}

final usageTrackerProvider =
    StateNotifierProvider<UsageTrackerNotifier, DailyUsageState>((ref) {
      return UsageTrackerNotifier();
    });
