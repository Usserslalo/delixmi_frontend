import 'package:flutter/material.dart';
import '../../widgets/map_placeholder_widget.dart';

class LocationPickerScreenTemp extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const LocationPickerScreenTemp({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreenTemp> createState() => _LocationPickerScreenTempState();
}

class _LocationPickerScreenTempState extends State<LocationPickerScreenTemp> {
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedLatitude = widget.initialLatitude;
    _selectedLongitude = widget.initialLongitude;
    _selectedAddress = widget.initialAddress;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Seleccionar Ubicación',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header con información elegante
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ubicación de Entrega',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedAddress ?? 'Selecciona una ubicación usando el botón de ubicación actual',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _selectedAddress != null ? Colors.grey[800] : Colors.grey[500],
                    height: 1.4,
                  ),
                ),
                if (_selectedLatitude != null && _selectedLongitude != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Lat: ${_selectedLatitude!.toStringAsFixed(6)}, '
                      'Lng: ${_selectedLongitude!.toStringAsFixed(6)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Mapa placeholder
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: MapPlaceholderWidget(
                initialLatitude: _selectedLatitude,
                initialLongitude: _selectedLongitude,
                initialAddress: _selectedAddress,
                onLocationSelected: (latitude, longitude, address) {
                  setState(() {
                    _selectedLatitude = latitude;
                    _selectedLongitude = longitude;
                    _selectedAddress = address;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botones de acción modernos
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: _selectedLatitude != null
                          ? LinearGradient(
                              colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _selectedLatitude == null ? Colors.grey[300] : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _selectedLatitude != null ? _confirmLocation : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: _selectedLatitude != null ? Colors.white : Colors.grey[500],
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Confirmar',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmLocation() {
    if (_selectedLatitude != null && _selectedLongitude != null) {
      Navigator.of(context).pop({
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
        'address': _selectedAddress,
      });
    }
  }
}
