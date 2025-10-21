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
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'MISSING_TOKEN':
              errorMessage = 'Token de acceso requerido';
              break;
            case 'INVALID_TOKEN':
              errorMessage = 'Token inválido';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Permisos insuficientes';
              break;
            case 'NO_RESTAURANT_ASSIGNED':
              errorMessage = 'No se encontró un restaurante asignado para este owner';
              break;
            case 'RESTAURANT_NOT_FOUND':
              errorMessage = 'Restaurante no encontrado';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<RestaurantProfile>(
          status: response.status,
          message: errorMessage,
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
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'VALIDATION_ERROR':
              // El backend envía detalles específicos en response.errors
              if (response.errors != null && response.errors!.isNotEmpty) {
                final errorDetails = response.errors!.map((error) {
                  if (error is Map<String, dynamic>) {
                    final field = error['field'] ?? '';
                    final message = error['message'] ?? '';
                    return field.isNotEmpty ? '$field: $message' : message;
                  }
                  return error.toString();
                }).join('\n');
                errorMessage = errorDetails.isNotEmpty ? errorDetails : response.message;
              }
              break;
            case 'NO_FIELDS_TO_UPDATE':
              errorMessage = 'No se proporcionaron campos para actualizar';
              break;
            case 'MISSING_TOKEN':
              errorMessage = 'Token de acceso requerido';
              break;
            case 'INVALID_TOKEN':
              errorMessage = 'Token inválido';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Permisos insuficientes';
              break;
            case 'RESTAURANT_NOT_FOUND':
              errorMessage = 'Restaurante no encontrado';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<RestaurantProfile>(
          status: response.status,
          message: errorMessage,
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
      String errorMessage = errorData['message'] ?? 'Error al subir logo';
      
      // Manejar códigos de error específicos del backend
      if (errorData['code'] != null) {
        switch (errorData['code']) {
          case 'NO_FILE_PROVIDED':
            errorMessage = 'No se proporcionó ningún archivo';
            break;
          case 'FILE_TOO_LARGE':
            errorMessage = 'El archivo es demasiado grande. El tamaño máximo permitido es 5MB';
            break;
          case 'INVALID_FILE_TYPE':
            errorMessage = 'Solo se permiten archivos JPG, JPEG y PNG';
            break;
          case 'TOO_MANY_FILES':
            errorMessage = 'Solo se permite subir un archivo a la vez';
            break;
          case 'UNAUTHORIZED':
            errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente';
            break;
          case 'FORBIDDEN':
            errorMessage = 'No tienes permisos para subir imágenes';
            break;
          case 'NO_RESTAURANT_ASSIGNED':
            errorMessage = 'No se encontró un restaurante asignado para este owner';
            break;
          default:
            errorMessage = errorData['message'] ?? 'Error al subir logo';
            break;
        }
      }
      
      return ApiResponse<UploadImageResponse>(
        status: 'error',
        message: errorMessage,
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
      String errorMessage = errorData['message'] ?? 'Error al subir portada';
      
      // Manejar códigos de error específicos del backend
      if (errorData['code'] != null) {
        switch (errorData['code']) {
          case 'NO_FILE_PROVIDED':
            errorMessage = 'No se proporcionó ningún archivo';
            break;
          case 'FILE_TOO_LARGE':
            errorMessage = 'El archivo es demasiado grande. El tamaño máximo permitido es 5MB';
            break;
          case 'INVALID_FILE_TYPE':
            errorMessage = 'Solo se permiten archivos JPG, JPEG y PNG';
            break;
          case 'TOO_MANY_FILES':
            errorMessage = 'Solo se permite subir un archivo a la vez';
            break;
          case 'UNAUTHORIZED':
            errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente';
            break;
          case 'FORBIDDEN':
            errorMessage = 'No tienes permisos para subir imágenes';
            break;
          case 'NO_RESTAURANT_ASSIGNED':
            errorMessage = 'No se encontró un restaurante asignado para este owner';
            break;
          default:
            errorMessage = errorData['message'] ?? 'Error al subir portada';
            break;
        }
      }
      
      return ApiResponse<UploadImageResponse>(
        status: 'error',
        message: errorMessage,
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
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Acceso denegado. Se requiere rol de owner';
              break;
            case 'NOT_FOUND':
              errorMessage = 'Usuario no encontrado';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: errorMessage,
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
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'VALIDATION_ERROR':
              // El backend envía detalles específicos en response.errors
              if (response.errors != null && response.errors!.isNotEmpty) {
                final errorDetails = response.errors!.map((error) {
                  if (error is Map<String, dynamic>) {
                    final field = error['field'] ?? '';
                    final message = error['message'] ?? '';
                    return field.isNotEmpty ? '$field: $message' : message;
                  }
                  return error.toString();
                }).join('\n');
                errorMessage = errorDetails.isNotEmpty ? errorDetails : response.message;
              }
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Acceso denegado. Se requiere rol de owner';
              break;
            case 'NOT_FOUND':
              errorMessage = 'Usuario no encontrado';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: errorMessage,
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
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'PRIMARY_BRANCH_NOT_FOUND':
              errorMessage = 'Sucursal principal no encontrada';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Acceso denegado. Se requiere rol de owner';
              break;
            case 'NO_RESTAURANT_ASSIGNED':
              errorMessage = 'No se encontró un restaurante asignado para este owner';
              break;
            case 'NOT_FOUND':
              errorMessage = 'Usuario no encontrado';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: errorMessage,
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

  /// Actualiza los detalles operativos de la sucursal principal del restaurante
  static Future<ApiResponse<Map<String, dynamic>>> updatePrimaryBranchDetails({
    String? name,
    String? phone,
    bool? usesPlatformDrivers,
    double? deliveryFee,
    int? estimatedDeliveryMin,
    int? estimatedDeliveryMax,
    double? deliveryRadius,
    String? status,
  }) async {
    try {
      debugPrint('🏢 RestaurantService: Actualizando detalles de sucursal principal...');
      
      // Construir body solo con campos que se van a actualizar
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (usesPlatformDrivers != null) body['usesPlatformDrivers'] = usesPlatformDrivers;
      if (deliveryFee != null) body['deliveryFee'] = deliveryFee;
      if (estimatedDeliveryMin != null) body['estimatedDeliveryMin'] = estimatedDeliveryMin;
      if (estimatedDeliveryMax != null) body['estimatedDeliveryMax'] = estimatedDeliveryMax;
      if (deliveryRadius != null) body['deliveryRadius'] = deliveryRadius;
      if (status != null) body['status'] = status;

      if (body.isEmpty) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'No se proporcionaron campos para actualizar',
        );
      }

      debugPrint('📤 Campos a actualizar en sucursal principal: ${body.keys.toList()}');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/primary-branch',
        headers,
        body,
        null,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('✅ Detalles de sucursal principal actualizados exitosamente');
        
        return ApiResponse<Map<String, dynamic>>(
          status: 'success',
          message: response.message,
          data: response.data!,
        );
      } else {
        debugPrint('❌ Error al actualizar sucursal principal: ${response.message}');
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'VALIDATION_ERROR':
              // El backend envía detalles específicos en response.errors
              if (response.errors != null && response.errors!.isNotEmpty) {
                final errorDetails = response.errors!.map((error) {
                  if (error is Map<String, dynamic>) {
                    final field = error['field'] ?? '';
                    final message = error['message'] ?? '';
                    return field.isNotEmpty ? '$field: $message' : message;
                  }
                  return error.toString();
                }).join('\n');
                errorMessage = errorDetails.isNotEmpty ? errorDetails : response.message;
              }
              break;
            case 'INVALID_DELIVERY_TIMES':
              errorMessage = 'El tiempo mínimo de entrega debe ser menor que el tiempo máximo';
              break;
            case 'NO_FIELDS_TO_UPDATE':
              errorMessage = 'No se proporcionó ningún campo válido para actualizar';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Acceso denegado. Se requiere rol de owner';
              break;
            case 'NO_RESTAURANT_ASSIGNED':
              errorMessage = 'No se encontró un restaurante asignado para este owner';
              break;
            case 'PRIMARY_BRANCH_NOT_FOUND':
              errorMessage = 'Sucursal principal no encontrada';
              break;
            case 'NOT_FOUND':
              errorMessage = 'Usuario no encontrado';
              break;
            case 'INTERNAL_ERROR':
              errorMessage = 'Error interno del servidor';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<Map<String, dynamic>>(
          status: response.status,
          message: errorMessage,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ RestaurantService.updatePrimaryBranchDetails: Error inesperado: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al actualizar los detalles de la sucursal principal: ${e.toString()}',
      );
    }
  }
}
