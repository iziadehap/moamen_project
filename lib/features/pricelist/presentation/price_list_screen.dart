import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PriceListScreen extends StatelessWidget {
  const PriceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prices = [
      {'service': 'Standard Delivery', 'price': '50 EGP'},
      {'service': 'Express Delivery', 'price': '100 EGP'},
      {'service': 'Heavy Goods', 'price': '200 EGP'},
      {'service': 'International', 'price': '500+ EGP'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Price List')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: prices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = prices[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(15),
              boxShadow: AppColors.glowShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['service']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['price']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
