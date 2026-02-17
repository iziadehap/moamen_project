import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/orders/presentation/add_order_screen.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/orders/presentation/widgets/order_filter.dart';
import 'package:moamen_project/features/orders/presentation/widgets/widgets.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final bool isSelectionMode;

  const OrdersScreen({super.key, this.isSelectionMode = false});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderFilter _selectedFilter = OrderFilter.all;

  @override
  void initState() {
    super.initState();
    if (widget.isSelectionMode) {
      _selectedFilter = OrderFilter.myOrders;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(orderProvider).hasFetched) {
        ref.read(orderProvider.notifier).fetchOrders();
      }
    });
  }

  void _onRefresh() {
    ref.read(orderProvider.notifier).fetchOrders();
  }

  void _onAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddOrderScreen()),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => const StatusInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Column(
            children: [
              OrderHeader(
                isSelectionMode: widget.isSelectionMode,
                onRefresh: _onRefresh,
                isAdmin: isAdmin,
                onAdd: _onAdd,
                onInfoPressed: _showInfo,
              ),
              OrderFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() => _selectedFilter = filter);
                },
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: _buildBody(orderState),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: (isAdmin && !widget.isSelectionMode)
      //     ? SafeArea(child: const AddOrderButton())
      //     : null,
    );
  }

  Widget _buildBody(dynamic state) {
    if (state.isLoading && !state.hasFetched) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (state.isError) {
      return _buildErrorState(state.errorMessage);
    }

    final userId = ref.watch(authProvider).user?.id;
    final filteredOrders = _getFilteredOrders(state.orders, userId);

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.darkCard,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return OrderListItem(
            order: order,
            isSelectionMode: widget.isSelectionMode,
          );
        },
      ),
    );
  }

  List<Order> _getFilteredOrders(List<Order> orders, String? userId) {
    return orders.where((order) {
      switch (_selectedFilter) {
        case OrderFilter.myOrders:
          return order.workerId == userId;
        case OrderFilter.all:
          return true;
        // case OrderFilter.active:
        //   return order.status == OrderStatus.pending ||
        //       order.status == OrderStatus.accepted ||
        //       order.status == OrderStatus.inProgress;
        default:
          return order.status == _selectedFilter.status;
      }
    }).toList();
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل البيانات',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            color: AppColors.textGrey.withOpacity(0.3),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد اوردر بهذا التصنيف',
            style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
