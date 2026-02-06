import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_provider.dart';
import '../../data/priceList_model.dart';
import '../controller/priceList_provider.dart';

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
    final adminId = ref.read(authProvider).user?.id;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: لم يتم العثور على بيانات المشرف')),
      );
      return;
    }

    if (isEdit) {
      await ref
          .read(priceProvider.notifier)
          .updatePriceItem(
            adminId: adminId,
            priceId: widget.service!.id,
            title: _titleController.text,
            price: price,
            description: _descriptionController.text,
            isActive: _isActive,
          );
    } else {
      await ref
          .read(priceProvider.notifier)
          .addPriceItem(
            adminId: adminId,
            title: _titleController.text,
            price: price,
            description: _descriptionController.text,
            isActive: _isActive,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceState = ref.watch(priceProvider);

    ref.listen(priceProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'تم تعديل الخدمة بنجاح' : 'تم إضافة الخدمة بنجاح',
            ),
            backgroundColor: Colors.green,
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
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isEdit ? 'تعديل الخدمة' : 'إضافة خدمة جديدة',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        _buildLabel('اسم الخدمة'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hint: 'مثال: توصيل سريع داخل المدينة',
                          icon: Icons.title_rounded,
                          validator: (v) =>
                              v!.isEmpty ? 'اسم الخدمة مطلوب' : null,
                        ),

                        const SizedBox(height: 20),

                        _buildLabel('السعر (ج.م)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _priceController,
                          hint: 'مثال: 50.0',
                          icon: Icons.attach_money_rounded,
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

                        _buildLabel('الوصف'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          hint: 'اكتب وصفاً مختصراً للخدمة...',
                          icon: Icons.description_outlined,
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
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isActive
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: _isActive
                                    ? AppColors.statusGreen
                                    : AppColors.textGrey,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'حالة الخدمة',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _isActive
                                          ? 'الخدمة تظهر للعملاء'
                                          : 'الخدمة مخفية عن العملاء',
                                      style: GoogleFonts.cairo(
                                        color: AppColors.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isActive,
                                activeColor: AppColors.statusGreen,
                                onChanged: (value) {
                                  setState(() => _isActive = value);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Save Button
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E66F6), Color(0xFF8B47FA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF2E66F6,
                                ).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: priceState.isLoading ? null : _savePrice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: priceState.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    isEdit ? 'حفظ التعديلات' : 'حفظ الخدمة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 16),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: AppColors.darkCard,
        prefixIcon: Icon(icon, color: AppColors.textGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
