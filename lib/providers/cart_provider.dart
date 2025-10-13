import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/restaurant_cart.dart';
import '../models/modifier_selection.dart';
import '../services/cart_service.dart';
import '../services/error_handler.dart';

class CartProvider extends ChangeNotifier {
  List<Cart> _carts = [];
  CartSummary? _summary;
  bool _isLoading = false;
  String? _errorMessage;
  int _totalItems = 0;

  // Getters
  List<Cart> get carts => _carts;
  CartSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalItems => _totalItems;
  bool get isEmpty => _carts.isEmpty;
  bool get isNotEmpty => _carts.isNotEmpty;
  bool get isModifiersRequiredError => _errorMessage == 'MODIFIERS_REQUIRED';

  /// Obtener carrito completo
  Future<void> loadCart() async {
    _setLoading(true);
    _clearError();

    try {
      // debugPrint('🛒 CartProvider: Cargando carrito...');
      final response = await CartService.getCart();

      if (response.isSuccess && response.data != null) {
        // Usar el nuevo servicio que retorna List<RestaurantCart>
        final restaurantCarts = response.data as List<RestaurantCart>;
        _carts = []; // Limpiar carritos antiguos
        _totalItems = restaurantCarts.fold(0, (sum, cart) => sum + cart.totalItems);
        // debugPrint('🛒 CartProvider: Carrito cargado - ${restaurantCarts.length} restaurantes, $_totalItems items');
      } else {
        _setError(response.message);
        // debugPrint('❌ CartProvider: Error al cargar carrito: ${response.message}');
      }
    } catch (e) {
      _setError('Error al cargar carrito: $e');
      ErrorHandler.logError('CartProvider.loadCart', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener resumen del carrito
  Future<void> loadCartSummary() async {
    try {
      // debugPrint('🛒 CartProvider: Cargando resumen del carrito...');
      final summary = await CartService.getCartSummary();

      _totalItems = summary['totalItems'] ?? 0;
      // debugPrint('🛒 CartProvider: Resumen cargado - $_totalItems items');
    } catch (e) {
      // debugPrint('❌ CartProvider: Excepción al cargar resumen: $e');
    }
  }

  /// Agregar producto al carrito con nuevo formato de modificadores
  Future<bool> addToCart({
    required int productId,
    required int quantity,
    List<ModifierSelection>? modifiers,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // debugPrint('🛒 CartProvider: Agregando producto $productId (cantidad: $quantity)...');
      if (modifiers != null && modifiers.isNotEmpty) {
        // debugPrint('🛒 CartProvider: Con modificadores (nuevo formato): $modifiers');
      }
      
      final response = await CartService.addToCart(
        productId: productId,
        quantity: quantity,
        modifiers: modifiers,
      );

      if (response.isSuccess) {
        // Recargar carrito para obtener el estado actualizado
        await loadCart();
        // debugPrint('✅ CartProvider: Producto agregado exitosamente');
        return true;
      } else {
        // Manejar error específico de modificadores requeridos
        if (response.code == 'MODIFIERS_REQUIRED') {
          _setError('MODIFIERS_REQUIRED');
          // debugPrint('⚠️ CartProvider: Modificadores requeridos para el producto');
        } else {
          _setError(response.message);
          // debugPrint('❌ CartProvider: Error al agregar producto: ${response.message}');
        }
        return false;
      }
    } catch (e) {
      _setError('Error al agregar producto: $e');
      // debugPrint('❌ CartProvider: Excepción al agregar producto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar producto al carrito (método de compatibilidad con formato antiguo)
  @Deprecated('Usar addToCart con parámetro modifiers en lugar de modifierOptionIds')
  Future<bool> addToCartLegacy({
    required int productId,
    required int quantity,
    List<int>? modifierOptionIds,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // debugPrint('🛒 CartProvider: Agregando producto $productId (cantidad: $quantity) [MODO LEGACY]...');
      if (modifierOptionIds != null && modifierOptionIds.isNotEmpty) {
        // debugPrint('🛒 CartProvider: Con modificadores (formato legacy): $modifierOptionIds');
      }
      
      final response = await CartService.addToCartLegacy(
        productId: productId,
        quantity: quantity,
        modifierOptionIds: modifierOptionIds,
      );

      if (response.isSuccess) {
        // Recargar carrito para obtener el estado actualizado
        await loadCart();
        // debugPrint('✅ CartProvider: Producto agregado exitosamente (legacy)');
        return true;
      } else {
        _setError(response.message);
        // debugPrint('❌ CartProvider: Error al agregar producto: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al agregar producto al carrito: $e');
      // debugPrint('❌ CartProvider: Excepción al agregar producto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar cantidad de un item
  Future<bool> updateItemQuantity({
    required int itemId,
    required int quantity,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // debugPrint('🛒 CartProvider: Actualizando item $itemId con cantidad $quantity...');
      final response = await CartService.updateQuantity(
        itemId: itemId,
        quantity: quantity,
      );

      if (response.isSuccess) {
        // Recargar carrito para obtener el estado actualizado
        await loadCart();
        // debugPrint('✅ CartProvider: Item actualizado exitosamente');
        return true;
      } else {
        _setError(response.message);
        // debugPrint('❌ CartProvider: Error al actualizar item: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar item: $e');
      // debugPrint('❌ CartProvider: Excepción al actualizar item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Incrementar cantidad de un item
  Future<bool> incrementItem(int itemId, int currentQuantity) async {
    return updateItemQuantity(
      itemId: itemId,
      quantity: currentQuantity + 1,
    );
  }

  /// Decrementar cantidad de un item
  Future<bool> decrementItem(int itemId, int currentQuantity) async {
    if (currentQuantity <= 1) {
      return removeItem(itemId);
    } else {
      return updateItemQuantity(
        itemId: itemId,
        quantity: currentQuantity - 1,
      );
    }
  }

  /// Eliminar item del carrito
  Future<bool> removeItem(int itemId) async {
    _setLoading(true);
    _clearError();

    try {
      // debugPrint('🛒 CartProvider: Eliminando item $itemId...');
      final response = await CartService.removeFromCart(itemId: itemId);

      if (response.isSuccess) {
        // Recargar carrito para obtener el estado actualizado
        await loadCart();
        // debugPrint('✅ CartProvider: Item eliminado exitosamente');
        return true;
      } else {
        _setError(response.message);
        // debugPrint('❌ CartProvider: Error al eliminar item: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar item: $e');
      // debugPrint('❌ CartProvider: Excepción al eliminar item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpiar carrito
  Future<bool> clearCart({int? restaurantId}) async {
    _setLoading(true);
    _clearError();

    try {
      // debugPrint('🛒 CartProvider: Limpiando carrito${restaurantId != null ? ' del restaurante $restaurantId' : ''}...');
      final response = await CartService.clearCart();

      if (response.isSuccess) {
        // Recargar carrito para obtener el estado actualizado
        await loadCart();
        // debugPrint('✅ CartProvider: Carrito limpiado exitosamente');
        return true;
      } else {
        _setError(response.message);
        // debugPrint('❌ CartProvider: Error al limpiar carrito: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al limpiar carrito: $e');
      // debugPrint('❌ CartProvider: Excepción al limpiar carrito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Validar carrito
  Future<bool> validateCart(int restaurantId) async {
    _setLoading(true);
    _clearError();

    try {
      // debugPrint('🛒 CartProvider: Validando carrito del restaurante $restaurantId...');
      // Validación simple - en el futuro se puede implementar
      final response = await CartService.getCart();

      if (response.isSuccess && response.data != null) {
        // Validar que hay productos en el carrito
        final restaurantCarts = response.data as List<RestaurantCart>;
        final isValid = restaurantCarts.any((cart) => cart.restaurantId == restaurantId && cart.isNotEmpty);
        // debugPrint('✅ CartProvider: Carrito validado - Válido: $isValid');
        return isValid;
      } else {
        _setError(response.message);
        // debugPrint('❌ CartProvider: Error al validar carrito: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al validar carrito: $e');
      // debugPrint('❌ CartProvider: Excepción al validar carrito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener carrito de un restaurante específico
  Cart? getCartByRestaurant(int restaurantId) {
    try {
      return _carts.firstWhere(
        (cart) => cart.restaurant.id == restaurantId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener total de items de un restaurante específico
  int getItemCountByRestaurant(int restaurantId) {
    final cart = getCartByRestaurant(restaurantId);
    return cart?.totalQuantity ?? 0;
  }

  /// Verificar si un producto está en el carrito
  bool isProductInCart(int productId, int restaurantId) {
    final cart = getCartByRestaurant(restaurantId);
    if (cart == null) return false;

    return cart.items.any((item) => item.product.id == productId);
  }

  /// Obtener cantidad de un producto específico en el carrito
  int getProductQuantity(int productId, int restaurantId) {
    final cart = getCartByRestaurant(restaurantId);
    if (cart == null) return 0;

    final item = cart.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: 0,
        product: Product(
          id: 0,
          name: '',
          description: '',
          price: 0.0,
          isAvailable: false,
          subcategoryId: 0,
        ),
        quantity: 0,
        priceAtAdd: 0.0,
        subtotal: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return item.quantity;
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar estado del provider
  void clear() {
    _carts = [];
    _summary = null;
    _totalItems = 0;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
