import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
// import 'package:icons_plus/icons_plus.dart';
import 'package:moamen_project/features/map/presentation/map_screen.dart';
import 'package:moamen_project/features/orders/presentation/orders_screen.dart';
import 'package:moamen_project/features/settings/presentation/profile_screen.dart';

import '../../pricelist/presentation/screens/price_list_screen.dart';
import 'controller/nav_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);

    final List<Widget> screens = [
      const OrdersScreen(),
      const PriceListScreen(),
      const MapScreen(),
      const ProfileScreen(),
    ];

    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Scaffold(
      backgroundColor: customTheme.background,
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: customTheme.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
          backgroundColor: customTheme.cardBackground,
          selectedItemColor: customTheme.primaryBlue,
          unselectedItemColor: customTheme.textSecondary.withValues(alpha: 0.5),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.shoppingBag),
              activeIcon: FaIcon(FontAwesomeIcons.shoppingBag),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.moneyBill),
              activeIcon: FaIcon(FontAwesomeIcons.moneyBill),
              label: 'الأسعار',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.map),
              activeIcon: FaIcon(FontAwesomeIcons.map),
              label: 'الخريطة',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user),
              activeIcon: FaIcon(FontAwesomeIcons.user),
              label: 'الحساب',
            ),
          ],
        ),
      ),
    );
  }
}
