import 'package:flutter/material.dart';
import '../../models/restaurant_cart.dart';

class RestaurantCartWidget extends StatelessWidget {
  final RestaurantCart restaurant;
  final VoidCallback onViewCart;
  final VoidCallback onViewStore;

  const RestaurantCartWidget({
    super.key,
    required this.restaurant,
    required this.onViewCart,
    required this.onViewStore,
  });

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);
    const mediumGray = Color(0xFF757575);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del restaurante con Material 3
            Row(
              children: [
                // Imagen del restaurante
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: restaurant.restaurantImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            restaurant.restaurantImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.restaurant_rounded,
                                color: mediumGray,
                                size: 28,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.restaurant_rounded,
                          color: mediumGray,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 12),
                
                // Información del restaurante con Material 3
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.restaurantName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_rounded,
                            size: 14,
                            color: mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant.totalItems} ${restaurant.totalItems == 1 ? 'producto' : 'productos'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Badge con cantidad - Material 3
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${restaurant.totalItems}',
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de productos (preview) con Material 3
            if (restaurant.items.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                          color: primaryOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Productos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: darkGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...restaurant.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.productName} x${item.quantity}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: darkGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Mostrar modificadores de forma compacta
                                if (item.modifiers.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.modifiers.map((m) => m.name).join(', '),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: primaryOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: darkGray,
                            ),
                          ),
                        ],
                      ),
                    )),
              
                    // Mostrar "..." si hay más productos
                    if (restaurant.items.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '... y ${restaurant.items.length - 2} producto${restaurant.items.length - 2 > 1 ? 's' : ''} más',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: mediumGray,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtotal con Material 3
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
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
              
              const SizedBox(height: 16),
            ],
            
            // Botones de acción con Material 3
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewStore,
                    icon: const Icon(Icons.store_rounded, size: 18),
                    label: const Text('Ver tienda'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryOrange,
                      side: const BorderSide(
                        color: primaryOrange,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onViewCart,
                    icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                    label: const Text('Ver carrito'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
