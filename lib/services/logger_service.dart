import 'package:flutter/foundation.dart';

/// Servicio de logging centralizado para la aplicación
class LoggerService {
  static const String _tag = 'DELIXMI';
  
  /// Log de información (solo en debug)
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('📱 ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de error (solo en debug)
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ ${tag ?? _tag}: $message');
      if (error != null) {
        debugPrint('❌ ${tag ?? _tag}: Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('❌ ${tag ?? _tag}: StackTrace: $stackTrace');
      }
    }
  }
  
  /// Log de éxito (solo en debug)
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('✅ ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de advertencia (solo en debug)
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('⚠️ ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de debug (solo en debug)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('🔍 ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de API (solo en debug)
  static void api(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('🌐 ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de carrito (solo en debug)
  static void cart(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('🛒 ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de autenticación (solo en debug)
  static void auth(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('🔐 ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de ubicación (solo en debug)
  static void location(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('📍 ${tag ?? _tag}: $message');
    }
  }
  
  /// Log de pago (solo en debug)
  static void payment(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('💳 ${tag ?? _tag}: $message');
    }
  }
}
