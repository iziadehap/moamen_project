import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/core/utils/order_status_helper.dart';

import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/add_order_screen.dart';
import 'package:moamen_project/features/orders/presentation/order_detail_screen.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final bool isSelectionMode;

  const OrdersScreen({super.key, this.isSelectionMode = false});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  _OrderFilter _selectedFilter = _OrderFilter.all;

  @override
  void initState() {
    super.initState();
    if (widget.isSelectionMode) {
      _selectedFilter = _OrderFilter.myOrders;
    }
    // Fetch orders if not already loaded or if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(orderProvider).hasFetched) {
        ref.read(orderProvider.notifier).fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';
    final orderState = ref.watch(orderProvider);
    final orderNotifier = ref.read(orderProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, orderNotifier),
              _buildFilterBar(),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: _buildBody(context, orderState, orderNotifier),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: (isAdmin && !widget.isSelectionMode)
          ? _buildAddButton(context)
          : null,
    );
  }

  Widget _buildFilterBar() {
    final filters = _OrderFilter.values;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          final status = filters[index].status;

          Color chipColor;
          if (filter == _OrderFilter.myOrders) {
            chipColor = Colors.amber;
          } else if (filter == _OrderFilter.all) {
            chipColor = Colors.white;
          } else if (filter == _OrderFilter.active) {
            chipColor = Colors.orangeAccent;
          } else {
            // Use helper for status color
            chipColor = OrderStatusHelper.getStatusColor(status!);
          }

          return ChoiceChip(
            label: Text(
              filter.label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (filter == _OrderFilter.all ? Colors.black : Colors.white)
                    : Colors.white70,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            backgroundColor: Colors.white.withOpacity(0.05),
            selectedColor: isSelected ? chipColor : null,
            checkmarkColor: filter == _OrderFilter.all
                ? Colors.black
                : Colors.white,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.midnightNavy.withOpacity(0.8),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.glowShadow,
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddOrderScreen()),
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
                const Icon(Icons.add_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'إضافة طلب جديد',
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
    );
  }

  Widget _buildHeader(BuildContext context, dynamic notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.midnightNavy,
            AppColors.midnightNavy.withOpacity(0.0),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (widget.isSelectionMode)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),

                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.isSelectionMode ? 'إختر طلباً' : 'طلباتك',
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showStatusInfoDialog(context),
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.textGrey,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(20, 20),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إدارة الطلبات الذكية 2026',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => notifier.fetchOrders(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Text(
                'حالات الطلب',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: OrderStatus.values.map((status) {
              final color = OrderStatusHelper.getStatusColor(status);
              final label = OrderStatusHelper.getStatusLabel(status);
              final description = OrderStatusHelper.getStatusDescription(
                status,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.cairo(
                              color: color,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.cairo(
                              color: AppColors.textGrey,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'حسناً',
                style: GoogleFonts.cairo(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state, dynamic notifier) {
    if (state.isLoading && !state.hasFetched) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (state.isError) {
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
                state.errorMessage,
                style: GoogleFonts.cairo(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => notifier.fetchOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
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

    // Filter logic
    final userId = ref.watch(authProvider).user?.id;

    final List<Order> filteredOrders = state.orders.where((order) {
      switch (_selectedFilter) {
        case _OrderFilter.myOrders:
          return order.workerId == userId;
        case _OrderFilter.all:
          return true;
        case _OrderFilter.active:
          return order.status == OrderStatus.pending ||
              order.status == OrderStatus.accepted ||
              order.status == OrderStatus.inProgress;
        default:
          return order.status == _selectedFilter.status;
      }
    }).toList();

    if (filteredOrders.isEmpty) {
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
              'لا يوجد طلبات بهذا التصنيف',
              style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => notifier.fetchOrders(),
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
          return _OrderListItem(
            order: order,
            isSelectionMode: widget.isSelectionMode,
          );
        },
      ),
    );
  }
}

enum _OrderFilter {
  myOrders('طلباتي', null),
  all('الكل', null),
  active('نشط', null), // Pending + Accepted + InProgress
  pending('جاهز', OrderStatus.pending),
  accepted('مقبول', OrderStatus.accepted),
  inProgress('قيد التنفيذ', OrderStatus.inProgress),
  completed('مكتمل', OrderStatus.completed),
  cancelled('ملغي', OrderStatus.cancelled);

  final String label;
  final OrderStatus? status;

  const _OrderFilter(this.label, this.status);
}

class _OrderListItem extends StatelessWidget {
  final Order order;
  final bool isSelectionMode;

  const _OrderListItem({required this.order, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Glassmorphic background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkCard.withOpacity(0.8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Highlighting Gradient Border (Top-left)
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
                      AppColors.primaryBlue.withOpacity(0.1),
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
                  if (isSelectionMode) {
                    Navigator.pop(context, order);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _PriorityBadge(priority: order.priority),
                          Text(
                            _formatDate(order.createdAt),
                            style: GoogleFonts.cairo(
                              color: AppColors.textGrey,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.title,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  order.description,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.textGrey.withOpacity(0.9),
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _StatusChip(status: order.status),
                        ],
                      ),

                      if (order.publicLandmark != null &&
                          order.publicLandmark!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.assistant_navigation,
                                color: AppColors.primaryBlue,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  order.publicLandmark!,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.textWhite.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildMetaDataItem(
                            icon: Icons.location_on_rounded,
                            label: order.publicArea,
                            color: AppColors.primaryBlue,
                          ),
                          const Spacer(),
                          _buildOrderTypeBadge(order.orderType),
                        ],
                      ),
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

  Widget _buildMetaDataItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: AppColors.textWhite.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeBadge(OrderType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withOpacity(0.2),
            AppColors.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
      ),
      child: Text(
        _orderTypeArabic(type),
        style: GoogleFonts.cairo(
          color: AppColors.primaryPurple.withAlpha(255),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _orderTypeArabic(OrderType type) {
    switch (type) {
      case OrderType.pickup:
        return 'استلام';
      case OrderType.delivery:
        return 'توصيل';
      case OrderType.pickupAndReturn:
        return 'استلام وعودة';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = OrderStatusHelper.getStatusColor(status);
    String text = OrderStatusHelper.getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final OrderPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (priority) {
      case OrderPriority.low:
        color = Colors.greenAccent;
        text = 'منخفضة';
        break;
      case OrderPriority.medium:
        color = AppColors.primaryBlue;
        text = 'متوسطة';
        break;
      case OrderPriority.high:
        color = Colors.orangeAccent;
        text = 'عالية';
        break;
      case OrderPriority.urgent:
        color = Colors.redAccent;
        text = 'عاجل جداً';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
