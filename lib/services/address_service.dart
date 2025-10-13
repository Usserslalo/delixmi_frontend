import 'dart:math';
import 'package:flutter/material.dart';
import '../models/api_response.dart';
import '../models/address.dart';
import 'api_service.dart';
import 'token_manager.dart';
import 'logger_service.dart';

class AddressService {
  /// Obtener todas las direcciones del usuario
  static Future<ApiResponse<List<dynamic>>> getAddresses() async {
    try {
      LoggerService.location('Obteniendo direcciones del usuario...', tag: 'AddressService');
      
      // Verificar token
      final token = await TokenManager.getToken();
      LoggerService.location('Token disponible: ${token != null ? "Sí" : "No"}', tag: 'AddressService');
      if (token == null || token.isEmpty) {
        return ApiResponse<List<dynamic>>(
          status: 'error',
          message: 'No hay token de autenticación disponible',
          data: [],
        );
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/customer/addresses',
        ApiService.authHeaders(token),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de direcciones: ${response.status}', tag: 'AddressService');
      LoggerService.location('Datos de direcciones: ${response.data}', tag: 'AddressService');

      // Extraer la lista de direcciones del objeto de respuesta
      List<dynamic> addressesList = [];
      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;
        
        // Verificar si existe la estructura data.addresses
        if (responseData.containsKey('data') && 
            responseData['data'] is Map<String, dynamic> &&
            responseData['data']['addresses'] is List) {
          addressesList = responseData['data']['addresses'] as List<dynamic>;
          LoggerService.location('Direcciones extraídas: ${addressesList.length} elementos', tag: 'AddressService');
        } 
        // Fallback: si las direcciones están en el nivel raíz
        else if (responseData.containsKey('addresses') && 
                 responseData['addresses'] is List) {
          addressesList = responseData['addresses'] as List<dynamic>;
          LoggerService.location('Direcciones en nivel raíz: ${addressesList.length} elementos', tag: 'AddressService');
        }
        else {
          LoggerService.warning('Estructura de respuesta no reconocida: ${responseData.keys}', tag: 'AddressService');
        }
      }

      return ApiResponse<List<dynamic>>(
        status: response.status,
        message: response.message,
        data: addressesList,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      LoggerService.error('Error al obtener direcciones: $e', tag: 'AddressService');
      return ApiResponse<List<dynamic>>(
        status: 'error',
        message: 'Error al obtener direcciones: $e',
        data: null,
      );
    }
  }

  /// Crear una nueva dirección
  static Future<ApiResponse<Map<String, dynamic>>> createAddress({
    required String alias,
    required String street,
    required String exteriorNumber,
    String? interiorNumber,
    required String neighborhood,
    required String city,
    required String state,
    required String zipCode,
    String? references,
    required double latitude,
    required double longitude,
  }) async {
    try {
      LoggerService.location('Creando nueva dirección: $alias', tag: 'AddressService');
      
      final requestData = CreateAddressRequest(
        alias: alias,
        street: street,
        exteriorNumber: exteriorNumber,
        interiorNumber: interiorNumber,
        neighborhood: neighborhood,
        city: city,
        state: state,
        zipCode: zipCode,
        references: references,
        latitude: latitude,
        longitude: longitude,
      );

      // Validar datos antes de enviar
      final validationError = requestData.validate();
      if (validationError != null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: validationError,
          data: null,
        );
      }

      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/customer/addresses',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        requestData.toJson(),
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta al crear dirección: ${response.status}', tag: 'AddressService');
      LoggerService.location('Datos de respuesta: ${response.data}', tag: 'AddressService');

      return response;
    } catch (e) {
      LoggerService.error('Error al crear dirección: $e', tag: 'AddressService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al crear dirección: $e',
        data: null,
      );
    }
  }

