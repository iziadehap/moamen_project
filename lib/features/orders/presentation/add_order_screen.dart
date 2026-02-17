import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/core/utils/normiliz_eg_phone.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/orders/presentation/location_picker_screen.dart';
import 'package:moamen_project/features/orders/presentation/widgets/add_order_widgets.dart';

class AddOrderScreen extends ConsumerStatefulWidget {
  final Order? order;
  const AddOrderScreen({super.key, this.order});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // State
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
    if (widget.order != null) _initFields(widget.order!);
  }

  void _initFields(Order order) {
    _titleController.text = order.title;
    _descriptionController.text = order.description;
    _areaController.text = order.publicArea;
    _fullAddressController.text = order.fullAddress ?? '';
    _latController.text = order.latitude?.toString() ?? '';
    _lngController.text = order.longitude?.toString() ?? '';
    _contactNameController.text = order.contactName ?? '';
    _contactPhoneController.text = order.contactPhone ?? '';
    _priority = order.priority;

    if (order.availability.isNotEmpty) {
      _initAvailability(order.availability);
    }

    if (order.photoUrls.isNotEmpty) {
      // Set initial photos if editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(orderProvider.notifier).setPhotoUrls(order.photoUrls);
      });
    }
  }

  void _initAvailability(List<Map<String, dynamic>> availability) {
    final firstRange = availability.first['timeRange'] as Map<String, dynamic>;
    bool allSame = availability.length == 7;

    for (var avail in availability) {
      final range = avail['timeRange'] as Map<String, dynamic>;
      if (range['fromHour'] != firstRange['fromHour'] ||
          range['fromMinute'] != firstRange['fromMinute'] ||
          range['toHour'] != firstRange['toHour'] ||
          range['toMinute'] != firstRange['toMinute']) {
        allSame = false;
        break;
      }
    }

    if (allSame) {
      _isAllWeek = true;
      _allWeekFromTime = TimeOfDay(
        hour: firstRange['fromHour'],
        minute: firstRange['fromMinute'],
      );
      _allWeekToTime = TimeOfDay(
        hour: firstRange['toHour'],
        minute: firstRange['toMinute'],
      );
    } else {
      _isAllWeek = false;
      for (var avail in availability) {
        final day = WeekDay.values.firstWhere((d) => d.name == avail['day']);
        final range = avail['timeRange'] as Map<String, dynamic>;
        _dailyTimes[day] = (
          TimeOfDay(hour: range['fromHour'], minute: range['fromMinute']),
          TimeOfDay(hour: range['toHour'], minute: range['toMinute']),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _fullAddressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);

    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: (lat != null && lng != null)
              ? LatLng(lat, lng)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latController.text = result.location.latitude.toString();
        _lngController.text = result.location.longitude.toString();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(orderProvider.notifier);

    // 1. Upload new local photos first
    final newUrls = await notifier.uploadAllPhotos();

    // 3. Check for errors (e.g. upload failed)
    if (ref.read(orderProvider).isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء رفع الصور، يرجى المحاولة مرة أخرى',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // 2. Combine with existing URLs (those that weren't removed)
    final existingUrls = ref.read(orderProvider).photoUrls;
    final totalPhotoUrls = [...existingUrls, ...newUrls];

    final availability = _buildAvailabilityJson();

    final orderData = Order(
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority,
      publicArea: _areaController.text,
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
      photoUrls: totalPhotoUrls,
      id: widget.order?.id ?? '',
      status: widget.order?.status ?? OrderStatus.pending,
      createdAt: widget.order?.createdAt,
      updatedAt: widget.order?.updatedAt,
    );

    final success = widget.order != null
        ? await notifier.updateOrder(
            orderId: widget.order!.id,
            orderData: orderData,
          )
        : await notifier.createOrderByAdmin(
            adminId: ref.read(authProvider).user?.id ?? '',
            orderData: orderData,
          );

    if (success != null && success != false && mounted) {
      // Clear photos on success
      ref.read(orderProvider.notifier).resetPhotos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.order != null
                ? 'تم تحديث الاوردر بنجاح'
                : 'تم إضافة الاوردر بنجاح',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.statusGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  List<Map<String, dynamic>> _buildAvailabilityJson() {
    if (_isAllWeek) {
      return WeekDay.values
          .map(
            (day) => {
              'day': day.name,
              'timeRange': {
                'fromHour': _allWeekFromTime.hour,
                'fromMinute': _allWeekFromTime.minute,
                'toHour': _allWeekToTime.hour,
                'toMinute': _allWeekToTime.minute,
              },
            },
          )
          .toList();
    } else {
      final list = <Map<String, dynamic>>[];
      _dailyTimes.forEach((day, times) {
        list.add({
          'day': day.name,
          'timeRange': {
            'fromHour': times.$1.hour,
            'fromMinute': times.$1.minute,
            'toHour': times.$2.hour,
            'toMinute': times.$2.minute,
          },
        });
      });
      return list;
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
                          const SectionHeader(
                            title: 'المعلومات العامة (عام للجميع)',
                          ),
                          const SizedBox(height: 16),
                          FormTextField(
                            controller: _titleController,
                            label: 'عنوان الاوردر (مثلاً: نقل حديد )',
                            icon: Icons.title_rounded,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 16),
                          FormTextField(
                            controller: _descriptionController,
                            label: 'وصف تفصيلي للخدمة',
                            icon: Icons.description_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildPriorityDropdown(),
                          const SizedBox(height: 32),
                          const SectionHeader(title: 'التوافر والوقت'),
                          const SizedBox(height: 16),
                          AvailabilityToggle(
                            isAllWeek: _isAllWeek,
                            onChanged: (v) => setState(() => _isAllWeek = v),
                            fromTime: _allWeekFromTime,
                            toTime: _allWeekToTime,
                            onFromChanged: (t) =>
                                setState(() => _allWeekFromTime = t),
                            onToChanged: (t) =>
                                setState(() => _allWeekToTime = t),
                          ),
                          if (!_isAllWeek) ...[
                            const SizedBox(height: 16),
                            ...WeekDay.values.map(
                              (day) => DailyScheduleItem(
                                day: day,
                                fromTime: _dailyTimes[day]!.$1,
                                toTime: _dailyTimes[day]!.$2,
                                onFromChanged: (t) => setState(
                                  () => _dailyTimes[day] = (
                                    t,
                                    _dailyTimes[day]!.$2,
                                  ),
                                ),
                                onToChanged: (t) => setState(
                                  () => _dailyTimes[day] = (
                                    _dailyTimes[day]!.$1,
                                    t,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          const SectionHeader(
                            title: 'الموقع العام (يظهر للجميع)',
                          ),
                          const SizedBox(height: 16),
                          FormTextField(
                            controller: _areaController,
                            label: 'المنطقة أو الحي',
                            icon: Icons.location_city_rounded,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 32),
                          const SectionHeader(title: 'الموقع التفصيلي (خاص)'),
                          const SizedBox(height: 16),
                          FormTextField(
                            controller: _fullAddressController,
                            label: 'العنوان الكامل',
                            icon: Icons.map_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildMapPickerButton(),
                          _buildLocationStatus(),
                          const SizedBox(height: 32),
                          const SectionHeader(title: 'بيانات التواصل (خاص)'),
                          const SizedBox(height: 16),
                          FormTextField(
                            controller: _contactNameController,
                            label: 'اسم جهة الاتصال',
                            icon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 16),
                          FormTextField(
                            controller: _contactPhoneController,
                            label: 'رقم التواصل',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v!.isEmpty) return 'مطلوب';
                              try {
                                normalizeEgyptianPhone(v);
                              } catch (_) {
                                return 'رقم الهاتف غير صحيح';
                              }
                              return null;
                            },
                          ),
                          // todo : uplode photos
                          const SizedBox(height: 16),
                          uplodePhotoWidget(),
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
            widget.order != null ? 'تعديل الاوردر' : 'إضافة اوردر جديد',
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

  Widget _buildPriorityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
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
    );
  }

  Widget _buildLocationStatus() {
    if (_latController.text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 12),
      child: Text(
        'تم تحديد الموقع: ${_latController.text}, ${_lngController.text}',
        style: GoogleFonts.cairo(
          color: AppColors.statusGreen,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                  'إنشاء الاوردر الآن',
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
