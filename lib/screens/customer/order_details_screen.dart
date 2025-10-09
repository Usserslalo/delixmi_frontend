import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/customer/delivery_map_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔍 OrderDetailsScreen: Cargando detalles del pedido ${widget.orderId}');
      debugPrint('🔍 OrderDetailsScreen: Tipo de ID: ${widget.orderId.runtimeType}');
      debugPrint('🔍 OrderDetailsScreen: Longitud del ID: ${widget.orderId.length}');
      debugPrint('🔍 OrderDetailsScreen: ¿Es external_reference?: ${widget.orderId.startsWith('delixmi_')}');
      
      final response = await OrderService.getOrderDetails(orderId: widget.orderId);
      
      debugPrint('🔍 OrderDetailsScreen: Respuesta recibida - Status: ${response.status}');
      debugPrint('🔍 OrderDetailsScreen: Message: ${response.message}');
      debugPrint('🔍 OrderDetailsScreen: Data: ${response.data}');
      
      if (response.isSuccess && response.data != null) {
        try {
          debugPrint('🔍 OrderDetailsScreen: Parseando Order desde JSON...');
          final order = Order.fromJson(response.data!);
          debugPrint('🔍 OrderDetailsScreen: Order parseado exitosamente - ID: ${order.id}');
          
          setState(() {
            _order = order;
            _isLoading = false;
          });
        } catch (parseError) {
          debugPrint('❌ OrderDetailsScreen: Error parseando Order: $parseError');
          setState(() {
            _errorMessage = 'Error al procesar datos del pedido: $parseError';
            _isLoading = false;
          });
        }
      } else {
        debugPrint('❌ OrderDetailsScreen: Error en respuesta - ${response.message}');
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ OrderDetailsScreen: Excepción general: $e');
      setState(() {
        _errorMessage = 'Error al cargar detalles del pedido: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_order?.orderNumber ?? 'Detalles del Pedido'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navegar directamente al home, limpiando el stack
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
        ),
        actions: [
          // ❌ REMOVIDO: Los usuarios no pueden cancelar pedidos
          // if (_order?.canBeCancelled == true)
          //   TextButton(
          //     onPressed: _showCancelDialog,
          //     child: Text(
          //       'Cancelar',
          //       style: TextStyle(
          //         color: Colors.red[600],
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_order == null) {
      return const Center(
        child: Text('No se encontró el pedido'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Mapa de entrega (NUEVO - al inicio)
          _buildDeliveryMapSection(),
          
          // Estado del pedido
          _buildStatusSection(),
          
          // Información del restaurante
          _buildRestaurantSection(),
          
          // Resumen del pedido
          _buildOrderSummarySection(),
          
          // Información de pago
          _buildPaymentSection(),
          
          const SizedBox(height: 24),
        ],
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
            'Error al cargar pedido',
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
            onPressed: _loadOrderDetails,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ubicación de Entrega',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Mapa de Google Maps
          DeliveryMapWidget(
            deliveryAddress: _order!.deliveryAddress,
            restaurant: _order!.restaurant,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Estado del Pedido',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Estado actual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(_order!.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(_order!.status).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(_order!.status),
                  color: _getStatusColor(_order!.status),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _order!.statusDisplayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getStatusColor(_order!.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timeline de estados (simplificado)
          _buildSimpleTimeline(),
        ],
      ),
    );
  }

  Widget _buildSimpleTimeline() {
    // Definir los pasos del pedido en orden
    final orderSteps = [
      {
        'status': 'pending',
        'title': 'Pedido Realizado',
        'description': 'Tu pedido ha sido recibido',
        'icon': Icons.schedule,
      },
      {
        'status': 'confirmed',
        'title': 'Pedido Confirmado',
        'description': 'El restaurante ha confirmado tu pedido',
        'icon': Icons.check_circle,
      },
      {
        'status': 'preparing',
        'title': 'En Preparación',
        'description': 'Tu pedido está siendo preparado',
        'icon': Icons.restaurant,
      },
      {
        'status': 'out_for_delivery',
        'title': 'En Camino',
        'description': 'Tu pedido está en camino',
        'icon': Icons.delivery_dining,
      },
      {
        'status': 'delivered',
        'title': 'Entregado',
        'description': 'Tu pedido ha sido entregado',
        'icon': Icons.check_circle_outline,
      },
    ];

    return Column(
      children: orderSteps.map((step) {
        // Determinar si este paso está activo basado en el estado del pedido
        final isActive = _isStepActive(step['status'] as String);
        
        return _buildTimelineItem(
          step['title'] as String,
          step['description'] as String,
          isActive,
          step['icon'] as IconData,
        );
      }).toList(),
    );
  }

  /// Determina si un paso específico está activo basado en el estado del pedido
  bool _isStepActive(String stepStatus) {
    if (_order == null) return false;
    
    final currentStatus = _order!.status;
    
    // Debug: Imprimir el estado actual del pedido
    print('🔍 OrderDetailsScreen: Estado actual del pedido: $currentStatus');
    print('🔍 OrderDetailsScreen: Verificando paso: $stepStatus');
    
    // Mapeo de estados para determinar qué paso está activo
    switch (currentStatus) {
      case 'pending':
        return stepStatus == 'pending';
      case 'confirmed':
        return stepStatus == 'confirmed';
      case 'preparing':
        return stepStatus == 'preparing';
      case 'ready_for_pickup':
        return stepStatus == 'preparing'; // Listo para recoger sigue siendo "En preparación"
      case 'out_for_delivery':
        return stepStatus == 'out_for_delivery';
      case 'delivered':
        return stepStatus == 'delivered';
      case 'cancelled':
      case 'refunded':
        return stepStatus == 'pending'; // Pedidos cancelados vuelven al primer paso
      default:
        return stepStatus == 'pending';
    }
  }

  Widget _buildTimelineItem(String title, String description, bool isActive, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.orange : Colors.grey[300],
            ),
            child: Icon(
              icon,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.orange : Colors.grey[600],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Restaurante',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _order!.restaurant.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _order!.restaurant.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.restaurant,
                            color: Colors.grey[600],
                            size: 30,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.restaurant,
                        color: Colors.grey[600],
                        size: 30,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order!.restaurant.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order!.restaurant.branch.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _order!.restaurant.branch.address,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _order!.restaurant.branch.phone,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen del Pedido',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lista de productos
          ..._order!.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.fastfood,
                              color: Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fastfood,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cantidad: ${item.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const Divider(),
          
          // Totales
          _buildTotalRow('Subtotal', _order!.subtotal),
          _buildTotalRow('Costo de envío', _order!.deliveryFee),
          _buildTotalRow('Cuota de servicio', _order!.serviceFee),
          const Divider(),
          _buildTotalRow('TOTAL', _order!.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _order!.paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Información de Pago',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Método de pago',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                _order!.paymentMethod == 'cash' ? 'Efectivo' : 'Tarjeta',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estado del pago',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(_order!.paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getPaymentStatusColor(_order!.paymentStatus).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _order!.paymentStatusDisplayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getPaymentStatusColor(_order!.paymentStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready_for_pickup':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready_for_pickup':
        return Icons.store;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // ❌ REMOVIDO: Funcionalidad de cancelación no disponible para usuarios
  // void _showCancelDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Cancelar Pedido'),
  //       content: const Text('¿Estás seguro de que quieres cancelar este pedido?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('No'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             _cancelOrder();
  //           },
  //           style: TextButton.styleFrom(
  //             foregroundColor: Colors.red,
  //           ),
  //           child: const Text('Sí, cancelar'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _cancelOrder() async {
  //   try {
  //     final response = await OrderService.cancelOrder(
  //       orderId: widget.orderId,
  //       reason: 'Cancelado por el usuario',
  //     );

  //     if (response.isSuccess) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Pedido cancelado exitosamente'),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //         _loadOrderDetails(); // Recargar detalles
  //       }
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error al cancelar pedido: ${response.message}'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error al cancelar pedido: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }
}
