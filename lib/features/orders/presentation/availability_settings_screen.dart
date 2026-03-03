import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/availability_utils.dart';
import 'package:moamen_project/features/orders/presentation/controller/availability_controller.dart';

class AvailabilitySettingsScreen extends ConsumerStatefulWidget {
  final AvailabilityConfig initialConfig;

  const AvailabilitySettingsScreen({super.key, required this.initialConfig});

  @override
  ConsumerState<AvailabilitySettingsScreen> createState() =>
      _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState
    extends ConsumerState<AvailabilitySettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(availabilityControllerProvider.notifier)
          .init(widget.initialConfig);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final state = ref.watch(availabilityControllerProvider);
    final notifier = ref.read(availabilityControllerProvider.notifier);

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(customTheme),
              if (state.error != null)
                _buildErrorBanner(state.error!, customTheme),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelStyle: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: GoogleFonts.cairo(),
                        labelColor: customTheme.primaryBlue,
                        unselectedLabelColor: customTheme.textSecondary,
                        indicatorColor: customTheme.primaryBlue,
                        tabs: const [
                          Tab(text: 'المواعيد الأسبوعية'),
                          Tab(text: 'استثناءات التواريخ'),
                        ],
                      ),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: TabBarView(
                            children: [_WeeklyRulesTab(), _OverridesTab()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(customTheme, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CustomThemeExtension customTheme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: customTheme.textPrimary,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: customTheme.textPrimary.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'إعدادات التوافر',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error, CustomThemeExtension customTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: customTheme.errorColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: customTheme.errorColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.cairo(
                color: customTheme.errorColor,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: customTheme.errorColor),
            onPressed: () =>
                ref.read(availabilityControllerProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    CustomThemeExtension customTheme,
    AvailabilityNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            gradient: customTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: customTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              final result = notifier.validateAndSave();
              if (result != null) {
                Navigator.pop(context, result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'حفظ الإعدادات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyRulesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availabilityControllerProvider);
    final notifier = ref.read(availabilityControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...state.config.weeklyRules.asMap().entries.map((entry) {
          return _RuleCard(index: entry.key, rule: entry.value);
        }),
        const SizedBox(height: 16),
        _AddButton(label: 'إضافة قاعدة جديدة', onTap: notifier.addWeeklyRule),
      ],
    );
  }
}

class _RuleCard extends ConsumerWidget {
  final int index;
  final WeeklyAvailabilityRule rule;

  const _RuleCard({required this.index, required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final notifier = ref.read(availabilityControllerProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قاعدة #${index + 1}',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: customTheme.primaryBlue,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: customTheme.errorColor,
                  size: 20,
                ),
                onPressed: () => notifier.removeWeeklyRule(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'أيام العمل:',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _DayPicker(
            selectedDays: rule.days,
            onChanged: (days) => notifier.updateRuleDays(index, days),
          ),
          const SizedBox(height: 20),
          Text(
            'فترات التوافر:',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ...rule.ranges.asMap().entries.map((rangeEntry) {
            return _RangeRow(
              range: rangeEntry.value,
              onChanged: (r) =>
                  notifier.updateTimeRangeInRule(index, rangeEntry.key, r),
              onDelete: () =>
                  notifier.removeTimeRangeFromRule(index, rangeEntry.key),
            );
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => notifier.addTimeRangeToRule(index),
            icon: const Icon(Icons.add, size: 18),
            label: Text('إضافة فترة', style: GoogleFonts.cairo()),
            style: TextButton.styleFrom(
              foregroundColor: customTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  final Set<Weekday> selectedDays;
  final ValueChanged<Set<Weekday>> onChanged;

  const _DayPicker({required this.selectedDays, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final days = [
      (Weekday.sat, 'سبت'),
      (Weekday.sun, 'أحد'),
      (Weekday.mon, 'اثنين'),
      (Weekday.tue, 'ثلاثاء'),
      (Weekday.wed, 'أربعاء'),
      (Weekday.thu, 'خميس'),
      (Weekday.fri, 'جمعة'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final isSelected = selectedDays.contains(day.$1);
        return FilterChip(
          label: Text(day.$2, style: GoogleFonts.cairo(fontSize: 12)),
          selected: isSelected,
          onSelected: (v) {
            final newDays = Set<Weekday>.from(selectedDays);
            if (v)
              newDays.add(day.$1);
            else
              newDays.remove(day.$1);
            onChanged(newDays);
          },
          selectedColor: customTheme.primaryBlue.withOpacity(0.2),
          checkmarkColor: customTheme.primaryBlue,
          labelStyle: TextStyle(
            color: isSelected
                ? customTheme.primaryBlue
                : customTheme.textSecondary,
          ),
        );
      }).toList(),
    );
  }
}

class _RangeRow extends StatelessWidget {
  final TimeRange range;
  final ValueChanged<TimeRange> onChanged;
  final VoidCallback onDelete;

  const _RangeRow({
    required this.range,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _TimeChip(
            label: 'من',
            time: TimeOfDay(
              hour: range.startMin ~/ 60,
              minute: range.startMin % 60,
            ),
            onChanged: (t) =>
                onChanged(TimeRange(t.hour * 60 + t.minute, range.endMin)),
          ),
          const SizedBox(width: 8),
          Text(':', style: TextStyle(color: customTheme.textSecondary)),
          const SizedBox(width: 8),
          _TimeChip(
            label: 'إلى',
            time: TimeOfDay(
              hour: range.endMin ~/ 60,
              minute: range.endMin % 60,
            ),
            onChanged: (t) =>
                onChanged(TimeRange(range.startMin, t.hour * 60 + t.minute)),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: customTheme.errorColor.withOpacity(0.5),
              size: 18,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimeChip({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (newTime != null) onChanged(newTime);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: customTheme.textPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              '$label ',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 10,
              ),
            ),
            Text(
              formatMinuteOfDay12hAr(time.hour * 60 + time.minute),
              style: GoogleFonts.cairo(
                color: customTheme.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverridesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availabilityControllerProvider);
    final notifier = ref.read(availabilityControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _AddButton(
          label: 'إضافة استثناء لتاريخ معين',
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (date != null) notifier.addOverride(date);
          },
        ),
        const SizedBox(height: 24),
        ...state.config.overrides.asMap().entries.map((entry) {
          return _OverrideCard(index: entry.key, dateOverride: entry.value);
        }),
      ],
    );
  }
}

class _OverrideCard extends ConsumerWidget {
  final int index;
  final DateOverride dateOverride;

  const _OverrideCard({required this.index, required this.dateOverride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final notifier = ref.read(availabilityControllerProvider.notifier);
    final isClosed = dateOverride.ranges.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isClosed
              ? customTheme.errorColor.withOpacity(0.2)
              : customTheme.textPrimary.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: isClosed
                    ? customTheme.errorColor
                    : customTheme.primaryBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${dateOverride.date.day}/${dateOverride.date.month}/${dateOverride.date.year}',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    'مغلق',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: customTheme.textSecondary,
                    ),
                  ),
                  Switch(
                    value: isClosed,
                    onChanged: (v) => notifier.toggleDayClosed(index),
                    activeColor: customTheme.errorColor,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: customTheme.errorColor.withOpacity(0.7),
                  size: 18,
                ),
                onPressed: () => notifier.removeOverride(index),
              ),
            ],
          ),
          if (!isClosed) ...[
            const SizedBox(height: 16),
            ...dateOverride.ranges.asMap().entries.map((rangeEntry) {
              return _RangeRow(
                range: rangeEntry.value,
                onChanged: (r) => notifier.updateTimeRangeInOverride(
                  index,
                  rangeEntry.key,
                  r,
                ),
                onDelete: () =>
                    notifier.removeTimeRangeFromOverride(index, rangeEntry.key),
              );
            }),
            TextButton.icon(
              onPressed: () => notifier.addTimeRangeToOverride(index),
              icon: const Icon(Icons.add, size: 18),
              label: Text('إضافة فترة', style: GoogleFonts.cairo()),
              style: TextButton.styleFrom(
                foregroundColor: customTheme.primaryBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: customTheme.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: customTheme.primaryBlue.withOpacity(0.2),
            style: BorderStyle.solid,
          ), // Fixed: dashed border not easy in vanilla
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: customTheme.primaryBlue),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: customTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
