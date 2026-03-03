import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/widgets/build_images_heder.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/pricelist/data/priceList_model.dart';
import 'package:moamen_project/features/pricelist/presentation/controller/priceList_provider.dart';
import 'package:moamen_project/features/pricelist/presentation/screens/add_price_list_screen.dart';
import '../../../../core/theme/app_theme.dart';

class PriceDetailScreen extends ConsumerStatefulWidget {
  final PriceListModel priceItem;

  const PriceDetailScreen({super.key, required this.priceItem});

  @override
  ConsumerState<PriceDetailScreen> createState() => _PriceDetailScreenState();
}

class _PriceDetailScreenState extends ConsumerState<PriceDetailScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';
    final priceState = ref.watch(priceProvider);
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    // Find the latest version of this item in the global state
    final currentItem = priceState.pricelist.firstWhere(
      (e) => e.id == widget.priceItem.id,
      orElse: () => widget.priceItem,
    );

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, customTheme),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header or Price Box
                        currentItem.photoUrls.isNotEmpty
                            ? BuildImagesHeder(
                                photoUrls: currentItem.photoUrls,
                                // hasPrice: true,
                                price: currentItem.price,
                              )
                            : _buildPriceBox(currentItem, customTheme),

                        const SizedBox(height: 32),

                        // Service Title
                        _buildSectionLabel('اسم الخدمة', customTheme),
                        const SizedBox(height: 8),
                        _buildInfoContainer(
                          currentItem.title,
                          customTheme,
                          isTitle: true,
                        ),

                        const SizedBox(height: 24),

                        // Description
                        _buildSectionLabel('الوصف', customTheme),
                        const SizedBox(height: 8),
                        _buildInfoContainer(
                          currentItem.description,
                          customTheme,
                        ),

                        const SizedBox(height: 24),

                        // Status
                        if (isAdmin) ...[
                          _buildSectionLabel('حالة الخدمة', customTheme),
                          const SizedBox(height: 8),
                          _buildStatusBadge(currentItem.isActive, customTheme),
                        ],

                        if (isAdmin) ...[
                          const SizedBox(height: 40),
                          _buildAdminActions(
                            context,
                            ref,
                            currentItem,
                            customTheme,
                          ),
                        ],
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

  // Widget _buildImageHeader(PriceListModel item) {
  //   return Container(
  //     height: 300,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(32),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.3),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(32),
  //       child: Stack(
  //         children: [
  //           CarouselSlider(
  //             carouselController: _carouselController,
  //             items: item.photoUrls.map((url) {
  //               return Image.network(
  //                 url,
  //                 width: double.infinity,
  //                 height: 300,
  //                 fit: BoxFit.cover,
  //               );
  //             }).toList(),
  //             options: CarouselOptions(
  //               height: 300,
  //               viewportFraction: 1.0,
  //               initialPage: 0,
  //               enableInfiniteScroll: item.photoUrls.length > 1,
  //               autoPlay: item.photoUrls.length > 1,
  //               autoPlayInterval: const Duration(seconds: 4),
  //               onPageChanged: (index, reason) {
  //                 setState(() {
  //                   _currentIndex = index;
  //                 });
  //               },
  //             ),
  //           ),
  //           // Gradient Overlay
  //           IgnorePointer(
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                   colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           // Price Badge (Glassmorphism)
  //           Positioned(
  //             bottom: 24,
  //             left: 24,
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 20,
  //                 vertical: 12,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(20),
  //                 border: Border.all(color: Colors.white.withOpacity(0.2)),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     '${item.price.toStringAsFixed(0)}',
  //                     style: GoogleFonts.cairo(
  //                       color: Colors.white,
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.w900,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Text(
  //                     'ج.م',
  //                     style: GoogleFonts.cairo(
  //                       color: Colors.white70,
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           // Carousel Indicators
  //           if (item.photoUrls.length > 1)
  //             Positioned(
  //               bottom: 24,
  //               right: 24,
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: item.photoUrls.asMap().entries.map((entry) {
  //                   return GestureDetector(
  //                     onTap: () => _carouselController.animateToPage(entry.key),
  //                     child: Container(
  //                       width: _currentIndex == entry.key ? 24 : 8,
  //                       height: 8,
  //                       margin: const EdgeInsets.symmetric(horizontal: 4),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(4),
  //                         color: Colors.white.withOpacity(
  //                           _currentIndex == entry.key ? 0.9 : 0.4,
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPriceBox(PriceListModel item, CustomThemeExtension customTheme) {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              customTheme.primaryBlue.withOpacity(0.3),
              customTheme.primaryPurple.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: customTheme.primaryBlue.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${item.price.toStringAsFixed(0)}',
              style: GoogleFonts.cairo(
                color: customTheme.textPrimary,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'جنيه مصري',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, CustomThemeExtension customTheme) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        color: customTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoContainer(
    String text,
    CustomThemeExtension customTheme, {
    bool isTitle = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.08)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: isTitle ? customTheme.textPrimary : customTheme.textSecondary,
          fontSize: isTitle ? 18 : 15,
          fontWeight: isTitle ? FontWeight.w800 : FontWeight.normal,
          height: isTitle ? 1.2 : 1.6,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, CustomThemeExtension customTheme) {
    final color = isActive
        ? customTheme.successColor
        : customTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'نشط' : 'معطل',
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(
    BuildContext context,
    WidgetRef ref,
    PriceListModel currentItem,
    CustomThemeExtension customTheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: customTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPriceListScreen(service: currentItem),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'تعديل',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: customTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: customTheme.errorColor.withOpacity(0.3)),
          ),
          child: IconButton(
            onPressed: () => _showDeleteDialog(context, ref, customTheme),
            icon: Icon(
              Icons.delete_rounded,
              color: customTheme.errorColor,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, CustomThemeExtension customTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: customTheme.background.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: customTheme.textPrimary.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: customTheme.textPrimary,
              size: 18,
            ),
            style: IconButton.styleFrom(
              backgroundColor: customTheme.textPrimary.withOpacity(0.05),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: customTheme.textPrimary.withOpacity(0.1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'تفاصيل الخدمة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: customTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    CustomThemeExtension customTheme,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'حذف الخدمة',
          style: GoogleFonts.cairo(
            color: customTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${widget.priceItem.title}"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: GoogleFonts.cairo(color: customTheme.textSecondary),
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
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: customTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await ref
          .read(priceProvider.notifier)
          .deletePriceItem(priceId: widget.priceItem.id);
      if (context.mounted) {
        Navigator.pop(context); // Go back to list after deletion
      }
    }
  }
}
