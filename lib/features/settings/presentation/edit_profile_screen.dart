import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'riverpod/setting_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final settingState = ref.watch(settingProvider);
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    // Listen for success
    ref.listen(settingProvider, (previous, next) {
      if (next.isSuccess == true) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث الملف الشخصي بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: customTheme.statusGreen,
          ),
        );
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: GoogleFonts.cairo()),
            backgroundColor: customTheme.errorColor,
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
                        Icons.arrow_back_rounded,
                        color: customTheme.textPrimary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: customTheme.textPrimary.withOpacity(
                          0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'تعديل الملف الشخصي',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: customTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Profile Image
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: customTheme.primaryBlue.withOpacity(0.5),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: customTheme.primaryBlue.withOpacity(
                                    0.2,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: customTheme.cardBackground,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (user?.imageUrl != null
                                            ? NetworkImage(user!.imageUrl!)
                                            : null)
                                        as ImageProvider?,
                              child:
                                  (_imageFile == null && user?.imageUrl == null)
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: customTheme.textSecondary
                                          .withOpacity(0.2),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: customTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: customTheme.background,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Name Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الاسم بالكامل',
                            style: GoogleFonts.cairo(
                              color: customTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: customTheme.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: customTheme.textPrimary.withOpacity(0.1),
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              style: GoogleFonts.cairo(
                                color: customTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'أدخل اسمك هنا',
                                hintStyle: GoogleFonts.cairo(
                                  color: customTheme.textSecondary.withOpacity(
                                    0.3,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: customTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: customTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: customTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: settingState.isLoading
                                ? null
                                : () {
                                    ref
                                        .read(settingProvider.notifier)
                                        .updateProfile(
                                          name: _nameController.text.trim(),
                                          imageFile: _imageFile,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: settingState.isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: AnimationWidget.loadingAnimation(24),
                                  )
                                : Text(
                                    'حفظ التغييرات',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
