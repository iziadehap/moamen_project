import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/images.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/auth/presentation/login_screen.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:moamen_project/features/settings/data/settings_provider.dart';
import 'package:moamen_project/features/adminDashbord/presentation/admin_dash.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _avatarController;
  late final Animation<double> _avatarScale;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _avatarScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 18, end: 38).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.role == SupabaseAccountTyps.admin;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: customTheme.accentGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Compact Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حسابي',
                                style: GoogleFonts.cairo(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: customTheme.textPrimary,
                                  letterSpacing: -1.1,
                                ),
                              ),
                              Text(
                                'مرحباً بعودتك',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.5,
                                  color: customTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          _LuxeHeaderButton(
                            icon: HeroIcons.cog_6_tooth,
                            onTap: () =>
                                _showSettingsSheet(context, ref, customTheme),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Smaller Avatar
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (_, __) => Container(
                                width: 138,
                                height: 138,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.55,
                                      ),
                                      blurRadius: _glowAnimation.value,
                                      spreadRadius: 6,
                                    ),
                                    BoxShadow(
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.45),
                                      blurRadius: _glowAnimation.value * 0.75,
                                      spreadRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ScaleTransition(
                              scale: _avatarScale,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.primaryPurple,
                                      AppColors.primaryBlue,
                                    ],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 54,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,

                                  backgroundImage: user?.imageUrl == null
                                      ? null
                                      : CachedNetworkImageProvider(
                                          user!.imageUrl!,
                                          
                                        ),

                                  child: user?.imageUrl == null
                                      ? const Icon(
                                          HeroIcons.user,
                                          size: 54,
                                          color: Colors.white24,
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: user!.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 120,
                                            placeholder: (context, url) =>
                                                BuildImagesShimmerEffect(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            // Live dot
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      ShaderMask(
                        shaderCallback: (b) => LinearGradient(
                          colors: [
                            customTheme.textPrimary,
                            AppColors.primaryPurple,
                          ],
                        ).createShader(b),
                        child: Text(
                          user?.name ?? 'مستخدم',
                          style: GoogleFonts.cairo(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LuxeBadge(
                            label: isAdmin ? 'مدير النظام' : 'مستخدم',
                            icon: isAdmin
                                ? HeroIcons.shield_check
                                : HeroIcons.user,
                            color: isAdmin
                                ? AppColors.primaryPurple
                                : AppColors.primaryBlue,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: customTheme.cardBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'معلومات',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 19,
                                        ),
                                      ),

                                      Lottie.asset(
                                        'assets/animation/hi_animathion.json',
                                        width: 50,
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    isAdmin
                                        ? 'أنت مدير النظاميمكنك تعديل جميع البيانات واضافه أي بيانات تريدها'
                                        : 'أنت مستخدم يمكنك تعديل بياناتك فقط وقبول طلبات',
                                    style: GoogleFonts.cairo(
                                      color: customTheme.textSecondary,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('حسنا'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _LuxeBadge(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: customTheme.cardBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'معلومات',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 19,
                                        ),
                                      ),

                                      Lottie.asset(
                                        'assets/animation/hi_animathion.json',
                                        width: 50,
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'هذا العدد هو أقصى عدد من الطلبات التي يمكنك قبولها',
                                    style: GoogleFonts.cairo(
                                      color: customTheme.textSecondary,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('حسنا'),
                                    ),
                                  ],
                                ),
                              );
                            },

                            label: '${user?.maxOrders ?? 0} طلبات',
                            icon: HeroIcons.shopping_cart,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Compact Floating Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _LuxeProfileCard(
                        title: 'تعديل الملف الشخصي',
                        subtitle: 'الاسم • الصورة • البيانات',
                        icon: HeroIcons.user_circle,
                        color: AppColors.primaryBlue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                      ),
                      if (isAdmin)
                        _LuxeProfileCard(
                          title: 'لوحة التحكم',
                          subtitle: 'إدارة المستخدمين والطلبات',
                          icon: HeroIcons.squares_2x2,
                          color: AppColors.primaryPurple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDash(),
                            ),
                          ),
                        ),
                      _LuxeProfileCard(
                        title: 'تسجيل الخروج',
                        subtitle: 'الخروج الآمن',
                        icon: HeroIcons.arrow_right_on_rectangle,
                        color: Colors.redAccent,
                        isLast: true,
                        onTap: () => _showLogoutDialog(context, ref),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: customTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'تأكيد الخروج',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 19),
        ),
        content: Text(
          'هل تريد تسجيل الخروج؟',
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 14.5,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'خروج',
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(
    BuildContext context,
    WidgetRef ref,
    CustomThemeExtension customTheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: customTheme.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'الإعدادات',
                style: GoogleFonts.cairo(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              _LuxeSettingTile(
                title: 'الوضع الليلي',
                icon: isDark ? HeroIcons.moon : HeroIcons.sun,
                color: AppColors.primaryPurple,
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeProvider.notifier).toggleTheme(),
                  activeColor: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== COMPACT LUXE COMPONENTS ======================

class _LuxeHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _LuxeHeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withOpacity(0.12),
                AppColors.primaryPurple.withOpacity(0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.25),
            ),
          ),
          child: Icon(icon, color: customTheme.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _LuxeBadge extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final Color color;
  const _LuxeBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.13), color.withOpacity(0.06)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxeProfileCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLast;

  const _LuxeProfileCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLast = false,
  });

  @override
  State<_LuxeProfileCard> createState() => _LuxeProfileCardState();
}

class _LuxeProfileCardState extends State<_LuxeProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(
      begin: 1.0,
      end: 0.965,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return ScaleTransition(
      scale: _tapScale,
      child: GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) => _tapController.reverse().then((_) => widget.onTap()),
        onTapCancel: () => _tapController.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.11),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: customTheme.textPrimary,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          color: customTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  HeroIcons.chevron_left,
                  color: customTheme.textPrimary.withOpacity(0.35),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxeSettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget trailing;

  const _LuxeSettingTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: customTheme.cardBackground.withOpacity(0.65),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
