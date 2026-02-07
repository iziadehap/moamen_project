import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/orders/presentation/location_picker_screen.dart';

class AddOrderScreen extends ConsumerStatefulWidget {
  final Order? order;
  const AddOrderScreen({super.key, this.order});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  OrderType _orderType = OrderType.pickup;
  OrderPriority _priority = OrderPriority.medium;
  bool _isAllWeek = true;
  TimeOfDay _allWeekFromTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _allWeekToTime = const TimeOfDay(hour: 23, minute: 59);

  final Map<WeekDay, (TimeOfDay, TimeOfDay)> _dailyTimes = {
    for (var day in WeekDay.values)
      day: (
        const TimeOfDay(hour: 0, minute: 0),
        const TimeOfDay(hour: 23, minute: 59),
      ),
  };

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      final order = widget.order!;
      _titleController.text = order.title;
      _descriptionController.text = order.description;
      _areaController.text = order.publicArea;
      _landmarkController.text = order.publicLandmark ?? '';
      _fullAddressController.text = order.fullAddress ?? '';
      _latController.text = order.latitude?.toString() ?? '';
      _lngController.text = order.longitude?.toString() ?? '';
      _contactNameController.text = order.contactName ?? '';
      _contactPhoneController.text = order.contactPhone ?? '';
      _orderType = order.orderType;
      _priority = order.priority;

