import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/core/utils/privcy_cash.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_provider.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:intl/intl.dart';

class AdminDash extends ConsumerStatefulWidget {
  const AdminDash({super.key});

  @override
  ConsumerState<AdminDash> createState() => _AdminDashState();
}

class _AdminDashState extends ConsumerState<AdminDash> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).fetchUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final notifier = ref.read(adminProvider.notifier);
    final filteredUsers = notifier.filteredUsers;

    ref.listen(adminProvider, (previous, next) {
      if (next.error.isNotEmpty && next.error != previous?.error) {
        print(next.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error,
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildFilters(ref, adminState),
              Expanded(
                child: adminState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : _buildUserList(filteredUsers),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لوحة التحكم',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        'إدارة المستخدمين',
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showSortOptions(context),
                icon: const Icon(Icons.sort_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            ref.read(adminProvider.notifier).setSearchQuery(value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو رقم الهاتف...',
          hintStyle: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textGrey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(WidgetRef ref, dynamic state) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'الكل',
                isSelected: state.filterRole == null,
                onTap: () =>
                    ref.read(adminProvider.notifier).setFilterRole(null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'مدير',
                isSelected: state.filterRole == SupabaseAccountTyps.admin,
                onTap: () => ref
                    .read(adminProvider.notifier)
                    .setFilterRole(SupabaseAccountTyps.admin),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'مستخدم',
                isSelected: state.filterRole == SupabaseAccountTyps.user,
                onTap: () => ref
                    .read(adminProvider.notifier)
                    .setFilterRole(SupabaseAccountTyps.user),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'كل الحالات',
                isSelected: state.filterStatus == null,
                onTap: () =>
                    ref.read(adminProvider.notifier).setFilterStatus(null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'نشط',
                isSelected: state.filterStatus == true,
                onTap: () =>
                    ref.read(adminProvider.notifier).setFilterStatus(true),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'معطل',
                isSelected: state.filterStatus == false,
                onTap: () =>
                    ref.read(adminProvider.notifier).setFilterStatus(false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد مستخدمين يطابقون البحث',
          style: GoogleFonts.cairo(color: AppColors.textGrey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: users.length,
      itemBuilder: (context, index) => _UserCard(user: users[index]),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.midnightNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ترتيب حسب',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortItem(
              icon: Icons.calendar_today_rounded,
              label: 'تاريخ الإنشاء',
              value: 'created_at',
            ),
            _buildSortItem(
              icon: Icons.person_rounded,
              label: 'الاسم',
              value: 'name',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final currentSort = ref.watch(adminProvider).sortBy;
    final isSelected = currentSort == value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
      ),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          color: isSelected ? Colors.white : AppColors.textGrey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
          : null,
      onTap: () {
        ref.read(adminProvider.notifier).setSortBy(value);
        Navigator.pop(context);
      },
    );
  }
}

class _UserCard extends ConsumerWidget {
  final UserModel user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = user.role == SupabaseAccountTyps.admin;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            leading: CircleAvatar(
              backgroundColor:
                  (isAdmin ? AppColors.primaryPurple : AppColors.primaryBlue)
                      .withOpacity(0.2),
              radius: 25,
              child: Icon(
                isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded,
                color: isAdmin
                    ? AppColors.primaryPurple
                    : AppColors.primaryBlue,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'بدون اسم',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Role Badge
                    _buildInfoBadge(
                      label: isAdmin ? 'مدير' : 'مستخدم',
                      color: isAdmin
                          ? AppColors.primaryPurple
                          : AppColors.primaryBlue,
                    ),
                    // Status Badge
                    _buildInfoBadge(
                      label: user.isActive ? 'نشط' : 'معطل',
                      color: user.isActive ? AppColors.statusGreen : Colors.red,
                      isOutline: false,
                    ),
                    // Max Orders Badge
                    _buildInfoBadge(
                      label: 'طلبات: ${user.maxOrders}',
                      color: AppColors.textGrey,
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconText(Icons.phone_rounded, user.phone),
                  const SizedBox(height: 4),
                  _buildIconText(
                    Icons.access_time_rounded,
                    dateFormat.format(user.createdAt),
                  ),
                  const SizedBox(height: 4),
                  _buildIconText(
                    Icons.fingerprint_rounded,
                    'ID: ${user.id}',
                    fontSize: 10,
                  ),
                ],
              ),
            ),
            trailing: PopupMenuButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textGrey,
              ),
              color: AppColors.midnightNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              itemBuilder: (context) => [
                _buildMenuItem(Icons.edit_rounded, 'تعديل', Colors.white),
                _buildMenuItem(Icons.delete_rounded, 'حذف', Colors.redAccent),
              ],
              onSelected: (value) {
                if (value == 'حذف') {
                  _showDeleteConfirm(context, ref);
                } else if (value == 'تعديل') {
                  _showEditDialog(context, ref);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required String label,
    required Color color,
    bool isOutline = true,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOutline ? color.withOpacity(0.1) : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: isOutline ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, {double fontSize = 12}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              color: AppColors.textGrey,
              fontSize: fontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.midnightNavy,
        title: Text(
          'حذف المستخدم',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Text(
          'هل أنت متأكد من حذف ${user.name}؟',
          style: GoogleFonts.cairo(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              final auth = ref.read(authProvider);
              if (auth.user != null) {
                ref
                    .read(adminProvider.notifier)
                    .deleteUser(auth.user!.id, user.id);
              }
              Navigator.pop(context);
            },
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    // Backend ignores Name/Phone updates, so we don't edit them.
    final maxOrdersController = TextEditingController(
      text: user.maxOrders.toString(),
    );
    bool isActive = user.isActive;
    bool isAdmin = user.role == SupabaseAccountTyps.admin;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.midnightNavy,
          title: Text(
            'تعديل المستخدم',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadOnlyField('الاسم', user.name ?? 'بدون اسم'),
                const SizedBox(height: 12),
                _buildReadOnlyField('الهاتف', user.phone),
                const SizedBox(height: 16),
                _buildTextField(
                  maxOrdersController,
                  'أقصى عدد للطلبات',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'حالة الحساب',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          isActive
                              ? "نشط (يمكنه استخدام التطبيق)"
                              : "معطل (لا يمكنه الدخول)",
                          style: GoogleFonts.cairo(
                            color: isActive
                                ? AppColors.statusGreen
                                : Colors.redAccent,
                            fontSize: 11,
                          ),
                        ),
                        value: isActive,
                        onChanged: (val) {
                          setState(() {
                            isActive = val;
                            // If we disable account, we must remove admin access too
                            if (!val) isAdmin = false;
                          });
                        },
                        activeColor: AppColors.statusGreen,
                      ),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'تعيين كمسؤول (Admin)',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          isAdmin ? "يمتلك صلاحيات كاملة" : "مستخدم عادي",
                          style: GoogleFonts.cairo(
                            color: isAdmin
                                ? AppColors.primaryPurple
                                : AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                        value: isAdmin,
                        onChanged: (val) async {
                          if (val) {
                            // Trying to enable admin
                            bool confirmed =
                                await _showPasswordConfirmation(context) ??
                                false;
                            if (confirmed) {
                              setState(() {
                                isAdmin = true;
                                isActive = true; // Auto-activate
                              });
                            }
                          } else {
                            // Trying to disable admin - Prevented
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'لا يمكن إلغاء صلاحيات المسؤول',
                                  style: GoogleFonts.cairo(color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        activeColor: AppColors.primaryPurple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textGrey),
              ),
            ),
            TextButton(
              onPressed: () {
                final auth = ref.read(authProvider);
                if (auth.user != null) {
                  final updated = UserModel(
                    id: user.id,
                    phone: user.phone, // Sending existing phone
                    name: user.name, // Sending existing name
                    role: isAdmin
                        ? SupabaseAccountTyps.admin
                        : SupabaseAccountTyps.user,
                    maxOrders:
                        int.tryParse(maxOrdersController.text) ??
                        user.maxOrders,
                    createdAt: user.createdAt,
                    isActive: isActive,
                  );
                  ref
                      .read(adminProvider.notifier)
                      .updateUser(auth.user!.id, user.id, updated);
                }
                Navigator.pop(context);
              },
              child: Text(
                'حفظ',
                style: GoogleFonts.cairo(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showPasswordConfirmation(BuildContext context) {
    final passController = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.midnightNavy,
        title: Text(
          'تأكيد الصلاحية',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'يرجى إدخال كلمة المرور لتأكيد تعيين هذا المستخدم كمسؤول.',
              style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildTextField(passController, 'كلمة المرور', obscureText: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement real password check here if needed.
              // For now, we just require any input or specific hardcoded check if requested.
              // The user request said "show pop to enter password".
              bool isSame = await PrivcyCash.comparePassword(
                passController.text,
              );
              if (passController.text.isNotEmpty && isSame) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'كلمة المرور غير صحيحة',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'تأكيد',
              style: GoogleFonts.cairo(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            value,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  PopupMenuItem _buildMenuItem(IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: label,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.cairo(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
