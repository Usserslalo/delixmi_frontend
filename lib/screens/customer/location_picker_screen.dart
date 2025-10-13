import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/geocoding_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ReverseGeocodeResult? prefilledData;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.prefilledData,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _centerLocation = const LatLng(20.488765, -99.234567); // Centro del mapa
  ReverseGeocodeResult? _geocodeResult;
  bool _isLoadingGeocode = false;
  bool _isGettingCurrentLocation = false;
  bool _hasMapError = false;
  Timer? _debounceTimer;

  // Ubicación por defecto (Ixmiquilpan, Hidalgo)
  static const LatLng _defaultLocation = LatLng(20.488765, -99.234567);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _checkMapAvailability();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _checkMapAvailability() {
    // Verificar si el mapa se puede cargar después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _mapController == null) {
        setState(() {
          _hasMapError = true;
        });
      }
    });
  }

  void _initializeLocation() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _centerLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _geocodeResult = widget.prefilledData;
    } else {
      _centerLocation = _defaultLocation;
      // Obtener ubicación actual automáticamente
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 🎨 COLORIMETRÍA UNIFICADA DE LA APP
    const primaryOrange = Color(0xFFF2843A);     // Naranja principal (tema de la app)
    const darkGray = Color(0xFF1A1A1A);          // Gris oscuro
    const lightGray = Color(0xFFF5F5F5);         // Gris claro
    const mediumGray = Color(0xFF757575);        // Gris medio
    const white = Color(0xFFFFFFFF);             // Blanco puro
    
    return Scaffold(
      backgroundColor: white,
      // AppBar con título
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkGray, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Seleccionar Ubicación',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: darkGray,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Mapa a pantalla completa
          _buildMapContent(),

          // Botón de confirmar ubicación en la parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dirección detectada (solo si existe)
                    if (_geocodeResult != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: primaryOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dirección detectada',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: mediumGray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _geocodeResult!.formattedAddress,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: darkGray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Botón de confirmar - siempre verde
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _geocodeResult != null && !_isLoadingGeocode 
                            ? () async {
                                debugPrint('🔘 Botón confirmar presionado');
                                setState(() {
                                  _isLoadingGeocode = true;
                                });
                                
                                // Simular un pequeño delay para mostrar la animación
                                await Future.delayed(const Duration(milliseconds: 500));
                                
                                if (mounted) {
                                  _confirmLocation();
                                  setState(() {
                                    _isLoadingGeocode = false;
                                  });
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: white,
                          disabledBackgroundColor: primaryOrange.withValues(alpha: 0.5),
                          disabledForegroundColor: white.withValues(alpha: 0.7),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoadingGeocode
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Confirmando...',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: white,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Confirmar Ubicación',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContent() {
    if (_hasMapError) {
      return _buildMapError();
    }

    return Stack(
      children: [
        // Mapa de Google
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _centerLocation,
            zoom: 16.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            setState(() {
              _hasMapError = false;
            });
            // Obtener dirección inicial
            _performReverseGeocode(_centerLocation);
          },
          onCameraMove: (CameraPosition position) {
            // Actualizar el centro del mapa mientras se mueve
            _centerLocation = position.target;
          },
          onCameraIdle: () {
            // Cuando el usuario deja de mover el mapa, hacer reverse geocoding
            _performReverseGeocodeWithDebounce(_centerLocation);
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          markers: {}, // Sin marcadores, usamos el pin central fijo
        ),

        // 🎨 Pin central sin sombras
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _isLoadingGeocode ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 32,
                    color: const Color(0xFFF2843A),  // Naranja de la app
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sombra del pin
              Container(
                width: 32,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),

        // 🎯 Botón de ubicación actual sin sombras
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isGettingCurrentLocation ? null : _getCurrentLocation,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  child: _isGettingCurrentLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2843A)),
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: Color(0xFF1A1A1A),
                          size: 22,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapError() {
    final theme = Theme.of(context);
    const primaryOrange = Color(0xFFF2843A);
    const darkGray = Color(0xFF1A1A1A);
    const mediumGray = Color(0xFF757575);
    const white = Color(0xFFFFFFFF);
    
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono minimalista
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: primaryOrange,
                ),
              ),
              const SizedBox(height: 32),
              // Título
              Text(
                'Mapa no disponible',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 12),
              // Descripción
              Text(
                'No se pudo cargar el mapa. Verifica tu conexión a internet y la configuración de Google Maps.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: mediumGray,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              // Botón minimalista
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasMapError = false;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Realizar reverse geocoding con debounce
  void _performReverseGeocodeWithDebounce(LatLng location) {
    // Cancelar el timer anterior si existe
    _debounceTimer?.cancel();

    // Crear un nuevo timer con delay de 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performReverseGeocode(location);
    });
  }

  /// Realizar reverse geocoding usando el backend
  Future<void> _performReverseGeocode(LatLng location) async {
    setState(() {
      _isLoadingGeocode = true;
    });

    try {
      final response = await GeocodingService.reverseGeocode(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            _geocodeResult = response.data;
            _isLoadingGeocode = false;
          });
        } else {
          setState(() {
            _geocodeResult = null;
            _isLoadingGeocode = false;
          });
          
          // Mostrar error solo si es crítico
          if (response.code == 'SERVICE_UNAVAILABLE') {
            _showErrorSnackBar('Servicio de geocodificación no disponible');
          }
        }
      }
    } catch (e) {
      debugPrint('Error en reverse geocoding: $e');
      if (mounted) {
        setState(() {
          _geocodeResult = null;
          _isLoadingGeocode = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingCurrentLocation = true;
    });

    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showErrorSnackBar('Permisos de ubicación denegados');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showErrorSnackBar('Los permisos de ubicación están denegados permanentemente');
        }
        return;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _centerLocation = location;
        });

        // Centrar el mapa en la ubicación actual
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(location, 16.0),
        );

        // Realizar reverse geocoding
        _performReverseGeocode(location);
      }
    } catch (e) {
      debugPrint('Error al obtener ubicación actual: $e');
      if (mounted) {
        _showErrorSnackBar('Error al obtener ubicación actual');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  void _confirmLocation() {
    debugPrint('🔍 _confirmLocation() ejecutado');
    debugPrint('🔍 _geocodeResult: $_geocodeResult');
    debugPrint('🔍 _geocodeResult == null: ${_geocodeResult == null}');
    
    if (_geocodeResult == null) {
      debugPrint('❌ Error: geocodeResult es null');
      _showErrorSnackBar('Por favor espera a que se obtenga la dirección');
      return;
    }

    debugPrint('🔍 _geocodeResult.isValid: ${_geocodeResult!.isValid}');
    
    if (!_geocodeResult!.isValid) {
      debugPrint('❌ Error: geocodeResult no es válido');
      _showErrorSnackBar('No se pudo obtener una dirección válida para esta ubicación');
      return;
    }

    debugPrint('✅ Navegando de vuelta con geocodeResult: ${_geocodeResult!.formattedAddress}');
    
    // Retornar el resultado de geocodificación completo
    Navigator.of(context).pop(_geocodeResult);
    
    debugPrint('✅ Navigator.pop ejecutado');
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