      // Availability
      if (order.availability.isNotEmpty) {
        // Check if all days have the same time range to determine if it's "All Week"
        final firstAvail = order.availability.first;
        final firstRange = firstAvail['timeRange'] as Map<String, dynamic>;
        bool allSame = true;
        for (var avail in order.availability) {
          final range = avail['timeRange'] as Map<String, dynamic>;
          if (range['fromHour'] != firstRange['fromHour'] ||
              range['fromMinute'] != firstRange['fromMinute'] ||
              range['toHour'] != firstRange['toHour'] ||
              range['toMinute'] != firstRange['toMinute']) {
            allSame = false;
            break;
          }
        }

        if (allSame && order.availability.length == 7) {
          _isAllWeek = true;
          _allWeekFromTime = TimeOfDay(
            hour: firstRange['fromHour'] as int,
            minute: firstRange['fromMinute'] as int,
          );
          _allWeekToTime = TimeOfDay(
            hour: firstRange['toHour'] as int,
            minute: firstRange['toMinute'] as int,
          );
        } else {
          _isAllWeek = false;
          for (var avail in order.availability) {
            final dayName = avail['day'] as String;
            final range = avail['timeRange'] as Map<String, dynamic>;
            final day = WeekDay.values.firstWhere((d) => d.name == dayName);
            _dailyTimes[day] = (
              TimeOfDay(
                hour: range['fromHour'] as int,
                minute: range['fromMinute'] as int,
              ),
              TimeOfDay(
                hour: range['toHour'] as int,
                minute: range['toMinute'] as int,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _pickLocation() async {
    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);
    final LatLng? initial = (lat != null && lng != null)
        ? LatLng(lat, lng)
        : null;

    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialLocation: initial),
      ),
    );

    if (result != null) {
      setState(() {
        _latController.text = result.location.latitude.toString();
        _lngController.text = result.location.longitude.toString();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _fullAddressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    print('submit taped');
    if (!_formKey.currentState!.validate()) return;

    // Build availability JSON
    final List<Map<String, dynamic>> availability = [];
    if (_isAllWeek) {
      for (var day in WeekDay.values) {
        availability.add({
          'day': day.name,
          'timeRange': {
            'fromHour': _allWeekFromTime.hour,
            'fromMinute': _allWeekFromTime.minute,
            'toHour': _allWeekToTime.hour,
            'toMinute': _allWeekToTime.minute,
          },
        });
      }
    } else {
      _dailyTimes.forEach((day, times) {
        availability.add({
          'day': day.name,
          'timeRange': {
            'fromHour': times.$1.hour,
            'fromMinute': times.$1.minute,
            'toHour': times.$2.hour,
            'toMinute': times.$2.minute,
          },
        });
      });
    }

    final orderData = Order(
      title: _titleController.text,
      description: _descriptionController.text,
      orderType: _orderType,
      priority: _priority,
      publicArea: _areaController.text,
      publicLandmark: _landmarkController.text,
      availability: availability,
      fullAddress: _fullAddressController.text.isEmpty
          ? null
          : _fullAddressController.text,
      latitude: double.tryParse(_latController.text),
      longitude: double.tryParse(_lngController.text),
      contactName: _contactNameController.text.isEmpty
          ? null
          : _contactNameController.text,
      contactPhone: _contactPhoneController.text.isEmpty
          ? null
          : _contactPhoneController.text,
      id: '',
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    final adminId = ref.read(authProvider).user?.id ?? '';

    Object? result;
    if (widget.order != null) {
      result = await ref
          .read(orderProvider.notifier)
          .updateOrder(orderId: widget.order!.id, orderData: orderData);
    } else {
      result = await ref
          .read(orderProvider.notifier)
          .createOrderByAdmin(adminId: adminId, orderData: orderData);
    }

    if (result != null && result != false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.order != null
                ? 'تم تحديث الطلب بنجاح'
                : 'تم إضافة الطلب بنجاح',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.statusGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(orderProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('المعلومات العامة'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _titleController,
                            'عنوان الطلب (مثلاً: نقل أثاث)',
                            Icons.title_rounded,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _descriptionController,
                            'وصف تفصيلي للخدمة',
                            Icons.description_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildOrderTypeDropdown()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildPriorityDropdown()),
                            ],
                          ),

                          const SizedBox(height: 32),
                          _buildSectionTitle('التوافر والوقت'),
                          const SizedBox(height: 16),
                          _buildAvailabilityToggle(),
                          if (!_isAllWeek) ...[
                            const SizedBox(height: 16),
                            _buildDailySchedule(),
                          ],

                          const SizedBox(height: 32),
                          _buildSectionTitle('الموقع العام (يظهر للجميع)'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _areaController,
                            'المنطقة أو الحي',
                            Icons.location_city_rounded,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _landmarkController,
                            'معلم شهير بالقرب منك',
                            Icons.assistant_navigation,
                          ),

                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('الموقع التفصيلي (خاص)'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _fullAddressController,
                            'العنوان الكامل',
                            Icons.map_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildMapPickerButton(),
                          if (_latController.text.isNotEmpty &&
                              _lngController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, right: 12),
                              child: Text(
                                'تم تحديد الموقع: ${_latController.text}, ${_lngController.text}',
                                style: GoogleFonts.cairo(
                                  color: AppColors.statusGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          const SizedBox(height: 32),
                          _buildSectionTitle('بيانات التواصل'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _contactNameController,
                            'اسم جهة الاتصال',
                            Icons.person_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _contactPhoneController,
                            'رقم التواصل',
                            Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 32),

                          _buildSubmitButton(isLoading),
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.order != null ? 'تعديل الطلب' : 'إضافة طلب جديد',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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

  Widget _buildAvailabilityToggle() {
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
                value: _isAllWeek,
                onChanged: (v) => setState(() => _isAllWeek = v),
                activeColor: AppColors.primaryBlue,
              ),
            ],
          ),
          if (_isAllWeek) ...[
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
                _buildTimePicker(
                  label: 'من',
                  time: _allWeekFromTime,
                  onChanged: (newTime) {
                    setState(() => _allWeekFromTime = newTime);
                  },
                ),
                const SizedBox(width: 8),
                Text(':', style: GoogleFonts.cairo(color: AppColors.textGrey)),
                const SizedBox(width: 8),
                _buildTimePicker(
                  label: 'إلى',
                  time: _allWeekToTime,
                  onChanged: (newTime) {
                    setState(() => _allWeekToTime = newTime);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailySchedule() {
    return Column(
      children: WeekDay.values.map((day) {
        final times = _dailyTimes[day]!;
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
              _buildTimePicker(
                label: 'من',
                time: times.$1,
                onChanged: (newTime) {
                  setState(() => _dailyTimes[day] = (newTime, times.$2));
                },
              ),
              const SizedBox(width: 8),
              Text(':', style: GoogleFonts.cairo(color: AppColors.textGrey)),
              const SizedBox(width: 8),
              _buildTimePicker(
                label: 'إلى',
                time: times.$2,
                onChanged: (newTime) {
                  setState(() => _dailyTimes[day] = (times.$1, newTime));
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
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

  Widget _buildOrderTypeDropdown() {
    return _buildDropdownContainer(
      child: DropdownButton<OrderType>(
        value: _orderType,
        dropdownColor: AppColors.darkCard,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textGrey,
        ),
        style: GoogleFonts.cairo(color: Colors.white),
        items: OrderType.values
            .map(
              (type) => DropdownMenuItem(
                value: type,
                child: Text(_orderTypeArabic(type)),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _orderType = value!),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return _buildDropdownContainer(
      child: DropdownButton<OrderPriority>(
        value: _priority,
        dropdownColor: AppColors.darkCard,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textGrey,
        ),
        style: GoogleFonts.cairo(color: Colors.white),
        items: OrderPriority.values
            .map(
              (p) =>
                  DropdownMenuItem(value: p, child: Text(_priorityArabic(p))),
            )
            .toList(),
        onChanged: (value) => setState(() => _priority = value!),
      ),
    );
  }

  Widget _buildMapPickerButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickLocation,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'تحديد الموقع من الخريطة',
                style: GoogleFonts.cairo(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.glowShadow,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'إنشاء الطلب الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  String _orderTypeArabic(OrderType type) {
    switch (type) {
      case OrderType.pickup:
        return 'استلام';
      case OrderType.delivery:
        return 'توصيل';
      case OrderType.pickupAndReturn:
        return 'استلام وعودة';
    }
  }

  String _priorityArabic(OrderPriority priority) {
    switch (priority) {
      case OrderPriority.low:
        return 'منخفضة';
      case OrderPriority.medium:
        return 'متوسطة';
      case OrderPriority.high:
        return 'عالية';
      case OrderPriority.urgent:
        return 'عاجل جداً';
    }
  }
}
