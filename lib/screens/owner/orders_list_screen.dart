import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/owner/order_models.dart';
import '../../services/owner_order_service.dart';
import '../../services/restaurant_service.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  List<Order> _orders = [];
  OrderPagination? _pagination;
  
  // Filter state
  int _currentPage = 1;
  final int _pageSize = 10;
  String? _selectedStatus;
  String? _dateFrom;
  String? _dateTo;
  String _sortBy = 'orderPlacedAt';
  String _sortOrder = 'desc';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // UI state
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // MEJORA 1: Tiempo Real - Poller y alertas sonoras
  Timer? _pollerTimer;
  int _lastPendingCount = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAlert = false;

  // Colores Material 3
  static const Color primaryOrange = Color(0xFFF2843A);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color outlineColor = Color(0xFF79747E);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    // MEJORA 2: Flujo Kanban - Cambiar a 4 tabs
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
    _scrollController.addListener(_onScroll);
    
    // MEJORA 1: Iniciar poller de tiempo real
    _startPoller();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    
    // MEJORA 1: Limpiar recursos del poller
    _pollerTimer?.cancel();
    _audioPlayer.dispose();
    
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_pagination?.hasNextPage == true && !_isLoading) {
        _loadNextPage();
      }
    }
  }

  // MEJORA 1: Poller de tiempo real
  void _startPoller() {
    _pollerTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkForNewOrders();
    });
  }

  Future<void> _checkForNewOrders() async {
    try {
      final response = await OwnerOrderService.getOrders(
        page: 1,
        pageSize: 1,
        status: 'pending',
      );

      if (response.isSuccess && response.data != null) {
        final currentPendingCount = response.data!.pagination.totalCount;
        
        // Si hay nuevos pedidos pendientes
        if (currentPendingCount > _lastPendingCount && _lastPendingCount > 0) {
          debugPrint('🔔 Nuevos pedidos detectados: $currentPendingCount (antes: $_lastPendingCount)');
          
          // Reproducir sonido de alerta
          _playAlertSound();
          
          // Recargar automáticamente la pestaña "Nuevos"
          if (mounted) {
            await _refresh();
          }
        }
        
        _lastPendingCount = currentPendingCount;
      }
    } catch (e) {
      debugPrint('❌ Error en poller: $e');
    }
  }

  Future<void> _playAlertSound() async {
    if (_isPlayingAlert) return;
    
    try {
      _isPlayingAlert = true;
      // Reproducir sonido de alerta en bucle hasta que el usuario interactúe
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'), volume: 0.8);
      
      // Configurar el audio para que se repita
      _audioPlayer.onPlayerComplete.listen((event) {
        if (_isPlayingAlert) {
          _audioPlayer.resume();
        }
      });
    } catch (e) {
      debugPrint('❌ Error reproduciendo sonido: $e');
    }
  }

  void _stopAlertSound() {
    if (_isPlayingAlert) {
      _isPlayingAlert = false;
      _audioPlayer.stop();
    }
  }

  // MEJORA 2: Contar pedidos por categoría para los badges
  int _getPendingOrdersCount() {
    return _orders.where((order) => order.status == 'pending').length;
  }

  int _getPreparingOrdersCount() {
    return _orders.where((order) => ['confirmed', 'preparing'].contains(order.status)).length;
  }

  int _getReadyOrdersCount() {
    return _orders.where((order) => order.status == 'ready_for_pickup').length;
  }

  int _getHistoryOrdersCount() {
    return _orders.where((order) => ['delivered', 'cancelled', 'refunded'].contains(order.status)).length;
  }

  Future<void> _loadOrders() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (_currentPage == 1) {
        _orders.clear();
      }
    });

    try {
      final response = await OwnerOrderService.getOrders(
        page: _currentPage,
        pageSize: _pageSize,
        status: _selectedStatus,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          if (_currentPage == 1) {
            _orders = response.data!.orders;
          } else {
            _orders.addAll(response.data!.orders);
          }
          _pagination = response.data!.pagination;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar pedidos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_pagination?.hasNextPage == true) {
      setState(() {
        _currentPage++;
      });
      await _loadOrders();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
    });
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: _buildPremiumAppBar(),
      body: Column(
        children: [
          // Espaciado para el app bar extendido
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 48),
          
          // Sección de búsqueda mejorada
          _buildPremiumSearchSection(),
          
          // Tabs mejorados con Material 3
          _buildPremiumTabBar(),
          
          // Contenido principal
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPremiumOrdersTab(['pending']),
                _buildPremiumOrdersTab(['confirmed', 'preparing']),
                _buildPremiumOrdersTab(['ready_for_pickup']),
                _buildPremiumOrdersTab(['delivered', 'cancelled', 'refunded']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
          ),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
            Icon(
              Icons.receipt_long_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text(
                  'Gestión de Pedidos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${_orders.length} pedidos totales',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.tune_rounded),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
        ),
      ),
        ),
      ],
    );
  }

  Widget _buildPremiumSearchSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search bar premium con Material 3
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar pedidos, clientes...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                  Icons.search_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _refresh();
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                          Icons.clear_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                _refresh();
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick filters premium
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPremiumFilterChip('Hoy', _isTodayFilter, Icons.today_rounded),
                const SizedBox(width: 12),
                _buildPremiumFilterChip('Esta semana', _isThisWeekFilter, Icons.date_range_rounded),
                const SizedBox(width: 12),
                _buildPremiumFilterChip('Urgentes', _isUrgentFilter, Icons.priority_high_rounded),
                const SizedBox(width: 12),
                _buildPremiumFilterChip('Nuevos', _isNewFilter, Icons.new_releases_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFilterChip(String label, bool Function(Order) filter, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = _selectedStatus != null || _dateFrom != null;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
        label,
              style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
                color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
            ),
          ],
      ),
      selected: isActive,
      onSelected: (selected) {
        // Implementar lógica de filtros rápidos
        _refresh();
      },
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
      side: BorderSide(
          color: isActive ? colorScheme.primary : Colors.transparent,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  bool _isTodayFilter(Order order) {
    final now = DateTime.now();
    final orderDate = order.orderPlacedAt;
    return orderDate.year == now.year && 
           orderDate.month == now.month && 
           orderDate.day == now.day;
  }

  bool _isThisWeekFilter(Order order) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return order.orderPlacedAt.isAfter(weekAgo);
  }

  bool _isUrgentFilter(Order order) {
    return order.status == 'pending' || order.status == 'confirmed';
  }

  bool _isNewFilter(Order order) {
    final now = DateTime.now();
    final orderDate = order.orderPlacedAt;
    final difference = now.difference(orderDate);
    return difference.inMinutes < 30; // Pedidos de los últimos 30 minutos
  }

  Widget _buildPremiumTabBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          _buildPremiumTab('Nuevos', Icons.new_releases_rounded, _getPendingOrdersCount()),
          _buildPremiumTab('Preparando', Icons.restaurant_rounded, _getPreparingOrdersCount()),
          _buildPremiumTab('Listos', Icons.check_circle_rounded, _getReadyOrdersCount()),
          _buildPremiumTab('Historial', Icons.history_rounded, _getHistoryOrdersCount()),
        ],
      ),
    );
  }

  Widget _buildPremiumTab(String label, IconData icon, int count) {
    return Tab(
      child: Container(
        constraints: const BoxConstraints(minWidth: 60),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            if (count > 0) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumOrdersTab(List<String>? filterStatuses) {
    final filteredOrders = filterStatuses != null
        ? _orders.where((order) => filterStatuses.contains(order.status)).toList()
        : _orders;

    if (_isLoading && _orders.isEmpty) {
      return _buildPremiumLoadingState();
    }

    if (_errorMessage != null && _orders.isEmpty) {
      return _buildPremiumErrorState();
    }

    if (filteredOrders.isEmpty) {
      return _buildPremiumEmptyState(filterStatuses);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredOrders.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredOrders.length) {
            return _buildPremiumLoadingIndicator();
          }

          final order = filteredOrders[index];
          return _buildPremiumOrderCard(order);
        },
      ),
    );
  }

  Widget _buildPremiumOrderCard(Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerLow.withOpacity(0.3),
                ],
              ),
            ),
          child: Padding(
              padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  _buildPremiumOrderHeader(order),
                  const SizedBox(height: 20),
                  _buildPremiumOrderInfo(order),
                  const SizedBox(height: 20),
                  _buildPremiumOrderActions(order),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOrderHeader(Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        // Avatar premium del cliente
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
          child: Text(
            order.customer.name.isNotEmpty 
                ? order.customer.name[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 18,
              fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Info del cliente mejorada
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.customer.fullName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Pedido #${order.id}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Estado del pedido premium
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                order.statusColor.withOpacity(0.1),
                order.statusColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: order.statusColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: order.statusColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                color: order.statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  order.statusIcon,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                order.statusDisplayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: order.statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumOrderInfo(Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        // Información del pedido premium
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.surfaceContainerHighest.withOpacity(0.5),
                colorScheme.surfaceContainerLow.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
          children: [
            Expanded(
                child: _buildPremiumInfoItem(
                  icon: Icons.payments_rounded,
                label: 'Total',
                value: '\$${order.total.toStringAsFixed(2)}',
                  color: colorScheme.primary,
              ),
            ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withOpacity(0.2),
            ),
            Expanded(
                child: _buildPremiumInfoItem(
                icon: Icons.shopping_basket_rounded,
                label: 'Artículos',
                value: '${order.orderItems.length}',
                  color: colorScheme.secondary,
              ),
            ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withOpacity(0.2),
            ),
            Expanded(
                child: _buildPremiumInfoItem(
                icon: Icons.access_time_rounded,
                label: 'Hace',
                value: _formatTimeAgo(order.orderPlacedAt),
                  color: colorScheme.tertiary,
              ),
            ),
          ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Dirección de entrega premium
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withOpacity(0.3),
                colorScheme.primaryContainer.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                Icons.location_on_rounded,
                  size: 20,
                  color: colorScheme.onPrimary,
              ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección de entrega',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                  order.address.fullAddress,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
          icon,
          size: 20,
          color: color,
        ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // MEJORA 4: Acciones rápidas premium en la tarjeta
  Widget _buildPremiumOrderActions(Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        // Botón "Ver detalles" premium mejorado
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _stopAlertSound();
                  _showOrderDetails(order);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.visibility_rounded,
                          size: 14,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Ver detalles',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Botones de acción rápida premium según el estado
        if (order.canBeUpdated) ...[
          if (order.status == 'pending') ...[
            // Acciones para pedidos pendientes - Aceptar
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _stopAlertSound();
                      _updateOrderStatus(order.id, 'confirmed');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Aceptar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Acciones para pedidos pendientes - Rechazar
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _stopAlertSound();
                      _updateOrderStatus(order.id, 'cancelled');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Rechazar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (order.status == 'confirmed') ...[
            // Acción para pedidos confirmados - Preparar
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _stopAlertSound();
                      _updateOrderStatus(order.id, 'preparing');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant_rounded, size: 12, color: colorScheme.onPrimary),
                          const SizedBox(width: 3),
                          Text(
                            'Preparar',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (order.status == 'preparing') ...[
            // Acción para pedidos en preparación - Listo
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _stopAlertSound();
                      _updateOrderStatus(order.id, 'ready_for_pickup');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Listo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Botón genérico de actualizar para otros estados
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _stopAlertSound();
                      _showStatusUpdateDialog(order);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.update_rounded, size: 12, color: colorScheme.onSecondary),
                          const SizedBox(width: 3),
                          Text(
                            'Actualizar',
                            style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildPremiumLoadingState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            strokeWidth: 3,
          ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando pedidos...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Obteniendo los últimos pedidos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLoadingIndicator() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Cargando más pedidos...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumErrorState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar pedidos',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumEmptyState(List<String>? filterStatuses) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    String title = 'No hay pedidos';
    String subtitle = 'Los pedidos aparecerán aquí cuando lleguen';
    IconData icon = Icons.receipt_long_outlined;
    
    if (filterStatuses != null) {
      if (filterStatuses.contains('pending')) {
        title = 'No hay pedidos nuevos';
        subtitle = 'Los nuevos pedidos aparecerán aquí';
        icon = Icons.new_releases_outlined;
      } else if (filterStatuses.contains('confirmed') || filterStatuses.contains('preparing')) {
        title = 'No hay pedidos en preparación';
        subtitle = 'Los pedidos confirmados aparecerán aquí';
        icon = Icons.restaurant_outlined;
      } else if (filterStatuses.contains('ready_for_pickup')) {
        title = 'No hay pedidos listos';
        subtitle = 'Los pedidos listos para recoger aparecerán aquí';
        icon = Icons.check_circle_outline;
      } else {
        title = 'No hay historial';
        subtitle = 'Los pedidos completados aparecerán aquí';
        icon = Icons.history_outlined;
      }
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  void _showOrderDetails(Order order) {
    // MEJORA 1: Detener alerta sonora al abrir modal
    _stopAlertSound();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsModal(order: order),
    );
  }

  void _showStatusUpdateDialog(Order order) {
    // MEJORA 1: Detener alerta sonora al abrir diálogo
    _stopAlertSound();
    
    final possibleStates = order.possibleNextStates;
    
    if (possibleStates.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Actualizar Estado',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: onSurfaceColor,
          ),
        ),
        content: Text(
          'Pedido #${order.id} - ${order.customer.fullName}',
          style: TextStyle(
            color: outlineColor,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: outlineColor),
            ),
          ),
          ...possibleStates.map((status) => FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order.id, status);
            },
            style: FilledButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: Text(_getStatusDisplayName(status)),
          )),
        ],
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmar';
      case 'preparing':
        return 'Preparar';
      case 'ready_for_pickup':
        return 'Marcar listo';
      case 'out_for_delivery':
        return 'Enviar';
      case 'delivered':
        return 'Entregar';
      case 'cancelled':
        return 'Cancelar';
      default:
        return status;
    }
  }

  // MEJORA 3: Actualizaciones instantáneas con UI local
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OwnerOrderService.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );

      if (response.isSuccess && response.data != null) {
        HapticFeedback.lightImpact();
        
        // MEJORA 1: Detener alerta sonora al interactuar con pedido
        _stopAlertSound();
        
        // MEJORA 3: Actualización optimista - actualizar UI localmente
        final updatedOrder = response.data!;
        
        setState(() {
          // Remover el pedido de su lista actual
          _orders.removeWhere((order) => order.id == orderId);
          
          // Añadir el pedido actualizado al inicio de la lista
          _orders.insert(0, updatedOrder);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Estado actualizado a ${_getStatusDisplayName(newStatus)}'),
              ],
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(response.message)),
              ],
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error al actualizar estado: ${e.toString()}')),
            ],
          ),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Filtros',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: onSurfaceColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado del pedido',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: onSurfaceColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Todos los estados',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'pending',
                  child: Text(
                    'Pendientes',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'confirmed',
                  child: Text(
                    'Confirmados',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'preparing',
                  child: Text(
                    'Preparando',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'ready_for_pickup',
                  child: Text(
                    'Listo para recoger',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'out_for_delivery',
                  child: Text(
                    'En camino',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'delivered',
                  child: Text(
                    'Entregados',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'cancelled',
                  child: Text(
                    'Cancelados',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'refunded',
                  child: Text(
                    'Reembolsados',
                    style: TextStyle(color: onSurfaceColor),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: outlineColor),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _refresh();
            },
            style: FilledButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsModal extends StatefulWidget {
  final Order order;

  const _OrderDetailsModal({required this.order});

  @override
  State<_OrderDetailsModal> createState() => _OrderDetailsModalState();
}

class _OrderDetailsModalState extends State<_OrderDetailsModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  LatLng? _customerLocation;
  LatLng? _restaurantLocation;
  bool _isLoadingLocation = false;

  // Colores Material 3
  static const Color primaryOrange = Color(0xFFF2843A);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color outlineColor = Color(0xFF79747E);
  static const Color surfaceVariantColor = Color(0xFFE7E0EC);
  static const Color successColor = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getLocations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getLocations() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Obtener ubicación del cliente usando geocoding
      final customerLocations = await locationFromAddress(widget.order.address.fullAddress);
      if (customerLocations.isNotEmpty) {
        setState(() {
          _customerLocation = LatLng(
            customerLocations.first.latitude,
            customerLocations.first.longitude,
          );
        });
      }

      // Obtener ubicación del restaurante desde el backend
      debugPrint('🏪 Obteniendo ubicación del restaurante...');
      final restaurantResponse = await RestaurantService.getRestaurantLocation();
      debugPrint('🏪 Respuesta del restaurante: ${restaurantResponse.status}');
      debugPrint('🏪 Datos del restaurante: ${restaurantResponse.data}');
      
      if (restaurantResponse.isSuccess && restaurantResponse.data != null) {
        final data = restaurantResponse.data!;
        debugPrint('🏪 Estructura de datos: ${data.keys.toList()}');
        
        // Intentar diferentes estructuras de datos
        Map<String, dynamic>? locationData;
        
        // Según la documentación del backend, la estructura es:
        // data.location.latitude y data.location.longitude
        if (data.containsKey('location')) {
          locationData = data['location'] as Map<String, dynamic>?;
          debugPrint('🏪 Ubicación encontrada en data.location: $locationData');
        } else if (data.containsKey('latitude') && data.containsKey('longitude')) {
          locationData = data;
          debugPrint('🏪 Coordenadas encontradas directamente en data');
        } else if (data.containsKey('branch') && data['branch'] is Map<String, dynamic>) {
          final branch = data['branch'] as Map<String, dynamic>;
          if (branch.containsKey('location')) {
            locationData = branch['location'] as Map<String, dynamic>?;
            debugPrint('🏪 Ubicación encontrada en data.branch.location: $locationData');
          }
        }
        
        if (locationData != null && 
            locationData['latitude'] != null && 
            locationData['longitude'] != null) {
          // El backend puede devolver las coordenadas como strings o números
          double lat, lng;
          
          if (locationData['latitude'] is String) {
            lat = double.parse(locationData['latitude'] as String);
          } else {
            lat = (locationData['latitude'] as num).toDouble();
          }
          
          if (locationData['longitude'] is String) {
            lng = double.parse(locationData['longitude'] as String);
          } else {
            lng = (locationData['longitude'] as num).toDouble();
          }
          
          debugPrint('🏪 Coordenadas del restaurante: lat=$lat, lng=$lng');
          
          setState(() {
            _restaurantLocation = LatLng(lat, lng);
          });
        } else {
          debugPrint('❌ No se encontraron coordenadas válidas del restaurante');
        }
      } else {
        debugPrint('❌ Error al obtener ubicación del restaurante: ${restaurantResponse.message}');
      }
    } catch (e) {
      debugPrint('Error getting locations: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildModalHandle(),
          _buildModalHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderTab(),
                _buildCustomerTab(),
                _buildMapTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: outlineColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${widget.order.id}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.order.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.order.statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.order.statusIcon,
                            size: 18,
                            color: widget.order.statusColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.order.statusDisplayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.order.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: surfaceVariantColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total: \$${widget.order.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: surfaceVariantColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primaryOrange,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: outlineColor,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            icon: const Icon(Icons.receipt_rounded, size: 20),
            text: 'Pedido',
          ),
          Tab(
            icon: const Icon(Icons.person_rounded, size: 20),
            text: 'Cliente',
          ),
          Tab(
            icon: const Icon(Icons.map_rounded, size: 20),
            text: 'Ubicación',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del pedido
          _buildSectionHeader(
            'Información del Pedido',
            Icons.info_rounded,
          ),
          const SizedBox(height: 16),
          _buildOrderInfoCard(),
          
          const SizedBox(height: 24),
          
          // Artículos del pedido
          _buildSectionHeader(
            'Artículos',
            Icons.restaurant_menu_rounded,
          ),
          const SizedBox(height: 16),
          ...widget.order.orderItems.map((item) => _buildOrderItemCard(item)),
          
          const SizedBox(height: 24),
          
          // Resumen de pago
          _buildSectionHeader(
            'Resumen de Pago',
            Icons.payment_rounded,
          ),
          const SizedBox(height: 16),
          _buildPaymentSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildCustomerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del cliente
          _buildSectionHeader(
            'Información del Cliente',
            Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          _buildCustomerInfoCard(),
          
          const SizedBox(height: 24),
          
          // Información de entrega
          _buildSectionHeader(
            'Información de Entrega',
            Icons.location_on_rounded,
          ),
          const SizedBox(height: 16),
          _buildDeliveryInfoCard(),
          
          if (widget.order.deliveryDriver != null) ...[
            const SizedBox(height: 24),
            
            // Información del repartidor
            _buildSectionHeader(
              'Repartidor',
              Icons.delivery_dining_rounded,
            ),
            const SizedBox(height: 16),
            _buildDriverInfoCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    if (_isLoadingLocation) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Si no tenemos ninguna ubicación, mostrar error
    if (_customerLocation == null && _restaurantLocation == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64,
              color: outlineColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudieron obtener las ubicaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.address.fullAddress,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: outlineColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Determinar la posición inicial de la cámara
    LatLng initialPosition;
    double initialZoom = 14.0;
    
    if (_customerLocation != null && _restaurantLocation != null) {
      // Si tenemos ambas ubicaciones, centrar entre ellas
      initialPosition = LatLng(
        (_customerLocation!.latitude + _restaurantLocation!.latitude) / 2,
        (_customerLocation!.longitude + _restaurantLocation!.longitude) / 2,
      );
      initialZoom = 12.0; // Zoom más amplio para mostrar ambas ubicaciones
    } else if (_customerLocation != null) {
      initialPosition = _customerLocation!;
    } else {
      initialPosition = _restaurantLocation!;
    }

    // Crear marcadores
    Set<Marker> markers = {};
    
    // Marcador del cliente (rojo)
    if (_customerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: _customerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Cliente: ${widget.order.customer.fullName}',
            snippet: widget.order.address.fullAddress,
          ),
        ),
      );
    }
    
    // Marcador del restaurante (verde)
    if (_restaurantLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: _restaurantLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'Restaurante',
            snippet: 'Ubicación del restaurante',
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: initialZoom,
            ),
            markers: markers,
            myLocationEnabled: false,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              // Si tenemos ambas ubicaciones, ajustar la cámara para mostrar ambas
              if (_customerLocation != null && _restaurantLocation != null) {
                _fitMapToShowBothLocations(controller);
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Información del cliente
              if (_customerLocation != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cliente: ${widget.order.customer.fullName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: primaryOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.order.address.fullAddress,
                        style: TextStyle(
                          color: outlineColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Información del restaurante
              if (_restaurantLocation != null) ...[
                if (_customerLocation != null) const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Restaurante',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                if (_customerLocation != null) const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ubicación del restaurante no disponible',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Instrucciones especiales
              if (widget.order.specialInstructions != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryOrange.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_rounded,
                        color: primaryOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.order.specialInstructions!,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _fitMapToShowBothLocations(GoogleMapController controller) async {
    if (_customerLocation == null || _restaurantLocation == null) return;

    // Crear LatLngBounds para incluir ambas ubicaciones
    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(_customerLocation!.latitude, _restaurantLocation!.latitude) - 0.01,
        math.min(_customerLocation!.longitude, _restaurantLocation!.longitude) - 0.01,
      ),
      northeast: LatLng(
        math.max(_customerLocation!.latitude, _restaurantLocation!.latitude) + 0.01,
        math.max(_customerLocation!.longitude, _restaurantLocation!.longitude) + 0.01,
      ),
    );

    // Ajustar la cámara para mostrar ambas ubicaciones con padding
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0), // 100px de padding
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: primaryOrange,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: onSurfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: outlineColor.withOpacity(0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Fecha de pedido', _formatDateTime(widget.order.orderPlacedAt)),
            _buildInfoRow('Método de pago', widget.order.paymentMethod.toUpperCase()),
            _buildInfoRow('Estado de pago', widget.order.paymentStatus.toUpperCase()),
            if (widget.order.orderDeliveredAt != null)
              _buildInfoRow('Fecha de entrega', _formatDateTime(widget.order.orderDeliveredAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: outlineColor.withOpacity(0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryOrange.withOpacity(0.1),
                  child: Text(
                    widget.order.customer.name.isNotEmpty 
                        ? widget.order.customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: primaryOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.customer.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.order.customer.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: outlineColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Teléfono', widget.order.customer.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: outlineColor.withOpacity(0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.order.address.alias,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.order.address.fullAddress,
              style: TextStyle(
                fontSize: 14,
                color: outlineColor,
                height: 1.4,
              ),
            ),
            if (widget.order.specialInstructions != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryOrange.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_rounded,
                      color: primaryOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.order.specialInstructions!,
                        style: TextStyle(
                          fontSize: 14,
                          color: onSurfaceColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    final driver = widget.order.deliveryDriver!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: outlineColor.withOpacity(0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: successColor.withOpacity(0.1),
              child: const Icon(
                Icons.delivery_dining_rounded,
                color: successColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${driver.name} ${driver.lastname}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driver.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: outlineColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Implementar llamada al repartidor
              },
              icon: const Icon(Icons.phone_rounded),
              style: IconButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: outlineColor.withOpacity(0.12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: surfaceVariantColor,
                  child: item.product.imageUrl != null
                      ? Image.network(
                          item.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.restaurant_rounded,
                              color: outlineColor,
                            );
                          },
                        )
                      : Icon(
                          Icons.restaurant_rounded,
                          color: outlineColor,
                        ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Cantidad: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 13,
                            color: outlineColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '\$${item.pricePerUnit.toStringAsFixed(2)} c/u',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    if (item.modifiers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...item.modifiers.map((modifier) => Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• ${modifier.modifierOption.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: outlineColor,
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: outlineColor.withOpacity(0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPaymentRow('Subtotal', widget.order.subtotal),
            _buildPaymentRow('Comisión de entrega', widget.order.deliveryFee),
            const Divider(color: outlineColor),
            _buildPaymentRow('Total', widget.order.total, isTotal: true),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: primaryOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Restaurante recibe: \$${widget.order.restaurantPayout.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: onSurfaceColor,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? primaryOrange : onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: outlineColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onSurfaceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} a las ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}