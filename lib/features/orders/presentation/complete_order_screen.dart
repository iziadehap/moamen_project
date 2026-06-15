import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/custom_snackbar.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/features/orders/presentation/widgets/add_order_widgets.dart';

class CompleteOrderScreen extends ConsumerStatefulWidget {
  final Order order;

  const CompleteOrderScreen({super.key, required this.order});

  @override
  ConsumerState<CompleteOrderScreen> createState() =>
      _CompleteOrderScreenState();
}

class _CompleteOrderScreenState extends ConsumerState<CompleteOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _picker = ImagePicker();

  File? _billPhoto;
  bool _isFromCamera = false;
  bool _showImageWarning = false;
  bool _isUploadingImage = false; // New loading state for image upload

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickBillPhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile == null || !mounted) return;

    // Start uploading
    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Simulate or handle actual upload here
      // If you need to upload to a server immediately, do it here
      await Future.delayed(const Duration(seconds: 1)); // Simulate upload delay
      
      setState(() {
        _billPhoto = File(pickedFile.path);
        _isFromCamera = source == ImageSource.camera;
        _showImageWarning = false;
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
        showCustomSnackBar(
          context,
          customTheme: customTheme,
          message: 'فشل في رفع الصورة: ${e.toString()}',
          icon: Icons.error,
          isError: true,
          color: customTheme.errorColor,
        );
      }
    }
  }

  void _showPhotoSourceSheet(CustomThemeExtension customTheme) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: customTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: customTheme.textPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'إضافة صورة الفاتورة',
                  style: GoogleFonts.cairo(
                    color: customTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_rounded,
                    color: customTheme.primaryBlue,
                  ),
                  title: Text(
                    'التقاط صورة بالكاميرا',
                    style: GoogleFonts.cairo(color: customTheme.textPrimary),
                  ),
                  onTap: _isUploadingImage
                      ? null
                      : () {
                          Navigator.pop(sheetContext);
                          _pickBillPhoto(ImageSource.camera);
                        },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: customTheme.primaryBlue,
                  ),
                  title: Text(
                    'اختيار من المعرض',
                    style: GoogleFonts.cairo(color: customTheme.textPrimary),
                  ),
                  onTap: _isUploadingImage
                      ? null
                      : () {
                          Navigator.pop(sheetContext);
                          _pickBillPhoto(ImageSource.gallery);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(CustomThemeExtension customTheme) async {
    // Check if no image is selected
    if (_billPhoto == null) {
      setState(() {
        _showImageWarning = true;
      });
      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: 'يرجى إرفاق صورة الفاتورة أو اختر "إكمال بدون صورة"',
        icon: Icons.warning_amber_rounded,
        color: customTheme.errorColor,
        isError: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final price = int.parse(_priceController.text.trim());

    final success = await ref.read(orderProvider.notifier).completeOrder(
          orderId: widget.order.id,
          billFile: _billPhoto!,
          isFromCam: _isFromCamera,
          price: price,
        );

    if (!mounted) return;

    if (success) {
      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: 'تم إتمام الاوردر بنجاح! شكراً لك.',
        icon: Icons.check,
        color: customTheme.successColor,
      );
      Navigator.pop(context, true);
    } else {
      final errorMessage = ref.read(orderProvider).errorMessage;
      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: errorMessage.isNotEmpty
            ? 'فشل إتمام الاوردر: $errorMessage'
            : 'فشل إتمام الاوردر',
        icon: Icons.error,
        isError: true,
        color: customTheme.errorColor,
      );
    }
  }

  Future<void> _submitWithoutImage(CustomThemeExtension customTheme) async {
    if (!_formKey.currentState!.validate()) return;

    final price = int.parse(_priceController.text.trim());

    final success = await ref.read(orderProvider.notifier).completeOrder(
          orderId: widget.order.id,
          billFile: null, // Send null instead of a file
          isFromCam: false,
          price: price,
        );

    if (!mounted) return;

    if (success) {
      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: 'تم إتمام الاوردر بنجاح! شكراً لك.',
        icon: Icons.check,
        color: customTheme.successColor,
      );
      Navigator.pop(context, true);
    } else {
      final errorMessage = ref.read(orderProvider).errorMessage;
      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: errorMessage.isNotEmpty
            ? 'فشل إتمام الاوردر: $errorMessage'
            : 'فشل إتمام الاوردر',
        icon: Icons.error,
        isError: true,
        color: customTheme.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final isLoading = ref.watch(orderProvider).isLoading;
    final isProcessing = isLoading || _isUploadingImage;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: customTheme.background,
        body: Container(
          decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(customTheme, isProcessing),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            widget.order.title,
                            style: GoogleFonts.cairo(
                              color: customTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أرفق صورة الفاتورة وأدخل السعر لإتمام الاوردر',
                            style: GoogleFonts.cairo(
                              color: customTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const SectionHeader(title: 'صورة الفاتورة'),
                          const SizedBox(height: 16),
                          
                          // Show warning if no image is selected
                          if (_showImageWarning && _billPhoto == null && !_isUploadingImage)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: customTheme.errorColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: customTheme.errorColor
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: customTheme.errorColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'لم تقم بإرفاق صورة الفاتورة. يمكنك إرفاق صورة أو استخدام زر "إكمال بدون صورة"',
                                      style: GoogleFonts.cairo(
                                        color: customTheme.errorColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Show image preview or upload indicator
                          if (_isUploadingImage)
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: customTheme.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: customTheme.primaryBlue
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimationWidget.loadingAnimation(40),
                                  const SizedBox(height: 16),
                                  Text(
                                    'جاري رفع الصورة...',
                                    style: GoogleFonts.cairo(
                                      color: customTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_billPhoto != null) ...[
                            _BillPhotoPreview(
                              image: FileImage(_billPhoto!),
                              onRemove: isProcessing
                                  ? null
                                  : () => setState(() {
                                        _billPhoto = null;
                                        _isFromCamera = false;
                                        _showImageWarning = false;
                                      }),
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          InkWell(
                            onTap: isProcessing
                                ? null
                                : () => _showPhotoSourceSheet(customTheme),
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                color: customTheme.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: customTheme.primaryBlue
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isUploadingImage)
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: customTheme.primaryBlue,
                                        ),
                                      )
                                    else
                                      Icon(
                                        _billPhoto == null
                                            ? Icons.add_a_photo_rounded
                                            : Icons.edit_rounded,
                                        color: customTheme.primaryBlue,
                                        size: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isUploadingImage
                                          ? 'جاري رفع الصورة...'
                                          : (_billPhoto == null
                                              ? 'إضافة صورة الفاتورة'
                                              : 'تغيير الصورة'),
                                      style: GoogleFonts.cairo(
                                        color: customTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const SectionHeader(title: 'السعر'),
                          const SizedBox(height: 16),
                          IgnorePointer(
                            ignoring: isProcessing,
                            child: Opacity(
                              opacity: isProcessing ? 0.7 : 1.0,
                              child: FormTextField(
                                controller: _priceController,
                                label: 'السعر (جنيه)',
                                icon: Icons.payments_outlined,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال السعر';
                                  }
                                  final parsed = int.tryParse(value.trim());
                                  if (parsed == null || parsed <= 0) {
                                    return 'يرجى إدخال سعر صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSubmitButtons(customTheme, isProcessing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CustomThemeExtension customTheme, bool isProcessing) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: isProcessing ? null : () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: customTheme.textPrimary,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: customTheme.textPrimary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'إتمام الاوردر',
            style: GoogleFonts.cairo(
              color: customTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButtons(CustomThemeExtension customTheme, bool isProcessing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: customTheme.background.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: customTheme.textPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Main submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: customTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: isProcessing ? null : () => _submit(customTheme),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isProcessing
                    ? AnimationWidget.loadingAnimation(24)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.task_alt_rounded,
                              color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'إتمام الاوردر',
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
          
          const SizedBox(height: 12),
          
          // Submit without image button (only shown when no image is selected and not uploading)
          if (_billPhoto == null && !_isUploadingImage)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: isProcessing ? null : () => _submitWithoutImage(customTheme),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: customTheme.textSecondary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.skip_next_rounded,
                      color: customTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إكمال بدون صورة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: customTheme.textSecondary,
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
}

class _BillPhotoPreview extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback? onRemove;

  const _BillPhotoPreview({required this.image, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: customTheme.textPrimary.withValues(alpha: 0.1),
            ),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: customTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}