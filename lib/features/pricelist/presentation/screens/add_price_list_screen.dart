import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/priceList_model.dart';
import '../controller/priceList_provider.dart';
import '../widgets/widgets.dart';

class AddPriceListScreen extends ConsumerStatefulWidget {
  final PriceListModel? service;
  const AddPriceListScreen({super.key, this.service});

  @override
  ConsumerState<AddPriceListScreen> createState() => _AddPriceListScreenState();
}

class _AddPriceListScreenState extends ConsumerState<AddPriceListScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _isActive = true;

  bool get isEdit => widget.service != null;

  bool get _hasChanges {
    final state = ref.read(priceProvider);
    if (!isEdit) {
      return _titleController.text.isNotEmpty ||
          _priceController.text.isNotEmpty ||
          state.localPhotos.isNotEmpty;
    }
    final s = widget.service!;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    return _titleController.text != s.title ||
        price != s.price ||
        _descriptionController.text != s.description ||
        _isActive != s.isActive ||
        state.localPhotos.isNotEmpty ||
        state.photoUrls.length != s.photoUrls.length ||
        state.photoUrls.any((url) => !s.photoUrls.contains(url));
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service?.title);
    _priceController = TextEditingController(
      text: widget.service?.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.service?.description,
    );
    _isActive = widget.service?.isActive ?? true;

    // Initialize photo state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(priceProvider.notifier)
          .setPhotoUrls(widget.service?.photoUrls ?? []);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _savePrice() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final notifier = ref.read(priceProvider.notifier);
    final state = ref.read(priceProvider);

    // 1. Upload new photos if any
    List<String> newUrls = [];
    if (state.localPhotos.isNotEmpty) {
      newUrls = await notifier.uploadAllPhotos();
      if (newUrls.isEmpty && state.localPhotos.isNotEmpty) {
        // Error already handled in notifier
        return;
      }
    }

    // 2. Combine with existing photos
    final totalPhotoUrls = [...state.photoUrls, ...newUrls];

    if (isEdit) {
      await notifier.updatePriceItem(
        priceId: widget.service!.id,
        title: _titleController.text,
        price: price,
        description: _descriptionController.text,
        photoUrls: totalPhotoUrls,
        isActive: _isActive,
      );
    } else {
      await notifier.addPriceItem(
        title: _titleController.text,
        price: price,
        description: _descriptionController.text,
        photoUrls: totalPhotoUrls,
        isActive: _isActive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceState = ref.watch(priceProvider);
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    ref.listen(priceProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'تم تعديل الخدمة بنجاح' : 'تم إضافة الخدمة بنجاح',
            ),
            backgroundColor: customTheme.statusGreen,
          ),
        );
        ref.read(priceProvider.notifier).resetActionState();
        Navigator.pop(context);
      } else if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: customTheme.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isEdit ? 'تعديل الخدمة' : 'إضافة خدمة جديدة',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: customTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel('اسم الخدمة', customTheme),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hint: 'مثال: توصيل سريع داخل المدينة',
                          icon: Icons.title_rounded,
                          customTheme: customTheme,
                          onChanged: (_) => setState(() {}),
                          validator: (v) =>
                              v!.isEmpty ? 'اسم الخدمة مطلوب' : null,
                        ),

                        const SizedBox(height: 20),

                        _buildLabel('السعر (ج.م)', customTheme),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _priceController,
                          hint: 'مثال: 50.0',
                          icon: Icons.attach_money_rounded,
                          customTheme: customTheme,
                          onChanged: (_) => setState(() {}),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return 'السعر مطلوب';
                            if (double.tryParse(v) == null)
                              return 'أدخل رقم صحيح';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        _buildLabel('الوصف', customTheme),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          hint: 'اكتب وصفاً مختصراً للخدمة...',
                          icon: Icons.description_outlined,
                          customTheme: customTheme,
                          onChanged: (_) => setState(() {}),
                          maxLines: 4,
                          validator: (v) => v!.isEmpty ? 'الوصف مطلوب' : null,
                        ),

                        const SizedBox(height: 24),

                        // Is Active Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: customTheme.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: customTheme.textPrimary.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isActive
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: _isActive
                                    ? customTheme.successColor
                                    : customTheme.textSecondary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'حالة الخدمة',
                                      style: GoogleFonts.cairo(
                                        color: customTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _isActive
                                          ? 'الخدمة تظهر للعملاء'
                                          : 'الخدمة مخفية عن العملاء',
                                      style: GoogleFonts.cairo(
                                        color: customTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isActive,
                                activeColor: customTheme.successColor,
                                onChanged: (value) {
                                  setState(() => _isActive = value);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        uplodePhotoWidget(),
                        const SizedBox(height: 60),

                        // Save Button
                        Builder(
                          builder: (context) {
                            final isEnabled =
                                !priceState.isLoading &&
                                (!isEdit || _hasChanges);
                            return Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: isEnabled
                                    ? customTheme.primaryGradient
                                    : LinearGradient(
                                        colors: [
                                          customTheme.textSecondary.withOpacity(
                                            0.2,
                                          ),
                                          customTheme.textSecondary.withOpacity(
                                            0.1,
                                          ),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: isEnabled
                                    ? [
                                        BoxShadow(
                                          color: customTheme.primaryBlue
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ElevatedButton(
                                onPressed: isEnabled ? _savePrice : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: priceState.isLoading
                                    ?  Center(
                                        child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child:
                                              AnimationWidget.loadingAnimation(
                                                24,
                                              )
                                        ),
                                      )
                                    : Text(
                                        isEdit ? 'حفظ التعديلات' : 'حفظ السعر ',
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildLabel(String text, CustomThemeExtension customTheme) {
    return Text(
      text,
      style: GoogleFonts.cairo(color: customTheme.textSecondary, fontSize: 16),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required CustomThemeExtension customTheme,
    int maxLines = 1,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: customTheme.textPrimary),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: customTheme.textPrimary.withOpacity(0.3)),
        filled: true,
        fillColor: customTheme.cardBackground,
        prefixIcon: Icon(icon, color: customTheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: customTheme.textPrimary.withOpacity(0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: customTheme.primaryBlue, width: 2),
        ),
      ),
    );
  }
}
