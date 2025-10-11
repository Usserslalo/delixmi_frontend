import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/deep_link_service.dart';
import '../../models/user.dart';

// GlobalKey para el NavigatorState
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Inicializar deep links PRIMERO
    DeepLinkService.initialize(navigatorKey);
    
    // Simular tiempo de carga mínimo
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final isAuthenticated = await AuthService.isAuthenticated();
      
      if (mounted) {
        // Verificar si hay un deep link pendiente antes de navegar
        await _checkForPendingDeepLink();
        
        if (isAuthenticated) {
          // Usuario ya autenticado, redirigir según su rol
          await _redirectByUserRole();
        } else {
          // No hay token, ir a login
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        // En caso de error, ir a login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _checkForPendingDeepLink() async {
    // Dar tiempo para que el DeepLinkService procese cualquier enlace inicial
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Redirige al usuario según su rol (misma lógica que LoginScreen)
  Future<void> _redirectByUserRole() async {
    try {
      // Obtener datos del usuario desde el token almacenado
      final user = await AuthService.getCurrentUser();
      
      if (user != null && user.roles.isNotEmpty) {
        final primaryRole = user.roles.first.roleName;
        
        // Logging para debugging
        print('🔑 SplashScreen: Redirigiendo usuario con rol: $primaryRole');
        
        if (mounted) {
          _redirectByRole(primaryRole, user);
        }
      } else {
        // Si no se puede obtener el usuario, ir a login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      print('❌ SplashScreen: Error al obtener datos del usuario: $e');
      // En caso de error, ir a login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  /// Redirige al usuario a la pantalla correcta según su rol
  void _redirectByRole(String roleName, User user) {
    switch (roleName) {
      // ===== ROLES DE PLATAFORMA =====
      case 'super_admin':
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
        break;
        
      case 'platform_manager':
        Navigator.pushReplacementNamed(context, '/platform_dashboard');
        break;
        
      case 'support_agent':
        Navigator.pushReplacementNamed(context, '/support_dashboard');
        break;
      
      // ===== ROLES DE RESTAURANTE =====
      case 'owner':
        Navigator.pushReplacementNamed(
          context,
          '/owner_dashboard',
          arguments: {
            'restaurantId': user.roles.first.restaurantId,
          },
        );
        break;
        
      case 'branch_manager':
        Navigator.pushReplacementNamed(
          context,
          '/branch_manager_dashboard',
          arguments: {
            'restaurantId': user.roles.first.restaurantId,
          },
        );
        break;
      
      // ===== ROLES DE REPARTIDOR =====
      case 'driver':
        Navigator.pushReplacementNamed(
          context,
          '/driver_dashboard',
          arguments: {
            'driverId': user.id,
          },
        );
        break;
      
      // ===== ROLES DE CLIENTE =====
      case 'customer':
        Navigator.pushReplacementNamed(context, '/customer_home');
        break;
      
      // ===== ROL NO SOPORTADO =====
      default:
        print('⚠️ SplashScreen: Rol no soportado: $roleName');
        Navigator.pushReplacementNamed(
          context,
          '/unsupported_role',
          arguments: {'role': roleName},
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.delivery_dining,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Delixmi',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu app de delivery favorita',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
