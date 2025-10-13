import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant_cart.dart';
import '../models/address.dart';
import '../services/checkout_service.dart';
import '../services/logger_service.dart';
import 'restaurant_cart_provider.dart';
import '../screens/customer/payment_screen.dart';

enum PaymentMethod {
  cash,
  card,
}

class CheckoutProvider extends ChangeNotifier {
  // 🔒 BLOQUEO GLOBAL A PRUEBA DE BALAS
  bool _isProcessing = false;
  
  // Estado del checkout actual
  String? _currentPaymentMethod;
  RestaurantCart? _currentRestaurant;
  Address? _currentAddress;
  String? _specialInstructions;
  
  // Getters
  bool get isProcessing => _isProcessing;
  String? get currentPaymentMethod => _currentPaymentMethod;
  RestaurantCart? get currentRestaurant => _currentRestaurant;
  Address? get currentAddress => _currentAddress;
  String? get specialInstructions => _specialInstructions;
  
  /// 🔒 MÉTODO ÚNICO PARA INICIAR CUALQUIER TIPO DE CHECKOUT
  /// Este es el ÚNICO lugar en toda la app que puede iniciar un pago
  Future<void> startCheckout({
    required PaymentMethod paymentMethod,
    required RestaurantCart restaurant,
    required Address address,
    required BuildContext context,
    String? specialInstructions,
  }) async {
    // 🚫 BLOQUEO GLOBAL: Si ya se está procesando, ignorar completamente
    if (_isProcessing) {
      LoggerService.location('🚫 BLOQUEO GLOBAL ACTIVADO - Ignorando llamada duplicada', tag: 'CheckoutProvider');
      return;
    }
    
    // 🔒 ACTIVAR BLOQUEO GLOBAL INMEDIATAMENTE
    _isProcessing = true;
    _currentPaymentMethod = paymentMethod.name;
    _currentRestaurant = restaurant;
    _currentAddress = address;
    _specialInstructions = specialInstructions;
    notifyListeners();
    
    LoggerService.location('🔒 BLOQUEO GLOBAL ACTIVADO - Iniciando checkout ${paymentMethod.name}', tag: 'CheckoutProvider');
    
    try {
      if (paymentMethod == PaymentMethod.cash) {
        await _processCashPayment(context);
        // Para efectivo, desactivar bloqueo después de completar
        _resetProcessingState();
      } else if (paymentMethod == PaymentMethod.card) {
        await _processCardPayment(context);
        // Para tarjeta, mantener bloqueo activo hasta que se complete el pago
        // El bloqueo se desactivará cuando se complete el pago en PaymentScreen
      }
    } catch (e) {
      LoggerService.error('Error en checkout: $e', tag: 'CheckoutProvider');
      if (context.mounted) {
        _showErrorMessage(context, e.toString());
      }
      // En caso de error, desactivar bloqueo
      _resetProcessingState();
    }
  }
  
  /// Procesar pago en efectivo
  Future<void> _processCashPayment(BuildContext context) async {
    LoggerService.location('💰 Procesando pago en efectivo', tag: 'CheckoutProvider');
    
    if (_currentAddress == null || _currentRestaurant == null) {
      LoggerService.error('Error: _currentAddress o _currentRestaurant es null', tag: 'CheckoutProvider');
      throw Exception('Dirección o restaurante no disponibles para el checkout');
    }
    
    final response = await CheckoutService.createCashOrderFromCart(
      addressId: _currentAddress!.id,
      restaurantId: _currentRestaurant!.restaurantId,
      specialInstructions: _specialInstructions,
    );
    
    if (response.isSuccess && response.data != null) {
      LoggerService.location('✅ Pedido en efectivo creado exitosamente', tag: 'CheckoutProvider');
      
      // Limpiar carrito solo si el contexto está montado
      if (context.mounted) {
        await _clearCart(context);
        
        // Verificar contexto después de operación async
        if (context.mounted) {
          _showSuccessMessage(
            context, 
            'Pedido creado exitosamente. Paga en efectivo al recibir.',
          );
          
          // Navegar de regreso
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } else {
      throw Exception(response.message);
    }
  }
  
  /// Procesar pago con tarjeta
  Future<void> _processCardPayment(BuildContext context) async {
    LoggerService.location('💳 Procesando pago con tarjeta', tag: 'CheckoutProvider');
    
    if (_currentRestaurant == null) {
      LoggerService.error('Error: _currentRestaurant es null', tag: 'CheckoutProvider');
      throw Exception('Restaurante no disponible para el checkout');
    }
    
    // Navegar directamente a PaymentScreen solo si el contexto está montado
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            restaurant: _currentRestaurant!,
            specialInstructions: _specialInstructions,
          ),
        ),
      );
    }
  }
  
  /// Limpiar carrito después del pedido
  Future<void> _clearCart(BuildContext context) async {
    try {
      final cartProvider = Provider.of<RestaurantCartProvider>(context, listen: false);
      await Future.delayed(const Duration(milliseconds: 1000));
      await cartProvider.loadCart();
      LoggerService.location('✅ Carrito recargado después de limpieza', tag: 'CheckoutProvider');
    } catch (e) {
      LoggerService.error('Error al recargar carrito: $e', tag: 'CheckoutProvider');
    }
  }
  
  /// Mostrar mensaje de éxito
  void _showSuccessMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  /// Mostrar mensaje de error
  void _showErrorMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $message'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  /// Resetear estado de procesamiento
  void _resetProcessingState() {
    _isProcessing = false;
    _currentPaymentMethod = null;
    _currentRestaurant = null;
    _currentAddress = null;
    _specialInstructions = null;
    notifyListeners();
    LoggerService.location('🔓 BLOQUEO GLOBAL DESACTIVADO', tag: 'CheckoutProvider');
  }
  
  /// Cancelar checkout actual
  void cancelCheckout() {
    if (_isProcessing) {
      LoggerService.location('❌ Cancelando checkout actual', tag: 'CheckoutProvider');
      _resetProcessingState();
    }
  }
  
  /// Completar checkout (llamado desde PaymentScreen cuando se complete el pago)
  void completeCheckout() {
    if (_isProcessing) {
      LoggerService.location('✅ Completando checkout', tag: 'CheckoutProvider');
      _resetProcessingState();
    }
  }
}

