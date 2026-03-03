import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/card_list.dart';
import 'package:moamen_project/features/orders/presentation/add_order_screen.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_state.dart';
import 'package:moamen_project/features/orders/presentation/order_detail_screen.dart';
import 'package:moamen_project/features/orders/presentation/widgets/order_filter.dart';
import 'package:moamen_project/features/orders/presentation/widgets/widgets.dart';
import 'package:moamen_project/features/map/presentation/controller/map_provider.dart';
import '../../../core/theme/app_theme.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final bool isSelectionMode;

  const OrdersScreen({super.key, this.isSelectionMode = false});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderFilter _selectedFilter = OrderFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      // Ensure location services are initialized for distance sorting
      ref.read(mapProvider.notifier).initLocationService();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final isAdmin = authState.user?.role == SupabaseAccountTyps.admin;
    final orderState = ref.watch(orderProvider);
    final userLocation = ref.watch(mapProvider).userLocation;

    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    // Listen for hint errors and clear them after a delay
    ref.listen(orderProvider.select((s) => s.hintError), (previous, next) {
      if (next != null) {
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            ref.read(orderProvider.notifier).clearHintError();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: customTheme.background,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
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
                  _buildSearchBar(customTheme),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: _buildBody(orderState, userLocation, customTheme),
                    ),
                  ),
                ],
              ),
              _buildHintErrorBanner(orderState.hintError, customTheme),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: (isAdmin && !widget.isSelectionMode)
      //     ? SafeArea(child: const AddOrderButton())
      //     : null,
    );
  }

  Widget _buildBody(
    dynamic state,
    dynamic userLocation,
    CustomThemeExtension customTheme,
  ) {
    if (state.isLoading && !state.hasFetched) {
      return Center(
        child: AnimationWidget.loadingAnimation(24),
      );
    }

    if (state.isError) {
      return _buildErrorState(state.errorMessage, customTheme);
    }

    final userId = ref.watch(authProvider).user?.id;
    final filteredOrders = _getFilteredOrders(
      state.orders,
      userId,
      userLocation,
    );

    if (filteredOrders.isEmpty) {
      return _buildEmptyState(customTheme);
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      color: customTheme.primaryBlue,
      backgroundColor: customTheme.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          final isAdmin =
              ref.watch(authProvider).user?.role == SupabaseAccountTyps.admin;
          final currentUserId = ref.watch(authProvider).user?.id;
          final isAuthorized =
              isAdmin ||
              (order.workerId != null && order.workerId == currentUserId);

          return CardList(
            images: isAuthorized ? order.photoUrls : [],
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: contant_widget(
              order,
              customTheme,
              isAuthorized: isAuthorized,
            ),
          );
        },
      ),
    );
  }

  List<Order> _getFilteredOrders(
    List<Order> orders,
    String? userId,
    dynamic userLocation,
  ) {
    var filtered = orders
        .where((order) {
          switch (_selectedFilter) {
            case OrderFilter.myOrders:
              return order.workerId == userId;
            case OrderFilter.all:
              return true;
            default:
              return order.status == _selectedFilter.status;
          }
        })
        .where((order) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          final title = order.title.toLowerCase();
          final description = order.description.toLowerCase();
          final area = order.publicArea.toLowerCase();
          final address = (order.fullAddress ?? '').toLowerCase();
          final contactName = (order.contactName ?? '').toLowerCase();
          final contactPhone = (order.contactPhone ?? '').toLowerCase();

          return title.contains(query) ||
              description.contains(query) ||
              area.contains(query) ||
              address.contains(query) ||
              contactName.contains(query) ||
              contactPhone.contains(query);
        })
        .toList();

    // Sort by distance if user location is available
    if (userLocation != null &&
        (_selectedFilter == OrderFilter.pending ||
            _selectedFilter == OrderFilter.all ||
            _selectedFilter == OrderFilter.myOrders)) {
      filtered.sort((a, b) {
        if (a.latitude == null || a.longitude == null) return 1;
        if (b.latitude == null || b.longitude == null) return -1;

        double distA = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          a.latitude!,
          a.longitude!,
        );
        double distB = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          b.latitude!,
          b.longitude!,
        );
        return distA.compareTo(distB);
      });
    }

    return filtered;
  }

  Widget _buildErrorState(String message, CustomThemeExtension customTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: customTheme.errorColor, size: 60),
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
              message,
              style: GoogleFonts.cairo(
                color: customTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: customTheme.primaryBlue,
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

  Widget _buildEmptyState(CustomThemeExtension customTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off_rounded
                : Icons.filter_list_off_rounded,
            color: customTheme.textSecondary.withOpacity(0.3),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'لم يتم العثور على نتائج'
                : 'لا يوجد اوردر بهذا التصنيف',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 16,
            ),
          ),
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
          hintText: 'ابحث عن أوردر...',
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

  Widget _buildHintErrorBanner(
    HintError? hintError,
    CustomThemeExtension customTheme,
  ) {
    bool isVisible = hintError != null;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      top: isVisible ? 10 : -100,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: customTheme.cardBackground.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: customTheme.errorColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: customTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: customTheme.errorColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      hintError?.message ?? '',
                      style: GoogleFonts.cairo(
                        color: customTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      hintError?.description ?? '',
                      style: GoogleFonts.cairo(
                        color: customTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  ref.read(orderProvider.notifier).clearHintError();
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: customTheme.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
