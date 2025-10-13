import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_cart_provider.dart';

class CartBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CartBadge({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantCartProvider>(
      builder: (context, cartProvider, _) {
        final itemCount = cartProvider.totalItems;
        
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              child,
              if (itemCount > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: _buildBadge(itemCount),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[600]!, Colors.red[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 22,
        minHeight: 22,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.0,
          letterSpacing: -0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class NavigationCartBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationCartBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantCartProvider>(
      builder: (context, cartProvider, _) {
        final itemCount = cartProvider.totalItems;
        final isLoading = cartProvider.isLoading;
        
        // Debug print para verificar el conteo
        debugPrint('🛒 CartBadge: Total items = $itemCount, Loading = $isLoading');
        
        return GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey[500],
                    size: 24,
                  ),
                  // Mostrar badge si hay items O si está cargando (para evitar parpadeo)
                  if (itemCount > 0 || (isLoading && itemCount == 0))
                    Positioned(
                      right: -8,
                      top: -8,
                      child: isLoading && itemCount == 0
                          ? _buildLoadingBadge()
                          : _buildBadge(itemCount),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[600]!, Colors.red[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 22,
        minHeight: 22,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.0,
          letterSpacing: -0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 22,
        minHeight: 22,
      ),
      child: const SizedBox(
        width: 8,
        height: 8,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}