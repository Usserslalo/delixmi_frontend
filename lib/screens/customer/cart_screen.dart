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
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        title: const Text(
          'Mi Carrito',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        centerTitle: true,
        backgroundColor: white,
        surfaceTintColor: white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CartBadge(
              onTap: () {
                // El badge es solo visual en esta pantalla
              },
              child: const Icon(
                Icons.shopping_cart_rounded,
                color: primaryOrange,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar el carrito',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.read<RestaurantCartProvider>().loadCart();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
              'Tu carrito está vacío',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega algunos productos deliciosos\npara comenzar tu pedido',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF757575),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.restaurant_rounded),
              label: const Text('Explorar Restaurantes'),
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