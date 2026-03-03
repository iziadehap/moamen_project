import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_provider.dart';
import 'package:moamen_project/features/adminDashbord/presentation/transaction_screen.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:moamen_project/features/adminDashbord/presentation/widgets/user_card.dart';
import 'package:moamen_project/features/adminDashbord/presentation/widgets/sort_options.dart';

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

    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, customTheme),
              _buildFilters(ref, adminState, customTheme),
              Expanded(
                child: adminState.isLoading
                    ? Center(child: AnimationWidget.loadingAnimation(24))
                    : _buildUserList(filteredUsers, customTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CustomThemeExtension customTheme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: customTheme.textPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: customTheme.textPrimary,
                          size: 18,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'لوحة التحكم',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: customTheme.textSecondary,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              'إدارة المستخدمين',
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: customTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionScreen(),
                      ),
                    ),
                    icon: Icon(
                      Icons.receipt_long_rounded,
                      color: customTheme.textPrimary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: customTheme.textPrimary.withOpacity(
                        0.05,
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: 'سجل المعاملات',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => showSortOptions(context, ref),
                    icon: Icon(
                      Icons.sort_rounded,
                      color: customTheme.textPrimary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: customTheme.textPrimary.withOpacity(
                        0.05,
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(customTheme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(CustomThemeExtension customTheme) {
    return Container(
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            ref.read(adminProvider.notifier).setSearchQuery(value),
        style: TextStyle(color: customTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو رقم الهاتف...',
          hintStyle: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: customTheme.textSecondary,
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

  Widget _buildFilters(
    WidgetRef ref,
    dynamic state,
    CustomThemeExtension customTheme,
  ) {
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
                customTheme: customTheme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'مدير',
                isSelected: state.filterRole == SupabaseAccountTyps.admin,
                onTap: () => ref
                    .read(adminProvider.notifier)
                    .setFilterRole(SupabaseAccountTyps.admin),
                customTheme: customTheme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'مستخدم',
                isSelected: state.filterRole == SupabaseAccountTyps.user,
                onTap: () => ref
                    .read(adminProvider.notifier)
                    .setFilterRole(SupabaseAccountTyps.user),
                customTheme: customTheme,
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
                customTheme: customTheme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'نشط',
                isSelected: state.filterStatus == true,
                onTap: () =>
                    ref.read(adminProvider.notifier).setFilterStatus(true),
                customTheme: customTheme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'معطل',
                isSelected: state.filterStatus == false,
                onTap: () =>
                    ref.read(adminProvider.notifier).setFilterStatus(false),
                customTheme: customTheme,
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
    required CustomThemeExtension customTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? customTheme.primaryBlue
              : customTheme.textPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? customTheme.primaryBlue
                : customTheme.textPrimary.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : customTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<UserModel> users,
    CustomThemeExtension customTheme,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد مستخدمين يطابقون البحث',
          style: GoogleFonts.cairo(color: customTheme.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: users.length,
      itemBuilder: (context, index) => UserCard(user: users[index]),
    );
  }
}
