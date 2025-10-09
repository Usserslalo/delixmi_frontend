import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/customer/order_card.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  List<Order> _deliveredOrders = []; // Solo pedidos entregados
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (refresh) {
        _currentPage = 1;
        _orders.clear();
        _deliveredOrders.clear();
        _hasMore = true;
      }
    });

    try {
      // Obtener solo pedidos entregados usando el filtro del backend
      final response = await OrderService.getOrdersHistory(
        page: _currentPage,
        pageSize: 20,
        status: 'delivered', // Filtrar solo pedidos entregados
      );

      if (response.isSuccess && response.data != null) {
        final ordersData = response.data!['orders'] as List<dynamic>? ?? [];
        final pagination = response.data!['pagination'] as Map<String, dynamic>? ?? {};
        
        final newOrders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        
        // Asegurarnos de que solo tengamos pedidos entregados
        final deliveredOrders = newOrders.where((order) => order.status == 'delivered').toList();
        
        setState(() {
          if (refresh) {
            _orders = newOrders;
            _deliveredOrders = deliveredOrders;
          } else {
            _orders.addAll(newOrders);
            _deliveredOrders.addAll(deliveredOrders);
          }
          _hasMore = pagination['hasNextPage'] == true;
          _currentPage++;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar historial de pedidos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _deliveredOrders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _deliveredOrders.isEmpty) {
      return _buildErrorView();
    }

    if (_deliveredOrders.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrders(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              _hasMore &&
              !_isLoading) {
            _loadOrders();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _deliveredOrders.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _deliveredOrders.length) {
              return OrderCard(
                order: _deliveredOrders[index],
                onTap: () => _navigateToOrderDetails(_deliveredOrders[index]),
                isHistory: true, // Indicar que es del historial
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar historial',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadOrders(refresh: true),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos completados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tus pedidos entregados aparecerán aquí',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Explorar Restaurantes'),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          orderId: order.id,
        ),
      ),
    );
  }
}

