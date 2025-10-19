import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../models/owner/restaurant_profile.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'token_manager.dart';

class RestaurantService {
  /// Obtiene el perfil completo del restaurante del owner autenticado
  static Future<ApiResponse<RestaurantProfile>> getProfile() async {
    try {
      debugPrint('🏪 RestaurantService: Obteniendo perfil del restaurante...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/profile',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final restaurantData = response.data!['restaurant'];
        final restaurant = RestaurantProfile.fromJson(restaurantData);
        
        debugPrint('✅ Perfil del restaurante obtenido: ${restaurant.name}');
        
        return ApiResponse<RestaurantProfile>(
          status: 'success',
          message: response.message,
          data: restaurant,
        );
      } else {
        debugPrint('❌ Error al obtener perfil: ${response.message}');
        return ApiResponse<RestaurantProfile>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ RestaurantService.getProfile: Error inesperado: $e');
      return ApiResponse<RestaurantProfile>(
        status: 'error',
        message: 'Error al obtener el perfil del restaurante: ${e.toString()}',
      );
    }
  }

  /// Actualiza la información del restaurante (nombre, descripción, URLs de imágenes, contacto)
  static Future<ApiResponse<RestaurantProfile>> updateProfile({
    String? name,
    String? description,
    String? phone,
    String? email,
    String? address,
    String? logoUrl,
    String? coverPhotoUrl,
  }) async {
    try {
      debugPrint('🏪 RestaurantService: Actualizando perfil del restaurante...');
      
      // Construir body solo con campos que se van a actualizar
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (address != null) body['address'] = address;
      if (logoUrl != null) body['logoUrl'] = logoUrl;
      if (coverPhotoUrl != null) body['coverPhotoUrl'] = coverPhotoUrl;

      if (body.isEmpty) {
        return ApiResponse<RestaurantProfile>(
          status: 'error',
          message: 'No se proporcionaron campos para actualizar',
        );
      }

      debugPrint('📤 Campos a actualizar: ${body.keys.toList()}');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/profile',
        headers,
        body,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final restaurantData = response.data!['restaurant'];
        final restaurant = RestaurantProfile.fromJson(restaurantData);
        
        debugPrint('✅ Perfil actualizado exitosamente');
        
        return ApiResponse<RestaurantProfile>(
          status: 'success',
          message: response.message,
          data: restaurant,
        );
      } else {
        debugPrint('❌ Error al actualizar perfil: ${response.message}');
        return ApiResponse<RestaurantProfile>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ RestaurantService.updateProfile: Error inesperado: $e');
      return ApiResponse<RestaurantProfile>(
        status: 'error',
        message: 'Error al actualizar el perfil: ${e.toString()}',
      );
    }
  }

  /// PASO A: Sube un logo del restaurante y devuelve la URL
  static Future<ApiResponse<UploadImageResponse>> uploadLogo(File imageFile) async {
    try {
      debugPrint('📤 RestaurantService: Subiendo logo...');
      
      // Debugging detallado del archivo
      final fileSize = await imageFile.length();
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      debugPrint('📁 Archivo: $fileName');
      debugPrint('📏 Tamaño: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('🔤 Extensión: $fileExtension');
      debugPrint('📂 Ruta completa: ${imageFile.path}');
      
      // Verificar que sea una imagen válida
      if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        debugPrint('❌ Extensión no válida: $fileExtension');
        return ApiResponse<UploadImageResponse>(
          status: 'error',
          message: 'Formato de archivo no válido. Solo se permiten JPG, JPEG y PNG.',
        );
      }
      
      final token = await TokenManager.getToken();
      
      // Crear MultipartRequest
      final uri = Uri.parse('${ApiService.fullUrl}/restaurant/upload-logo');
      final request = http.MultipartRequest('POST', uri);
      
      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';
      
      // Agregar archivo con MIME type explícito
      final mimeType = fileExtension == 'jpg' || fileExtension == 'jpeg' 
          ? 'image/jpeg' 
          : 'image/png';
      
      debugPrint('📤 Enviando archivo con MIME type: $mimeType');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'logo',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final uploadResponse = UploadImageResponse.fromJson(responseData['data']);
          
          debugPrint('✅ Logo subido exitosamente: ${uploadResponse.logoUrl}');
          
          return ApiResponse<UploadImageResponse>(
            status: 'success',
            message: responseData['message'],
            data: uploadResponse,
          );
        }
      }
      
      final errorData = jsonDecode(response.body);
      return ApiResponse<UploadImageResponse>(
        status: 'error',
        message: errorData['message'] ?? 'Error al subir logo',
        code: errorData['code'],
      );
    } catch (e) {
      debugPrint('❌ RestaurantService.uploadLogo: Error inesperado: $e');
      return ApiResponse<UploadImageResponse>(
        status: 'error',
        message: 'Error inesperado al subir el logo: ${e.toString()}',
      );
    }
  }

  /// PASO A: Sube una foto de portada del restaurante y devuelve la URL
  static Future<ApiResponse<UploadImageResponse>> uploadCover(File imageFile) async {
    try {
      debugPrint('📤 RestaurantService: Subiendo foto de portada...');
      
      // Debugging detallado del archivo
      final fileSize = await imageFile.length();
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      debugPrint('📁 Archivo: $fileName');
      debugPrint('📏 Tamaño: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('🔤 Extensión: $fileExtension');
      debugPrint('📂 Ruta completa: ${imageFile.path}');
      
      // Verificar que sea una imagen válida
      if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        debugPrint('❌ Extensión no válida: $fileExtension');
        return ApiResponse<UploadImageResponse>(
          status: 'error',
          message: 'Formato de archivo no válido. Solo se permiten JPG, JPEG y PNG.',
        );
      }
      
      final token = await TokenManager.getToken();
      
      // Crear MultipartRequest
      final uri = Uri.parse('${ApiService.fullUrl}/restaurant/upload-cover');
      final request = http.MultipartRequest('POST', uri);
      
      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';
      
      // Agregar archivo con MIME type explícito
      final mimeType = fileExtension == 'jpg' || fileExtension == 'jpeg' 
          ? 'image/jpeg' 
          : 'image/png';
      
      debugPrint('📤 Enviando archivo con MIME type: $mimeType');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'cover',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          final uploadResponse = UploadImageResponse.fromJson(responseData['data']);
          
          debugPrint('✅ Portada subida exitosamente: ${uploadResponse.coverPhotoUrl}');
          
          return ApiResponse<UploadImageResponse>(
            status: 'success',
            message: responseData['message'],
            data: uploadResponse,
          );
        }
      }
      
      final errorData = jsonDecode(response.body);
      return ApiResponse<UploadImageResponse>(
        status: 'error',
        message: errorData['message'] ?? 'Error al subir portada',
        code: errorData['code'],
      );
    } catch (e) {
      debugPrint('❌ RestaurantService.uploadCover: Error inesperado: $e');
      return ApiResponse<UploadImageResponse>(
        status: 'error',
        message: 'Error inesperado al subir la portada: ${e.toString()}',
      );
    }
  }

  /// Verifica si la ubicación del restaurante está configurada
  static Future<ApiResponse<Map<String, dynamic>>> getLocationStatus() async {
    try {
      debugPrint('🏪 RestaurantService: Verificando estado de ubicación...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/location-status',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('✅ Estado de ubicación obtenido: ${response.data}');
        
        return ApiResponse<Map<String, dynamic>>(
          status: 'success',
          message: response.message,
          data: response.data!,
        );
      } else {
        debugPrint('❌ Error al obtener estado de ubicación: ${response.message}');
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ RestaurantService.getLocationStatus: Error inesperado: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al verificar el estado de ubicación: ${e.toString()}',
      );
    }
  }

  /// Actualiza la ubicación del restaurante
  static Future<ApiResponse<Map<String, dynamic>>> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      debugPrint('🏪 RestaurantService: Actualizando ubicación del restaurante...');
      debugPrint('📍 Latitud: $latitude, Longitud: $longitude');
      debugPrint('📍 Dirección: $address');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final Map<String, dynamic> body = {
        'latitude': latitude,
        'longitude': longitude,
      };
      
      if (address != null && address.isNotEmpty) {
        body['address'] = address;
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/location',
        headers,
        body,
        null,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('✅ Ubicación actualizada exitosamente');
        
        return ApiResponse<Map<String, dynamic>>(
          status: 'success',
          message: response.message,
          data: response.data!,
        );
      } else {
        debugPrint('❌ Error al actualizar ubicación: ${response.message}');
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ RestaurantService.updateLocation: Error inesperado: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al actualizar la ubicación: ${e.toString()}',
      );
    }
  }

  /// Obtiene los datos completos de ubicación del restaurante (incluyendo latitud, longitud y dirección)
  /// Ahora el endpoint getLocationStatus devuelve tanto el estado como los datos completos
  static Future<ApiResponse<Map<String, dynamic>>> getRestaurantLocation() async {
    try {
      debugPrint('🏪 RestaurantService: Obteniendo ubicación completa del restaurante...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/location-status', // Este endpoint ahora devuelve isLocationSet + location data
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('✅ Ubicación del restaurante obtenida: ${response.data}');
        
        return ApiResponse<Map<String, dynamic>>(
          status: 'success',
          message: response.message,
          data: response.data!,
        );
      } else {
        debugPrint('❌ Error al obtener ubicación: ${response.message}');
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ RestaurantService.getRestaurantLocation: Error inesperado: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener la ubicación del restaurante: ${e.toString()}',
      );
    }
  }

  /// Obtiene la información de la sucursal principal del restaurante del owner autenticado
  static Future<ApiResponse<Map<String, dynamic>>> getPrimaryBranch() async {
    try {
      debugPrint('🏢 RestaurantService: Obteniendo sucursal principal...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/primary-branch',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final branchData = response.data!['branch'];
        debugPrint('✅ Sucursal principal obtenida: ${branchData['name']} (ID: ${branchData['id']})');
        
        return ApiResponse<Map<String, dynamic>>(
          status: 'success',
          message: response.message,
          data: {
            'branch': branchData,
          },
        );
      } else {
        debugPrint('❌ Error al obtener sucursal principal: ${response.message}');
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ RestaurantService.getPrimaryBranch: Error inesperado: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener la sucursal principal: ${e.toString()}',
      );
    }
  }
}
