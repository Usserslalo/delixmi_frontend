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
      final userJson = Uri(queryParameters: userData.map((key, value) => MapEntry(key, value.toString()))).query;
      await _storage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw Exception('Error al guardar los datos del usuario: ${e.toString()}');
    }
  }

  /// Obtiene los datos del usuario guardados
  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userKey);
    } catch (e) {
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