  /// Actualizar una dirección existente
  static Future<ApiResponse<Map<String, dynamic>>> updateAddress({
    required int addressId,
    required String alias,
    required String street,
    required String exteriorNumber,
    String? interiorNumber,
    required String neighborhood,
    required String city,
    required String state,
    required String zipCode,
    String? references,
    required double latitude,
    required double longitude,
  }) async {
    try {
      LoggerService.location('Actualizando dirección $addressId: $alias', tag: 'AddressService');
      
      final requestData = UpdateAddressRequest(
        alias: alias,
        street: street,
        exteriorNumber: exteriorNumber,
        interiorNumber: interiorNumber,
        neighborhood: neighborhood,
        city: city,
        state: state,
        zipCode: zipCode,
        references: references,
        latitude: latitude,
        longitude: longitude,
      );

      // Validar datos antes de enviar
      final validationError = requestData.validate();
      if (validationError != null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: validationError,
          data: null,
        );
      }

      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/customer/addresses/$addressId',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        requestData.toJson(),
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta al actualizar dirección: ${response.status}', tag: 'AddressService');
      LoggerService.location('Datos de respuesta: ${response.data}', tag: 'AddressService');
      
      // Debug adicional para diagnosticar el problema
      if (response.isSuccess && response.data != null) {
        debugPrint('🔍 AddressService: Estructura de datos recibida:');
        debugPrint('🔍 AddressService: Keys: ${response.data!.keys}');
        debugPrint('🔍 AddressService: Tipo de datos: ${response.data!.runtimeType}');
        
        // Verificar si los datos están anidados
        if (response.data!.containsKey('data')) {
          debugPrint('🔍 AddressService: Datos anidados encontrados en "data"');
          debugPrint('🔍 AddressService: Contenido de "data": ${response.data!['data']}');
        }
        if (response.data!.containsKey('address')) {
          debugPrint('🔍 AddressService: Datos anidados encontrados en "address"');
          debugPrint('🔍 AddressService: Contenido de "address": ${response.data!['address']}');
        }
      }

      return response;
    } catch (e) {
      LoggerService.error('Error al actualizar dirección: $e', tag: 'AddressService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al actualizar dirección: $e',
        data: null,
      );
    }
  }

  /// Eliminar una dirección
  static Future<ApiResponse<Map<String, dynamic>>> deleteAddress({
    required int addressId,
  }) async {
    try {
      LoggerService.location('Eliminando dirección $addressId...', tag: 'AddressService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/customer/addresses/$addressId',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta al eliminar dirección: ${response.status}', tag: 'AddressService');
      LoggerService.location('Datos de respuesta: ${response.data}', tag: 'AddressService');

      return response;
    } catch (e) {
      LoggerService.error('Error al eliminar dirección: $e', tag: 'AddressService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al eliminar dirección: $e',
        data: null,
      );
    }
  }

  /// Obtener una dirección específica por ID
  static Future<ApiResponse<Map<String, dynamic>>> getAddress({
    required int addressId,
  }) async {
    try {
      LoggerService.location('Obteniendo dirección $addressId...', tag: 'AddressService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/customer/addresses/$addressId',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de dirección: ${response.status}', tag: 'AddressService');
      LoggerService.location('Datos de dirección: ${response.data}', tag: 'AddressService');

      return response;
    } catch (e) {
      LoggerService.error('Error al obtener dirección: $e', tag: 'AddressService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener dirección: $e',
        data: null,
      );
    }
  }

  /// Buscar direcciones por texto
  static Future<List<Address>> searchAddresses({
    required String query,
    required List<Address> addresses,
  }) async {
    if (query.isEmpty) return addresses;
    
    final lowercaseQuery = query.toLowerCase();
    return addresses.where((address) {
      return address.alias.toLowerCase().contains(lowercaseQuery) ||
             address.street.toLowerCase().contains(lowercaseQuery) ||
             address.neighborhood.toLowerCase().contains(lowercaseQuery) ||
             address.city.toLowerCase().contains(lowercaseQuery) ||
             address.state.toLowerCase().contains(lowercaseQuery) ||
             address.zipCode.contains(query);
    }).toList();
  }

  /// Validar si una dirección está dentro de la zona de cobertura
  static Future<bool> validateCoverageArea({
    required double latitude,
    required double longitude,
    int? restaurantId,
  }) async {
    try {
      // Importar CoverageService aquí para evitar dependencias circulares
      // Validación de zona de cobertura - funcionalidad pendiente
      debugPrint('📍 Validando zona de cobertura para lat: $latitude, lng: $longitude');
      
      // Por ahora, validación básica
      if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
        return false;
      }
      
      // Simular validación de zona (Ciudad de México)
      final distance = calculateDistance(
        lat1: 19.4326,
        lng1: -99.1332,
        lat2: latitude,
        lng2: longitude,
      );
      
      return distance <= 15.0; // 15 km de radio
    } catch (e) {
      debugPrint('❌ Error al validar zona de cobertura: $e');
      return false;
    }
  }

  /// Calcular distancia entre dos puntos (Haversine formula)
  static double calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
        cos(lat2 * pi / 180) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Obtener coordenadas aproximadas basadas en código postal
  static Future<Map<String, double>?> getCoordinatesFromZipCode({
    required String zipCode,
  }) async {
    try {
      // Geocodificación por código postal - funcionalidad pendiente
      // Por ahora, retornamos coordenadas de ejemplo
      LoggerService.location('Obteniendo coordenadas para código postal: $zipCode', tag: 'AddressService');
      
      // Coordenadas de ejemplo para México
      return {
        'latitude': 19.4326, // Ciudad de México
        'longitude': -99.1332,
      };
    } catch (e) {
      LoggerService.error('Error al obtener coordenadas: $e', tag: 'AddressService');
      return null;
    }
  }

  /// Formatear dirección para mostrar
  static String formatAddress({
    required String street,
    required String exteriorNumber,
    String? interiorNumber,
    required String neighborhood,
    required String city,
    required String state,
    required String zipCode,
  }) {
    final parts = [
      street,
      exteriorNumber,
      if (interiorNumber != null && interiorNumber.isNotEmpty) 'Int. $interiorNumber',
      neighborhood,
      city,
      state,
      zipCode,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  /// Validar formato de código postal mexicano
  static bool isValidZipCode(String zipCode) {
    return RegExp(r'^\d{5}$').hasMatch(zipCode);
  }

  /// Validar coordenadas
  static bool isValidCoordinates({
    required double latitude,
    required double longitude,
  }) {
    return latitude >= -90 && latitude <= 90 &&
           longitude >= -180 && longitude <= 180;
  }
}
