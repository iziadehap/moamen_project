import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/utils/availability_utils.dart';

class AvailabilityState {
  final AvailabilityConfig config;
  final String? error;
  final bool isSaving;

  AvailabilityState({required this.config, this.error, this.isSaving = false});

  AvailabilityState copyWith({
    AvailabilityConfig? config,
    String? error,
    bool? isSaving,
    bool clearError = false,
  }) {
    return AvailabilityState(
      config: config ?? this.config,
      error: clearError ? null : (error ?? this.error),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AvailabilityNotifier extends Notifier<AvailabilityState> {
  @override
  AvailabilityState build() {
    return AvailabilityState(
      config: const AvailabilityConfig(weeklyRules: [], overrides: []),
    );
  }

  void init(AvailabilityConfig initialConfig) {
    state = state.copyWith(config: initialConfig);
  }

  // --- Weekly Rules ---

  void addWeeklyRule() {
    final newRule = WeeklyAvailabilityRule(
      days: {},
      ranges: [const TimeRange(540, 1020)], // 9:00 AM - 5:00 PM
    );
    state = state.copyWith(
      config: state.config.copyWith(
        weeklyRules: [...state.config.weeklyRules, newRule],
      ),
    );
  }

  void removeWeeklyRule(int index) {
    final rules = List<WeeklyAvailabilityRule>.from(state.config.weeklyRules);
    rules.removeAt(index);
    state = state.copyWith(config: state.config.copyWith(weeklyRules: rules));
  }

  void updateRuleDays(int index, Set<Weekday> days) {
    final rules = List<WeeklyAvailabilityRule>.from(state.config.weeklyRules);
    rules[index] = rules[index].copyWith(days: days);
    state = state.copyWith(config: state.config.copyWith(weeklyRules: rules));
  }

  void addTimeRangeToRule(int ruleIndex) {
    final rules = List<WeeklyAvailabilityRule>.from(state.config.weeklyRules);
    final lastRange = rules[ruleIndex].ranges.lastOrNull;

    // Default to a 1 hour gap after last range, or afternoon if empty
    int start = (lastRange?.endMin ?? 720) + 60;
    if (start > 1380) start = 1320; // Cap at 10 PM
    int end = start + 120; // 2 hours duration
    if (end > 1440) end = 1440;

    rules[ruleIndex] = rules[ruleIndex].copyWith(
      ranges: [...rules[ruleIndex].ranges, TimeRange(start, end)],
    );
    state = state.copyWith(config: state.config.copyWith(weeklyRules: rules));
  }

  void updateTimeRangeInRule(
    int ruleIndex,
    int rangeIndex,
    TimeRange newRange,
  ) {
    final rules = List<WeeklyAvailabilityRule>.from(state.config.weeklyRules);
    final ranges = List<TimeRange>.from(rules[ruleIndex].ranges);
    ranges[rangeIndex] = newRange;
    rules[ruleIndex] = rules[ruleIndex].copyWith(ranges: ranges);
    state = state.copyWith(config: state.config.copyWith(weeklyRules: rules));
  }

  void removeTimeRangeFromRule(int ruleIndex, int rangeIndex) {
    final rules = List<WeeklyAvailabilityRule>.from(state.config.weeklyRules);
    final ranges = List<TimeRange>.from(rules[ruleIndex].ranges);
    ranges.removeAt(rangeIndex);
    rules[ruleIndex] = rules[ruleIndex].copyWith(ranges: ranges);
    state = state.copyWith(config: state.config.copyWith(weeklyRules: rules));
  }

  // --- Date Overrides ---

  void addOverride(DateTime date) {
    final d = dateOnly(date);
    // Check if already exists
    if (state.config.overrides.any((o) => dateOnly(o.date) == d)) {
      state = state.copyWith(error: 'هذا التاريخ موجود بالفعل في الاستثناءات');
      return;
    }

    final newOverride = DateOverride(
      date: d,
      ranges: [const TimeRange(540, 1020)],
    );
    state = state.copyWith(
      config: state.config.copyWith(
        overrides: [...state.config.overrides, newOverride],
      ),
    );
  }

  void removeOverride(int index) {
    final overrides = List<DateOverride>.from(state.config.overrides);
    overrides.removeAt(index);
    state = state.copyWith(config: state.config.copyWith(overrides: overrides));
  }

  void toggleDayClosed(int index) {
    final overrides = List<DateOverride>.from(state.config.overrides);
    final current = overrides[index];

    if (current.ranges.isEmpty) {
      // Re-open with default
      overrides[index] = current.copyWith(ranges: [const TimeRange(540, 1020)]);
    } else {
      // Close day (empty ranges)
      overrides[index] = current.copyWith(ranges: []);
    }
    state = state.copyWith(config: state.config.copyWith(overrides: overrides));
  }

  void updateTimeRangeInOverride(
    int overrideIndex,
    int rangeIndex,
    TimeRange newRange,
  ) {
    final overrides = List<DateOverride>.from(state.config.overrides);
    final ranges = List<TimeRange>.from(overrides[overrideIndex].ranges);
    ranges[rangeIndex] = newRange;
    overrides[overrideIndex] = overrides[overrideIndex].copyWith(
      ranges: ranges,
    );
    state = state.copyWith(config: state.config.copyWith(overrides: overrides));
  }

  void addTimeRangeToOverride(int overrideIndex) {
    final overrides = List<DateOverride>.from(state.config.overrides);
    final lastRange = overrides[overrideIndex].ranges.lastOrNull;

    int start = (lastRange?.endMin ?? 720) + 60;
    if (start > 1380) start = 1320;
    int end = start + 120;
    if (end > 1440) end = 1440;

    overrides[overrideIndex] = overrides[overrideIndex].copyWith(
      ranges: [...overrides[overrideIndex].ranges, TimeRange(start, end)],
    );
    state = state.copyWith(config: state.config.copyWith(overrides: overrides));
  }

  void removeTimeRangeFromOverride(int overrideIndex, int rangeIndex) {
    final overrides = List<DateOverride>.from(state.config.overrides);
    final ranges = List<TimeRange>.from(overrides[overrideIndex].ranges);
    ranges.removeAt(rangeIndex);
    overrides[overrideIndex] = overrides[overrideIndex].copyWith(
      ranges: ranges,
    );
    state = state.copyWith(config: state.config.copyWith(overrides: overrides));
  }

  // --- Actions ---

  AvailabilityConfig? validateAndSave() {
    try {
      final normalized = AvailabilityCore.normalizeConfig(state.config);
      state = state.copyWith(config: normalized, clearError: true);
      return normalized;
    } on AvailabilityException catch (e) {
      state = state.copyWith(error: e.arabicMessage);
      return null;
    } catch (e) {
      state = state.copyWith(error: 'حدث خطأ غير متوقع');
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final availabilityControllerProvider =
    NotifierProvider<AvailabilityNotifier, AvailabilityState>(
      AvailabilityNotifier.new,
    );
