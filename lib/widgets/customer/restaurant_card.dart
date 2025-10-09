import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de portada con overlay de estado
                _buildCoverImage(context),
                
                // Contenido principal
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con nombre y estado
                      _buildRestaurantHeader(context),
                      
                      const SizedBox(height: 8),
                      
                      // Información clave (rating, tiempo, envío)
                      _buildKeyInfo(context),
                      
                      const SizedBox(height: 12),
                      
                      // Descripción
                      _buildDescription(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return Stack(
      children: [
        // Imagen de portada con caché
        Container(
          height: 180,
          width: double.infinity,
          child: restaurant.coverPhotoUrl != null && restaurant.coverPhotoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: restaurant.coverPhotoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImagePlaceholder(),
                  errorWidget: (context, url, error) {
                    print('❌ Error cargando imagen de portada: $error');
                    print('❌ URL intentada: $url');
                    return _buildImagePlaceholder();
                  },
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 100),
                )
              : _buildImagePlaceholder(),
        ),
        
        // Overlay con logo del restaurante
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: restaurant.logoUrl != null && restaurant.logoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: restaurant.logoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildLogoPlaceholder(),
                        errorWidget: (context, url, error) {
                          print('❌ Error cargando logo: $error');
                          print('❌ URL intentada: $url');
                          return _buildLogoPlaceholder();
                        },
                        fadeInDuration: const Duration(milliseconds: 200),
                      )
                    : _buildLogoPlaceholder(),
              ),
          ),
        ),
        
        // Badge de estado en la esquina superior derecha
        Positioned(
          top: 16,
          right: 16,
          child: _buildStatusBadge(context),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[300]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 36,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Imagen próxima',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Icon(
        Icons.restaurant,
        size: 24,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    // Usar el campo isOpen real del backend (calculado según horarios)
    final isOpen = restaurant.isCurrentlyOpen;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Abierto' : 'Cerrado',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      restaurant.description ?? 'Sin descripción disponible',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
        height: 1.4,
        fontSize: 14,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildKeyInfo(BuildContext context) {
    return Row(
      children: [
        // Distancia (si está disponible)
        if (restaurant.minDistance != null) ...[
          _buildInfoChip(
            icon: Icons.location_on_rounded,
            text: '${restaurant.minDistance!.toStringAsFixed(1)} km',
            color: Colors.purple,
            context: context,
          ),
          const SizedBox(width: 8),
        ],
        
        // Rating
        if (restaurant.rating != null && restaurant.rating! > 0) ...[
          _buildInfoChip(
            icon: Icons.star_rounded,
            text: restaurant.formattedRating,
            color: Colors.amber,
            context: context,
          ),
          const SizedBox(width: 8),
        ],
        
        // Tiempo de entrega
        if (restaurant.deliveryTime != null) ...[
          _buildInfoChip(
            icon: Icons.access_time_rounded,
            text: restaurant.formattedDeliveryTime,
            color: Colors.blue,
            context: context,
          ),
          const SizedBox(width: 8),
        ],
        
        // Precio de envío
        if (restaurant.deliveryFee != null) ...[
          _buildInfoChip(
            icon: Icons.local_shipping_rounded,
            text: restaurant.formattedDeliveryFee,
            color: Colors.green,
            context: context,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }


}
