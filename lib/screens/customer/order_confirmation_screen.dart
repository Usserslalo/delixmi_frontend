import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_cart.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/checkout_provider.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final RestaurantCart restaurant;
  final String paymentMethod;
  final Address deliveryAddress;

  const OrderConfirmationScreen({
    super.key,
    required this.restaurant,
    required this.paymentMethod,
    required this.deliveryAddress,
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

    // Auto-confirmar cuando llegue a 0 (CON BLOQUEO ESTRICTO)
    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isCancelled) {
        final checkoutProvider = context.read<CheckoutProvider>();
        if (!checkoutProvider.isProcessing) {
          debugPrint('⏰ Countdown completado - Intentando auto-confirmar pedido');
          _confirmOrder();
        } else {
          debugPrint('🚫 Auto-confirmación BLOQUEADA - Ya se está procesando un pedido');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Confirmar Pedido',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        elevation: 1,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, child) {
            if (checkoutProvider.isProcessing) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: _cancelOrder,
            );
          },
        ),
      ),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          if (checkoutProvider.isProcessing) {
            return _buildProcessingView();
          }
          
          if (_isCancelled) {
            return _buildCancelledView();
          }
          
          return _buildConfirmationView();
        },
      ),
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _countdown <= 5 
                            ? [
                                Theme.of(context).colorScheme.errorContainer,
                                Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.8),
                              ]
                            : [
                                Theme.of(context).colorScheme.primaryContainer,
                                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
                              ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _countdown <= 5 
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_countdown <= 5 
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_countdown',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _countdown <= 5 
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Confirmando pedido automáticamente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tu pedido se confirmará en $_countdown segundos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Address deliveryAddress) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.restaurant.restaurantName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          
            // Lista de productos
            ...widget.restaurant.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.productName} x${item.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        // Mostrar modificadores si existen
                        if (item.modifiers.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          ...item.modifiers.map((modifier) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${modifier.name} (+\$${modifier.price.toStringAsFixed(2)})',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          
            const SizedBox(height: 16),
            
            // Totales
            _buildTotalRow('Subtotal', widget.restaurant.subtotal),
            _buildTotalRow('Costo de envío', 25.0),
            _buildTotalRow('Cuota de servicio', widget.restaurant.subtotal * 0.05),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: _buildTotalRow('TOTAL', widget.restaurant.subtotal + 25.0 + (widget.restaurant.subtotal * 0.05), isTotal: true),
            ),
          ],
        ),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Información de entrega',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                deliveryAddress.fullAddress,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tiempo estimado: 30-45 min',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.paymentMethod == 'cash' ? Icons.money_rounded : Icons.credit_card_rounded,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pago: ${widget.paymentMethod == 'cash' ? 'Efectivo' : 'Tarjeta'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: checkoutProvider.isProcessing ? null : _cancelOrder,
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: FilledButton.icon(
                    // 🔒 BLOQUEO GLOBAL: Botón deshabilitado si está procesando
                    onPressed: checkoutProvider.isProcessing ? null : () {
                      debugPrint('🔘 Botón "Confirmar Ahora" presionado');
                      _confirmOrder();
                    },
                    icon: checkoutProvider.isProcessing 
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      checkoutProvider.isProcessing ? 'Procesando...' : 'Confirmar Ahora',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: checkoutProvider.isProcessing 
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: checkoutProvider.isProcessing 
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: checkoutProvider.isProcessing ? 0 : 2,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El pedido se confirmará automáticamente si no tomas acción',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Procesando tu pedido...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Por favor espera un momento mientras procesamos tu pedido',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Pedido Cancelado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tu pedido ha sido cancelado exitosamente',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Volver al Carrito'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
    final checkoutProvider = context.read<CheckoutProvider>();
    
    // 🔒 BLOQUEO GLOBAL: Si ya se está procesando, ignorar completamente
    if (checkoutProvider.isProcessing) {
      debugPrint('🚫 _confirmOrder: BLOQUEO GLOBAL ACTIVADO - Ignorando llamada duplicada');
      return;
    }
    
    debugPrint('🔒 _confirmOrder: Iniciando procesamiento con CheckoutProvider');

    try {
      // Usar el CheckoutProvider para manejar el checkout
      await checkoutProvider.startCheckout(
        paymentMethod: widget.paymentMethod == 'cash' ? PaymentMethod.cash : PaymentMethod.card,
        restaurant: widget.restaurant,
        address: widget.deliveryAddress,
        context: context,
        specialInstructions: null,
      );
    } catch (e) {
      debugPrint('Error en _confirmOrder: $e');
      // El error ya se maneja en el CheckoutProvider
    }
  }

}
