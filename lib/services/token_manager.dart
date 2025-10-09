import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Guarda el token JWT de forma segura
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Error al guardar el token: ${e.toString()}');
    }
  }

  /// Obtiene el token JWT guardado
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Elimina el token JWT
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      // Ignorar errores al eliminar token
    }
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
      print('🔍 TokenManager.saveUserData: Guardando datos: $userData');
      final userJson = jsonEncode(userData);
      print('🔍 TokenManager.saveUserData: JSON generado: $userJson');
      await _storage.write(key: _userKey, value: userJson);
      print('✅ TokenManager.saveUserData: Datos guardados exitosamente');
    } catch (e) {
      print('❌ TokenManager.saveUserData: Error: $e');
      throw Exception('Error al guardar los datos del usuario: ${e.toString()}');
    }
  }

  /// Obtiene los datos del usuario guardados
  static Future<String?> getUserData() async {
    try {
      final data = await _storage.read(key: _userKey);
      print('🔍 TokenManager.getUserData: Datos recuperados: $data');
      return data;
    } catch (e) {
      print('❌ TokenManager.getUserData: Error: $e');
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
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
