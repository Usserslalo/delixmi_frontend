import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'token_manager.dart';

class TokenInterceptor {
  static bool _isRefreshing = false;
  static final List<http.Request> _pendingRequests = [];

  /// Intercepta las respuestas HTTP y maneja la renovación automática de tokens
  static Future<http.Response> interceptResponse(http.Response response) async {
    // Si la respuesta es 401 (Unauthorized), intentar renovar el token
    if (response.statusCode == 401) {
      return await _handleUnauthorized(response);
    }
    
    return response;
  }

  /// Intercepta las peticiones HTTP para agregar tokens automáticamente
  static Future<http.Request> interceptRequest(http.Request request) async {
    // Solo agregar token si no es un endpoint de autenticación
    if (!request.url.path.contains('/auth/') || 
        request.url.path.contains('/auth/refresh-token')) {
      try {
        final token = await TokenManager.getAccessToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        // Si no hay token, continuar sin Authorization header
      }
    }
    
    return request;
  }

  /// Maneja respuestas 401 intentando renovar el token
  static Future<http.Response> _handleUnauthorized(http.Response response) async {
    // Si ya estamos renovando el token, esperar
    if (_isRefreshing) {
      return await _waitForTokenRefresh(response);
    }

    _isRefreshing = true;

    try {
      // Intentar renovar el token
      await AuthService.refreshToken();
      
      // Procesar todas las peticiones pendientes
      await _processPendingRequests();
      
      // Retornar la respuesta original (el cliente debe reintentar)
      return response;
    } catch (e) {
      // Si falla la renovación, limpiar tokens y redirigir a login
      await AuthService.logout();
      return response;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Espera a que termine la renovación del token
  static Future<http.Response> _waitForTokenRefresh(http.Response response) async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return response;
  }

  /// Procesa todas las peticiones pendientes
  static Future<void> _processPendingRequests() async {
    final requests = List<http.Request>.from(_pendingRequests);
    _pendingRequests.clear();
    
    for (final request in requests) {
      try {
        // Reintentar la petición con el nuevo token
        final headers = await TokenManager.getAuthHeaders();
        final newRequest = http.Request(
          request.method,
          request.url,
        );
        newRequest.headers.addAll(headers);
        newRequest.body = request.body;
        
        // Aquí podrías enviar la petición nuevamente si fuera necesario
        // Por ahora solo limpiamos la lista
      } catch (e) {
        // Manejar error si es necesario
      }
    }
  }

  /// Agrega una petición a la cola de espera
  static void addPendingRequest(http.Request request) {
    _pendingRequests.add(request);
  }

  /// Limpia la cola de peticiones pendientes
  static void clearPendingRequests() {
    _pendingRequests.clear();
  }
}
