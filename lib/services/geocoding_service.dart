import '../models/api_response.dart';
import 'api_service.dart';
import 'token_manager.dart';
import 'logger_service.dart';

/// Modelo para la respuesta de geocodificación inversa
class ReverseGeocodeResult {
  final String? street;
  final String? exteriorNumber;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? stateShort;
  final String? zipCode;
  final String? country;
  final String? countryCode;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? locationType;
  final bool hasMinimumData;

  ReverseGeocodeResult({
    this.street,
    this.exteriorNumber,
    this.neighborhood,
    this.city,
    this.state,
    this.stateShort,
    this.zipCode,
    this.country,
    this.countryCode,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.locationType,
    required this.hasMinimumData,
  });

  factory ReverseGeocodeResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final coordinates = address['coordinates'] as Map<String, dynamic>? ?? {};
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};

    return ReverseGeocodeResult(
      street: address['street'] as String?,
      exteriorNumber: address['exterior_number'] as String?,
      neighborhood: address['neighborhood'] as String?,
      city: address['city'] as String?,
      state: address['state'] as String?,
      stateShort: address['state_short'] as String?,
      zipCode: address['zip_code'] as String?,
      country: address['country'] as String?,
      countryCode: address['country_code'] as String?,
      formattedAddress: address['formatted_address'] as String? ?? '',
      latitude: _parseDouble(coordinates['latitude']),
      longitude: _parseDouble(coordinates['longitude']),
      placeId: address['place_id'] as String?,
      locationType: address['location_type'] as String?,
      hasMinimumData: _parseBool(metadata['hasMinimumData']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return false;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Dirección corta para mostrar en UI
  String get shortAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) {
      parts.add(street!);
    }
    if (exteriorNumber != null && exteriorNumber!.isNotEmpty) {
      parts.add(exteriorNumber!);
    }
    return parts.join(' ');
  }

  /// Dirección completa para mostrar en UI
  String get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) {
      parts.add(street!);
    }
    if (exteriorNumber != null && exteriorNumber!.isNotEmpty) {
      parts.add(exteriorNumber!);
    }
    if (neighborhood != null && neighborhood!.isNotEmpty) {
      parts.add(neighborhood!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }
    if (zipCode != null && zipCode!.isNotEmpty) {
      parts.add(zipCode!);
    }
    return parts.join(', ');
  }

  /// Validar si tiene los datos mínimos requeridos
  bool get isValid {
    // Validación flexible: al menos debe tener dirección formateada y coordenadas válidas
    return formattedAddress.isNotEmpty && 
           latitude != 0.0 && 
           longitude != 0.0 &&
           latitude >= -90 && 
           latitude <= 90 &&
           longitude >= -180 && 
           longitude <= 180;
  }

  @override
  String toString() {
    return 'ReverseGeocodeResult(street: $street, city: $city, state: $state, hasMinimumData: $hasMinimumData)';
  }
}

/// Servicio para geocodificación inversa (coordenadas → dirección)
class GeocodingService {
  /// Realizar geocodificación inversa usando el backend
  static Future<ApiResponse<ReverseGeocodeResult>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      LoggerService.location(
        'Iniciando geocodificación inversa para lat: $latitude, lng: $longitude',
        tag: 'GeocodingService',
      );

      // Validar coordenadas
      if (latitude < -90 || latitude > 90) {
        return ApiResponse<ReverseGeocodeResult>(
          status: 'error',
          message: 'La latitud debe estar entre -90 y 90',
          data: null,
        );
      }

      if (longitude < -180 || longitude > 180) {
        return ApiResponse<ReverseGeocodeResult>(
          status: 'error',
          message: 'La longitud debe estar entre -180 y 180',
          data: null,
        );
      }

      // Obtener token
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<ReverseGeocodeResult>(
          status: 'error',
          message: 'No hay token de autenticación disponible',
          data: null,
        );
      }

      // Preparar datos de la petición
      final requestData = {
        'latitude': latitude,
        'longitude': longitude,
      };

      LoggerService.location(
        'Enviando petición de geocodificación al backend...',
        tag: 'GeocodingService',
      );

      // Hacer petición al backend
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/geocoding/reverse',
        ApiService.authHeaders(token),
        requestData,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location(
        'Respuesta de geocodificación: ${response.status}',
        tag: 'GeocodingService',
      );

      if (response.isSuccess && response.data != null) {
        // Extraer datos de la respuesta
        final data = response.data!['data'] as Map<String, dynamic>? ?? response.data!;
        
        final result = ReverseGeocodeResult.fromJson(data);
        
        LoggerService.location(
          'Geocodificación exitosa: ${result.formattedAddress}',
          tag: 'GeocodingService',
        );

        return ApiResponse<ReverseGeocodeResult>(
          status: 'success',
          message: 'Geocodificación realizada exitosamente',
          data: result,
        );
      } else {
        LoggerService.warning(
          'Error en geocodificación: ${response.message}',
          tag: 'GeocodingService',
        );

        return ApiResponse<ReverseGeocodeResult>(
          status: 'error',
          message: response.message,
          data: null,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      LoggerService.error(
        'Excepción en geocodificación: $e',
        tag: 'GeocodingService',
      );

      return ApiResponse<ReverseGeocodeResult>(
        status: 'error',
        message: 'Error al realizar geocodificación: $e',
        data: null,
      );
    }
  }

  /// Realizar geocodificación inversa con reintentos
  static Future<ApiResponse<ReverseGeocodeResult>> reverseGeocodeWithRetry({
    required double latitude,
    required double longitude,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    ApiResponse<ReverseGeocodeResult>? lastResponse;

    while (attempts < maxRetries) {
      attempts++;
      
      LoggerService.location(
        'Intento de geocodificación $attempts/$maxRetries',
        tag: 'GeocodingService',
      );

      lastResponse = await reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      if (lastResponse.isSuccess) {
        return lastResponse;
      }

      // Si no es el último intento, esperar antes de reintentar
      if (attempts < maxRetries) {
        LoggerService.warning(
          'Reintentando geocodificación en ${retryDelay.inSeconds}s...',
          tag: 'GeocodingService',
        );
        await Future.delayed(retryDelay);
      }
    }

    // Retornar la última respuesta si todos los intentos fallaron
    return lastResponse ?? ApiResponse<ReverseGeocodeResult>(
      status: 'error',
      message: 'No se pudo realizar la geocodificación después de $maxRetries intentos',
      data: null,
    );
  }

  /// Validar si las coordenadas son válidas
  static bool areCoordinatesValid({
    required double latitude,
    required double longitude,
  }) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  /// Formatear coordenadas para mostrar en UI
  static String formatCoordinates({
    required double latitude,
    required double longitude,
    int decimals = 6,
  }) {
    return 'Lat: ${latitude.toStringAsFixed(decimals)}, Lng: ${longitude.toStringAsFixed(decimals)}';
  }
}

