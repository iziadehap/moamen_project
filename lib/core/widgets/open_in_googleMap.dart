// open_in_googleMap.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenInGoogleMap extends StatelessWidget {
  final String location;
  final Widget child;
  const OpenInGoogleMap({
    super.key,
    required this.location,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: const Text('افتح في خرائط جوجل'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$location',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}
