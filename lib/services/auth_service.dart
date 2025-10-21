import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/auth/user.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_response.dart';
import '../models/auth/refresh_response.dart';
import 'api_service.dart';
import 'token_manager.dart';
import 'onboarding_service.dart';

class AuthService {
  /// Realiza el registro de un nuevo usuario
  /// Devuelve una respuesta especializada que maneja casos como EMAIL_SEND_ERROR
  static Future<RegisterResponse> register({
    required String name,
    required String lastname,
    required String email,
    required String phone,
    required String password,
  }) async {
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
      
      // Resetear el onboarding para el nuevo usuario
      await OnboardingService.instance.resetForNewUser();
      debugPrint('🎉 AuthService: Onboarding reseteado para nuevo usuario');
      
      return RegisterResponse.success(
        message: response.message,
        user: user,
      );
    }

    // Manejo de errores específicos según la documentación de la API
    switch (response.code) {
      case 'USER_EXISTS':
        return RegisterResponse.error(
          message: 'El correo electrónico ya está en uso',
          errorCode: 'USER_EXISTS',
        );
      
      case 'VALIDATION_ERROR':
        return RegisterResponse.error(
          message: response.message,
          errorCode: 'VALIDATION_ERROR',
        );
      
      case 'EMAIL_SEND_ERROR':
        // Usuario creado pero falló el envío del correo
        if (response.data != null) {
          try {
            // El backend envía userId y email en el data cuando hay EMAIL_SEND_ERROR
            final userData = response.data!;
            final partialUser = User(
              id: userData['userId'],
              name: name, // Usar los datos que enviamos en el registro
              lastname: lastname,
              email: userData['email'],
              phone: phone,
              status: 'pending', // El usuario está pendiente de verificación
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              roles: [], // Se llenará cuando el usuario complete la verificación
            );
            
            // Resetear el onboarding para el nuevo usuario (aunque haya error de email)
            await OnboardingService.instance.resetForNewUser();
            debugPrint('🎉 AuthService: Onboarding reseteado para nuevo usuario (con EMAIL_SEND_ERROR)');
            
            return RegisterResponse.emailSendError(
              message: 'Tu cuenta fue creada, pero tuvimos un problema al enviar el correo de verificación. Puedes solicitar un reenvío.',
              user: partialUser,
            );
          } catch (e) {
            debugPrint('Error al crear usuario parcial desde EMAIL_SEND_ERROR: $e');
          }
        }
        
        return RegisterResponse.error(
          message: 'Tu cuenta fue creada, pero tuvimos un problema al enviar el correo de verificación. Puedes solicitar un reenvío.',
          errorCode: 'EMAIL_SEND_ERROR',
        );
      
      case 'INTERNAL_ERROR':
        return RegisterResponse.error(
          message: 'Error interno del servidor. Por favor, intenta más tarde.',
          errorCode: 'INTERNAL_ERROR',
        );
      
      default:
        return RegisterResponse.error(
          message: response.message,
          errorCode: response.code,
        );
    }
  }

  /// Método de compatibilidad para el registro (devuelve ApiResponse)
  /// Usado por código existente que no ha sido actualizado
  static Future<ApiResponse<User>> registerLegacy({
    required String name,
    required String lastname,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await register(
      name: name,
      lastname: lastname,
      email: email,
      phone: phone,
      password: password,
    );

    return ApiResponse<User>(
      status: response.isSuccess ? 'success' : 'error',
      message: response.message,
      code: response.errorCode,
      data: response.user,
    );
  }

  /// Realiza el login del usuario
  /// Inicia sesión y devuelve la respuesta completa
  static Future<LoginResponse> login(String email, String password) async {
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
      final loginResponse = LoginResponse.fromJson({
        'status': response.status,
        'message': response.message,
        'data': response.data!,
      });
      
      // Guardar tokens en almacenamiento seguro
      await TokenManager.saveTokens(
        accessToken: loginResponse.data.accessToken,
        refreshToken: loginResponse.data.refreshToken,
      );
      
      // Guardar información del usuario
      await TokenManager.saveUserData(loginResponse.data.user.toJson());
      
      return loginResponse;
    } else {
      // Mapear códigos de error específicos según la documentación de la API
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'INVALID_CREDENTIALS':
          errorMessage = 'Credenciales incorrectas';
          break;
        case 'ACCOUNT_NOT_VERIFIED':
          errorMessage = 'Cuenta no verificada. Por favor, verifica tu correo electrónico.';
          break;
        case 'USER_NOT_FOUND':
          errorMessage = 'Usuario no encontrado';
          break;
        case 'VALIDATION_ERROR':
          errorMessage = response.message; // Usar el mensaje detallado de validación
          break;
        case 'TOO_MANY_REQUESTS':
          errorMessage = 'Demasiados intentos de login. Intenta nuevamente en unos minutos.';
          break;
      }
      
      throw Exception(errorMessage);
    }
  }
  
  /// Renueva el access token usando el refresh token
  static Future<RefreshResponse> refreshToken() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No hay refresh token disponible');
      }

      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/refresh-token',
        ApiService.defaultHeaders,
        {
          'refreshToken': refreshToken,
        },
        null,
      );

      if (response.isSuccess && response.data != null) {
        final refreshResponse = RefreshResponse.fromJson({
          'status': response.status,
          'message': response.message,
          'data': response.data!,
        });

        // Guardar los nuevos tokens
        await TokenManager.saveTokens(
          accessToken: refreshResponse.data.accessToken,
          refreshToken: refreshResponse.data.refreshToken,
        );

        return refreshResponse;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // Si falla el refresh, limpiar tokens
      await TokenManager.deleteTokens();
      await TokenManager.clearUserData();
      rethrow;
    }
  }

  /// Cierra sesión
  static Future<void> logout() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      
      if (refreshToken != null) {
        // Llamar al endpoint de logout con refresh token
        await ApiService.makeRequest<Map<String, dynamic>>(
          'POST',
          '/auth/logout',
          ApiService.defaultHeaders,
          {
            'refreshToken': refreshToken,
          },
          null,
        );
      }
    } catch (e) {
      // debugPrint('Error en logout del servidor: $e');
    } finally {
      // Limpiar almacenamiento local
      await TokenManager.deleteTokens();
      await TokenManager.clearUserData();
    }
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

      // Manejo de errores específicos según la documentación de la API
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'MISSING_TOKEN':
        case 'INVALID_TOKEN':
        case 'TOKEN_EXPIRED':
          errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
          break;
      }

      return ApiResponse<User>(
        status: response.status,
        message: errorMessage,
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

  /// Actualiza el perfil del usuario autenticado
  static Future<ApiResponse<User>> updateProfile({
    String? name,
    String? lastname,
    String? phone,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      
      // Construir body solo con campos no nulos
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (lastname != null) body['lastname'] = lastname;
      if (phone != null) body['phone'] = phone;
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PUT',
        '/auth/profile',
        headers,
        body,
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

      // Manejo de errores específicos según la documentación de la API
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'PHONE_EXISTS':
          errorMessage = 'Este número de teléfono ya está registrado por otro usuario';
          break;
        case 'VALIDATION_ERROR':
          errorMessage = response.message; // Usar el mensaje detallado de validación
          break;
        case 'MISSING_TOKEN':
        case 'INVALID_TOKEN':
        case 'TOKEN_EXPIRED':
          errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
          break;
      }

      return ApiResponse<User>(
        status: response.status,
        message: errorMessage,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      return ApiResponse<User>(
        status: 'error',
        message: 'Error al actualizar el perfil: ${e.toString()}',
      );
    }
  }

  /// Cambia la contraseña del usuario autenticado
  static Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PUT',
        '/auth/change-password',
        headers,
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        null,
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'success',
          message: response.message,
          data: response.data!,
        );
      }

      // Manejo de errores específicos según la documentación de la API
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'INVALID_CURRENT_PASSWORD':
          errorMessage = 'La contraseña actual es incorrecta';
          break;
        case 'VALIDATION_ERROR':
          errorMessage = response.message; // Usar el mensaje detallado de validación
          break;
        case 'MISSING_TOKEN':
        case 'INVALID_TOKEN':
        case 'TOKEN_EXPIRED':
          errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
          break;
      }

      return ApiResponse<Map<String, dynamic>>(
        status: response.status,
        message: errorMessage,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al cambiar la contraseña: ${e.toString()}',
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

    // Manejo de errores específicos según la documentación de la API
    if (!response.isSuccess) {
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'ALREADY_VERIFIED':
          errorMessage = 'La cuenta ya está verificada';
          break;
        case 'USER_NOT_FOUND':
          errorMessage = 'Usuario no encontrado';
          break;
        case 'VALIDATION_ERROR':
          errorMessage = response.message; // Usar el mensaje detallado de validación
          break;
        case 'EMAIL_SEND_ERROR':
          errorMessage = 'Error al enviar el correo. Por favor, intenta más tarde.';
          break;
      }

      return ApiResponse<Map<String, dynamic>>(
        status: response.status,
        message: errorMessage,
        code: response.code,
        errors: response.errors,
      );
    }

    return response;
  }

  /// Reenvía el email de verificación (alias para compatibilidad)
  static Future<ApiResponse<Map<String, dynamic>>> resendVerification({
    required String email,
  }) async {
    return await resendVerificationEmail(email: email);
  }

  /// Verifica el email con token
  static Future<ApiResponse<Map<String, dynamic>>> verifyEmail({
    required String token,
  }) async {
    final response = await ApiService.makeRequest<Map<String, dynamic>>(
      'GET',
      '/auth/verify-email?token=$token',
      ApiService.defaultHeaders,
      null,
      null,
    );

    // Manejo de errores específicos según la documentación de la API
    if (!response.isSuccess) {
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'INVALID_TOKEN':
          errorMessage = 'El token de verificación no es válido';
          break;
        case 'TOKEN_EXPIRED':
          errorMessage = 'El token de verificación ha expirado';
          break;
        case 'ALREADY_VERIFIED':
          errorMessage = 'La cuenta ya está verificada';
          break;
        case 'USER_NOT_FOUND':
          errorMessage = 'Usuario no encontrado';
          break;
        case 'VALIDATION_ERROR':
          errorMessage = response.message; // Usar el mensaje detallado de validación
          break;
      }

      return ApiResponse<Map<String, dynamic>>(
        status: response.status,
        message: errorMessage,
        code: response.code,
        errors: response.errors,
      );
    }

    return response;
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

    // Manejo de errores específicos según la documentación de la API
    if (!response.isSuccess) {
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'VALIDATION_ERROR':
          errorMessage = response.message; // Usar el mensaje detallado de validación
          break;
        case 'EMAIL_SEND_ERROR':
          errorMessage = 'Error al enviar el correo. Por favor, intenta más tarde.';
          break;
      }

      return ApiResponse<Map<String, dynamic>>(
        status: response.status,
        message: errorMessage,
        code: response.code,
        errors: response.errors,
      );
    }

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

    // Manejo de errores específicos según la documentación de la API
    if (!response.isSuccess) {
      String errorMessage = response.message;
      
      switch (response.code) {
        case 'INVALID_OR_EXPIRED_TOKEN':
          errorMessage = 'Token inválido o expirado. Por favor, solicita un nuevo enlace.';
          break;
        case 'VALIDATION_ERROR':
          errorMessage = response.message; // Usar el mensaje detallado de validación
          break;
      }

      return ApiResponse<Map<String, dynamic>>(
        status: response.status,
        message: errorMessage,
        code: response.code,
        errors: response.errors,
      );
    }

    return response;
  }

  /// Obtiene el token guardado
  static Future<String?> getToken() async {
    return await TokenManager.getToken();
  }

  /// Verifica si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    try {
      // Verificar si hay tokens válidos
      final hasTokens = await TokenManager.hasValidTokens();
      if (!hasTokens) {
        return false;
      }
      
      // Verificar si el access token es válido
      final response = await verifyToken();
      if (response.isSuccess) {
        return true;
      }
      
      // Si el access token expiró, intentar renovar con refresh token
      try {
        await refreshToken();
        return true;
      } catch (e) {
        // Si falla el refresh, el usuario no está autenticado
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Obtiene los datos del usuario guardados
  static Future<User?> getCurrentUser() async {
    try {
      final userData = await TokenManager.getUserData();
      if (userData != null) {
        final userJson = jsonDecode(userData);
        return User.fromJson(userJson);
      }
      return null;
    } catch (e) {
      // debugPrint('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  /// Cierra la sesión del usuario

  /// Limpia todos los datos de autenticación
  static Future<void> clearAll() async {
    await TokenManager.clearAll();
  }
}