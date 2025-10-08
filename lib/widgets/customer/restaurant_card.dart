import 'package:flutter/material.dart';
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
                      // Nombre del restaurante con badge de estado
                      _buildRestaurantHeader(context),
                      
                      const SizedBox(height: 8),
                      
                      // Descripción
                      _buildDescription(context),
                      
                      const SizedBox(height: 16),
                      
                      // Información adicional
                      _buildAdditionalInfo(context),
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
        // Imagen de portada
        Container(
          height: 180,
          width: double.infinity,
          child: restaurant.coverPhotoUrl != null
              ? Image.network(
                  _convertLocalhostUrl(restaurant.coverPhotoUrl!),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImagePlaceholder();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Error cargando imagen de portada: $error');
                    print('❌ URL intentada: ${_convertLocalhostUrl(restaurant.coverPhotoUrl!)}');
                    return _buildImagePlaceholder();
                  },
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
                child: restaurant.logoUrl != null
                    ? Image.network(
                        _convertLocalhostUrl(restaurant.logoUrl!),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildLogoPlaceholder();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Error cargando logo: $error');
                          print('❌ URL intentada: ${_convertLocalhostUrl(restaurant.logoUrl!)}');
                          return _buildLogoPlaceholder();
                        },
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
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 40,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              'Imagen no disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
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
    final isActive = restaurant.status == 'active';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.orange,
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
            isActive ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Abierto' : 'Cerrado',
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

  Widget _buildAdditionalInfo(BuildContext context) {
    return Row(
      children: [
        // Rating
        if (restaurant.rating != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Colors.amber[600],
                ),
                const SizedBox(width: 4),
                Text(
                  restaurant.formattedRating,
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // Tiempo de entrega
        if (restaurant.deliveryTime != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 4),
                Text(
                  restaurant.formattedDeliveryTime,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // Precio de envío
        if (restaurant.deliveryFee != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_shipping_rounded,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  restaurant.formattedDeliveryFee,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Convierte URLs de localhost a 10.0.2.2 para funcionar en el emulador Android
  String _convertLocalhostUrl(String url) {
    // Si la URL contiene localhost, reemplazarla con 10.0.2.2 para el emulador
    if (url.contains('localhost')) {
      final convertedUrl = url.replaceFirst('localhost', '10.0.2.2');
      print('🔄 URL convertida: $url -> $convertedUrl');
      return convertedUrl;
    }
    return url;
  }
}
