import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_cart_provider.dart';
import '../../models/restaurant_cart.dart';
import '../../widgets/customer/restaurant_cart_widget.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/cart_badge.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar carrito al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantCartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CartBadge(
              onTap: () {
                // El badge es solo visual en esta pantalla
              },
              child: Icon(
                Icons.shopping_cart,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<RestaurantCartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading && cartProvider.isEmpty) {
            return const LoadingWidget(
              message: 'Cargando carrito...',
            );
          }

          if (cartProvider.errorMessage != null) {
            return _buildErrorState(cartProvider.errorMessage!);
          }

          if (cartProvider.isEmpty) {
            return _buildEmptyCart();
          }

          return _buildCartContent(cartProvider);
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
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
            'Error al cargar el carrito',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<RestaurantCartProvider>().loadCart();
            },
            child: const Text('Reintentar'),
          ),
        ],
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
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega algunos productos para comenzar',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.restaurant),
            label: const Text('Explorar Restaurantes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(RestaurantCartProvider cartProvider) {
    return Column(
      children: [
        // Lista de restaurantes
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cartProvider.loadCart(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartProvider.restaurantCarts.length,
              itemBuilder: (context, index) {
                final restaurant = cartProvider.restaurantCarts[index];
                return RestaurantCartWidget(
                  restaurant: restaurant,
                  onViewCart: () => _navigateToCartDetail(restaurant),
                  onViewStore: () => _navigateToRestaurant(restaurant),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToCartDetail(RestaurantCart restaurant) {
    Navigator.of(context).pushNamed(
      '/cart-detail',
      arguments: restaurant,
    );
  }

  void _navigateToRestaurant(RestaurantCart restaurant) {
    Navigator.of(context).pushNamed(
      '/restaurant-detail',
      arguments: restaurant.restaurantId,
    );
  }
}