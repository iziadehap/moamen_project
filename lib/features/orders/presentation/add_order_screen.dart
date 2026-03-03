import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/normiliz_eg_phone.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/custom_snackbar.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/orders/presentation/location_picker_screen.dart';
import 'package:moamen_project/features/orders/presentation/widgets/add_order_widgets.dart';
import 'package:moamen_project/core/utils/alx_places.dart';
import 'package:moamen_project/core/utils/availability_utils.dart';
import 'package:moamen_project/features/orders/presentation/availability_settings_screen.dart';

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
  OrderStatus _status = OrderStatus.pending;
  String? _workerId;
  bool _isAllWeek = true;
  bool _isManualArea = false;
  AlexPlace? _selectedPlace;
  AvailabilityConfig _availabilityConfig = const AvailabilityConfig(
    weeklyRules: [],
    overrides: [],
  );
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
    _status = order.status;
    _workerId = order.workerId;

    // Check if it's a predefined place
    final matchingPlace = alexPlaces
        .where((p) => p.name == order.publicArea)
        .firstOrNull;
    if (matchingPlace != null) {
      _selectedPlace = matchingPlace;
      _isManualArea = false;
    } else {
      _isManualArea = true;
    }

    if (order.availability.isNotEmpty) {
      _initAvailability(order.availability);
      _availabilityConfig = AvailabilityConfig.fromModelAvailability(
        order.availability,
      );
    }

    if (order.photoUrls.isNotEmpty) {
      // Set initial photos if editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(orderProvider.notifier).setPhotoUrls(order.photoUrls);
        }
      });
    }
  }

  void _initAvailability(List<Map<String, dynamic>> availability) {
    if (availability.isEmpty) return;

    final firstAvail = availability.first;
    final firstRange = firstAvail['timeRange'] as Map<String, dynamic>?;

    if (firstRange == null) return;

    bool allSame = availability.length == 7;

    for (var avail in availability) {
      final range = avail['timeRange'] as Map<String, dynamic>?;
      if (range == null ||
          range['fromHour'] != firstRange['fromHour'] ||
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
        hour: firstRange['fromHour'] ?? 0,
        minute: firstRange['fromMinute'] ?? 0,
      );
      _allWeekToTime = TimeOfDay(
        hour: firstRange['toHour'] ?? 23,
        minute: firstRange['toMinute'] ?? 59,
      );
    } else {
      _isAllWeek = false;
      for (var avail in availability) {
        final dayName = avail['day'] as String?;
        if (dayName == null) continue;

        final day = WeekDay.values.firstWhere(
          (d) => d.name == dayName,
          orElse: () => WeekDay.monday,
        );
        final range = avail['timeRange'] as Map<String, dynamic>?;

        if (range != null) {
          _dailyTimes[day] = (
            TimeOfDay(
              hour: range['fromHour'] ?? 0,
              minute: range['fromMinute'] ?? 0,
            ),
            TimeOfDay(
              hour: range['toHour'] ?? 23,
              minute: range['toMinute'] ?? 59,
            ),
          );
        }
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
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    // Check if location is selected
    if (_latController.text.isEmpty || _lngController.text.isEmpty) {
      if (mounted) {
        showCustomSnackBar(
          context,
          customTheme: customTheme,
          message: 'يرجى تحديد الموقع على الخريطة أولاً',
          icon: Icons.error,
          isError: true,
          color: customTheme.errorColor,
        );
      }
      return;
    }

    final notifier = ref.read(orderProvider.notifier);

    // 1. Upload new local photos first
    final newUrls = await notifier.uploadAllPhotos();

    // 3. Check for errors (e.g. upload failed)
    if (ref.read(orderProvider).isError) {
      print('AddOrderScreen._submit: Error during photo upload');
      if (mounted) {
        showCustomSnackBar(
          context,
          customTheme: customTheme,
          message: 'حدث خطأ أثناء رفع الصور، يرجى المحاولة مرة أخرى',
          icon: Icons.error,
          isError: true,
          color: customTheme.errorColor,
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
      status: widget.order != null ? _status : OrderStatus.pending,
      workerId: _workerId,
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

    if (success == null || success == false) {
      print(
        'AddOrderScreen._submit: Failed to ${widget.order != null ? 'update' : 'create'} order',
      );
    }

    if (success != null && success != false && mounted) {
      // Clear photos on success
      ref.read(orderProvider.notifier).resetPhotos();

      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: widget.order != null
            ? 'تم تحديث الاوردر بنجاح'
            : 'تم إضافة الاوردر بنجاح',
        icon: Icons.check,
        color: customTheme.statusGreen,
      );
      Navigator.pop(context);
    }
  }

  List<Map<String, dynamic>> _buildAvailabilityJson() {
    // If user used the advanced settings, prefer those
    if (_availabilityConfig.weeklyRules.isNotEmpty ||
        _availabilityConfig.overrides.isNotEmpty) {
      final list = <Map<String, dynamic>>[];
      for (final rule in _availabilityConfig.weeklyRules) {
        for (final day in rule.days) {
          for (final range in rule.ranges) {
            list.add({
              'day': day.name,
              'timeRange': {
                'fromHour': range.startMin ~/ 60,
                'fromMinute': range.startMin % 60,
                'toHour': range.endMin ~/ 60,
                'toMinute': range.endMin % 60,
              },
            });
          }
        }
      }
      // Note: Overrides are stored in the same 'availability' field for now,
      // but the model might need an update to fully support them.
      // For now, we map weekly rules to the existing structure.
      if (list.isNotEmpty) return list;
    }

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
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final isLoading = ref.watch(orderProvider).isLoading;

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(customTheme),
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
                            label: 'عنوان الاوردر (مثلاً: نقل حديد)',
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
                          _buildPriorityDropdown(customTheme),
                          const SizedBox(height: 16),
                          if (widget.order != null) ...[
                            _buildStatusDropdown(customTheme),
                            const SizedBox(height: 16),
                          ],
                          if (_workerId != null && _workerId!.isNotEmpty) ...[
                            _buildWorkerSection(customTheme),
                            const SizedBox(height: 16),
                          ],
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
                          const SizedBox(height: 16),
                          _buildAdvancedAvailabilityButton(customTheme),
                          const SizedBox(height: 32),
                          const SectionHeader(
                            title: 'الموقع العام (يظهر للجميع)',
                          ),
                          const SizedBox(height: 16),
                          _buildPlacesDropdown(customTheme),
                          if (_isManualArea) ...[
                            const SizedBox(height: 16),
                            FormTextField(
                              controller: _areaController,
                              label: 'المنطقة أو الحي (يدوياً)',
                              icon: Icons.location_city_rounded,
                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                            ),
                          ],
                          if (_isManualArea || _selectedPlace != null) ...[
                            const SizedBox(height: 32),
                            const SectionHeader(title: 'الموقع التفصيلي (خاص)'),
                            const SizedBox(height: 16),
                            FormTextField(
                              controller: _fullAddressController,
                              label: 'العنوان الكامل',
                              icon: Icons.map_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildMapPickerButton(customTheme),
                            _buildLocationStatus(customTheme),
                          ],
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
                          const SizedBox(height: 16),
                          uplodePhotoWidget(),
                          const SizedBox(height: 32),
                          // _buildSubmitButton(isLoading, customTheme),
                          // const SizedBox(height: 40),
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

  Widget _buildHeader(CustomThemeExtension customTheme) {
    final isLoading = ref.watch(orderProvider).isLoading;

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

          // Title
          Expanded(
            child: Text(
              widget.order != null ? 'تعديل الاوردر' : 'إضافة اوردر جديد',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: customTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 12),

          // ✅ Submit/Update button in header
          _HeaderActionButton(
            isLoading: isLoading,
            label: widget.order != null ? 'تحديث' : 'إنشاء',
            onTap: isLoading ? null : _submit,
            customTheme: customTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDropdown(CustomThemeExtension customTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
      ),
      child: DropdownButton<OrderPriority>(
        value: _priority,
        dropdownColor: customTheme.cardBackground,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: customTheme.textSecondary,
        ),
        style: GoogleFonts.cairo(color: customTheme.textPrimary),
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

  Widget _buildMapPickerButton(CustomThemeExtension customTheme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: customTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: customTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: _pickLocation,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, color: customTheme.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Text(
              'تحديد الموقع من الخريطة *',
              style: GoogleFonts.cairo(
                color: customTheme.primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus(CustomThemeExtension customTheme) {
    if (_latController.text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 12),
      child: Text(
        'تم تحديد الموقع: ${_latController.text}, ${_lngController.text}',
        style: GoogleFonts.cairo(
          color: customTheme.statusGreen,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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

  Widget _buildPlacesDropdown(CustomThemeExtension customTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المنطقة أو الحي',
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showPlacesPicker(customTheme),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: customTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: customTheme.textPrimary.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isManualArea
                      ? Icons.edit_location_alt_rounded
                      : Icons.location_on_rounded,
                  color: customTheme.primaryBlue.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isManualArea
                        ? 'أخرى (إدخال يدوي)'
                        : (_selectedPlace?.name ?? 'اختر منطقة من القائمة'),
                    style: GoogleFonts.cairo(
                      color: (_isManualArea || _selectedPlace != null)
                          ? customTheme.textPrimary
                          : customTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: customTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPlacesPicker(CustomThemeExtension customTheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlacesPickerSheet(
        customTheme: customTheme,
        onPlaceSelected: (place) {
          setState(() {
            _isManualArea = false;
            _selectedPlace = place;
            _areaController.text = place.name;
            _latController.text = place.lat.toString();
            _lngController.text = place.lng.toString();
          });
        },
        onManualSelected: () {
          setState(() {
            _isManualArea = true;
            _selectedPlace = null;
            _areaController.clear();
            _latController.clear();
            _lngController.clear();
          });
        },
      ),
    );
  }

  Widget _buildStatusDropdown(CustomThemeExtension customTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حالة الاوردر',
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: customTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
          ),
          child: DropdownButton<OrderStatus>(
            value: _status,
            dropdownColor: customTheme.cardBackground,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: customTheme.textSecondary,
            ),
            style: GoogleFonts.cairo(color: customTheme.textPrimary),
            items: OrderStatus.values
                .map(
                  (s) =>
                      DropdownMenuItem(value: s, child: Text(_statusArabic(s))),
                )
                .toList(),
            onChanged: (value) => setState(() {
              _status = value!;
              if (_status == OrderStatus.pending) {
                _workerId = null;
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerSection(CustomThemeExtension customTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: customTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.engineering_rounded, color: customTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العامل المعين',
                  style: GoogleFonts.cairo(
                    color: customTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  _workerId ?? '',
                  style: GoogleFonts.cairo(
                    color: customTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _workerId = null;
                // Automatically set status to pending if worker is removed
                _status = OrderStatus.pending;
              });
            },
            icon: Icon(
              Icons.person_remove_rounded,
              color: customTheme.errorColor,
              size: 18,
            ),
            label: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: customTheme.errorColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusArabic(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.accepted:
        return 'تم القبول';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Widget _buildAdvancedAvailabilityButton(CustomThemeExtension customTheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: customTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: customTheme.primaryBlue.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push<AvailabilityConfig>(
              context,
              MaterialPageRoute(
                builder: (context) => AvailabilitySettingsScreen(
                  initialConfig: _availabilityConfig,
                ),
              ),
            );
            if (result != null) {
              setState(() {
                _availabilityConfig = result;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.settings_suggest_rounded,
                  color: customTheme.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة التوافر المتقدمة',
                        style: GoogleFonts.cairo(
                          color: customTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'فترات متعددة، استثناءات تواريخ معينة',
                        style: GoogleFonts.cairo(
                          color: customTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: customTheme.textSecondary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlacesPickerSheet extends StatefulWidget {
  final CustomThemeExtension customTheme;
  final Function(AlexPlace) onPlaceSelected;
  final VoidCallback onManualSelected;

  const _PlacesPickerSheet({
    required this.customTheme,
    required this.onPlaceSelected,
    required this.onManualSelected,
  });

  @override
  State<_PlacesPickerSheet> createState() => _PlacesPickerSheetState();
}

class _PlacesPickerSheetState extends State<_PlacesPickerSheet> {
  final _searchController = TextEditingController();
  List<AlexPlace> _filteredPlaces = alexPlaces;

  void _filterPlaces(String query) {
    setState(() {
      _filteredPlaces = alexPlaces
          .where(
            (p) =>
                p.name.contains(query) ||
                p.zone.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: widget.customTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        gradient: widget.customTheme.scaffoldGradient,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.customTheme.textPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'اختر المنطقة',
                  style: GoogleFonts.cairo(
                    color: widget.customTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: widget.customTheme.textPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPlaces,
              style: GoogleFonts.cairo(color: widget.customTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'ابحث عن منطقة...',
                hintStyle: GoogleFonts.cairo(
                  color: widget.customTheme.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: widget.customTheme.primaryBlue,
                ),
                filled: true,
                fillColor: widget.customTheme.textPrimary.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: widget.customTheme.textPrimary.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildOptionItem(
                    icon: Icons.edit_location_alt_rounded,
                    title: 'أخرى (إدخال يدوي)',
                    subtitle: 'اختر هذا للمناطق غير الموجودة بالقائمة',
                    isManual: true,
                    onTap: () {
                      widget.onManualSelected();
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      color: widget.customTheme.textPrimary.withOpacity(0.1),
                    ),
                  ),
                  ..._filteredPlaces.map(
                    (place) => _buildOptionItem(
                      icon: Icons.location_on_rounded,
                      title: place.name,
                      subtitle: _zoneArabic(place.zone),
                      onTap: () {
                        widget.onPlaceSelected(place);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isManual = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isManual
            ? widget.customTheme.primaryBlue.withOpacity(0.1)
            : widget.customTheme.textPrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isManual
              ? widget.customTheme.primaryBlue.withOpacity(0.3)
              : widget.customTheme.textPrimary.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isManual
                ? widget.customTheme.primaryBlue.withOpacity(0.2)
                : widget.customTheme.textPrimary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isManual
                ? widget.customTheme.primaryBlue
                : widget.customTheme.textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: isManual
                ? widget.customTheme.primaryBlue
                : widget.customTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            color: widget.customTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: isManual
              ? widget.customTheme.primaryBlue
              : widget.customTheme.textSecondary.withOpacity(0.3),
          size: 14,
        ),
      ),
    );
  }

  String _zoneArabic(String zone) {
    switch (zone.toLowerCase()) {
      case 'west':
        return 'غرب الإسكندرية';
      case 'center':
        return 'وسط الإسكندرية';
      case 'east':
        return 'شرق الإسكندرية';
      case 'montaza':
        return 'حي المنتزة';
      default:
        return zone;
    }
  }
}

class _HeaderActionButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onTap;
  final CustomThemeExtension customTheme;

  const _HeaderActionButton({
    required this.isLoading,
    required this.label,
    required this.onTap,
    required this.customTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onTap == null ? 0.55 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: customTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: customTheme.primaryBlue.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: AnimationWidget.loadingAnimation(18),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
