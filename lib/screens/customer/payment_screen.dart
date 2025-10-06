import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/restaurant_cart.dart';
import '../../providers/address_provider.dart';
import '../../providers/restaurant_cart_provider.dart';
import '../../services/checkout_service.dart';
import '../../services/payment_service.dart';
import '../../services/logger_service.dart';

class PaymentScreen extends StatefulWidget {
  final RestaurantCart restaurant;
  final String? specialInstructions;

  const PaymentScreen({
    super.key,
    required this.restaurant,
    this.specialInstructions,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String? _errorMessage;
  bool _showWebView = false;
  String? _initPoint;
  WebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showWebView ? 'Pago con Mercado Pago' : 'Procesando Pago'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: _showWebView ? _buildWebView() : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return _buildProcessingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return _buildInitialView();
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Preparando pago con Mercado Pago',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Se abrirá la ventana de pago en unos momentos...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Iniciar Pago',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Procesando pago...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Por favor espera mientras se procesa tu pago',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: _cancelPayment,
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Error en el pago',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _retryPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final addressProvider = context.read<AddressProvider>();
      final deliveryAddress = addressProvider.currentDeliveryAddress;
      
      if (deliveryAddress == null) {
        throw Exception('No hay dirección de entrega seleccionada');
      }

      LoggerService.location('Iniciando proceso de pago', tag: 'PaymentScreen');
      LoggerService.location('Restaurante: ${widget.restaurant.restaurantName}', tag: 'PaymentScreen');
      LoggerService.location('Dirección: ${deliveryAddress.alias}', tag: 'PaymentScreen');

      // Crear preferencia de Mercado Pago
      LoggerService.location('Creando preferencia de Mercado Pago...', tag: 'PaymentScreen');
      final response = await CheckoutService.createMercadoPagoPreference(
        addressId: deliveryAddress.id,
        restaurantId: widget.restaurant.restaurantId,
        useCart: true,
        specialInstructions: widget.specialInstructions,
      );

      LoggerService.location('Respuesta del backend: ${response.status}', tag: 'PaymentScreen');
      LoggerService.location('Datos recibidos: ${response.data}', tag: 'PaymentScreen');

      if (response.isSuccess && response.data != null) {
        final initPoint = response.data!['init_point'] as String?;
        final externalReference = response.data!['external_reference'] as String?;
        final total = (response.data!['total'] ?? 0.0).toDouble();
        
        LoggerService.location('Init point extraído: $initPoint', tag: 'PaymentScreen');
        LoggerService.location('External reference: $externalReference', tag: 'PaymentScreen');
        LoggerService.location('Total recibido: \$${total.toStringAsFixed(2)}', tag: 'PaymentScreen');
        
        // Validar que el total sea correcto usando los datos del backend
        final subtotal = (response.data!['subtotal'] ?? 0.0).toDouble();
        final deliveryFee = (response.data!['delivery_fee'] ?? 0.0).toDouble();
        final serviceFee = (response.data!['service_fee'] ?? 0.0).toDouble();
        final expectedTotal = subtotal + deliveryFee + serviceFee;
        
        if ((total - expectedTotal).abs() > 0.01) {
          LoggerService.error('⚠️ ADVERTENCIA: Total incorrecto en Mercado Pago', tag: 'PaymentScreen');
          LoggerService.error('Subtotal: \$${subtotal.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.error('Envío: \$${deliveryFee.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.error('Servicio: \$${serviceFee.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.error('Total esperado: \$${expectedTotal.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.error('Total recibido: \$${total.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.error('Diferencia: \$${(total - expectedTotal).abs().toStringAsFixed(2)}', tag: 'PaymentScreen');
        } else {
          LoggerService.location('✅ Total correcto en Mercado Pago', tag: 'PaymentScreen');
          LoggerService.location('Subtotal: \$${subtotal.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.location('Envío: \$${deliveryFee.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.location('Servicio: \$${serviceFee.toStringAsFixed(2)}', tag: 'PaymentScreen');
          LoggerService.location('Total: \$${total.toStringAsFixed(2)}', tag: 'PaymentScreen');
        }
        
        if (initPoint != null && initPoint.isNotEmpty) {
          LoggerService.location('Preferencia creada exitosamente', tag: 'PaymentScreen');
          LoggerService.location('Abriendo Mercado Pago...', tag: 'PaymentScreen');
          
          // Abrir Mercado Pago
          final success = await PaymentService.openMercadoPago(
            initPoint: initPoint,
            context: context,
          );

          LoggerService.location('Resultado de abrir Mercado Pago: $success', tag: 'PaymentScreen');

          if (success) {
            LoggerService.location('Mercado Pago abierto exitosamente', tag: 'PaymentScreen');
            // El usuario será redirigido de vuelta a la app via deep link
            // El manejo del resultado se hace en el main.dart
          } else {
            LoggerService.location('URL Launcher falló, usando WebView como fallback', tag: 'PaymentScreen');
            // Usar WebView como fallback
            setState(() {
              _initPoint = initPoint;
              _showWebView = true;
              _isProcessing = false;
            });
          }
        } else {
          LoggerService.error('Init point es null o vacío', tag: 'PaymentScreen');
          throw Exception('No se recibió el init_point de Mercado Pago');
        }
      } else {
        LoggerService.error('Error en la respuesta del backend: ${response.message}', tag: 'PaymentScreen');
        throw Exception(response.message);
      }
    } catch (e) {
      LoggerService.error('Error en el proceso de pago: $e', tag: 'PaymentScreen');
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  void _retryPayment() {
    setState(() {
      _errorMessage = null;
    });
    _startPayment();
  }

  void _cancelPayment() {
    Navigator.of(context).pop();
  }

  /// Método para manejar el resultado del pago (llamado desde main.dart)
  void handlePaymentResult(PaymentResult result) {
    LoggerService.location('Manejando resultado del pago: $result', tag: 'PaymentScreen');
    
    setState(() {
      _isProcessing = false;
    });

    if (result.isSuccess) {
      _showSuccessMessage();
    } else if (result.isFailure) {
      _showFailureMessage();
    } else if (result.isPending) {
      _showPendingMessage();
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Pago realizado exitosamente!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Limpiar carrito y regresar
    _clearCartAndReturn();
  }

  void _showFailureMessage() {
    setState(() {
      _errorMessage = 'El pago fue rechazado. Por favor intenta nuevamente.';
    });
  }

  void _showPendingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('El pago está pendiente de confirmación. Te notificaremos cuando se confirme.'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
    
    // Regresar sin limpiar carrito (el pago está pendiente)
    Navigator.of(context).pop();
  }

  Future<void> _clearCartAndReturn() async {
    try {
      final cartProvider = context.read<RestaurantCartProvider>();
      await cartProvider.loadCart(); // Recargar para sincronizar con backend
      
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      LoggerService.error('Error al limpiar carrito: $e', tag: 'PaymentScreen');
      // Aún así regresar
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Widget _buildWebView() {
    if (_initPoint == null) {
      return const Center(
        child: Text('Error: No se encontró la URL de pago'),
      );
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            LoggerService.location('Navegando a: ${request.url}', tag: 'PaymentScreen');
            
            // Detectar deep links de retorno
            if (request.url.contains('delixmi://payment/')) {
              LoggerService.location('Deep link detectado: ${request.url}', tag: 'PaymentScreen');
              // Procesar el deep link
              final result = PaymentService.processDeepLink(request.url);
              LoggerService.location('Resultado del pago: $result', tag: 'PaymentScreen');
              
              // Mostrar notificación
              if (result.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Pago realizado exitosamente!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 4),
                  ),
                );
              } else if (result.isFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El pago fue rechazado'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              } else if (result.isPending) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El pago está pendiente de confirmación'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
              
              // Cerrar la pantalla de pago
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_initPoint!));

    return WebViewWidget(controller: _webViewController!);
  }
}
