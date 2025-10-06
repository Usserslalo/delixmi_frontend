import '../models/api_response.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'token_manager.dart';

class AuthService {
  /// Realiza el registro de un nuevo usuario
  static Future<ApiResponse<User>> register({
    required String name,
    required String lastname,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Debug: Imprimir datos que se van a enviar (solo en desarrollo)
    // print('=== DATOS DE REGISTRO ===');
    // print('name: $name');
    // print('lastname: $lastname');
    // print('email: $email');
    // print('phone: $phone');
    // print('password: ${password.replaceAll(RegExp(r'.'), '*')}'); // Ocultar contraseña
    // print('========================');
    
    final response = await ApiService.makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/register',
      ApiService.defaultHeaders,
      {
        'name': name,
        'lastname': lastname,
        'email': email,
        'phone': phone,
        'password': password,
      },
      null,
    );

    if (response.isSuccess && response.data != null) {
      final userData = response.data!['user'];
      final user = User.fromJson(userData);
      return ApiResponse<User>(
        status: 'success',
        message: response.message,
        data: user,
      );
    }

    return ApiResponse<User>(
      status: response.status,
      message: response.message,
      code: response.code,
      errors: response.errors,
    );
  }

  /// Realiza el login del usuario
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/login',
      ApiService.defaultHeaders,
      {
        'email': email,
        'password': password,
      },
      null,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      final user = User.fromJson(data['user']);
      final token = data['token'];
      final expiresIn = data['expiresIn'];

      // Guardar token y datos del usuario
      await TokenManager.saveToken(token);
      await TokenManager.saveUserData(user.toJson());

      return ApiResponse<Map<String, dynamic>>(
        status: 'success',
        message: response.message,
        data: {
          'token': token,
          'user': user,
          'expiresIn': expiresIn,
        },
      );
    }

    return ApiResponse<Map<String, dynamic>>(
      status: response.status,
      message: response.message,
      code: response.code,
      errors: response.errors,
    );
  }

  /// Obtiene el perfil del usuario autenticado
  static Future<ApiResponse<User>> getProfile() async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/auth/profile',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final userData = response.data!['user'];
        final user = User.fromJson(userData);
        
        // Actualizar datos del usuario guardados
        await TokenManager.saveUserData(user.toJson());
        
        return ApiResponse<User>(
          status: 'success',
          message: response.message,
          data: user,
        );
      }

      return ApiResponse<User>(
        status: response.status,
        message: response.message,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      return ApiResponse<User>(
        status: 'error',
        message: 'Error al obtener el perfil: ${e.toString()}',
      );
    }
  }

  /// Verifica si el token es válido
  static Future<ApiResponse<Map<String, dynamic>>> verifyToken() async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/auth/verify',
        headers,
        null,
        null,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al verificar el token: ${e.toString()}',
      );
    }
  }

  /// Reenvía el email de verificación
  static Future<ApiResponse<Map<String, dynamic>>> resendVerificationEmail({
    required String email,
  }) async {
    final response = await ApiService.makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/resend-verification',
      ApiService.defaultHeaders,
      {
        'email': email,
      },
      null,
    );

    return response;
  }

  /// Reenvía el email de verificación (alias para compatibilidad)
  static Future<ApiResponse<Map<String, dynamic>>> resendVerification({
    required String email,
  }) async {
    return await resendVerificationEmail(email: email);
  }

  /// Solicita restablecimiento de contraseña
  static Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    final response = await ApiService.makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/forgot-password',
      ApiService.defaultHeaders,
      {
        'email': email,
      },
      null,
    );

    return response;
  }

  /// Restablece la contraseña con el token del email
  static Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await ApiService.makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/reset-password',
      ApiService.defaultHeaders,
      {
        'token': token,
        'newPassword': newPassword,
      },
      null,
    );

    return response;
  }

  /// Obtiene el token guardado
  static Future<String?> getToken() async {
    return await TokenManager.getToken();
  }

  /// Verifica si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    return await TokenManager.hasValidToken();
  }

  /// Obtiene los datos del usuario guardados
  static Future<User?> getCurrentUser() async {
    try {
      final userData = await TokenManager.getUserData();
      if (userData != null) {
        // Parsear el JSON string guardado correctamente
        final userJson = Map<String, dynamic>.from(
          Uri.splitQueryString(userData)
        );
        return User.fromJson(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cierra la sesión del usuario
  static Future<void> logout() async {
    await TokenManager.clearAll();
  }

  /// Limpia todos los datos de autenticación
  static Future<void> clearAll() async {
    await TokenManager.clearAll();
  }
}