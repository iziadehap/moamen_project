import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/fake_email.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/open_phone_number.dart';
import 'package:moamen_project/features/adminDashbord/data/transaction_model.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_provider.dart';
import 'package:moamen_project/features/adminDashbord/presentation/transaction_details_screen.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  String? _selectedType; // null = all

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminProvider.notifier).fetchTransactions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final state = ref.watch(adminProvider);
    final all = List<TransactionModel>.from(state.transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final filtered = _selectedType == null
        ? all
        : all.where((t) => t.type == _selectedType).toList();

    // Stats
    final totalAdd = all
        .where(
          (t) =>
              t.type == TransactionType.adminAdd ||
              t.type == TransactionType.purchase,
        )
        .fold<int>(0, (sum, t) => sum + t.amount.abs());
    final totalRemove = all
        .where(
          (t) =>
              t.type == TransactionType.adminRemove ||
              t.type == TransactionType.usage,
        )
        .fold<int>(0, (sum, t) => sum + t.amount.abs());

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, customTheme),
              _buildStatsRow(all.length, totalAdd, totalRemove, customTheme),
              _buildFilterChips(customTheme),
              const SizedBox(height: 4),
              Expanded(
                child: state.isLoading
                    ? Center(child: AnimationWidget.loadingAnimation(24))
                    : state.error.isNotEmpty
                    ? _buildError(state.error, customTheme)
                    : filtered.isEmpty
                    ? _buildEmpty(customTheme)
                    : _buildList(filtered, customTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, CustomThemeExtension customTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: customTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: customTheme.textPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) =>
                customTheme.primaryGradient.createShader(bounds),
            child: Text(
              'سجل المعاملات',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () =>
                ref.read(adminProvider.notifier).fetchTransactions(),
            style: IconButton.styleFrom(
              backgroundColor: customTheme.primaryBlue.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.refresh_rounded,
              color: customTheme.primaryBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow(
    int count,
    int totalAdd,
    int totalRemove,
    CustomThemeExtension customTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          _statCard(
            'الإجمالي',
            '$count',
            Icons.receipt_long_rounded,
            customTheme.primaryBlue,
            customTheme,
          ),
          const SizedBox(width: 10),
          _statCard(
            'مضاف',
            '+$totalAdd',
            Icons.trending_up_rounded,
            customTheme.statusGreen,
            customTheme,
          ),
          const SizedBox(width: 10),
          _statCard(
            'محذوف',
            '-$totalRemove',
            Icons.trending_down_rounded,
            customTheme.errorColor,
            customTheme,
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    CustomThemeExtension customTheme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: customTheme.cardBackground.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    color: customTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: customTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────────────────────

  Widget _buildFilterChips(CustomThemeExtension customTheme) {
    final types = [
      (null, 'الكل', customTheme.primaryBlue),
      (TransactionType.adminAdd, 'إضافة نقاط ', customTheme.statusGreen),
      (TransactionType.adminRemove, 'حذف نقاط', customTheme.errorColor),
      // (TransactionType.purchase, 'شراء نقاط', AppColors.primaryPurple),
      (TransactionType.usage, 'استخدام نقاط', customTheme.statusCyan),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (val, label, color) = types[i];
          final selected = _selectedType == val;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.2)
                    : customTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? color
                      : customTheme.textPrimary.withOpacity(0.07),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  color: selected ? color : customTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── List ────────────────────────────────────────────────────────────────────

  Widget _buildList(
    List<TransactionModel> transactions,
    CustomThemeExtension customTheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: transactions.length,
      itemBuilder: (_, i) => _TransactionCard(
        transaction: transactions[i],
        customTheme: customTheme,
      ),
    );
  }

  // ─── Empty / Error ────────────────────────────────────────────────────────────

  Widget _buildEmpty(CustomThemeExtension customTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: customTheme.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد معاملات',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, CustomThemeExtension customTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: customTheme.errorColor.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'حدث خطأ',
              style: GoogleFonts.cairo(
                color: customTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction Card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final CustomThemeExtension customTheme;
  const _TransactionCard({
    required this.transaction,
    required this.customTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _typeConfig(transaction.type, customTheme);
    final dateFormat = DateFormat('yyyy/MM/dd  HH:mm');
    final isPositive =
        transaction.type == TransactionType.adminAdd ||
        transaction.type == TransactionType.purchase;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailsScreen(transaction: transaction),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: customTheme.cardBackground.withOpacity(0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cfg.color.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              // Profile & Badge Slot
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cfg.color.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: cfg.color.withOpacity(0.1),
                      backgroundImage: transaction.userProfile?.imageUrl != null
                          ? NetworkImage(transaction.userProfile!.imageUrl!)
                          : null,
                      child: transaction.userProfile?.imageUrl == null
                          ? Icon(
                              Icons.person_rounded,
                              color: cfg.color,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cfg.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: customTheme.cardBackground,
                          width: 2,
                        ),
                      ),
                      child: Icon(cfg.icon, color: Colors.white, size: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.userProfile?.name ?? 'بدون اسم',
                      style: GoogleFonts.cairo(
                        color: customTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (transaction.userProfile != null)
                      OpenPhoneNumber(
                        phone: transaction.userProfile!.phone,
                        child: Text(
                          PhoneToEmailConverter.reutrnPhoneFromEmailWithoutCountryCode(
                            transaction.userProfile!.phone,
                          ),
                          style: GoogleFonts.cairo(
                            color: customTheme.primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '${cfg.label} • ${dateFormat.format(transaction.createdAt)}',
                      style: GoogleFonts.cairo(
                        color: customTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    if (transaction.adminProfile != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 10,
                            color: customTheme.primaryPurple.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'بواسطة: ${transaction.adminProfile!.name ?? "أدمن"}',
                              style: GoogleFonts.cairo(
                                color: customTheme.primaryPurple.withOpacity(
                                  0.6,
                                ),
                                fontSize: 9,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount & Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: cfg.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cfg.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${isPositive ? '+' : '-'}${transaction.amount.abs()}',
                      style: GoogleFonts.cairo(
                        color: cfg.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${transaction.balanceBefore}',
                        style: GoogleFonts.cairo(
                          color: customTheme.textSecondary.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                      Icon(
                        Icons.arrow_right_rounded,
                        size: 14,
                        color: customTheme.textSecondary.withOpacity(0.4),
                      ),
                      Text(
                        '${transaction.balanceAfter}',
                        style: GoogleFonts.cairo(
                          color: customTheme.textPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TypeConfig _typeConfig(String type, CustomThemeExtension customTheme) {
    switch (type) {
      case TransactionType.adminAdd:
        return _TypeConfig(
          label: 'إضافة بواسطة أدمن',
          icon: Icons.add_circle_rounded,
          color: customTheme.statusGreen,
        );
      case TransactionType.adminRemove:
        return _TypeConfig(
          label: 'حذف بواسطة أدمن',
          icon: Icons.remove_circle_rounded,
          color: customTheme.errorColor,
        );
      case TransactionType.purchase:
        return _TypeConfig(
          label: 'شراء',
          icon: Icons.shopping_cart_rounded,
          color: customTheme.primaryPurple,
        );
      case TransactionType.usage:
        return _TypeConfig(
          label: 'استخدام',
          icon: Icons.bolt_rounded,
          color: customTheme.statusCyan,
        );
      default:
        return _TypeConfig(
          label: type,
          icon: Icons.swap_horiz_rounded,
          color: customTheme.textSecondary,
        );
    }
  }
}

class _TypeConfig {
  final String label;
  final IconData icon;
  final Color color;
  const _TypeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
