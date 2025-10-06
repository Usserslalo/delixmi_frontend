import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/cart_item.dart';
import '../models/restaurant_cart.dart';
import '../services/cart_service.dart';

class RestaurantCartProvider extends ChangeNotifier {
  List<RestaurantCart> _restaurantCarts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<RestaurantCart> get restaurantCarts => _restaurantCarts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _restaurantCarts.isEmpty;
  bool get isNotEmpty => _restaurantCarts.isNotEmpty;

  /// Total de items en el carrito
  int get totalItems {
    return _restaurantCarts.fold(0, (sum, restaurant) => sum + restaurant.totalItems);
  }

  /// Subtotal total del carrito
  double get subtotal {
    return _restaurantCarts.fold(0.0, (sum, restaurant) => sum + restaurant.subtotal);
  }

  /// Cantidad de restaurantes en el carrito
  int get restaurantCount => _restaurantCarts.length;

  /// Cargar carrito del usuario
  Future<void> loadCart() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🛒 RestaurantCartProvider: Cargando carrito...');
      
      // Ejecutar diagnóstico si es la primera vez (deshabilitado temporalmente)
      // if (_restaurantCarts.isEmpty) {
      //   await CartService.diagnoseConnection();
      // }
      
      final response = await CartService.getCart();

      if (response.isSuccess && response.data != null) {
        _restaurantCarts = response.data!;
        debugPrint('🛒 RestaurantCartProvider: Carrito cargado - ${_restaurantCarts.length} restaurantes');
      } else {
        _setError(response.message);
        debugPrint('❌ RestaurantCartProvider: Error al cargar carrito: ${response.message}');
      }
    } catch (e) {
      _setError('Error al cargar carrito: $e');
      debugPrint('❌ RestaurantCartProvider: Excepción al cargar carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar resumen del carrito (para el badge en la navegación)
  Future<void> loadCartSummary() async {
    try {
      debugPrint('🛒 RestaurantCartProvider: Cargando resumen del carrito...');
      final response = await CartService.getCart();
      
      if (response.isSuccess && response.data != null) {
        _restaurantCarts = response.data!;
        debugPrint('🛒 RestaurantCartProvider: Resumen cargado - ${totalItems} items totales');
      }
    } catch (e) {
      debugPrint('❌ RestaurantCartProvider: Error al cargar resumen: $e');
    }
  }

  /// Agregar producto al carrito
  Future<bool> addToCart({
    required int productId,
    required int quantity,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🛒 RestaurantCartProvider: Agregando producto $productId al carrito...');
      final response = await CartService.addToCart(
        productId: productId,
        quantity: quantity,
      );

      if (response.isSuccess) {
        await loadCart(); // Recargar carrito
        debugPrint('✅ RestaurantCartProvider: Producto agregado exitosamente');
        return true;
      } else {
        _setError(response.message);
        debugPrint('❌ RestaurantCartProvider: Error al agregar producto: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al agregar producto al carrito: $e');
      debugPrint('❌ RestaurantCartProvider: Excepción al agregar producto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar cantidad de item
  Future<bool> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🛒 RestaurantCartProvider: Actualizando cantidad del item $itemId...');
      final response = await CartService.updateQuantity(
        itemId: itemId,
        quantity: quantity,
      );

      if (response.isSuccess) {
        await loadCart(); // Recargar carrito
        debugPrint('✅ RestaurantCartProvider: Cantidad actualizada exitosamente');
        return true;
      } else {
        _setError(response.message);
        debugPrint('❌ RestaurantCartProvider: Error al actualizar cantidad: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar cantidad: $e');
      debugPrint('❌ RestaurantCartProvider: Excepción al actualizar cantidad: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar item del carrito
  Future<bool> removeFromCart({
    required int itemId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🛒 RestaurantCartProvider: Eliminando item $itemId del carrito...');
      final response = await CartService.removeFromCart(itemId: itemId);

      if (response.isSuccess) {
        await loadCart(); // Recargar carrito
        debugPrint('✅ RestaurantCartProvider: Producto eliminado exitosamente');
        return true;
      } else {
        _setError(response.message);
        debugPrint('❌ RestaurantCartProvider: Error al eliminar producto: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar producto: $e');
      debugPrint('❌ RestaurantCartProvider: Excepción al eliminar producto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpiar carrito
  Future<bool> clearCart() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🛒 RestaurantCartProvider: Limpiando carrito...');
      final response = await CartService.clearCart();

      if (response.isSuccess) {
        _restaurantCarts = [];
        debugPrint('✅ RestaurantCartProvider: Carrito limpiado exitosamente');
        return true;
      } else {
        _setError(response.message);
        debugPrint('❌ RestaurantCartProvider: Error al limpiar carrito: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al limpiar carrito: $e');
      debugPrint('❌ RestaurantCartProvider: Excepción al limpiar carrito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpiar carrito de un restaurante específico
  Future<bool> clearRestaurantCart(int restaurantId) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🛒 RestaurantCartProvider: Limpiando carrito del restaurante $restaurantId...');
      
      // Filtrar el carrito para remover solo el restaurante específico
      _restaurantCarts.removeWhere((cart) => cart.restaurantId == restaurantId);
      
      debugPrint('✅ RestaurantCartProvider: Carrito del restaurante $restaurantId limpiado exitosamente');
      debugPrint('🛒 RestaurantCartProvider: Carritos restantes: ${_restaurantCarts.length}');
      
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _setError('Error al limpiar carrito del restaurante: $e');
      debugPrint('❌ RestaurantCartProvider: Excepción al limpiar carrito del restaurante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener carrito de un restaurante específico
  RestaurantCart? getRestaurantCart(int restaurantId) {
    try {
      return _restaurantCarts.firstWhere((cart) => cart.restaurantId == restaurantId);
    } catch (e) {
      return null;
    }
  }

  /// Obtener producto del carrito por ID
  CartItem? getCartItem(int productId) {
    for (final restaurantCart in _restaurantCarts) {
      final item = restaurantCart.getItemByProductId(productId);
      if (item != null) return item;
    }
    return null;
  }

  /// Verificar si un producto está en el carrito
  bool hasProduct(int productId) {
    return _restaurantCarts.any((restaurant) => restaurant.hasProduct(productId));
  }

  /// Obtener cantidad de un producto en el carrito
  int getProductQuantity(int productId) {
    final item = getCartItem(productId);
    return item?.quantity ?? 0;
  }

  /// Obtener subtotal por restaurante
  double getSubtotalForRestaurant(int restaurantId) {
    final restaurantCart = getRestaurantCart(restaurantId);
    return restaurantCart?.subtotal ?? 0.0;
  }

  /// Obtener todos los items de un restaurante específico
  List<CartItem> getItemsForRestaurant(int restaurantId) {
    final restaurantCart = getRestaurantCart(restaurantId);
    return restaurantCart?.items ?? [];
  }

  /// Obtener todos los items de todos los restaurantes
  List<CartItem> getAllItems() {
    List<CartItem> allItems = [];
    for (final restaurantCart in _restaurantCarts) {
      allItems.addAll(restaurantCart.items);
    }
    return allItems;
  }

  /// Obtener resumen del carrito
  Future<Map<String, dynamic>> getCartSummary() async {
    try {
      return await CartService.getCartSummary();
    } catch (e) {
      debugPrint('❌ RestaurantCartProvider: Error al obtener resumen: $e');
      return {
        'totalItems': totalItems,
        'totalAmount': subtotal,
        'restaurantCount': restaurantCount,
      };
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  /// Notificar cambios de manera segura, evitando llamadas durante el build
  void _safeNotifyListeners() {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Limpiar estado del provider
  void clear() {
    _restaurantCarts = [];
    _errorMessage = null;
    _isLoading = false;
    _safeNotifyListeners();
  }
}
