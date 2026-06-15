import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/images.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class CardList extends StatefulWidget {
  final VoidCallback ontap;
  final Widget child;
  final List<String> images;
  final Order? order; // Add order parameter
  final bool showBillButton; // Option to show bill button

  const CardList({
    super.key,
    required this.images,
    required this.child,
    required this.ontap,
    this.order,
    this.showBillButton = true,
  });

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  int _currentIndex = 0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenImageViewer(imageUrl: imageUrl),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showBillImage(BuildContext context, String billUrl) {
    _showFullScreenImage(context, billUrl);
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            customTheme.textPrimary.withValues(alpha: 0.05),
            customTheme.textPrimary.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
            ),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: customTheme.cardBackground.withValues(alpha: 0.8),
                  border: Border.all(
                    color: customTheme.textPrimary.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      customTheme.primaryBlue.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.ontap();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.images.isNotEmpty) ...[
                            _buildImageCarousel(customTheme),
                            const SizedBox(width: 16),
                          ],
                          Expanded(child: widget.child),
                        ],
                      ),
                      // Show price and bill button if order exists
                      if (widget.order != null && widget.order!.price != null)
                        const SizedBox(height: 12),
                      if (widget.order != null && widget.order!.price != null)
                        _buildPriceAndBillSection(customTheme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndBillSection(CustomThemeExtension customTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: customTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: customTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price section
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: customTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'السعر:',
                  style: TextStyle(
                    color: customTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.order!.price} جنيه',
                  style: TextStyle(
                    color: customTheme.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Bill button (only if billUrl exists and showBillButton is true)
          if (widget.showBillButton && widget.order!.billUrl != null && widget.order!.billUrl!.isNotEmpty)
          
            GestureDetector(
              onTap: () => _showBillImage(context, widget.order!.billUrl!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: customTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: customTheme.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: customTheme.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'عرض الفاتورة',
                      style: TextStyle(
                        color: customTheme.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(CustomThemeExtension customTheme) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            items: widget.images.map((e) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, e),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: e,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 120,
                    placeholder: (context, url) => BuildImagesShimmerEffect(),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 120,
              viewportFraction: 1.0,
              initialPage: _currentIndex,
              enableInfiniteScroll: widget.images.length > 1,
              autoPlay: widget.images.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          if (widget.images.length > 1) ...[
            const SizedBox(height: 8),
            _buildDotsIndicator(widget.images.length, width: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int count, {double width = 70}) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return SizedBox(
      width: width,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (index) {
              final isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: isActive ? 6 : 4,
                height: isActive ? 6 : 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? customTheme.primaryGradient.colors[0]
                      : customTheme.textSecondary.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Full Screen Image Viewer Widget
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: customTheme.errorColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'فشل في تحميل الصورة',
                      style: TextStyle(
                        color: customTheme.errorColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}