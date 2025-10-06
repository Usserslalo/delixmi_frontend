import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/order.dart';

class DeliveryMapWidget extends StatefulWidget {
  final OrderAddress deliveryAddress;
  final OrderRestaurant restaurant;

  const DeliveryMapWidget({
    super.key,
    required this.deliveryAddress,
    required this.restaurant,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    // Coordenadas de la dirección de entrega
    final deliveryLat = widget.deliveryAddress.latitude ?? 20.480377;
    final deliveryLng = widget.deliveryAddress.longitude ?? -99.218668;
    
    // Coordenadas del restaurante (usar coordenadas de ejemplo por ahora)
    const double restaurantLat = 20.486789;
    const double restaurantLng = -99.212345;

    _markers = {
      // Marcador del restaurante
      Marker(
        markerId: const MarkerId('restaurant'),
        position: const LatLng(restaurantLat, restaurantLng),
        infoWindow: InfoWindow(
          title: widget.restaurant.name,
          snippet: widget.restaurant.branch.name,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      // Marcador de la dirección de entrega
      Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(deliveryLat, deliveryLng),
        infoWindow: InfoWindow(
          title: widget.deliveryAddress.alias,
          snippet: 'Dirección de entrega',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Mapa de Google Maps
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _fitBounds();
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.deliveryAddress.latitude ?? 20.480377,
                  widget.deliveryAddress.longitude ?? -99.218668,
                ),
                zoom: 14.0,
              ),
              markers: _markers,
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: true,
            ),
            
            // Overlay con información de la dirección
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.deliveryAddress.alias,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.deliveryAddress.fullAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botón de centrar mapa
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _centerMap,
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitBounds() {
    if (_mapController != null && _markers.isNotEmpty) {
      // Calcular bounds para mostrar ambos marcadores
      double minLat = _markers.first.position.latitude;
      double maxLat = _markers.first.position.latitude;
      double minLng = _markers.first.position.longitude;
      double maxLng = _markers.first.position.longitude;

      for (Marker marker in _markers) {
        minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
        maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
        minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
        maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
      }

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.01, minLng - 0.01),
            northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
          ),
          100.0, // padding
        ),
      );
    }
  }

  void _centerMap() {
    if (_mapController != null) {
      _fitBounds();
    }
  }
}
