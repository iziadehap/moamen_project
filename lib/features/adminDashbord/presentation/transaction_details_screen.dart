import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/fake_email.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/widgets/build_images_heder.dart';
import 'package:moamen_project/core/widgets/open_phone_number.dart';
import 'package:moamen_project/features/adminDashbord/data/transaction_model.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final dateFormat = DateFormat('yyyy/MM/dd  HH:mm:ss');
    final isPositive =
        transaction.type == TransactionType.adminAdd ||
        transaction.type == TransactionType.purchase;
    final color = isPositive ? customTheme.statusGreen : customTheme.errorColor;
    final label = _getLabel(transaction.type);

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, customTheme),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (transaction.order?.photoUrls != null &&
                        transaction.order!.photoUrls.isNotEmpty) ...[
                      BuildImagesHeder(photoUrls: transaction.order!.photoUrls),
                      const SizedBox(height: 20),
                    ],
                    _buildMainCard(
                      isPositive,
                      color,
                      label,
                      dateFormat,
                      customTheme,
                    ),
                    const SizedBox(height: 20),
                    _buildTransactionFlow(context, customTheme),
                    if (transaction.order != null) ...[
                      const SizedBox(height: 16),
                      _buildOrderSection(customTheme),
                    ],
                    const SizedBox(height: 16),
                    _buildTechnicalSection(customTheme),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CustomThemeExtension customTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          Text(
            'تفاصيل المعاملة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: customTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(
    bool isPositive,
    Color color,
    String label,
    DateFormat df,
    CustomThemeExtension customTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: customTheme.cardBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add_chart_rounded : Icons.area_chart_rounded,
              color: color,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${isPositive ? '+' : '-'}${transaction.amount.abs()}',
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: customTheme.textPrimary.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat(
                'الرصيد قبل',
                '${transaction.balanceBefore}',
                customTheme,
              ),
              Container(
                width: 1,
                height: 30,
                color: customTheme.textPrimary.withOpacity(0.1),
              ),
              _buildSimpleStat(
                'الرصيد بعد',
                '${transaction.balanceAfter}',
                customTheme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            df.format(transaction.createdAt),
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
    String label,
    String value,
    CustomThemeExtension customTheme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: customTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionFlow(
    BuildContext context,
    CustomThemeExtension customTheme,
  ) {
    final admin = transaction.adminProfile;
    final user = transaction.userProfile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: customTheme.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFlowParticipant(
                profile: admin,
                label: 'الأدمن',
                color: customTheme.primaryPurple,
                isMissing: admin == null,
                customTheme: customTheme,
              ),
              Icon(
                Icons.double_arrow_rounded,
                color: customTheme.primaryBlue.withOpacity(0.5),
                size: 24,
              ),
              if (user != null)
                _buildAvatarInfo(
                  user,
                  'المستخدم',
                  customTheme.primaryBlue,
                  customTheme,
                ),
            ],
          ),
          if (admin != null) ...[
            const SizedBox(height: 20),
            Divider(color: customTheme.textPrimary.withOpacity(0.1), height: 1),
            const SizedBox(height: 16),
            _buildProfileDetails(
              admin,
              'الأدمن المسؤول',
              customTheme.primaryPurple,
              customTheme,
            ),
          ],
          if (user != null) ...[
            const SizedBox(height: 16),
            if (admin != null)
              Divider(
                color: customTheme.textPrimary.withOpacity(0.1),
                height: 1,
              ),
            const SizedBox(height: 16),
            _buildProfileDetails(
              user,
              'ملف المستخدم',
              customTheme.primaryBlue,
              customTheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlowParticipant({
    UserModel? profile,
    required String label,
    required Color color,
    required bool isMissing,
    required CustomThemeExtension customTheme,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            backgroundImage: (!isMissing && profile?.imageUrl != null)
                ? NetworkImage(profile!.imageUrl!)
                : null,
            child: (isMissing || profile?.imageUrl == null)
                ? Icon(
                    isMissing
                        ? Icons.help_outline_rounded
                        : Icons.person_rounded,
                    color: color,
                    size: 30,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isMissing ? 'غير معروف' : (profile?.name ?? 'بدون اسم'),
          style: GoogleFonts.cairo(
            color: customTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: color.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarInfo(
    UserModel profile,
    String label,
    Color color,
    CustomThemeExtension customTheme,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            backgroundImage: profile.imageUrl != null
                ? NetworkImage(profile.imageUrl!)
                : null,
            child: profile.imageUrl == null
                ? Icon(Icons.person_rounded, color: color, size: 30)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.name ?? 'بدون اسم',
          style: GoogleFonts.cairo(
            color: customTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: color.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(
    UserModel profile,
    String title,
    Color color,
    CustomThemeExtension customTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.contact_page_rounded, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name ?? 'بدون اسم',
                    style: GoogleFonts.cairo(
                      color: customTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  OpenPhoneNumber(
                    phone: profile.phone,
                    child: Text(
                      PhoneToEmailConverter.reutrnPhoneFromEmailWithoutCountryCode(
                        profile.phone,
                      ),
                      style: GoogleFonts.cairo(
                        color: customTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: color.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'ID: ${profile.id.substring(0, 8)}...',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSection(CustomThemeExtension customTheme) {
    final order = transaction.order!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customTheme.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: customTheme.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                color: customTheme.primaryBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'تفاصيل الطلب',
                style: GoogleFonts.cairo(
                  color: customTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: customTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.name,
                  style: GoogleFonts.cairo(
                    color: customTheme.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.title,
            style: GoogleFonts.cairo(
              color: customTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${order.id}',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSection(CustomThemeExtension customTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customTheme.cardBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code_rounded,
                color: customTheme.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'بيانات تقنية',
                style: GoogleFonts.cairo(
                  color: customTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _techRow('رقم المعاملة (UUID)', transaction.id, customTheme),
          if (transaction.idempotencyKey != null) ...[
            const SizedBox(height: 8),
            _techRow(
              'Idempotency Key',
              transaction.idempotencyKey!,
              customTheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _techRow(
    String label,
    String value,
    CustomThemeExtension customTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 10,
          ),
        ),
        SelectableText(
          value,
          style: GoogleFonts.sourceCodePro(
            color: customTheme.textPrimary.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _getLabel(String type) {
    switch (type) {
      case TransactionType.adminAdd:
        return 'إضافة بواسطة أدمن';
      case TransactionType.adminRemove:
        return 'حذف بواسطة أدمن';
      case TransactionType.purchase:
        return 'شراء';
      case TransactionType.usage:
        return 'استخدام';
      default:
        return type;
    }
  }
}
