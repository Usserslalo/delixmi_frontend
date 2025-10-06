import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'logger_service.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isInitialized = false;

  /// Inicializa el servicio de deep links
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    if (!_isInitialized) {
      _initDeepLinks();
      _isInitialized = true;
    }
  }

  static void _initDeepLinks() {
    // Manejar deep links cuando la app está cerrada
    _appLinks.getInitialLink().then((link) {
      if (link != null) {
        LoggerService.info('Deep link inicial detectado: ${link.toString()}', tag: 'DeepLink');
        _handleDeepLink(link);
      }
    });

    // Manejar deep links cuando la app está en background
    _appLinks.uriLinkStream.listen((link) {
      LoggerService.info('Deep link recibido: ${link.toString()}', tag: 'DeepLink');
      _handleDeepLink(link);
    });
  }

  static void _handleDeepLink(Uri link) {
    if (_navigatorKey?.currentState == null) {
      LoggerService.error('Navigator no disponible para manejar deep link', tag: 'DeepLink');
      return;
    }

    LoggerService.debug('Procesando deep link: scheme=${link.scheme}, host=${link.host}, query=${link.queryParameters}', tag: 'DeepLink');

    // Manejar enlaces de reset password
    if (link.scheme == 'delixmi' && link.host == 'reset-password') {
      final token = link.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        LoggerService.success('Token de reset password encontrado: ${token.substring(0, 10)}...', tag: 'DeepLink');
        _navigateToResetPassword(token);
      } else {
        LoggerService.warning('Token de reset password no encontrado o vacío', tag: 'DeepLink');
      }
    }
    
    // Manejar enlaces de verificación de email
    else if (link.scheme == 'delixmi' && link.host == 'verify-email') {
      final email = link.queryParameters['email'];
      if (email != null && email.isNotEmpty) {
        LoggerService.success('Email de verificación encontrado: $email', tag: 'DeepLink');
        _navigateToEmailVerification(email);
      } else {
        LoggerService.warning('Email de verificación no encontrado o vacío', tag: 'DeepLink');
      }
    }
    
    // Manejar enlaces genéricos de la app
    else if (link.scheme == 'delixmi') {
      switch (link.host) {
        case 'login':
          LoggerService.info('Navegando a login', tag: 'DeepLink');
          _navigateToLogin();
          break;
        case 'register':
          LoggerService.info('Navegando a register', tag: 'DeepLink');
          _navigateToRegister();
          break;
        case 'home':
          LoggerService.info('Navegando a home', tag: 'DeepLink');
          _navigateToHome();
          break;
        default:
          LoggerService.warning('Host no reconocido: ${link.host}', tag: 'DeepLink');
      }
    } else {
      LoggerService.warning('Esquema no reconocido: ${link.scheme}', tag: 'DeepLink');
    }
  }

  static void _navigateToResetPassword(String token) {
    if (_navigatorKey?.currentState == null) {
      LoggerService.error('No se puede navegar a reset password: navigator no disponible', tag: 'DeepLink');
      return;
    }
    
    LoggerService.info('Navegando a ResetPasswordScreen con token', tag: 'DeepLink');
    
    try {
      _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
        '/reset-password',
        (route) => false,
        arguments: token,
      );
    } catch (e) {
      LoggerService.error('Error al navegar a reset password: $e', tag: 'DeepLink');
      // Fallback: navegar a login si hay error
      try {
        _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } catch (fallbackError) {
        LoggerService.error('Error en fallback de navegación: $fallbackError', tag: 'DeepLink');
      }
    }
  }

  static void _navigateToEmailVerification(String email) {
    if (_navigatorKey?.currentState == null) {
      LoggerService.error('No se puede navegar a email verification: navigator no disponible', tag: 'DeepLink');
      return;
    }
    
    LoggerService.info('Navegando a EmailVerificationScreen con email: $email', tag: 'DeepLink');
    
    try {
      _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
        '/email-verification',
        (route) => false,
        arguments: email,
      );
    } catch (e) {
      LoggerService.error('Error al navegar a email verification: $e', tag: 'DeepLink');
      // Fallback: navegar a login si hay error
      try {
        _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } catch (fallbackError) {
        LoggerService.error('Error en fallback de navegación: $fallbackError', tag: 'DeepLink');
      }
    }
  }

  static void _navigateToLogin() {
    if (_navigatorKey?.currentState == null) return;
    
    LoggerService.info('Navegando a LoginScreen', tag: 'DeepLink');
    _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  static void _navigateToRegister() {
    if (_navigatorKey?.currentState == null) return;
    
    LoggerService.info('Navegando a RegisterScreen', tag: 'DeepLink');
    _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
      '/register',
      (route) => false,
    );
  }

  static void _navigateToHome() {
    if (_navigatorKey?.currentState == null) return;
    
    LoggerService.info('Navegando a HomeScreen', tag: 'DeepLink');
    _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  /// Genera un enlace de reset password para testing
  static String generateResetPasswordLink(String token) {
    return 'delixmi://reset-password?token=$token';
  }

  /// Genera un enlace de verificación de email para testing
  static String generateEmailVerificationLink(String email) {
    return 'delixmi://verify-email?email=$email';
  }
}
