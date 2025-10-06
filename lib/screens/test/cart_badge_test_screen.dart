import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_cart_provider.dart';
import '../../widgets/shared/cart_badge.dart';

class CartBadgeTestScreen extends StatefulWidget {
  const CartBadgeTestScreen({super.key});

  @override
  State<CartBadgeTestScreen> createState() => _CartBadgeTestScreenState();
}

class _CartBadgeTestScreenState extends State<CartBadgeTestScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar carrito al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantCartProvider>().loadCartSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Cart Badge'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<RestaurantCartProvider>(
        builder: (context, cartProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cart Badge Test',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Información del carrito
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Carrito',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Total Items: ${cartProvider.totalItems}'),
                        Text('Restaurant Count: ${cartProvider.restaurantCount}'),
                        Text('Subtotal: \$${cartProvider.subtotal.toStringAsFixed(2)}'),
                        Text('Is Loading: ${cartProvider.isLoading}'),
                        Text('Is Empty: ${cartProvider.isEmpty}'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Diferentes ejemplos de badges
                Text(
                  'Ejemplos de Badges',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Badge en AppBar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('AppBar Badge: '),
                        const SizedBox(width: 16),
                        CartBadge(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('AppBar Badge tapped')),
                            );
                          },
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Badge en botón
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('Button Badge: '),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Button Badge tapped')),
                            );
                          },
                          icon: CartBadge(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Button Badge tapped')),
                              );
                            },
                            child: const Icon(Icons.shopping_cart),
                          ),
                          label: const Text('Ver Carrito'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Navigation Badge
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Navigation Badge:'),
                        const SizedBox(height: 16),
                        NavigationCartBadge(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Carrito',
                          isSelected: false,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigation Badge tapped')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botones de prueba
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Simular agregar items
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Simulando agregar items...')),
                        );
                      },
                      child: const Text('Simular +1'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Recargar carrito
                        context.read<RestaurantCartProvider>().loadCartSummary();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Carrito recargado')),
                        );
                      },
                      child: const Text('Recargar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
