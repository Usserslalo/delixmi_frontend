import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/geocoding_service.dart';
import '../../services/restaurant_service.dart';
import '../../services/token_manager.dart';
import '../../config/app_routes.dart';

class SetRestaurantLocationScreen extends StatefulWidget {
  const SetRestaurantLocationScreen({super.key});

  @override
  State<SetRestaurantLocationScreen> createState() => _SetRestaurantLocationScreenState();
}

class _SetRestaurantLocationScreenState extends State<SetRestaurantLocationScreen> {
  GoogleMapController? _mapController;
  LatLng _centerLocation = const LatLng(20.488765, -99.234567); // Centro del mapa
  ReverseGeocodeResult? _geocodeResult;
  bool _isLoadingGeocode = false;
  bool _isGettingCurrentLocation = false;
  bool _hasMapError = false;
  bool _isSaving = false;
  Timer? _debounceTimer;

  final TextEditingController _addressController = TextEditingController();

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
    _addressController.dispose();
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
    // Cargar la ubicación guardada del restaurante de forma asíncrona
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedLocation();
    });
  }

  /// Carga la ubicación guardada del restaurante desde el backend
  Future<void> _loadSavedLocation() async {
    try {
      final response = await RestaurantService.getLocationStatus();
      
      if (mounted && response.isSuccess) {
        final data = response.data;
        
        final isLocationSet = data?['isLocationSet'] as bool? ?? false;
        
        if (isLocationSet) {
          // Obtener los datos completos de ubicación del backend
          final locationData = data?['location'] as Map<String, dynamic>?;
          if (locationData != null) {
            // El backend devuelve los valores como strings, necesitamos convertirlos
            final latStr = locationData['latitude'] as String?;
            final lngStr = locationData['longitude'] as String?;
            final address = locationData['address'] as String?;
            
            if (latStr != null && lngStr != null) {
              final lat = double.tryParse(latStr);
              final lng = double.tryParse(lngStr);
              
              if (lat != null && lng != null) {
                setState(() {
                  _centerLocation = LatLng(lat, lng);
                  if (address != null && address.isNotEmpty) {
                    _addressController.text = address;
                  }
                });
                
                // Mover la cámara a la ubicación guardada si el mapa ya está inicializado
                if (_mapController != null) {
                  try {
                    await _mapController!.animateCamera(
                      CameraUpdate.newLatLng(_centerLocation),
                    );
                  } catch (e) {
                    debugPrint('Error al mover cámara a ubicación guardada: $e');
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error al cargar ubicación guardada: $e');
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
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: darkGray),
              onPressed: () => Navigator.pop(context),
            )
          : null,
        title: Text(
          'Ubicación del Restaurante',
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

          // Panel inferior con información y botón
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
                    // Información de ubicación actual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: lightGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryOrange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.restaurant_rounded,
                                  color: primaryOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ubicación del restaurante',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: mediumGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${_centerLocation.latitude.toStringAsFixed(6)}, Lng: ${_centerLocation.longitude.toStringAsFixed(6)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: darkGray,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Campo de dirección
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Dirección del restaurante (opcional)',
                          hintText: _geocodeResult?.formattedAddress ?? 'Ingresa la dirección completa',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryOrange, width: 2),
                          ),
                        ),
                      ),
                    ),

                    // Botón de guardar ubicación
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveLocation,
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
                        child: _isSaving
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
                                    'Guardando...',
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
                                    Icons.save_rounded,
                                    color: white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Guardar Ubicación',
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
            
            // Si la ubicación guardada está diferente a la por defecto, mover la cámara
            if (_centerLocation != _defaultLocation) {
              controller.animateCamera(
                CameraUpdate.newLatLng(_centerLocation),
              );
            }
            
            // Obtener dirección inicial solo si no tenemos una dirección guardada
            if (_addressController.text.isEmpty) {
              _performReverseGeocode(_centerLocation);
            }
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

        // 🎨 Pin central para restaurante
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    size: 32,
                    color: Color(0xFFF2843A),  // Naranja de la app
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

        // 🎯 Botón para actualizar ubicación actual
        Positioned(
          top: 16,
          right: 16,
          child: Tooltip(
            message: 'Actualizar a mi ubicación actual',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
          
          // Actualizar el campo de dirección si está vacío
          if (_addressController.text.isEmpty) {
            _addressController.text = response.data!.formattedAddress;
          }
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

  Future<void> _saveLocation() async {
    if (_isSaving) return;

    // Validar coordenadas según el backend Zod schema
    final lat = _centerLocation.latitude;
    final lng = _centerLocation.longitude;
    
    if (lat < -90 || lat > 90) {
      _showErrorSnackBar('La latitud debe estar entre -90 y 90 grados');
      return;
    }
    
    if (lng < -180 || lng > 180) {
      _showErrorSnackBar('La longitud debe estar entre -180 y 180 grados');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Usar la dirección del campo de texto si está llena, sino usar la del geocoding
      String? address = _addressController.text.trim().isNotEmpty 
          ? _addressController.text.trim() 
          : _geocodeResult?.formattedAddress;

      // Validar dirección según backend (5-255 caracteres)
      if (address != null && address.isNotEmpty) {
        if (address.length < 5) {
          setState(() => _isSaving = false);
          _showErrorSnackBar('La dirección debe tener al menos 5 caracteres');
          return;
        }
        if (address.length > 255) {
          setState(() => _isSaving = false);
          _showErrorSnackBar('La dirección no puede exceder 255 caracteres');
          return;
        }
      }

      debugPrint('💾 Guardando ubicación del restaurante...');
      debugPrint('📍 Lat: ${_centerLocation.latitude}, Lng: ${_centerLocation.longitude}');
      debugPrint('📍 Address: $address');

      final response = await RestaurantService.updateLocation(
        latitude: _centerLocation.latitude,
        longitude: _centerLocation.longitude,
        address: address,
      );

      if (mounted) {
        if (response.isSuccess) {
          // Verificar que la ubicación está configurada
          final statusResponse = await RestaurantService.getLocationStatus();
          
          if (statusResponse.isSuccess && 
              statusResponse.data?['isLocationSet'] == true) {
            
            // Actualizar el estado global de ubicación
            await TokenManager.saveLocationStatus(true);
            
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Ubicación guardada exitosamente'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            // Regresar o navegar según el contexto
            if (mounted) {
              if (Navigator.canPop(context)) {
                // Estamos en flujo de edición, regresar con resultado
                Navigator.pop(context, true);
              } else {
                // Estamos en flujo inicial obligatorio, navegar al dashboard
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.ownerDashboard,
                  (route) => false,
                );
              }
            }
          } else {
            _showErrorSnackBar('Error al verificar la ubicación guardada');
          }
        } else {
          // Handle specific error codes based on the documentation
          String errorMessage = response.message;
          
          switch (response.code) {
            case 'VALIDATION_ERROR':
              // Usar el mensaje detallado del backend que incluye los errores específicos
              errorMessage = response.message;
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Acceso denegado. Se requiere rol de owner';
              break;
            case 'NOT_FOUND':
              errorMessage = 'Usuario no encontrado';
              break;
            default:
              errorMessage = response.message;
          }
          
          _showErrorSnackBar(errorMessage);
        }
      }
    } catch (e) {
      debugPrint('Error al guardar ubicación: $e');
      if (mounted) {
        _showErrorSnackBar('Error inesperado al guardar la ubicación');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
