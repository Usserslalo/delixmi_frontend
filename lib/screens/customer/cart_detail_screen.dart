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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.restaurantName),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Consumer<RestaurantCartProvider>(
            builder: (context, cartProvider, child) {
              final currentRestaurant = cartProvider.getRestaurantCart(widget.restaurant.restaurantId);
              if (currentRestaurant != null && currentRestaurant.totalItems > 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentRestaurant.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
                            _showRemoveConfirmation(item.productName, () {
                              cartProvider.removeFromCart(itemId: item.id);
                            });
                          } else {
                            cartProvider.updateQuantity(
                              itemId: item.id,
                              quantity: newQuantity,
                            );
                          }
                        },
                        onRemove: () {
                          _showRemoveConfirmation(item.productName, () {
                            cartProvider.removeFromCart(itemId: item.id);
                          });
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Carrito vacío',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No hay productos en el carrito de este restaurante',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/restaurant-detail',
                arguments: widget.restaurant.restaurantId,
              );
            },
            icon: const Icon(Icons.restaurant),
            label: const Text('Ver Restaurante'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(RestaurantCart restaurant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Resumen de precios
          _buildPriceSummary(restaurant),
          
          const SizedBox(height: 16),
          
          // Botón continuar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _navigateToCheckout(restaurant),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continuar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(RestaurantCart restaurant) {
    return Column(
      children: [
        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '\$${restaurant.subtotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Nota sobre tarifas
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Las tarifas de envío y servicio se calcularán en el checkout',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRemoveConfirmation(String productName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "$productName" del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(RestaurantCart restaurant) {
    Navigator.of(context).pushNamed(
      '/checkout',
      arguments: restaurant,
    );
  }
}
