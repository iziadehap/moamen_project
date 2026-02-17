import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 12),
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryBlue.withOpacity(0.5),
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        errorStyle: GoogleFonts.cairo(fontSize: 10),
      ),
    );
  }
}

class AvailabilityToggle extends StatelessWidget {
  final bool isAllWeek;
  final ValueChanged<bool> onChanged;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  final Function(TimeOfDay) onFromChanged;
  final Function(TimeOfDay) onToChanged;

  const AvailabilityToggle({
    super.key,
    required this.isAllWeek,
    required this.onChanged,
    required this.fromTime,
    required this.toTime,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primaryBlue.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text(
                'متاح طوال الأسبوع',
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Switch(
                value: isAllWeek,
                onChanged: onChanged,
                activeColor: AppColors.primaryBlue,
              ),
            ],
          ),
          if (isAllWeek) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white10),
            ),
            Row(
              children: [
                Text(
                  'التوقيت لكل الأيام:',
                  style: GoogleFonts.cairo(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                TimePickerField(
                  label: 'من',
                  time: fromTime,
                  onChanged: onFromChanged,
                ),
                const SizedBox(width: 8),
                Text(':', style: GoogleFonts.cairo(color: AppColors.textGrey)),
                const SizedBox(width: 8),
                TimePickerField(
                  label: 'إلى',
                  time: toTime,
                  onChanged: onToChanged,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const TimePickerField({
    super.key,
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryBlue,
                  onPrimary: Colors.white,
                  surface: AppColors.darkCard,
                  onSurface: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (newTime != null) onChanged(newTime);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ',
              style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 10),
            ),
            Text(
              time.format(context),
              style: GoogleFonts.cairo(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyScheduleItem extends StatelessWidget {
  final WeekDay day;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  final Function(TimeOfDay) onFromChanged;
  final Function(TimeOfDay) onToChanged;

  const DailyScheduleItem({
    super.key,
    required this.day,
    required this.fromTime,
    required this.toTime,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              _dayArabic(day),
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          TimePickerField(
            label: 'من',
            time: fromTime,
            onChanged: onFromChanged,
          ),
          const SizedBox(width: 8),
          Text(':', style: GoogleFonts.cairo(color: AppColors.textGrey)),
          const SizedBox(width: 8),
          TimePickerField(label: 'إلى', time: toTime, onChanged: onToChanged),
        ],
      ),
    );
  }

  String _dayArabic(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return 'الاثنين';
      case WeekDay.tuesday:
        return 'الثلاثاء';
      case WeekDay.wednesday:
        return 'الأربعاء';
      case WeekDay.thursday:
        return 'الخميس';
      case WeekDay.friday:
        return 'الجمعة';
      case WeekDay.saturday:
        return 'السبت';
      case WeekDay.sunday:
        return 'الأحد';
    }
  }
}

Widget uplodePhotoWidget() {
  return Consumer(
    builder: (context, ref, child) {
      final state = ref.watch(orderProvider);
      final controller = ref.read(orderProvider.notifier);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'الصور المرفقة'),
          const SizedBox(height: 16),
          if (state.photoUrls.isNotEmpty || state.localPhotos.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Remote Photos
                  ...state.photoUrls.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return _PhotoItem(
                      image: NetworkImage(url),
                      onRemove: () => controller.removePhoto(index),
                    );
                  }),
                  // Local Photos
                  ...state.localPhotos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return _PhotoItem(
                      image: FileImage(file),
                      onRemove: () => controller.removeLocalPhoto(index),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 12),
          InkWell(
            onTap: state.isLoading ? null : () => controller.pickLocalPhoto(),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إضافة صور',
                      style: GoogleFonts.cairo(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _PhotoItem extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;

  const _PhotoItem({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 12),
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
