import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/custom_snackbar.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'riverpod/setting_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _nameController;

  // Initial value to detect changes
  late final String _initialName;

  late final AnimationController _fadeController;
  late final AnimationController _avatarPulseController;
  late final AnimationController _slideController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _avatarPulseAnimation;
  late final Animation<Offset> _slideAnimation;

  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isImageChanged = false;
  bool _isNameFocused = false;

  // ✅ Prevent showing snackbars multiple times
  bool _handledSuccessOnce = false;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authProvider).user;
    _initialName = (user?.name ?? '').trim();
    _nameController = TextEditingController(text: _initialName);

    // ✅ Rebuild when name changes so button enable state updates
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _avatarPulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _avatarPulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _avatarPulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _isImageChanged = true;
    });
  }

  void _onSave() {
    ref
        .read(settingProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          imageFile: _imageFile,
          isImageChanged: _isImageChanged,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final settingState = ref.watch(settingProvider);
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    // ✅ Detect if user changed name
    final currentName = _nameController.text.trim();
    final bool isNameChanged = currentName != _initialName;

    // ✅ Button enabled if anything changed + not loading
    final bool canSave =
        !settingState.isLoading && (isNameChanged || _isImageChanged);

    // ✅ Keep listen in build, but guard against repeated success handling
    ref.listen(settingProvider, (previous, next) {
      if (!context.mounted) return;

      if (next.isSuccess == true && !_handledSuccessOnce) {
        _handledSuccessOnce = true;

        showCustomSnackBar(
          context,
          customTheme: customTheme,
          message: 'تم تحديث الملف الشخصي بنجاح',
          icon: Icons.check_circle_rounded,
          color: customTheme.statusGreen,
        );
        Navigator.pop(context);
        return;
      }

      final failure = next.failureInEditScreen;
      if (failure != null) {
        showCustomSnackBar(
          context,
          customTheme: customTheme,
          message: failure.message,
          icon: Icons.error_outline_rounded,
          color: customTheme.errorColor,
          isError: true,
        );
      }
    });

    final ImageProvider? avatarProvider = _imageFile != null
        ? FileImage(_imageFile!)
        : (user?.imageUrl != null ? NetworkImage(user!.imageUrl!) : null);

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(customTheme),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildAvatarSection(
                            avatarProvider: avatarProvider,
                            customTheme: customTheme,
                          ),
                          const SizedBox(height: 48),
                          _buildNameInput(customTheme),
                          const SizedBox(height: 48),
                          _buildSaveButton(
                            settingState: settingState,
                            customTheme: customTheme,
                            isDisabled: !canSave,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
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

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(CustomThemeExtension customTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _GlassButton(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_rounded,
              color: customTheme.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'تعديل الملف الشخصي',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: customTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Avatar ────────────────────────────────────────────────────────────────

  Widget _buildAvatarSection({
    required ImageProvider? avatarProvider,
    required CustomThemeExtension customTheme,
  }) {
    return Column(
      children: [
        ScaleTransition(
          scale: _avatarPulseAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      customTheme.primaryBlue.withOpacity(0.25),
                      customTheme.primaryBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      customTheme.primaryBlue.withOpacity(0.8),
                      customTheme.primaryBlue.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: CircleAvatar(
                    backgroundColor: customTheme.cardBackground,
                    backgroundImage: avatarProvider,
                    child: avatarProvider == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 56,
                            color: customTheme.textSecondary.withOpacity(0.25),
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          customTheme.primaryBlue,
                          customTheme.primaryBlue.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: customTheme.background,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: customTheme.primaryBlue.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isImageChanged) ...[
          const SizedBox(height: 12),
          _AnimatedBadge(
            label: 'صورة جديدة محددة ✓',
            color: customTheme.statusGreen,
          ),
        ],
      ],
    );
  }

  // ─── Name Input ─────────────────────────────────────────────────────────────

  Widget _buildNameInput(CustomThemeExtension customTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 10),
          child: Text(
            'الاسم بالكامل',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Focus(
          onFocusChange: (focused) => setState(() => _isNameFocused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: customTheme.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isNameFocused
                    ? customTheme.primaryBlue.withOpacity(0.6)
                    : customTheme.textPrimary.withOpacity(0.08),
                width: _isNameFocused ? 1.5 : 1,
              ),
              boxShadow: _isNameFocused
                  ? [
                      BoxShadow(
                        color: customTheme.primaryBlue.withOpacity(0.12),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: TextField(
              controller: _nameController,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.cairo(
                color: customTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'أدخل اسمك هنا',
                hintStyle: GoogleFonts.cairo(
                  color: customTheme.textSecondary.withOpacity(0.35),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 17,
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: _isNameFocused
                      ? customTheme.primaryBlue
                      : customTheme.textSecondary.withOpacity(0.5),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Save Button ────────────────────────────────────────────────────────────

  Widget _buildSaveButton({
    required dynamic settingState,
    required CustomThemeExtension customTheme,
    required bool isDisabled,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.55 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDisabled
                ? LinearGradient(
                    colors: [Colors.grey.shade600, Colors.grey.shade700],
                  )
                : customTheme.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: customTheme.primaryBlue.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled ? null : _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: settingState.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: AnimationWidget.loadingAnimation(24),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'حفظ التغييرات',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
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

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _GlassButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.onTap, required this.child});

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(10),
        transform: Matrix4.identity()..scale(_pressed ? 0.93 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: widget.child,
      ),
    );
  }
}

class _AnimatedBadge extends StatefulWidget {
  final String label;
  final Color color;

  const _AnimatedBadge({required this.label, required this.color});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.color.withOpacity(0.3)),
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.cairo(
            color: widget.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
