import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/screens/full_screen_images.dart';
import 'package:moamen_project/core/utils/images.dart';

class BuildImagesHeder extends StatefulWidget {
  final List<String> photoUrls;
  final double? price;
  // final bool hasPrice;
  const BuildImagesHeder({
    super.key,
    required this.photoUrls,
    // required this.hasPrice,
    this.price,
  });

  @override
  State<BuildImagesHeder> createState() => _BuildImagesHederState();
}

class _BuildImagesHederState extends State<BuildImagesHeder> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final CarouselSliderController _carouselController =
        CarouselSliderController();
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      images: widget.photoUrls,
                      initialIndex: currentIndex,
                    ),
                  ),
                );
              },
              child: CarouselSlider(
                carouselController: _carouselController,
                items: widget.photoUrls.map((url) {
                  return CachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => BuildImagesShimmerEffect(),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  enableInfiniteScroll: widget.photoUrls.length > 1,
                  autoPlay: widget.photoUrls.length > 1,
                  autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            // Gradient Overlay
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                  ),
                ),
              ),
            ),
            // Price Badge (Glassmorphism)
            if (widget.price != null)
              Positioned(
                bottom: 24,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.price?.toStringAsFixed(0)}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ج.م',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Carousel Indicators
            if (widget.photoUrls.length > 1)
              Positioned(
                bottom: 24,
                right: 24,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.photoUrls.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _carouselController.animateToPage(entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: currentIndex == entry.key ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withOpacity(
                            currentIndex == entry.key ? 0.95 : 0.35,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
