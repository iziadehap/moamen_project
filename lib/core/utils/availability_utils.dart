import 'dart:math';
import 'package:moamen_project/features/orders/data/models/order_model.dart'
    as model;

/// Weekday aligned to Dart DateTime.weekday:
/// Mon=1..Sun=7
enum Weekday { mon, tue, wed, thu, fri, sat, sun }

Weekday weekdayFromModel(model.WeekDay day) {
  switch (day) {
    case model.WeekDay.monday:
      return Weekday.mon;
    case model.WeekDay.tuesday:
      return Weekday.tue;
    case model.WeekDay.wednesday:
      return Weekday.wed;
    case model.WeekDay.thursday:
      return Weekday.thu;
    case model.WeekDay.friday:
      return Weekday.fri;
    case model.WeekDay.saturday:
      return Weekday.sat;
    case model.WeekDay.sunday:
      return Weekday.sun;
  }
}

Weekday weekdayFromArabicName(String name) {
  final n = name.toLowerCase();
  switch (n) {
    case 'الاثنين':
    case 'monday':
    case 'mon':
      return Weekday.mon;
    case 'الثلاثاء':
    case 'tuesday':
    case 'tue':
      return Weekday.tue;
    case 'الأربعاء':
    case 'wednesday':
    case 'wed':
      return Weekday.wed;
    case 'الخميس':
    case 'thursday':
    case 'thu':
      return Weekday.thu;
    case 'الجمعة':
    case 'friday':
    case 'fri':
      return Weekday.fri;
    case 'السبت':
    case 'saturday':
    case 'sat':
      return Weekday.sat;
    case 'الأحد':
    case 'sunday':
    case 'sun':
      return Weekday.sun;
    default:
      return Weekday.mon;
  }
}

Weekday weekdayFromDateTime(DateTime dt) {
  switch (dt.weekday) {
    case DateTime.monday:
      return Weekday.mon;
    case DateTime.tuesday:
      return Weekday.tue;
    case DateTime.wednesday:
      return Weekday.wed;
    case DateTime.thursday:
      return Weekday.thu;
    case DateTime.friday:
      return Weekday.fri;
    case DateTime.saturday:
      return Weekday.sat;
    case DateTime.sunday:
      return Weekday.sun;
    default:
      return Weekday.mon;
  }
}

DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

class TimeRange {
  /// inclusive
  final int startMin;

  /// exclusive
  final int endMin;

  const TimeRange(this.startMin, this.endMin);

  int get duration => endMin - startMin;

  Map<String, dynamic> toJson() => {'startMin': startMin, 'endMin': endMin};

  static TimeRange fromJson(Map<String, dynamic> json) {
    return TimeRange(json['startMin'] as int, json['endMin'] as int);
  }

  @override
  String toString() => 'TimeRange($startMin -> $endMin)';
}

class WeeklyAvailabilityRule {
  final Set<Weekday> days;
  final List<TimeRange> ranges;

  const WeeklyAvailabilityRule({required this.days, required this.ranges});

  Map<String, dynamic> toJson() => {
    'days': days.map((d) => d.name).toList(),
    'ranges': ranges.map((r) => r.toJson()).toList(),
  };

  static WeeklyAvailabilityRule fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List)
        .map((s) => Weekday.values.firstWhere((d) => d.name == s))
        .toSet();
    final ranges = (json['ranges'] as List)
        .map((e) => TimeRange.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return WeeklyAvailabilityRule(days: days, ranges: ranges);
  }

  WeeklyAvailabilityRule copyWith({
    Set<Weekday>? days,
    List<TimeRange>? ranges,
  }) {
    return WeeklyAvailabilityRule(
      days: days ?? this.days,
      ranges: ranges ?? this.ranges,
    );
  }
}

class DateOverride {
  /// Date only (00:00). Use dateOnly() on input.
  final DateTime date;
  final List<TimeRange> ranges; // empty => closed

