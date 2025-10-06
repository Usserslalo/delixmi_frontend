import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/order.dart';

class OrderMapWidget extends StatefulWidget {
  final OrderAddress deliveryAddress;
  final String restaurantAddress;

  const OrderMapWidget({
    super.key,
    required this.deliveryAddress,
    required this.restaurantAddress,
  });

  @override
  State<OrderMapWidget> createState() => _OrderMapWidgetState();
}

class _OrderMapWidgetState extends State<OrderMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    // Coordenadas de ejemplo (en una implementación real, necesitarías las coordenadas reales)
    const double deliveryLat = 20.480377;
    const double deliveryLng = -99.218668;
    const double restaurantLat = 20.486789;
    const double restaurantLng = -99.212345;

    _markers = {
      Marker(
        markerId: const MarkerId('restaurant'),
        position: const LatLng(restaurantLat, restaurantLng),
        infoWindow: const InfoWindow(
          title: 'Restaurante',
          snippet: 'Punto de origen',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: const MarkerId('delivery'),
        position: const LatLng(deliveryLat, deliveryLng),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _fitBounds();
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(20.480377, -99.218668),
            zoom: 14.0,
          ),
          markers: _markers,
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
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
}
