import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _primaryBranchIdKey = 'primary_branch_id';
  static const String _isLocationSetKey = 'is_location_set';

  /// Guarda los tokens JWT de forma segura
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw Exception('Error al guardar los tokens: ${e.toString()}');
    }
  }

  /// Guarda solo el access token (compatibilidad con código existente)
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw Exception('Error al guardar el token: ${e.toString()}');
    }
  }

  /// Obtiene el access token guardado
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el refresh token guardado
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el token JWT guardado (compatibilidad con código existente)
  static Future<String?> getToken() async {
    return await getAccessToken();
  }

  /// Elimina todos los tokens
  static Future<void> deleteTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      // Ignorar errores al eliminar tokens
    }
  }

  /// Alias para deleteTokens (compatibilidad con AuthService)
  static Future<void> clearToken() async {
    await deleteTokens();
  }

  /// Verifica si hay un token válido guardado
  static Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Guarda los datos del usuario de forma segura
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      // debugPrint('🔍 TokenManager.saveUserData: Guardando datos: $userData');
      final userJson = jsonEncode(userData);
      // debugPrint('🔍 TokenManager.saveUserData: JSON generado: $userJson');
      await _storage.write(key: _userKey, value: userJson);
      // debugPrint('✅ TokenManager.saveUserData: Datos guardados exitosamente');
    } catch (e) {
      // debugPrint('❌ TokenManager.saveUserData: Error: $e');
      throw Exception('Error al guardar los datos del usuario: ${e.toString()}');
    }
  }

  /// Obtiene los datos del usuario guardados
  static Future<String?> getUserData() async {
    try {
      final data = await _storage.read(key: _userKey);
      // debugPrint('🔍 TokenManager.getUserData: Datos recuperados: $data');
      return data;
    } catch (e) {
      // debugPrint('❌ TokenManager.getUserData: Error: $e');
      return null;
    }
  }

  /// Elimina los datos del usuario
  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userKey);
    } catch (e) {
      // Ignorar errores al eliminar datos
    }
  }

  /// Alias para deleteUserData (compatibilidad con AuthService)
  static Future<void> clearUserData() async {
    await deleteUserData();
  }

  /// Limpia todos los datos de autenticación
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Ignorar errores al limpiar
    }
  }

  /// Obtiene los headers de autenticación
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible');
    }
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Verifica si hay tokens válidos guardados
  static Future<bool> hasValidTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      return accessToken != null && accessToken.isNotEmpty && 
             refreshToken != null && refreshToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Guarda el ID de la sucursal principal
  static Future<void> savePrimaryBranchId(int branchId) async {
    try {
      await _storage.write(key: _primaryBranchIdKey, value: branchId.toString());
    } catch (e) {
      throw Exception('Error al guardar el ID de sucursal principal: ${e.toString()}');
    }
  }

  /// Obtiene el ID de la sucursal principal
  static Future<int?> getPrimaryBranchId() async {
    try {
      final branchIdString = await _storage.read(key: _primaryBranchIdKey);
      return branchIdString != null ? int.tryParse(branchIdString) : null;
    } catch (e) {
      return null;
    }
  }

  /// Guarda el estado de ubicación configurada
  static Future<void> saveLocationStatus(bool isLocationSet) async {
    try {
      await _storage.write(key: _isLocationSetKey, value: isLocationSet.toString());
    } catch (e) {
      throw Exception('Error al guardar el estado de ubicación: ${e.toString()}');
    }
  }

  /// Obtiene el estado de ubicación configurada
  static Future<bool> getLocationStatus() async {
    try {
      final locationString = await _storage.read(key: _isLocationSetKey);
      return locationString == 'true';
    } catch (e) {
      return false; // Por defecto, asumir que no está configurada
    }
  }

  /// Elimina el ID de la sucursal principal
  static Future<void> deletePrimaryBranchId() async {
    try {
      await _storage.delete(key: _primaryBranchIdKey);
    } catch (e) {
      // Ignorar errores al eliminar
    }
  }

  /// Elimina el estado de ubicación
  static Future<void> deleteLocationStatus() async {
    try {
      await _storage.delete(key: _isLocationSetKey);
    } catch (e) {
      // Ignorar errores al eliminar
    }
  }

  /// Limpia todos los datos de autenticación incluyendo branchId y location
  static Future<void> clearAllOwnerData() async {
    try {
      await _storage.delete(key: _primaryBranchIdKey);
      await _storage.delete(key: _isLocationSetKey);
      await clearAll();
    } catch (e) {
      // Ignorar errores al limpiar
    }
  }
}
