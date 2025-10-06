import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';

class ErrorHandler {
  /// Maneja errores de API de forma centralizada
  static void handleApiError(
    BuildContext context,
    ApiResponse response, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String message = customMessage ?? response.message;
    
    // Log del error para debugging
    if (kDebugMode) {
      print('❌ API Error: ${response.status} - $message');
      if (response.errors != null) {
        print('❌ Validation Errors: ${response.errors}');
      }
    }

    // Mostrar SnackBar con el error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getErrorColor(response.status),
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Maneja errores de excepción
  static void handleException(
    BuildContext context,
    dynamic exception, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String message = customMessage ?? 'Ha ocurrido un error inesperado';
    
    // Log del error para debugging
    if (kDebugMode) {
      print('❌ Exception: $exception');
    }

    // Mostrar SnackBar con el error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Muestra un diálogo de error con opciones
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de confirmación para acciones destructivas
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText ?? 'Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Valida campos de formulario
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  /// Valida teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Ingresa un teléfono válido';
    }
    
    return null;
  }

  /// Valida contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  /// Valida confirmación de contraseña
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  /// Obtiene el color apropiado para el tipo de error
  static Color _getErrorColor(String status) {
    switch (status.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  /// Formatea mensajes de error de validación
  static String formatValidationErrors(Map<String, List<String>> errors) {
    final errorMessages = <String>[];
    
    errors.forEach((field, messages) {
      for (final message in messages) {
        errorMessages.add('$field: $message');
      }
    });
    
    return errorMessages.join('\n');
  }

  /// Maneja errores de red
  static void handleNetworkError(BuildContext context, {VoidCallback? onRetry}) {
    handleException(
      context,
      'Error de conexión',
      customMessage: 'Verifica tu conexión a internet e intenta nuevamente',
      onRetry: onRetry,
    );
  }

  /// Maneja errores de autenticación
  static void handleAuthError(BuildContext context) {
    showErrorDialog(
      context,
      title: 'Sesión Expirada',
      message: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
      buttonText: 'Iniciar Sesión',
      onPressed: () {
        Navigator.of(context).pop(); // Cerrar diálogo
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  }

  /// Maneja errores de permisos
  static void handlePermissionError(
    BuildContext context, {
    required String permission,
    VoidCallback? onRetry,
  }) {
    showErrorDialog(
      context,
      title: 'Permiso Requerido',
      message: 'Necesitas permitir el acceso a $permission para continuar.',
      buttonText: 'Configurar',
      onPressed: onRetry,
    );
  }

  /// Log de errores para debugging
  static void logError(String context, dynamic error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ Error in $context: $error');
      if (stackTrace != null) {
        print('❌ Stack trace: $stackTrace');
      }
    }
  }

  /// Log de información para debugging
  static void logInfo(String context, String message) {
    if (kDebugMode) {
      print('ℹ️ Info in $context: $message');
    }
  }

  /// Log de éxito para debugging
  static void logSuccess(String context, String message) {
    if (kDebugMode) {
      print('✅ Success in $context: $message');
    }
  }
}
