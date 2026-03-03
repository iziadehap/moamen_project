import 'package:carousel_slider/carousel_slider.dart';
// import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/utils/app_config_data.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/build_images_heder.dart';
import 'package:moamen_project/core/widgets/open_in_googleMap.dart';
import 'package:moamen_project/core/widgets/open_phone_number.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/add_order_screen.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/core/utils/availability_utils.dart';
import 'package:moamen_project/core/utils/order_status_helper.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'location_picker_screen.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool congratolation = false;
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  // late ConfettiController _confettiController;

  Order get order => widget.order;

  @override
  void initState() {
    super.initState();
    // _confettiController = ConfettiController(
    //   duration: const Duration(seconds: 3),
    // );
  }

  @override
  void dispose() {
    // _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);

    // Find the latest version of this order in the state
    final currentOrder = orderState.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    final isAdmin = authState.user?.role == SupabaseAccountTyps.admin;
    final currentUserId = authState.user?.id;
    final isAlreadyMine =
        currentOrder.workerId != null && currentOrder.workerId == currentUserId;

    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  _buildHeader(
                    context,
                    isAdmin,
                    ref,
                    currentOrder,
                    customTheme,
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusBatch(currentOrder.status, customTheme),
                            const SizedBox(height: 16),
                            Text(
                              currentOrder.title,
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: customTheme.textPrimary,
                              ),
                            ),
                            if (isAdmin || isAlreadyMine) ...[
                              const SizedBox(height: 8),
                              Text(
                                currentOrder.description,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: customTheme.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            if (isAdmin || isAlreadyMine) ...[
                              _buildImages(currentOrder.photoUrls),
                              const SizedBox(height: 32),
                            ],

                            _buildSectionTitle('المعلومات العامة', customTheme),
                            const SizedBox(height: 16),
                            _buildInfoCard([
                              // _buildInfoRow(
                              //   Icons.category_rounded,
                              //   'نوع الاوردر',
                              //   _orderTypeArabic(order.orderType),
                              // ),
                              _buildInfoRow(
                                Icons.priority_high_rounded,
                                'الأولوية',
                                _priorityArabic(currentOrder.priority),
                                customTheme,
                              ),
                              _buildInfoRow(
                                Icons.location_city_rounded,
                                'المنطقة',
                                currentOrder.publicArea,
                                customTheme,
                              ),
                            ], customTheme),

                            const SizedBox(height: 32),
                            _buildSectionTitle('التوافر والوقت', customTheme),
                            const SizedBox(height: 16),
                            _buildAvailabilityCard(
                              currentOrder.availability,
                              customTheme,
                            ),

                            _buildAcceptButton(
                              isAlreadyMine,
                              currentOrder,
                              customTheme,
                            ),

                            if (isAdmin || isAlreadyMine) ...[
                              const SizedBox(height: 32),
                              _buildSectionTitle(
                                isAdmin
                                    ? 'بيانات التواصل والتوصيل (خاصة بالمسؤول)'
                                    : 'بيانات التواصل والتوصيل',
                                customTheme,
                              ),
                              const SizedBox(height: 16),
                              if (currentOrder.latitude != null &&
                                  currentOrder.longitude != null)
                                _buildMapPreview(
                                  context,
                                  currentOrder,
                                  customTheme,
                                ),
                              const SizedBox(height: 16),
                              _buildInfoCard([
                                if (currentOrder.fullAddress != null)
                                  _buildInfoRow(
                                    Icons.home_work_rounded,
                                    'العنوان الكامل',
                                    currentOrder.fullAddress!,
                                    customTheme,
                                  ),
                                if (currentOrder.latitude != null &&
                                    currentOrder.longitude != null)
                                  OpenInGoogleMap(
                                    location:
                                        '${currentOrder.latitude}, ${currentOrder.longitude}',
                                    child: _buildInfoRow(
                                      Icons.location_on_rounded,
                                      'الإحداثيات',
                                      '${currentOrder.latitude}, ${currentOrder.longitude}',
                                      customTheme,
                                      canTap: true,
                                    ),
                                  ),
                                if (currentOrder.contactName != null)
                                  _buildInfoRow(
                                    Icons.person_rounded,
                                    'اسم المستلم',
                                    currentOrder.contactName!,
                                    customTheme,
                                  ),
                                if (currentOrder.contactPhone != null)
                                  OpenPhoneNumber(
                                    phone: currentOrder.contactPhone!,
                                    child: _buildInfoRow(
                                      canTap: true,
                                      Icons.phone_android_rounded,
                                      'رقم التواصل',
                                      currentOrder.contactPhone!,
                                      customTheme,
                                    ),
                                  ),
                              ], customTheme),
                            ],

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (congratolation) _buildCongratulation(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isAdmin
          ? _buildEditButton(context, currentOrder, customTheme)
          : null,
    );
  }

  Widget _buildCongratulation() {
    double height = MediaQuery.of(context).size.height;
    return AnimationWidget.congratolation(size: height, isPlaying: false);
  }

  Widget _buildAcceptButton(
    bool isAlreadyMine,
    Order currentOrder,
    CustomThemeExtension customTheme,
  ) {
    final isAcceptedByOther =
        currentOrder.status == OrderStatus.accepted && !isAlreadyMine;

    final isAvarbleToAccept =
        currentOrder.status == OrderStatus.pending && !isAlreadyMine;

    final isCompleted = currentOrder.status == OrderStatus.completed;

    // if (!isAvarbleToAccept) {
    //   // build button to show order is not available to accept
    //   return const SizedBox.shrink();
    // }

    final orderState = ref.watch(orderProvider);
    final isLoading = orderState.isLoading;

    String buttonText = 'قبول هذا الاوردر الآن';
    IconData buttonIcon = Icons.check_circle_outline_rounded;
    bool isDisabled = false;
    Gradient? buttonGradient = customTheme.primaryGradient;

    if (isCompleted) {
      buttonText = 'تم إتمام هذا الاوردر';
      buttonIcon = Icons.task_alt_rounded;
      isDisabled = true;
      buttonGradient = null;
    } else if (isAlreadyMine && currentOrder.status == OrderStatus.accepted) {
      buttonText = 'إتمام هذا الاوردر';
      buttonIcon = Icons.task_alt_rounded;
      isDisabled = false;
      buttonGradient = customTheme.primaryGradient;
    } else if (isAlreadyMine) {
      buttonText = 'هذا الاوردر لديك بالفعل';
      buttonIcon = Icons.assignment_turned_in_rounded;
      isDisabled = true;
      buttonGradient = null;
    } else if (isAcceptedByOther) {
      buttonText = 'تم قبوله بالفعل من مستخدم اخر';
      buttonIcon = Icons.info_outline_rounded;
      isDisabled = true;
      buttonGradient = null;
    } else if (!isAvarbleToAccept) {
      buttonText = 'هذا الاوردر غير قابل للقبول';
      buttonIcon = Icons.info_outline_rounded;
      isDisabled = true;
      buttonGradient = null;
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: isDisabled ? null : buttonGradient,
        color: isDisabled ? Colors.grey.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDisabled ? [] : [],
        border: isDisabled
            ? Border.all(color: customTheme.textPrimary.withOpacity(0.1))
            : null,
      ),
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled)
            ? null
            : () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                if (isAlreadyMine &&
                    currentOrder.status == OrderStatus.accepted) {
                  // Show confirmation dialog before completion
                  _showCompleteConfirmation(
                    context,
                    ref,
                    currentOrder,
                    customTheme,
                  );
                } else {
                  // Accept Order Logic
                  final success = await ref
                      .read(orderProvider.notifier)
                      .acceptOrder(currentOrder.id);

                  success.fold(
                    (failure) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Column(
                            children: [
                              Text(failure.message, style: GoogleFonts.cairo()),
                              Text(
                                failure.description ?? '',
                                style: GoogleFonts.cairo(),
                              ),
                            ],
                          ),
                          backgroundColor: customTheme.errorColor,
                        ),
                      );
                    },
                    (success) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم قبول الاوردر بنجاح! يمكنك الآن البدء في تنفيذه.',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: customTheme.successColor,
                        ),
                      );
                      navigator.pop();
                    },
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: AnimationWidget.loadingAnimation(24),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonIcon,
                    color: isDisabled
                        ? customTheme.textSecondary
                        : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        buttonText,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDisabled
                              ? customTheme.textSecondary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImages(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    return BuildImagesHeder(photoUrls: images);
  }

  Widget _buildMapPreview(
    BuildContext context,
    Order currentOrder,
    CustomThemeExtension customTheme,
  ) {
    if (currentOrder.latitude == null || currentOrder.longitude == null) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: customTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            'الموقع غير متوفر',
            style: GoogleFonts.cairo(color: customTheme.textSecondary),
          ),
        ),
      );
    }
    final location = LatLng(currentOrder.latitude!, currentOrder.longitude!);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPickerScreen(
              initialLocation: location,
              isReadOnly: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: isDarkMode
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.moamen.project',
                  errorTileCallback: (tile, error, stackTrace) {
                    debugPrint('فشل تحميل مربع الخريطة: $error');
                  },
                  tileDisplay: const TileDisplay.fadeIn(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: customTheme.errorColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Overlay gradient for a more 'interactable' look
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),
            // Tapping hint
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: customTheme.background.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: customTheme.textPrimary.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fullscreen_rounded,
                      color:
                          customTheme.textPrimary, // Gradient overlay is dark
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'عرض الخريطة بالكامل',
                      style: GoogleFonts.cairo(
                        color:
                            customTheme.textPrimary, // Gradient overlay is dark
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    Order currentOrder,
    CustomThemeExtension customTheme,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        decoration: BoxDecoration(
          color: customTheme.background.withOpacity(0.8),
          border: Border(
            top: BorderSide(color: customTheme.textPrimary.withOpacity(0.1)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              gradient: customTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrderScreen(order: currentOrder),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'تعديل تفاصيل الاوردر',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isAdmin,
    WidgetRef ref,
    Order currentOrder,
    CustomThemeExtension customTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                'تفاصيل الاوردر',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimary,
                ),
              ),
            ],
          ),
          Spacer(),
          if (isAdmin) ...[
            IconButton(
              onPressed: () => _showDeleteConfirmation(
                context,
                ref,
                currentOrder,
                customTheme,
              ),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: customTheme.errorColor,
                size: 22,
              ),
              style: IconButton.styleFrom(
                backgroundColor: customTheme.errorColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () => _showCancelConfirmation(
                context,
                ref,
                currentOrder,
                customTheme,
              ),
              icon: Icon(
                Icons.cancel_sharp,
                color: customTheme.errorColor,
                size: 22,
              ),
              style: IconButton.styleFrom(
                backgroundColor: customTheme.errorColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCompleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Order currentOrder,
    CustomThemeExtension customTheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: customTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: customTheme.textPrimary.withOpacity(0.1)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: customTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: customTheme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'تأكيد الإتمام',
                style: GoogleFonts.cairo(
                  color: customTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من أنك قمت بإتمام هذا الاوردر؟ سيتم تغيير الحالة إلى مكتمل.',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: customTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: customTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  // Close dialog first
                  navigator.pop();

                  await ref
                      .read(orderProvider.notifier)
                      .completeOrder(currentOrder.id);

                  final newState = ref.read(orderProvider);
                  if (!newState.isError) {
                    // Play confetti
                    setState(() {
                      congratolation = true;
                    });
                    // playCongratulation();
                    // _confettiController.play();

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم إتمام الاوردر بنجاح! شكراً لك.',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: customTheme.successColor,
                      ),
                    );

                    // Wait a bit for the animation to be seen
                    await Future.delayed(const Duration(seconds: 2));

                    // Close details screen
                    if (context.mounted) {
                      navigator.pop();
                    }
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'فشل إتمام الاوردر: ${newState.errorMessage}',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: customTheme.errorColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'نعم، أتممته',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Order currentOrder,
    CustomThemeExtension customTheme,
  ) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: customTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: customTheme.textPrimary.withOpacity(0.1)),
          ),
          title: Text(
            'حذف الاوردر',
            style: GoogleFonts.cairo(
              color: customTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل أنت متأكد من رغبتك في حذف هذا الاوردر؟ لا يمكن التراجع عن هذا الإجراء.',
                style: GoogleFonts.cairo(color: customTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: GoogleFonts.cairo(color: customTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'كلمة مرور الحذف',
                  labelStyle: GoogleFonts.cairo(
                    color: customTheme.textSecondary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: customTheme.textPrimary.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: customTheme.primaryGradient.colors[0],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: customTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'يرجى إدخال كلمة المرور أولاً',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                // 1. Local Validation: Verify password first without setting state error
                final isVerified = await AppConfigData().verifyBigBossPassword(
                  passwordController.text,
                );

                if (!isVerified) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'كلمة المرور غير صحيحة',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: customTheme.errorColor,
                    ),
                  );
                  return;
                }

                // 2. If verified, proceed with deletion
                final userId = ref.read(authProvider).user?.id ?? '';

                // Close dialog
                navigator.pop();

                final success = await ref
                    .read(orderProvider.notifier)
                    .deleteOrder(
                      orderId: currentOrder.id,
                      userId: userId,
                      order: currentOrder,
                    );

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم حذف الاوردر بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: customTheme.successColor,
                    ),
                  );
                  // Return to orders screen
                  navigator.pop();
                } else {
                  // If it's a server error (not password), show generic or state error
                  final errorMsg = ref.read(orderProvider).errorMessage;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        errorMsg.isEmpty ? 'فشل حذف الاوردر' : errorMsg,
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: customTheme.errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: customTheme.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'حذف',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(
    BuildContext context,
    WidgetRef ref,
    Order currentOrder,
    CustomThemeExtension customTheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: customTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: customTheme.textPrimary.withOpacity(0.1)),
          ),
          title: Text(
            'الغاء الاوردر',
            style: GoogleFonts.cairo(
              color: customTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في إلغاء هذا الاوردر؟',
            style: GoogleFonts.cairo(color: customTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'تراجع',
                style: GoogleFonts.cairo(color: customTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = ref.read(authProvider).user?.id ?? '';
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                // Close dialog
                navigator.pop();

                final success = await ref
                    .read(orderProvider.notifier)
                    .cancelOrder(orderId: currentOrder.id, userId: userId);

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم الغاء الاوردر بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: customTheme.successColor,
                    ),
                  );
                  // Return to orders screen
                  navigator.pop();
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'فشل الغاء الاوردر',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: customTheme.errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: customTheme.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'الغاء',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBatch(
    OrderStatus status,
    CustomThemeExtension customTheme,
  ) {
    Color color = OrderStatusHelper.getStatusColor(status, customTheme);
    String text = OrderStatusHelper.getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, CustomThemeExtension customTheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: customTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            color: customTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    List<Widget> children,
    CustomThemeExtension customTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
      ),
      child: Column(
        children: children
            .expand(
              (w) => [w, if (children.last != w) const SizedBox(height: 16)],
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    CustomThemeExtension customTheme, {
    bool canTap = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: customTheme.primaryGradient.colors[0].withOpacity(0.5),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: canTap
              ? Text(
                  value,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.cairo(
                    color: customTheme.primaryGradient.colors[0],
                    decoration: TextDecoration.underline,
                    decorationColor: customTheme.primaryGradient.colors[0],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Text(
                  value,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.cairo(
                    // fontWeight: FontWeight.bold,
                    color: customTheme.textPrimary,
                    fontSize: 12,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard(
    List<Map<String, dynamic>> availability,
    CustomThemeExtension customTheme,
  ) {
    if (availability.isEmpty) return const SizedBox.shrink();

    final config = AvailabilityConfig.fromModelAvailability(availability);
    final now = DateTime.now();
    final isAvailable = AvailabilityCore.isAvailableAt(config, now);
    final nextAvailable = AvailabilityCore.nextAvailableStart(config, now);

    // 1. Sort days logically (Saturday to Friday)
    final dayOrder = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];
    final sortedAvail = List<Map<String, dynamic>>.from(availability)
      ..sort((a, b) {
        int getIdx(dynamic d) {
          final s = d.toString().toLowerCase();
          final key = s.length > 3 ? s.substring(0, 3) : s;
          // Note: Wednesday starts with 'wed', Thursday starts with 'thu'
          // Some systems might use 'thurs', but our enum uses 'thu'
          return dayOrder.indexOf(key);
        }

        return getIdx(a['day']).compareTo(getIdx(b['day']));
      });

    // 2. Group identical time ranges
    final grouped = <List<String>, String>{};
    for (var avail in sortedAvail) {
      final range = avail['timeRange'];
      if (range == null) continue;

      final fromH = range['fromHour'] as int;
      final fromM = range['fromMinute'] as int;
      final toH = range['toHour'] as int;
      final toM = range['toMinute'] as int;

      final timeStr =
          '${formatMinuteOfDay12hAr(fromH * 60 + fromM)} - ${formatMinuteOfDay12hAr(toH * 60 + toM)}';

      final day = _dayArabic(avail['day']);
      bool foundGroup = false;
      for (var entry in grouped.entries) {
        if (entry.value == timeStr) {
          entry.key.add(day);
          foundGroup = true;
          break;
        }
      }
      if (!foundGroup) {
        grouped[[day]] = timeStr;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // Availability Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (isAvailable
                              ? customTheme.successColor
                              : customTheme.errorColor)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        (isAvailable
                                ? customTheme.successColor
                                : customTheme.errorColor)
                            .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? customTheme.successColor
                            : customTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable ? 'متاح الآن' : 'غير متاح حالياً',
                      style: GoogleFonts.cairo(
                        color: isAvailable
                            ? customTheme.successColor
                            : customTheme.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isAvailable && nextAvailable != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'متاح : ${formatMinuteOfDay12hAr(nextAvailable.hour * 60 + nextAvailable.minute)}',
                    style: GoogleFonts.cairo(
                      color: customTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          ...grouped.entries.map((group) {
            final days = group.key;
            final time = group.value;

            String dayString;
            if (days.length == 7) {
              dayString = 'طوال أيام الأسبوع';
            } else if (days.length > 2) {
              dayString = '${days.first} - ${days.last}';
            } else {
              dayString = days.join('، ');
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: customTheme.textPrimary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: customTheme.textPrimary.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: customTheme.primaryGradient.colors[0].withOpacity(
                        0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: customTheme.primaryGradient.colors[0],
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayString,
                          style: GoogleFonts.cairo(
                            color: customTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'مواعيد التوافر',
                          style: GoogleFonts.cairo(
                            color: customTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: customTheme.primaryGradient.colors[0].withOpacity(
                        0.08,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: customTheme.primaryGradient.colors[0]
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.cairo(
                        color: customTheme.primaryGradient.colors[0],
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _dayArabic(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday':
      case 'mon':
        return 'الاثنين';
      case 'tuesday':
      case 'tue':
        return 'الثلاثاء';
      case 'wednesday':
      case 'wed':
        return 'الأربعاء';
      case 'thursday':
      case 'thu':
        return 'الخميس';
      case 'friday':
      case 'fri':
        return 'الجمعة';
      case 'saturday':
      case 'sat':
        return 'السبت';
      case 'sunday':
      case 'sun':
        return 'الأحد';
      default:
        return dayName;
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
