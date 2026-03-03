import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/app_config_data.dart';
import 'package:moamen_project/core/utils/fake_email.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/widgets/custom_snackbar.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_provider.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:moamen_project/core/widgets/open_phone_number.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const UserDetailsScreen({super.key, required this.user});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  late TextEditingController maxOrdersController;
  late bool isActive;
  late bool isAdmin;
  int addedOrders = 0;

  @override
  void initState() {
    super.initState();
    maxOrdersController = TextEditingController(
      text: widget.user.maxOrders.toString(),
    );
    isActive = widget.user.isActive;
    isAdmin = widget.user.role == SupabaseAccountTyps.admin;
  }

  @override
  void dispose() {
    maxOrdersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Scaffold(
      backgroundColor: customTheme.background,
      appBar: AppBar(
        title: Text(
          'تفاصيل المستخدم',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: customTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: customTheme.textPrimary),
        actions: [
          IconButton(
            onPressed: () => _showDeleteConfirm(customTheme),
            icon: Icon(Icons.delete_rounded, color: customTheme.errorColor),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Center(
                child: widget.user.imageUrl != null
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(widget.user.imageUrl!),
                      )
                    : CircleAvatar(
                        backgroundColor:
                            (isAdmin
                                    ? customTheme.primaryPurple
                                    : customTheme.primaryBlue)
                                .withOpacity(0.2),
                        radius: 40,
                        child: Icon(
                          isAdmin
                              ? Icons.admin_panel_settings_rounded
                              : Icons.person_rounded,
                          color: isAdmin
                              ? customTheme.primaryPurple
                              : customTheme.primaryBlue,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.user.name ?? 'بدون اسم',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: customTheme.textPrimary,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoBadge(
                      label: isAdmin ? 'مدير' : 'مستخدم',
                      color: isAdmin
                          ? customTheme.primaryPurple
                          : customTheme.primaryBlue,
                      customTheme: customTheme,
                    ),
                    _buildInfoBadge(
                      label: isActive ? 'نشط' : 'معطل',
                      color: isActive
                          ? customTheme.statusGreen
                          : customTheme.errorColor,
                      isOutline: false,
                      customTheme: customTheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'المعلومات الأساسية',
                style: GoogleFonts.cairo(
                  color: customTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildReadOnlyField(
                'الاسم',
                widget.user.name ?? 'بدون اسم',
                customTheme,
              ),
              const SizedBox(height: 12),
              OpenPhoneNumber(
                phone: widget.user.phone,
                child: _buildReadOnlyField(
                  'الهاتف',
                  widget.user.phone,
                  customTheme,
                  isPhone: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                'تاريخ الانضمام',
                dateFormat.format(widget.user.createdAt),
                customTheme,
              ),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                'ID الخاص بالمستخدم',
                widget.user.id,
                customTheme,
              ),

              const SizedBox(height: 32),
              Text(
                'إعدادات الحساب',
                style: GoogleFonts.cairo(
                  color: customTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildMaxOrders(customTheme),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: customTheme.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: customTheme.textPrimary.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  children: [
                    if (!isAdmin) ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'حالة الحساب',
                          style: GoogleFonts.cairo(
                            color: customTheme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          isActive
                              ? "نشط (يمكنه استخدام التطبيق)"
                              : "معطل (لا يمكنه الدخول)",
                          style: GoogleFonts.cairo(
                            color: isActive
                                ? customTheme.statusGreen
                                : customTheme.errorColor,
                            fontSize: 12,
                          ),
                        ),
                        value: isActive,
                        onChanged: (val) {
                          setState(() {
                            isActive = val;
                          });
                        },
                        activeColor: customTheme.statusGreen,
                      ),
                      Divider(color: customTheme.textPrimary.withOpacity(0.1)),
                    ],
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'تعيين كمسؤول (Admin)',
                        style: GoogleFonts.cairo(
                          color: customTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        isAdmin ? "يمتلك صلاحيات كاملة" : "مستخدم عادي",
                        style: GoogleFonts.cairo(
                          color: isAdmin
                              ? customTheme.primaryPurple
                              : customTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      value: isAdmin,
                      onChanged: (val) async {
                        if (val) {
                          bool confirmed =
                              await _showPasswordConfirmation(customTheme) ??
                              false;
                          if (confirmed) {
                            setState(() {
                              isAdmin = true;
                              isActive = true;
                            });
                          }
                        } else {
                          // Try to disable admin
                          bool confirmed =
                              await _showPasswordConfirmation(customTheme) ??
                              false;
                          if (confirmed) {
                            setState(() {
                              isAdmin = false;
                            });
                          }
                        }
                      },
                      activeColor: customTheme.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: customTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: customTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _confirmAndSave(customTheme),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'حفظ التعديلات',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmAndSave(CustomThemeExtension customTheme) {
    List<String> changes = [];

    if (isActive != widget.user.isActive) {
      changes.add('حالة الحساب: ${isActive ? 'نشط' : 'معطل'}');
    }
    if (isAdmin != (widget.user.role == SupabaseAccountTyps.admin)) {
      changes.add('نوع الحساب: ${isAdmin ? 'مسؤول' : 'مستخدم'}');
    }
    if (addedOrders > 0) {
      changes.add('إضافة طلبات: +$addedOrders');
    } else if (addedOrders < 0) {
      changes.add('إزالة طلبات: ${addedOrders.abs()}-');
    }

    if (changes.isEmpty) {
      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: 'لا توجد تعديلات لحفظها',
        icon: Icons.info,
        color: customTheme.statusOrange,
      );

      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customTheme.background,
        title: Text(
          'تأكيد التعديلات',
          style: GoogleFonts.cairo(
            color: customTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من حفظ التغييرات التالية؟',
              style: GoogleFonts.cairo(color: customTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ...changes.map(
              (change) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: customTheme.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      change,
                      style: GoogleFonts.cairo(
                        color: customTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: customTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close confirm dialog
              _executeSave(customTheme); // actually save
            },
            child: Text(
              'حفظ',
              style: GoogleFonts.cairo(
                color: customTheme.statusGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _executeSave(CustomThemeExtension customTheme) {
    final auth = ref.read(authProvider);
    if (auth.user != null) {
      final updated = UserModel(
        id: widget.user.id,
        phone: widget.user.phone,
        name: widget.user.name,
        role: isAdmin ? SupabaseAccountTyps.admin : SupabaseAccountTyps.user,
        maxOrders:
            int.tryParse(maxOrdersController.text) ?? widget.user.maxOrders,
        createdAt: widget.user.createdAt,
        isActive: isActive,
      );
      ref.read(adminProvider.notifier).updateUser(widget.user.id, updated);
      showCustomSnackBar(
        context,
        customTheme: customTheme,
        message: 'تم حفظ التعديلات',
        icon: Icons.check_circle,
        color: customTheme.statusGreen,
      );
    }
    Navigator.pop(context);
  }

  void _showDeleteConfirm(CustomThemeExtension customTheme) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customTheme.background,
        title: Text(
          'حذف المستخدم',
          style: GoogleFonts.cairo(color: customTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من حذف ${widget.user.name}؟ لا يمكن التراجع عن هذا الإجراء.',
              style: GoogleFonts.cairo(color: customTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              passController,
              'كلمة المرور',
              customTheme,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: customTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (passController.text.isEmpty) return;
              bool isSame = await AppConfigData().verifyBigBossPassword(
                passController.text,
              );
              if (isSame) {
                final auth = ref.read(authProvider);
                if (auth.user != null) {
                  ref
                      .read(adminProvider.notifier)
                      .deleteUser(auth.user!.id, widget.user.id);
                }
                if (mounted) {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // return to list
                }
              } else {
                if (mounted) {
                  showCustomSnackBar(
                    context,
                    customTheme: customTheme,
                    message: 'كلمة المرور غير صحيحة',
                    icon: Icons.error,
                    color: customTheme.errorColor,
                  );
                }
              }
            },
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(color: customTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPasswordConfirmation(CustomThemeExtension customTheme) {
    final passController = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customTheme.background,
        title: Text(
          'تأكيد الصلاحية',
          style: GoogleFonts.cairo(color: customTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'يرجى إدخال كلمة المرور لتأكيد تعيين هذا المستخدم كمسؤول.',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              passController,
              'كلمة المرور',
              customTheme,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: customTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              bool isSame = await AppConfigData().verifyBigBossPassword(
                passController.text,
              );
              if (passController.text.isNotEmpty && isSame) {
                Navigator.pop(context, true);
              } else {
                showCustomSnackBar(
                  context,
                  customTheme: customTheme,
                  message: 'كلمة المرور غير صحيحة',
                  icon: Icons.error,
                  isError: true,
                  color: customTheme.errorColor,
                );
              }
            },
            child: Text(
              'تأكيد',
              style: GoogleFonts.cairo(color: customTheme.primaryBlue),
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
    required CustomThemeExtension customTheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOutline ? color.withOpacity(0.1) : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: isOutline ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMaxOrders(CustomThemeExtension customTheme) {
    final int oldOrders = widget.user.maxOrders;
    final int newOrders = oldOrders + addedOrders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'أقصى عدد للطلبات (Max Orders)',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showMinusOrdersDialog(customTheme),
                  icon: const Icon(Icons.remove, size: 16),
                  label: Text('إزالة', style: GoogleFonts.cairo(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customTheme.errorColor.withOpacity(0.2),
                    foregroundColor: customTheme.errorColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddOrdersDialog(customTheme),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text('إضافة', style: GoogleFonts.cairo(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customTheme.primaryBlue.withOpacity(0.2),
                    foregroundColor: customTheme.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: customTheme.textPrimary.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: customTheme.textPrimary.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الطلبات السابقة: $oldOrders',
                style: GoogleFonts.cairo(
                  color: customTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (addedOrders != 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      addedOrders > 0
                          ? 'عدد المضاف: $addedOrders+'
                          : 'عدد المخصوم: ${addedOrders.abs()}-',
                      style: GoogleFonts.cairo(
                        color: addedOrders > 0
                            ? customTheme.statusGreen
                            : customTheme.errorColor,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          addedOrders = 0;
                          maxOrdersController.text = widget.user.maxOrders
                              .toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: customTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.close,
                          color: customTheme.errorColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Divider(color: customTheme.textPrimary.withOpacity(0.1)),
              const SizedBox(height: 4),
              Text(
                'الإجمالي الجديد: $newOrders',
                style: GoogleFonts.cairo(
                  color: customTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMinusOrdersDialog(CustomThemeExtension customTheme) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customTheme.background,
        title: Text(
          'إزالة طلبات',
          style: GoogleFonts.cairo(color: customTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'كم عدد الطلبات التي تريد إزالتها؟',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              amountController,
              'عدد الطلبات',
              customTheme,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: customTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final int amount = int.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                final int currentTotal = widget.user.maxOrders + addedOrders;
                if (currentTotal - amount < 0) {
                  showCustomSnackBar(
                    context,
                    customTheme: customTheme,
                    message: 'لا يمكن أن يكون الإجمالي أقل من صفر',
                    icon: Icons.error,
                    isError: true,
                    color: customTheme.errorColor,
                  );
                  return;
                }
                setState(() {
                  addedOrders -= amount;
                  maxOrdersController.text =
                      (widget.user.maxOrders + addedOrders).toString();
                });
              }
              Navigator.pop(context);
            },
            child: Text(
              'إزالة',
              style: GoogleFonts.cairo(color: customTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrdersDialog(CustomThemeExtension customTheme) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customTheme.background,
        title: Text(
          'إضافة طلبات',
          style: GoogleFonts.cairo(color: customTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'كم عدد الطلبات التي تريد إضافتها؟',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              amountController,
              'عدد الطلبات',
              customTheme,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: customTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final int amount = int.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                setState(() {
                  addedOrders += amount;
                  maxOrdersController.text =
                      (widget.user.maxOrders + addedOrders).toString();
                });
              }
              Navigator.pop(context);
            },
            child: Text(
              'إضافة',
              style: GoogleFonts.cairo(color: customTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(
    String label,
    String value,
    CustomThemeExtension customTheme, {
    bool isPhone = false,
  }) {
    print('phone: $value');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: customTheme.textPrimary.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: customTheme.textPrimary.withOpacity(0.08),
            ),
          ),
          //win is phone add underline bule
          child: isPhone
              ? Text(
                  PhoneToEmailConverter.reutrnPhoneFromEmailWithoutCountryCode(
                    value,
                  ),
                  style: GoogleFonts.cairo(
                    color: customTheme.primaryBlue,
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                    decorationColor: customTheme.primaryBlue,
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.cairo(
                    color: customTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    CustomThemeExtension customTheme, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: customTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          color: customTheme.textSecondary,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: customTheme.textPrimary.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: customTheme.primaryBlue),
        ),
        filled: true,
        fillColor: customTheme.textPrimary.withOpacity(0.05),
      ),
    );
  }
}
