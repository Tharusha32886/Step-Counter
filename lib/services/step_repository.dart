import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../data/hive_boxes.dart';
import '../data/models/settings.dart';
import '../data/models/step_day.dart';

/// Handles step math (baseline/offset), persistence, and derived metrics.
class StepRepository extends ChangeNotifier {
  // Today
  int _todaySteps = 0;
  double _todayDistanceKm = 0;
  double _todayCalories = 0;
  int _goal = 8000;

  // Weekly cache (Sun..Sat or local week start)
  List<StepDay> _last7 = [];

  // Runtime counters
  int? _lastCumulative; // last raw sensor value
  int _baseline = 0;    // baseline for the day
  int _offset = 0;      // accumulated steps from before any sensor reset today

  Timer? _midnightTimer;

  // Getters for UI
  int get todaySteps => _todaySteps;
  double get todayDistanceKm => _todayDistanceKm;
  double get todayCalories => _todayCalories;
  int get goal => _goal;
  double get progress => _goal == 0 ? 0 : (_todaySteps / _goal).clamp(0, 1);
  List<StepDay> get last7 => _last7;

  Future<void> init() async {
    // Load settings
    final settings = settingsBox.get('settings');
    _goal = settings?.dailyGoal ?? 8000;

    // Load today record if exists
    final todayKey = _keyFor(DateTime.now());
    final today = daysBox.get(todayKey);
    if (today != null) {
      _todaySteps = today.steps;
      _todayDistanceKm = today.distanceKm;
      _todayCalories = today.calories;
    }

    // Load runtime state
    _baseline = (runtimeBox.get('baseline') as int?) ?? 0;
    _offset = (runtimeBox.get('offset') as int?) ?? 0;
    _lastCumulative = runtimeBox.get('lastCumulative') as int?;
    final lastDateString = runtimeBox.get('lastDate') as String?;
    final lastDate = lastDateString == null ? null : DateFormat('yyyy-MM-dd').parse(lastDateString);

    // If date changed while app was killed, reset daily state
    final now = DateTime.now();
    if (lastDate == null || !_isSameDay(lastDate, now)) {
      _newDayReset();
    }

    await _refreshLast7();

    // Schedule midnight rollover
    _scheduleMidnight();
    notifyListeners();
  }

  /// Called by pedometer service whenever a new cumulative step value arrives.
  Future<void> onCumulativeSteps(int cumulative) async {
    final now = DateTime.now();

    // Date change protection (if stream keeps running past midnight)
    if (!_isSameDay(now, _currentStoredDate())) {
      _newDayReset();
    }

    if (_lastCumulative == null) {
      _lastCumulative = cumulative;
      if (_baseline == 0) {
        _baseline = cumulative;
        await runtimeBox.put('baseline', _baseline);
      }
    } else if (cumulative < _lastCumulative!) {
      // Device reboot or sensor reset -> keep today's count by moving it to offset
      _offset = _todaySteps;
      _baseline = cumulative;
      await runtimeBox.put('offset', _offset);
      await runtimeBox.put('baseline', _baseline);
    }

    _lastCumulative = cumulative;
    await runtimeBox.put('lastCumulative', _lastCumulative);
    await runtimeBox.put('lastDate', _keyFor(DateTime.now()));

    final stepsToday = _offset + (cumulative - _baseline);
    _setToday(stepsToday);
    await _persistToday();
    notifyListeners();
  }

  void _setToday(int steps) {
    _todaySteps = steps < 0 ? 0 : steps;
    final strideMeters = _estimateStrideMeters();
    _todayDistanceKm = (_todaySteps * strideMeters) / 1000.0;
    _todayCalories = _todaySteps * 0.04; // ~0.04 kcal/step
  }

  double _estimateStrideMeters() {
    final s = settingsBox.get('settings');
    if (s?.heightCm != null && s!.heightCm! > 0) {
      // Generic estimate: ~0.415 * height
      return (s.heightCm! * 0.415) / 100.0;
    }
    return 0.78; // average adult stride
  }

  Future<void> _persistToday() async {
    final key = _keyFor(DateTime.now());
    final record = daysBox.get(key);
    final entry = StepDay(
      date: _normalize(DateTime.now()),
      steps: _todaySteps,
      distanceKm: double.parse(_todayDistanceKm.toStringAsFixed(3)),
      calories: double.parse(_todayCalories.toStringAsFixed(1)),
      goal: _goal,
    );
    if (record == null) {
      await daysBox.put(key, entry);
    } else {
      record
        ..steps = entry.steps
        ..distanceKm = entry.distanceKm
        ..calories = entry.calories
        ..goal = entry.goal;
      await record.save();
    }
    await _refreshLast7();
  }

  Future<void> _refreshLast7() async {
    final now = _normalize(DateTime.now());
    final days = <StepDay>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = _keyFor(d);
      final rec = daysBox.get(key) ??
          StepDay(date: d, steps: 0, distanceKm: 0, calories: 0, goal: _goal);
      days.add(rec);
    }
    _last7 = days;
  }

  Future<void> setGoal(int newGoal) async {
    _goal = newGoal;
    final s = settingsBox.get('settings');
    if (s == null) {
      await settingsBox.put('settings', Settings(dailyGoal: newGoal));
    } else {
      s.dailyGoal = newGoal;
      await s.save();
    }
    await _persistToday();
    notifyListeners();
  }

  Future<void> setProfile({double? heightCm, double? weightKg}) async {
    final s = settingsBox.get('settings');
    if (s == null) {
      await settingsBox.put('settings', Settings(dailyGoal: _goal, heightCm: heightCm, weightKg: weightKg));
    } else {
      s.heightCm = heightCm ?? s.heightCm;
      s.weightKg = weightKg ?? s.weightKg;
      await s.save();
    }
    // Recompute derived values
    _setToday(_todaySteps);
    await _persistToday();
    notifyListeners();
  }

  void _newDayReset() {
    _baseline = _lastCumulative ?? 0;
    _offset = 0;
    runtimeBox.put('baseline', _baseline);
    runtimeBox.put('offset', _offset);
    runtimeBox.put('lastDate', _keyFor(DateTime.now()));
    _setToday(0);
    _persistToday();
  }

  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now) + const Duration(seconds: 1);
    _midnightTimer = Timer(duration, () {
      _newDayReset();
      _scheduleMidnight();
      notifyListeners();
    });
  }

  DateTime _currentStoredDate() {
    final lastDateString = runtimeBox.get('lastDate') as String?;
    return lastDateString == null ? _normalize(DateTime.now()) : DateFormat('yyyy-MM-dd').parse(lastDateString);
    }

  String _keyFor(DateTime d) => DateFormat('yyyy-MM-dd').format(_normalize(d));
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }
}
