import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_cart_provider.dart';
import '../../models/restaurant_cart.dart';
import '../../widgets/customer/cart_item_widget.dart';

class CartDetailScreen extends StatefulWidget {
  final RestaurantCart restaurant;

  const CartDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<CartDetailScreen> createState() => _CartDetailScreenState();
}

class _CartDetailScreenState extends State<CartDetailScreen> {
  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        title: Text(
          widget.restaurant.restaurantName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        centerTitle: true,
        backgroundColor: white,
        surfaceTintColor: white,
        elevation: 0,
        actions: [
          Consumer<RestaurantCartProvider>(
            builder: (context, cartProvider, child) {
              final currentRestaurant = cartProvider.getRestaurantCart(widget.restaurant.restaurantId);
              if (currentRestaurant != null && currentRestaurant.totalItems > 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${currentRestaurant.totalItems}',
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<RestaurantCartProvider>(
        builder: (context, cartProvider, child) {
          final currentRestaurant = cartProvider.getRestaurantCart(widget.restaurant.restaurantId);
          
          if (currentRestaurant == null || currentRestaurant.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cartProvider.loadCart(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentRestaurant.items.length,
                    itemBuilder: (context, index) {
                      final item = currentRestaurant.items[index];
                      return CartItemWidget(
                        item: item,
                        onQuantityChanged: (newQuantity) {
                          if (newQuantity <= 0) {
                            // Eliminar directamente sin mostrar diálogo adicional
                            // ya que el CartItemWidget tiene su propio diálogo de confirmación
                            cartProvider.removeFromCart(itemId: item.id);
                          } else {
                            cartProvider.updateQuantity(
                              itemId: item.id,
                              quantity: newQuantity,
                            );
                          }
                        },
                        onRemove: () {
                          // Eliminar directamente sin mostrar diálogo adicional
                          // ya que el CartItemWidget tiene su propio diálogo de confirmación
                          cartProvider.removeFromCart(itemId: item.id);
                        },
                      );
                    },
                  ),
                ),
              ),
              
              // Resumen y botón continuar
              _buildCheckoutSection(currentRestaurant),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: primaryOrange.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Carrito vacío',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay productos en el carrito\nde este restaurante',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF757575),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/restaurant-detail',
                  arguments: widget.restaurant.restaurantId,
                );
              },
              icon: const Icon(Icons.restaurant_rounded),
              label: const Text('Ver Restaurante'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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

  Widget _buildCheckoutSection(RestaurantCart restaurant) {
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Resumen de precios
            _buildPriceSummary(restaurant),
            
            const SizedBox(height: 20),
            
            // Botón continuar con Material 3
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _navigateToCheckout(restaurant),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text(
                  'Continuar al checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(RestaurantCart restaurant) {
    const primaryOrange = Color(0xFFF2843A);
    const darkGray = Color(0xFF1A1A1A);

    return Column(
      children: [
        // Subtotal con Material 3
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryOrange.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: darkGray,
                ),
              ),
              Text(
                '\$${restaurant.subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Nota sobre tarifas con Material 3
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF90CAF9),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF1976D2),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Las tarifas de envío y servicio se calcularán en el checkout',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF1565C0),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  void _navigateToCheckout(RestaurantCart restaurant) {
    Navigator.of(context).pushNamed(
      '/checkout',
      arguments: restaurant,
    );
  }
}
