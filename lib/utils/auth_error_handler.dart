import 'package:flutter/material.dart';

class AuthErrorHandler {
  /// Maneja errores específicos de autenticación y muestra mensajes apropiados
  static String handleAuthError(String? errorCode, String? message) {
    switch (errorCode) {
      case 'VALIDATION_ERROR':
        return message ?? 'Datos de entrada inválidos';
      
      case 'INVALID_CREDENTIALS':
        return 'Credenciales incorrectas. Verifica tu email y contraseña';
      
      case 'ACCOUNT_NOT_VERIFIED':
        return 'Cuenta no verificada. Por favor, verifica tu correo electrónico';
      
      case 'USER_NOT_FOUND':
        return 'Usuario no encontrado';
      
      case 'USER_EXISTS':
        return 'El correo electrónico ya está registrado';
      
      case 'RATE_LIMIT_EXCEEDED':
        return 'Demasiados intentos. Intenta más tarde';
      
      case 'EMAIL_SEND_ERROR':
        return 'Error al enviar el correo. Intenta nuevamente';
      
      case 'INVALID_TOKEN':
        return 'Token inválido o expirado';
      
      case 'TOKEN_EXPIRED':
        return 'Sesión expirada. Inicia sesión nuevamente';
      
      case 'PHONE_EXISTS':
        return 'Este número de teléfono ya está registrado';
      
      case 'INTERNAL_ERROR':
        return 'Error interno del servidor. Intenta más tarde';
      
      default:
        return message ?? 'Error desconocido. Intenta nuevamente';
    }
  }

  /// Muestra un SnackBar con el error de autenticación
  static void showAuthErrorSnackBar(BuildContext context, String? errorCode, String? message) {
    final errorMessage = handleAuthError(errorCode, message);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Muestra un diálogo de error de autenticación
  static void showAuthErrorDialog(BuildContext context, String? errorCode, String? message) {
    final errorMessage = handleAuthError(errorCode, message);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de Autenticación'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  /// Verifica si el error requiere verificación de email
  static bool requiresEmailVerification(String? errorCode) {
    return errorCode == 'ACCOUNT_NOT_VERIFIED';
  }

  /// Verifica si el error es de rate limiting
  static bool isRateLimitError(String? errorCode) {
    return errorCode == 'RATE_LIMIT_EXCEEDED';
  }

  /// Verifica si el error requiere re-login
  static bool requiresReLogin(String? errorCode) {
    return errorCode == 'INVALID_TOKEN' || 
           errorCode == 'TOKEN_EXPIRED' ||
           errorCode == 'INVALID_CREDENTIALS';
  }
}
