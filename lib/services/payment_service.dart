import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'token_manager.dart';
import 'logger_service.dart';

class PaymentService {
  /// Abrir Mercado Pago usando url_launcher
  static Future<bool> openMercadoPago({
    required String initPoint,
    required BuildContext context,
  }) async {
    try {
      LoggerService.location('Abriendo Mercado Pago: $initPoint', tag: 'PaymentService');
      
      final uri = Uri.parse(initPoint);
      
      // Intentar diferentes modos de lanzamiento
      bool launched = false;
      
      // Intentar con modo externo primero
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          LoggerService.location('Mercado Pago abierto con modo externo', tag: 'PaymentService');
    } catch (e) {
          LoggerService.error('Error con modo externo: $e', tag: 'PaymentService');
        }
      }
      
      // Si falló, intentar con modo plataforma
      if (!launched) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          launched = true;
          LoggerService.location('Mercado Pago abierto con modo plataforma', tag: 'PaymentService');
        } catch (e) {
          LoggerService.error('Error con modo plataforma: $e', tag: 'PaymentService');
        }
      }
      
      // Si aún falló, intentar con modo inAppWebView
      if (!launched) {
        try {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          launched = true;
          LoggerService.location('Mercado Pago abierto con WebView', tag: 'PaymentService');
        } catch (e) {
          LoggerService.error('Error con WebView: $e', tag: 'PaymentService');
        }
      }
      
      if (launched) {
        LoggerService.location('Mercado Pago abierto exitosamente', tag: 'PaymentService');
        return true;
      } else {
        LoggerService.error('No se pudo abrir la URL con ningún modo: $initPoint', tag: 'PaymentService');
        return false;
      }
    } catch (e) {
      LoggerService.error('Error al abrir Mercado Pago: $e', tag: 'PaymentService');
      return false;
    }
  }

  
  /// Verificar estado del pago
  static Future<ApiResponse<Map<String, dynamic>>> checkPaymentStatus({
    required String paymentId,
  }) async {
    try {
      LoggerService.location('Verificando estado del pago: $paymentId', tag: 'PaymentService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/checkout/payment-status/$paymentId',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Estado del pago: ${response.status}', tag: 'PaymentService');
      return response;
    } catch (e) {
      LoggerService.error('Error al verificar estado del pago: $e', tag: 'PaymentService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al verificar estado del pago: $e',
        data: null,
      );
    }
  }
  
  /// Procesar resultado del deep link
  static PaymentResult processDeepLink(String link) {
    LoggerService.location('Procesando deep link: $link', tag: 'PaymentService');
    
    if (link.contains('delixmi://payment/success')) {
      return PaymentResult.success;
    } else if (link.contains('delixmi://payment/failure')) {
      return PaymentResult.failure;
    } else if (link.contains('delixmi://payment/pending')) {
      return PaymentResult.pending;
    } else {
      LoggerService.error('Deep link no reconocido: $link', tag: 'PaymentService');
      return PaymentResult.unknown;
    }
  }

  /// Extraer order ID del deep link (usar external_reference completo)
  static String? extractOrderId(String link) {
    try {
      final uri = Uri.parse(link);
      // Usar external_reference completo (formato: delixmi_uuid)
      final externalRef = uri.queryParameters['external_reference'];
      if (externalRef != null && externalRef.startsWith('delixmi_')) {
        // Usar el external_reference completo como está
        return externalRef;
      }
      // Fallback al payment_id si no hay external_reference
      return uri.queryParameters['payment_id'];
    } catch (e) {
      LoggerService.error('Error al extraer order ID: $e', tag: 'PaymentService');
      return null;
    }
  }

  /// Extraer payment ID del deep link (para referencia)
  static String? extractPaymentId(String link) {
    try {
      final uri = Uri.parse(link);
      return uri.queryParameters['payment_id'];
    } catch (e) {
      LoggerService.error('Error al extraer payment ID: $e', tag: 'PaymentService');
      return null;
    }
  }
}

/// Resultado del pago
enum PaymentResult {
  success,
  failure,
  pending,
  unknown,
}

/// Extensión para obtener mensajes del resultado
extension PaymentResultExtension on PaymentResult {
  String get message {
    switch (this) {
      case PaymentResult.success:
        return 'Pago realizado exitosamente';
      case PaymentResult.failure:
        return 'El pago fue rechazado';
      case PaymentResult.pending:
        return 'El pago está pendiente de confirmación';
      case PaymentResult.unknown:
        return 'Estado del pago desconocido';
    }
  }

  bool get isSuccess => this == PaymentResult.success;
  bool get isFailure => this == PaymentResult.failure;
  bool get isPending => this == PaymentResult.pending;
}