  const DateOverride({required this.date, required this.ranges});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'ranges': ranges.map((r) => r.toJson()).toList(),
  };

  static DateOverride fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    final ranges = (json['ranges'] as List)
        .map((e) => TimeRange.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return DateOverride(date: dateOnly(date), ranges: ranges);
  }

  DateOverride copyWith({DateTime? date, List<TimeRange>? ranges}) {
    return DateOverride(date: date ?? this.date, ranges: ranges ?? this.ranges);
  }
}

class AvailabilityConfig {
  final List<WeeklyAvailabilityRule> weeklyRules;
  final List<DateOverride> overrides;

  const AvailabilityConfig({
    required this.weeklyRules,
    required this.overrides,
  });

  Map<String, dynamic> toJson() => {
    'weeklyRules': weeklyRules.map((r) => r.toJson()).toList(),
    'overrides': overrides.map((o) => o.toJson()).toList(),
  };

  static AvailabilityConfig fromJson(Map<String, dynamic> json) {
    final weeklyRules = (json['weeklyRules'] as List)
        .map(
          (e) => WeeklyAvailabilityRule.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
    final overrides = (json['overrides'] as List)
        .map((e) => DateOverride.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return AvailabilityConfig(weeklyRules: weeklyRules, overrides: overrides);
  }

  AvailabilityConfig copyWith({
    List<WeeklyAvailabilityRule>? weeklyRules,
    List<DateOverride>? overrides,
  }) {
    return AvailabilityConfig(
      weeklyRules: weeklyRules ?? this.weeklyRules,
      overrides: overrides ?? this.overrides,
    );
  }

  /// Create config from the Order model's [availability] field.
  static AvailabilityConfig fromModelAvailability(
    List<Map<String, dynamic>> availability,
  ) {
    final weeklyRules = <WeeklyAvailabilityRule>[];

    for (var entry in availability) {
      final dayName = entry['day']?.toString() ?? '';
      final weekday = weekdayFromArabicName(dayName.toLowerCase());

      final timeRange = entry['timeRange'];
      if (timeRange == null) {
        print(
          'AvailabilityConfig.fromModelAvailability: Missing timeRange for $dayName',
        );
        continue;
      }

      final fromH = timeRange['fromHour'];
      final fromM = timeRange['fromMinute'];
      final toH = timeRange['toHour'];
      final toM = timeRange['toMinute'];

      if (fromH == null || fromM == null || toH == null || toM == null) {
        print(
          'AvailabilityConfig.fromModelAvailability: Missing hour/minute data for $dayName',
        );
        continue;
      }

      final startMin = (fromH as int) * 60 + (fromM as int);
      final endMin = (toH as int) * 60 + (toM as int);

      if (endMin > startMin) {
        weeklyRules.add(
          WeeklyAvailabilityRule(
            days: {weekday},
            ranges: [TimeRange(startMin, endMin)],
          ),
        );
      } else {
        print(
          'AvailabilityConfig.fromModelAvailability: Invalid range ($startMin to $endMin) for $dayName',
        );
      }
    }

    return AvailabilityCore.normalizeConfig(
      AvailabilityConfig(weeklyRules: weeklyRules, overrides: []),
    );
  }
}

/// =========================
/// Validation + Normalize
/// =========================
class AvailabilityException implements Exception {
  final String code;
  final String arabicMessage;
  // final String message;
  AvailabilityException(this.code, this.arabicMessage);
  @override
  String toString() => 'AvailabilityException: $arabicMessage';
}

class AvailabilityCore {
  /// Normalize ranges:
  /// - validate bounds (0..1440)
  /// - validate end > start
  /// - sort by start
  /// - merge overlaps / touching
  static List<TimeRange> normalizeRanges(List<TimeRange> ranges) {
    if (ranges.isEmpty) return const [];

    final sorted = [...ranges]
      ..sort((a, b) => a.startMin.compareTo(b.startMin));
    final out = <TimeRange>[];

    for (final r in sorted) {
      _validateRange(r);

      if (out.isEmpty) {
        out.add(r);
        continue;
      }

      final last = out.last;
      if (r.startMin <= last.endMin) {
        // overlap or touch => merge
        out[out.length - 1] = TimeRange(
          min(last.startMin, r.startMin),
          max(last.endMin, r.endMin),
        );
      } else {
        out.add(r);
      }
    }

    return out;
  }

  static void _validateRange(TimeRange r) {
    if (r.startMin < 0 || r.startMin > 1440) {
      throw AvailabilityException(
        'بدايه النطاق خارج الحدود: ${r.startMin}',
        'START_MIN_OUT_OF_BOUNDS : ${r.startMin}',
      );
    }
    if (r.endMin < 0 || r.endMin > 1440) {
      throw AvailabilityException(
        // arabic error message
        'نهايه النطاق خارج الحدود: ${r.endMin}',
        'endMin out of bounds: ${r.endMin}',
      );
    }
    if (r.endMin <= r.startMin) {
      throw AvailabilityException(
        'خطا في النطاق: نهاية النطاق يجب أن تكون أكبر من بدايه النطاق',
        'Invalid range: endMin must be > startMin',
      );
    }
    // Disallow cross-midnight by definition (endMin>startMin on same day only)
  }

  /// Get normalized ranges for a specific date.
  /// - If override exists for date -> return override ranges only
  /// - else -> combine all weekly rules that include that weekday
  static List<TimeRange> dailyRanges(AvailabilityConfig cfg, DateTime dt) {
    final d = dateOnly(dt);

    final ov = cfg.overrides.where((o) => dateOnly(o.date) == d).toList();
    if (ov.isNotEmpty) {
      // override wins
      return normalizeRanges(ov.first.ranges);
    }

    final wd = weekdayFromDateTime(dt);
    final collected = <TimeRange>[];
    for (final rule in cfg.weeklyRules) {
      if (rule.days.contains(wd)) {
        collected.addAll(rule.ranges);
      }
    }
    return normalizeRanges(collected);
  }

  /// Is available at that exact moment.
  static bool isAvailableAt(AvailabilityConfig cfg, DateTime dt) {
    final minOfDay = dt.hour * 60 + dt.minute;
    final ranges = dailyRanges(cfg, dt);
    return ranges.any((r) => minOfDay >= r.startMin && minOfDay < r.endMin);
  }

  /// Returns the start DateTime of the next available slot, starting from [from].
  /// - checks same day then next days up to [maxDaysLookahead]
  /// - if already inside available range -> returns [from] (rounded to minute)
  static DateTime? nextAvailableStart(
    AvailabilityConfig cfg,
    DateTime from, {
    int maxDaysLookahead = 14,
  }) {
    final base = from;
    for (int dayOffset = 0; dayOffset <= maxDaysLookahead; dayOffset++) {
      final day = dateOnly(base).add(Duration(days: dayOffset));
      final ranges = dailyRanges(cfg, day);

      if (ranges.isEmpty) continue;

      if (dayOffset == 0) {
        final curMin = base.hour * 60 + base.minute;

        // already available
        for (final r in ranges) {
          if (curMin >= r.startMin && curMin < r.endMin) {
            return DateTime(
              base.year,
              base.month,
              base.day,
              base.hour,
              base.minute,
            );
          }
        }

        // find first start after now
        for (final r in ranges) {
          if (r.startMin >= curMin) {
            return DateTime(
              day.year,
              day.month,
              day.day,
            ).add(Duration(minutes: r.startMin));
          }
        }
      } else {
        // next day -> first range start
        final r0 = ranges.first;
        return DateTime(
          day.year,
          day.month,
          day.day,
        ).add(Duration(minutes: r0.startMin));
      }
    }
    return null;
  }

  /// Build a clean config:
  /// - normalize each weekly rule ranges
  /// - merge weekly rules that target same day-set (optional simple behavior)
  /// - normalize overrides too
  static AvailabilityConfig normalizeConfig(AvailabilityConfig cfg) {
    final weekly = <WeeklyAvailabilityRule>[];
    for (final r in cfg.weeklyRules) {
      if (r.days.isEmpty) continue;
      final nr = normalizeRanges(r.ranges);
      weekly.add(WeeklyAvailabilityRule(days: r.days, ranges: nr));
    }

    final overrides = <DateOverride>[];
    for (final o in cfg.overrides) {
      final d = dateOnly(o.date);
      final nr = normalizeRanges(o.ranges);
      overrides.add(DateOverride(date: d, ranges: nr));
    }

    return AvailabilityConfig(weeklyRules: weekly, overrides: overrides);
  }
}

/// =========================
/// 12-hour helpers (Arabic)
/// =========================

/// Convert 12h time to minute-of-day.
/// hour: 1..12
/// minute: 0..59
/// isPM: true for PM (مساءً/م), false for AM (صباحًا/ص)
int toMinuteOfDay12h({
  required int hour,
  required int minute,
  required bool isPM,
}) {
  if (hour < 1 || hour > 12) {
    throw AvailabilityException('hour must be 1..12', 'hour must be 1..12');
  }
  if (minute < 0 || minute > 59) {
    throw AvailabilityException('minute must be 0..59', 'minute must be 0..59');
  }

  int h = hour % 12; // 12 -> 0
  if (isPM) h += 12;
  return h * 60 + minute;
}

/// Parse strings like:
/// "10:30 PM", "10:30 pm", "10:30 ص", "10:30 م", "10:30 صباحا", "10:30 مساء"
int parse12hToMinuteOfDay(String input) {
  final s = input.trim().toLowerCase();

  // detect AM/PM arabic/english
  final isPM =
      s.contains('pm') ||
      s.contains('مساء') ||
      s.contains('م') && !s.contains('ص'); // crude but works for "10:00 م"

  final isAM = s.contains('am') || s.contains('صباح') || s.contains('ص');

  if (!isPM && !isAM) {
    throw AvailabilityException(
      // arabic error message
      'علامة AM/PM مفقودة في: $input',
      'Missing AM/PM marker in: $input',
    );
  }

  // extract hh:mm
  final timePart = s
      .replaceAll('am', '')
      .replaceAll('pm', '')
      .replaceAll('صباح', '')
      .replaceAll('مساء', '')
      .replaceAll('ص', '')
      .replaceAll('م', '')
      .replaceAll('اً', '')
      .trim();

  final parts = timePart.split(':');
  if (parts.length != 2) {
    print(
      'AvailabilityCore.parse12hToMinuteOfDay: Failed to parse time string "$input"',
    );
    throw AvailabilityException(
      'خطأ في تنسيق الوقت: $input',
      'Invalid time format: $input',
    );
  }

  final hour = int.tryParse(parts[0].trim());
  final minute = int.tryParse(parts[1].trim());
  if (hour == null || minute == null) {
    throw AvailabilityException(
      'خطأ في الرقم: $input',
      'Invalid numbers in time: $input',
    );
  }

  return toMinuteOfDay12h(hour: hour, minute: minute, isPM: isPM);
}

/// Format minute-of-day to Arabic 12h like "1:05 م" / "11:30 ص"
String formatMinuteOfDay12hAr(int minuteOfDay) {
  if (minuteOfDay < 0 || minuteOfDay > 1439) {
    throw AvailabilityException(
      'الوقت خارج الحدود: $minuteOfDay',
      'minuteOfDay out of bounds: $minuteOfDay',
    );
  }
  final h24 = minuteOfDay ~/ 60;
  final m = minuteOfDay % 60;
  final isPM = h24 >= 12;

  int h12 = h24 % 12;
  if (h12 == 0) h12 = 12;

  final mm = m.toString().padLeft(2, '0');
  return '$h12:$mm ${isPM ? "م" : "ص"}';
}
