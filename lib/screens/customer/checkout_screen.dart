import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/restaurant_cart.dart';
import '../../models/checkout_summary.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../services/checkout_service.dart';
import 'addresses_screen.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final RestaurantCart restaurant;

  const CheckoutScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutSummary? _checkoutSummary;
  String _paymentMethod = 'cash';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCheckoutSummary();
    });
  }

  Future<void> _calculateCheckoutSummary() async {
    final addressProvider = context.read<AddressProvider>();
    final deliveryAddress = addressProvider.currentDeliveryAddress;
    
    if (deliveryAddress != null) {
      try {
        // Obtener cálculos reales del backend
        final response = await CheckoutService.createMercadoPagoPreference(
          addressId: deliveryAddress.id,
          restaurantId: widget.restaurant.restaurantId,
          useCart: true,
        );
        
        if (response.isSuccess && response.data != null) {
          // Calcular subtotal correctamente desde los items del carrito (incluye modificadores)
          final calculatedSubtotal = widget.restaurant.items.fold(0.0, (sum, item) => sum + item.subtotal);
          final deliveryFee = (response.data!['delivery_fee'] ?? 0.0).toDouble();
          final serviceFee = (response.data!['service_fee'] ?? 0.0).toDouble();
          final estimatedDeliveryTime = response.data!['estimated_delivery_time']?['timeRange'] ?? '30-45 min';
          
          // Usar el subtotal calculado del frontend (que incluye modificadores) en lugar del backend
          final correctedTotal = calculatedSubtotal + deliveryFee + serviceFee;
          
          setState(() {
            _checkoutSummary = CheckoutSummary(
              items: widget.restaurant.items,
              deliveryAddress: deliveryAddress,
              subtotal: calculatedSubtotal, // Usar subtotal calculado del frontend
              deliveryFee: deliveryFee,
              serviceFee: serviceFee,
              total: correctedTotal, // Recalcular total con subtotal correcto
              estimatedDeliveryTime: estimatedDeliveryTime,
              paymentMethod: _paymentMethod,
            );
          });
        } else {
          // Fallback a valores por defecto si falla la API
          _calculateCheckoutSummaryFallback(deliveryAddress);
        }
      } catch (e) {
        debugPrint('Error al obtener cálculos del backend: $e');
        // Fallback a valores por defecto
        _calculateCheckoutSummaryFallback(deliveryAddress);
      }
    }
  }
  
  void _calculateCheckoutSummaryFallback(Address deliveryAddress) {
    setState(() {
      _checkoutSummary = CheckoutSummary.calculate(
        items: widget.restaurant.items,
        deliveryAddress: deliveryAddress,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu pedido'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          // Recalcular el resumen cuando cambie la dirección
          final deliveryAddress = addressProvider.currentDeliveryAddress;
          if (deliveryAddress != null && _checkoutSummary?.deliveryAddress.id != deliveryAddress.id) {
            // Solo recalcular si cambió la dirección
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _calculateCheckoutSummary();
            });
          }

          return _checkoutSummary == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Mapa de entrega
                      _buildDeliveryMap(),
                      
                      // Información de entrega
                      _buildDeliveryInfo(),
                      
                      // Resumen del pedido
                      _buildOrderSummary(),
                      
                      // Método de pago
                      _buildPaymentMethod(),
                      
                      // Botón hacer pedido
                      _buildOrderButton(),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildDeliveryMap() {
    if (_checkoutSummary == null) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final deliveryAddress = _checkoutSummary!.deliveryAddress;
    final deliveryLocation = LatLng(
      deliveryAddress.latitude,
      deliveryAddress.longitude,
    );

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Mapa de Google Maps
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: deliveryLocation,
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                // Controller disponible si se necesita en el futuro
              },
              markers: {
                Marker(
                  markerId: const MarkerId('delivery_location'),
                  position: deliveryLocation,
                  infoWindow: InfoWindow(
                    title: 'Ubicación de entrega',
                    snippet: '${deliveryAddress.street}, ${deliveryAddress.city}',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: true,
            ),
            
            // Overlay con información
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Entrega: ${deliveryAddress.city}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botón para cambiar dirección
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _navigateToAddresses(),
                  icon: Icon(
                    Icons.edit_location,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dirección de entrega',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _checkoutSummary!.deliveryAddress.fullAddress,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Tiempo estimado: ${_formatEstimatedTime(_checkoutSummary!.estimatedDeliveryTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen del pedido',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.productName} x${item.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      // Mostrar modificadores si existen
                      if (item.modifiers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ...item.modifiers.map((modifier) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '• ${modifier.name} (+\$${modifier.price.toStringAsFixed(2)})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                      ],
                    ],
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
          _buildTotalRow('Subtotal', _checkoutSummary!.subtotal),
          _buildTotalRow('Costo de envío', _checkoutSummary!.deliveryFee),
          _buildTotalRow('Cuota de servicio', _checkoutSummary!.serviceFee),
          const Divider(),
          _buildTotalRow('TOTAL', _checkoutSummary!.total, isTotal: true),
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

  Widget _buildPaymentMethod() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
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
                Icons.payment,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Método de pago',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Opciones de pago
          RadioListTile<String>(
            title: const Text('Efectivo'),
            subtitle: const Text('Paga al recibir tu pedido'),
            value: 'cash',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          RadioListTile<String>(
            title: const Text('Tarjeta'),
            subtitle: const Text('Pago seguro con Mercado Pago'),
            value: 'card',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _processOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Hacer pedido',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _navigateToAddresses() async {
    final selectedAddress = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddressesScreen(
          isSelectionMode: true,
        ),
      ),
    );
    
    // Si se seleccionó una dirección, actualizar el estado
    if (selectedAddress != null && selectedAddress is Address) {
      final addressProvider = context.read<AddressProvider>();
      addressProvider.selectAddress(selectedAddress);
      
      // Mostrar mensaje de confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dirección de entrega cambiada a "${selectedAddress.alias}"'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _processOrder() {
    if (_checkoutSummary == null) return;

    // Navegar a la vista de confirmación
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          restaurant: widget.restaurant,
          paymentMethod: _paymentMethod,
        ),
      ),
    );
  }

  String _formatEstimatedTime(String timeString) {
    // Si el tiempo viene con decimales extraños, formatearlo correctamente
    if (timeString.contains('.')) {
      try {
        // Extraer números del string
        final RegExp regex = RegExp(r'(\d+\.?\d*)-(\d+\.?\d*)');
        final Match? match = regex.firstMatch(timeString);
        
        if (match != null) {
          final double minMinutes = double.parse(match.group(1)!);
          final double maxMinutes = double.parse(match.group(2)!);
          
          // Redondear a números enteros
          final int roundedMin = minMinutes.round();
          final int roundedMax = maxMinutes.round();
          
          return '${roundedMin}-${roundedMax} min';
        }
      } catch (e) {
        debugPrint('Error al formatear tiempo: $e');
      }
    }
    
    // Si ya está bien formateado o hay error, devolver tal como está
    return timeString;
  }
}