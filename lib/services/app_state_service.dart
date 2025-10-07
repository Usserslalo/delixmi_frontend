import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'navigation_service.dart';
import 'error_handler.dart';

class AppStateService {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  bool _isInitialized = false;
  bool _isOnline = true;
  bool _isAuthenticated = false;
  String? _currentUserId;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isOnline => _isOnline;
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;

  /// Inicializar el servicio de estado de la aplicación
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Verificar conectividad
      await _checkConnectivity();
      
      // Verificar autenticación
      await _checkAuthentication();
      
      // Configurar listeners
      _setupConnectivityListener();
      
      _isInitialized = true;
      ErrorHandler.logSuccess('AppStateService', 'Servicio inicializado correctamente');
    } catch (e) {
      ErrorHandler.logError('AppStateService.initialize', e);
      rethrow;
    }
  }

  /// Verificar conectividad de red
  Future<void> _checkConnectivity() async {
    try {
      // Simular verificación de conectividad
      _isOnline = true; // Por ahora asumimos que siempre hay conexión
    } catch (e) {
      ErrorHandler.logError('AppStateService._checkConnectivity', e);
      _isOnline = false;
    }
  }

  /// Verificar estado de autenticación
  Future<void> _checkAuthentication() async {
    try {
      _isAuthenticated = await AuthService.isAuthenticated();
      if (_isAuthenticated) {
        final user = await AuthService.getCurrentUser();
        _currentUserId = user?.id.toString();
      } else {
        _currentUserId = null;
      }
    } catch (e) {
      ErrorHandler.logError('AppStateService._checkAuthentication', e);
      _isAuthenticated = false;
      _currentUserId = null;
    }
  }

  /// Configurar listener de conectividad
  void _setupConnectivityListener() {
    // Por ahora no implementamos listener de conectividad
    // Se puede agregar en el futuro con connectivity_plus
  }


  /// Actualizar estado de autenticación
  Future<void> updateAuthenticationState() async {
    await _checkAuthentication();
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await AuthService.logout();
      _isAuthenticated = false;
      _currentUserId = null;
      
      // Navegar al login
      NavigationService.goToLogin();
      
      ErrorHandler.logSuccess('AppStateService', 'Sesión cerrada correctamente');
    } catch (e) {
      ErrorHandler.logError('AppStateService.logout', e);
    }
  }

  /// Verificar si la aplicación está lista para funcionar
  bool get isReady => _isInitialized && _isOnline;

  /// Verificar si se puede realizar una operación que requiere autenticación
  bool get canPerformAuthenticatedOperation => _isAuthenticated && _isOnline;

  /// Verificar si se puede realizar una operación que requiere conexión
  bool get canPerformNetworkOperation => _isOnline;

  /// Obtener estado de la aplicación como string
  String get status {
    if (!_isInitialized) return 'Inicializando...';
    if (!_isOnline) return 'Sin conexión';
    if (!_isAuthenticated) return 'No autenticado';
    return 'Listo';
  }

  /// Verificar permisos necesarios
  Future<bool> checkRequiredPermissions() async {
    // Aquí se pueden verificar permisos como ubicación, notificaciones, etc.
    return true;
  }

  /// Limpiar estado de la aplicación
  void clearState() {
    _isAuthenticated = false;
    _currentUserId = null;
    _isOnline = true; // No limpiar estado de conectividad
  }

  /// Reinicializar el servicio
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }
}

/// Widget para mostrar el estado de la aplicación
class AppStateIndicator extends StatelessWidget {
  const AppStateIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();
    
    if (!appState.isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.orange,
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Sin conexión',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// Provider para el estado de la aplicación
class AppStateProvider extends ChangeNotifier {
  final AppStateService _appStateService = AppStateService();

  AppStateService get appState => _appStateService;

  Future<void> initialize() async {
    await _appStateService.initialize();
    notifyListeners();
  }

  Future<void> updateAuthenticationState() async {
    await _appStateService.updateAuthenticationState();
    notifyListeners();
  }

  Future<void> logout() async {
    await _appStateService.logout();
    notifyListeners();
  }
}
