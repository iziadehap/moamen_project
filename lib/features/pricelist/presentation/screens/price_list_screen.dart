import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/build_buttons.dart';
import 'package:moamen_project/core/widgets/card_list.dart';
import 'package:moamen_project/features/pricelist/data/priceList_model.dart';
import 'package:moamen_project/features/pricelist/presentation/controller/priceList_provider.dart';
import 'package:moamen_project/features/pricelist/presentation/screens/add_price_list_screen.dart';
import 'package:moamen_project/features/pricelist/presentation/screens/price_detail_screen.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/pricelist/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_theme.dart';

class PriceListScreen extends ConsumerStatefulWidget {
  const PriceListScreen({super.key});

  @override
  ConsumerState<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends ConsumerState<PriceListScreen> {
  bool _hasFetched = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched) {
        ref.read(priceProvider.notifier).getPricelist();
        _hasFetched = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';
    final priceState = ref.watch(priceProvider);
    final priceNotifier = ref.read(priceProvider.notifier);
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Scaffold(
      backgroundColor: customTheme.background,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(
                  context,
                  priceNotifier,
                  isAdmin,
                  priceState.pricelist.length,
                  customTheme,
                ),
                _buildSearchBar(customTheme),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: _buildBody(
                      context,
                      priceState,
                      priceNotifier,
                      isAdmin,
                      customTheme,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: isAdmin
      //     ? SafeArea(child: _buildAddButton(context))
      //     : null,
    );
  }

  // Widget _buildAddButton(BuildContext context) {
  //   return SafeArea(
  //     child: Container(
  //       padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
  //       decoration: BoxDecoration(
  //         color: AppColors.midnightNavy.withOpacity(0.8),
  //         border: const Border(top: BorderSide(color: Colors.white10)),
  //       ),
  //       child: SizedBox(
  //         width: double.infinity,
  //         height: 56,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             gradient: AppColors.primaryGradient,
  //             borderRadius: BorderRadius.circular(16),
  //             boxShadow: AppColors.glowShadow,
  //           ),
  //           child: ElevatedButton(
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => const AddPriceListScreen(),
  //                 ),
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.transparent,
  //               shadowColor: Colors.transparent,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Icon(Icons.add_rounded, color: Colors.white),
  //                 const SizedBox(width: 12),
  //                 Text(
  //                   'إضافة خدمة جديدة',
  //                   style: GoogleFonts.cairo(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildHeader(
    BuildContext context,
    dynamic notifier,
    bool isAdmin,
    int count,
    CustomThemeExtension customTheme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(color: customTheme.background.withOpacity(0.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'قائمة الأسعار',
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: customTheme.textPrimary,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: customTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: customTheme.primaryBlue.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '$count خدمة',
                        style: GoogleFonts.cairo(
                          color: customTheme.primaryBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'تصفح وابحث عن الخدمات والأسعار',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: customTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (isAdmin) ...[
            BuildButtons(
              ontap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPriceListScreen(),
                ),
              ),
              icon: Icons.add,
            ),
            const SizedBox(width: 12),
          ],
          // BuildButtons(
          //   ontap: () => notifier.getPricelist(),
          //   icon: Icons.refresh_rounded,
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(CustomThemeExtension customTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.cairo(color: customTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'ابحث عن خدمة...',
          hintStyle: GoogleFonts.cairo(color: customTheme.textSecondary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: customTheme.primaryBlue,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: customTheme.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: customTheme.textPrimary.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
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
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic state,
    dynamic notifier,
    bool isAdmin,
    CustomThemeExtension customTheme,
  ) {
    if (state.isLoading && state.pricelist.isEmpty) {
      return Center(child: AnimationWidget.loadingAnimation(24));
    }

    if (state.error != null && state.pricelist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: GoogleFonts.cairo(
                color: customTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                state.error ?? 'حدث خطأ غير متوقع',
                style: GoogleFonts.cairo(
                  color: customTheme.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => notifier.getPricelist(),
              style: ElevatedButton.styleFrom(
                backgroundColor: customTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final filteredList = state.pricelist.where((item) {
      final title = item.title.toLowerCase();
      final description = item.description.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_outlined,
              color: customTheme.textSecondary.withOpacity(0.3),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'لم يتم العثور على نتائج'
                  : 'لا توجد خدمات حالياً',
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => notifier.getPricelist(),
      color: customTheme.primaryBlue,
      backgroundColor: customTheme.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final priceItem = filteredList[index];
          return _PriceListItem(priceItem: priceItem, isAdmin: isAdmin);
        },
      ),
    );
  }
}

class _PriceListItem extends ConsumerStatefulWidget {
  final PriceListModel priceItem;
  final bool isAdmin;

  const _PriceListItem({required this.priceItem, required this.isAdmin});

  @override
  ConsumerState<_PriceListItem> createState() => _PriceListItemState();
}

class _PriceListItemState extends ConsumerState<_PriceListItem> {
  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return CardList(
      images: widget.priceItem.photoUrls,
      ontap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PriceDetailScreen(priceItem: widget.priceItem),
          ),
        );
      },
      child: price_list_item_widget(
        context,
        widget.priceItem,
        widget.isAdmin,
        customTheme,
      ),
    );
  }
}
