import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/deep_link_service.dart';

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
          // Usuario ya autenticado, ir al home
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
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
