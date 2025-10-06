import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_cart.dart';
import '../../models/address.dart';
import '../../models/api_response.dart';
import '../../providers/restaurant_cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../services/checkout_service.dart';
import 'payment_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final RestaurantCart restaurant;
  final String paymentMethod;

  const OrderConfirmationScreen({
    super.key,
    required this.restaurant,
    required this.paymentMethod,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _countdown = 15;
  bool _isProcessing = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _countdownController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _startCountdown() {
    _countdownController.forward();
    
    // Actualizar countdown cada segundo
    _countdownController.addListener(() {
      if (mounted) {
        setState(() {
          _countdown = 15 - (_countdownController.value * 15).round();
        });
      }
    });

    // Auto-confirmar cuando llegue a 0
    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isCancelled && !_isProcessing) {
        _confirmOrder();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: _isProcessing 
            ? null 
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelOrder,
              ),
      ),
      body: _isProcessing
          ? _buildProcessingView()
          : _isCancelled
              ? _buildCancelledView()
              : _buildConfirmationView(),
    );
  }

  Widget _buildConfirmationView() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        final deliveryAddress = addressProvider.currentDeliveryAddress;
        
        if (deliveryAddress == null) {
          return const Center(
            child: Text('No hay dirección de entrega seleccionada'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header con countdown
              _buildCountdownHeader(),
              
              const SizedBox(height: 24),
              
              // Resumen del pedido
              _buildOrderSummary(deliveryAddress),
              
              const SizedBox(height: 24),
              
              // Información de entrega
              _buildDeliveryInfo(deliveryAddress),
              
              const SizedBox(height: 32),
              
              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _countdown <= 5 ? Colors.red[50] : Colors.orange[50],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _countdown <= 5 ? Colors.red[300]! : Colors.orange[300]!,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _countdown <= 5 ? Colors.red[700] : Colors.orange[700],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Confirmando pedido automáticamente',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Tu pedido se confirmará en $_countdown segundos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Address deliveryAddress) {
    return Container(
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
              Expanded(
                child: Text(
                  widget.restaurant.restaurantName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lista de productos
          ...widget.restaurant.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.productName} x${item.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const Divider(),
          
          // Totales
          _buildTotalRow('Subtotal', widget.restaurant.subtotal),
          _buildTotalRow('Costo de envío', 25.0),
          _buildTotalRow('Cuota de servicio', widget.restaurant.subtotal * 0.05),
          const Divider(),
          _buildTotalRow('TOTAL', widget.restaurant.subtotal + 25.0 + (widget.restaurant.subtotal * 0.05), isTotal: true),
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

  Widget _buildDeliveryInfo(Address deliveryAddress) {
    return Container(
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
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Dirección de entrega',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            deliveryAddress.fullAddress,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tiempo estimado: 30-45 min',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                widget.paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pago: ${widget.paymentMethod == 'cash' ? 'Efectivo' : 'Tarjeta'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isProcessing ? null : _cancelOrder,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red[300]!),
              foregroundColor: Colors.red[700],
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Confirmar Ahora',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Procesando tu pedido...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor espera un momento',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cancel_outlined,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Pedido Cancelado',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu pedido ha sido cancelado exitosamente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al Carrito'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder() {
    setState(() {
      _isCancelled = true;
      _countdownController.stop();
    });
  }

  Future<void> _confirmOrder() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final addressProvider = context.read<AddressProvider>();
      final deliveryAddress = addressProvider.currentDeliveryAddress;
      
      if (deliveryAddress == null) {
        throw Exception('No hay dirección de entrega seleccionada');
      }

      // Preparar items para el pedido
      final items = widget.restaurant.items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
      }).toList();

      ApiResponse<Map<String, dynamic>> response;

      if (widget.paymentMethod == 'cash') {
        // Crear pedido de efectivo
        response = await CheckoutService.createCashOrder(
          addressId: deliveryAddress.id,
          restaurantId: widget.restaurant.restaurantId,
          items: items,
        );
      } else {
        // Navegar a pantalla de pago con Mercado Pago
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              restaurant: widget.restaurant,
              specialInstructions: null, // No hay specialInstructions en este contexto
            ),
          ),
        );
        return; // No continuar con el flujo normal
      }

      if (response.isSuccess && response.data != null) {
        // Limpiar carrito
        await _clearCart();
        
        if (mounted) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.paymentMethod == 'cash'
                    ? 'Pedido creado exitosamente. Paga en efectivo al recibir.'
                    : 'Pedido creado exitosamente. Redirigiendo a Mercado Pago...',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navegar de regreso
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearCart() async {
    try {
      final restaurantCartProvider = context.read<RestaurantCartProvider>();
      
      // El backend ahora limpia automáticamente el carrito
      // Solo necesitamos recargar para sincronizar con el backend
      await Future.delayed(const Duration(milliseconds: 1000));
      await restaurantCartProvider.loadCart();
      
      debugPrint('✅ Carrito recargado después de limpieza automática del backend');
    } catch (e) {
      debugPrint('Error al recargar carrito: $e');
    }
  }
}
