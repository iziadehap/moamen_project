import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:moamen_project/core/utils/images.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moamen_project/core/theme/app_theme.dart';

class CardList extends StatefulWidget {
  final VoidCallback ontap;
  final Widget child;
  final List<String> images;
  // final Widget content;

  // final Order order;
  // final bool isSelectionMode;

  const CardList({
    super.key,
    // required this.order,
    required this.images,
    // required this.content,
    required this.child,
    required this.ontap,
    // this.isSelectionMode = false,
  });

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  int _currentIndex = 0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            customTheme.textPrimary.withOpacity(0.05),
            customTheme.textPrimary.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
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
                  color: customTheme.cardBackground.withOpacity(0.8),
                  border: Border.all(
                    color: customTheme.textPrimary.withOpacity(0.08),
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
                      customTheme.primaryBlue.withOpacity(0.1),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.images.isNotEmpty) ...[
                        _buildImageCarousel(customTheme),
                        const SizedBox(width: 16),
                      ],
                      Expanded(child: widget.child),
                      // Content
                      // contant_widget(),
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

  Widget _buildImageCarousel(CustomThemeExtension customTheme) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            items: widget.images.map((e) {
              return ClipRRect(
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
                      : customTheme.textSecondary.withOpacity(0.2),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
