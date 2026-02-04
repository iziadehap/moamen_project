import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/auth/presentation/login_screen.dart';
import '../../pricelist/presentation/price_list_screen.dart';
import '../../admin/presentation/add_order_screen.dart';
import 'widgets/dashboard_button.dart';

// class DashboardScreen extends GetView<LoginController> {
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Assuming LoginController is still in memory or we can access user data from a UserSessionService
    // For now, using Get.find<LoginController>() which was put in LoginScreen
    final user = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user.user?.role == SupabaseAccountTyps.admin ? 'Admin' : 'User'}!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'What would you like to do today?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600
                    ? 4
                    : 2, // Responsive
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  DashboardButton(
                    title: 'Orders',
                    icon: Icons.list_alt_rounded,
                    color: Colors.blueAccent,
                    onTap: () {
                      // TODO: implement orders screen
                      // Get.to(() => const OrdersScreen());
                    },
                  ),
                  DashboardButton(
                    title: 'Map',
                    icon: Icons.map_rounded,
                    color: Colors.greenAccent,
                    onTap: () {
                      // Get.to(() => const MapScreen());
                      Get.snackbar('Feature', 'Map Screen Coming Soon');
                    },
                  ),
                  DashboardButton(
                    title: 'Price List',
                    icon: Icons.attach_money_rounded,
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PriceListScreen(),
                        ),
                      );
                    },
                  ),
                  if (user.user?.role == SupabaseAccountTyps.admin)
                    DashboardButton(
                      title: 'Add Order',
                      icon: Icons.add_location_alt_rounded,
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddOrderScreen(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
