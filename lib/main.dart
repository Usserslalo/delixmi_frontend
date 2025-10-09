import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/restaurant_detail_screen.dart';
import 'screens/customer/product_detail_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/cart_detail_screen.dart';
import 'screens/customer/addresses_screen.dart';
import 'screens/customer/address_form_screen.dart';
import 'screens/customer/location_picker_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/customer/payment_screen.dart';
import 'screens/customer/orders_screen.dart';
import 'screens/customer/order_details_screen.dart';
import 'screens/customer/order_history_screen.dart';
import 'screens/customer/edit_profile_screen.dart';
import 'screens/customer/change_password_screen.dart';
import 'screens/customer/help_support_screen.dart';
import 'screens/customer/profile_screen.dart';
import 'screens/test/cart_badge_test_screen.dart';
import 'screens/shared/splash_screen.dart';
import 'models/address.dart';
import 'models/product.dart';
import 'models/user.dart';
import 'models/restaurant_cart.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_cart_provider.dart';
import 'providers/address_provider.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'theme.dart';
import 'services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await NotificationService.initialize();
  
  runApp(const DelixmiApp());
}

class DelixmiApp extends StatefulWidget {
  const DelixmiApp({super.key});

  @override
  State<DelixmiApp> createState() => _DelixmiAppState();
}

class _DelixmiAppState extends State<DelixmiApp> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Manejar deep links cuando la app está abierta
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri.toString());
    });

    // Manejar deep links cuando la app se abre desde un deep link
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri.toString());
      }
    });
  }

  void _handleDeepLink(String link) {
    debugPrint('🔗 Deep link recibido: $link');
    
    final result = PaymentService.processDeepLink(link);
    debugPrint('🔗 Resultado del pago: $result');
    
    // Extraer order ID del deep link (usar external_reference)
    final orderId = PaymentService.extractOrderId(link);
    debugPrint('🔗 Order ID extraído: $orderId');
    
    // Intentar manejar el deep link con retry
    _handleDeepLinkWithRetry(link, result, orderId, 0);
  }

  void _handleDeepLinkWithRetry(String link, PaymentResult result, String? orderId, int retryCount) {
    final navigator = NavigationService.navigatorKey.currentState;
    
    if (navigator == null) {
      if (retryCount < 5) {
        debugPrint('❌ Navigator no disponible, reintentando en 500ms... (intento ${retryCount + 1}/5)');
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLinkWithRetry(link, result, orderId, retryCount + 1);
        });
        return;
      } else {
        debugPrint('❌ Navigator no disponible después de 5 intentos. Ignorando deep link.');
        return;
      }
    }

    debugPrint('✅ Navigator disponible, procesando deep link...');

    // Cerrar la PaymentScreen si está abierta
    navigator.popUntil((route) {
      // Si la ruta es la PaymentScreen, la cerramos
      if (route.settings.name == '/payment' || route.settings.name == '/checkout') {
        return true; // Pop hasta esta ruta
      }
      return route.isFirst; // O hasta la primera ruta
    });

    // Mostrar notificación del resultado y navegar
    if (result.isSuccess) {
      _showPaymentNotification('¡Pago realizado exitosamente!', Colors.green);
      if (orderId != null) {
        // Navegar a la pantalla de detalles del pedido y limpiar todo el stack
        navigator.pushNamedAndRemoveUntil(
          '/order-details',
          (route) => false, // Limpiar todo el stack
          arguments: orderId,
        );
      } else {
        debugPrint('⚠️ Deep link de pago exitoso sin orderId. Navegando a lista de pedidos.');
        navigator.pushNamedAndRemoveUntil(
          '/orders',
          (route) => false, // Limpiar todo el stack
        );
      }
    } else if (result.isFailure) {
      _showPaymentNotification('El pago fue rechazado', Colors.red);
      navigator.pushNamedAndRemoveUntil(
        '/home',
        (route) => false, // Limpiar todo el stack y ir al home
      );
    } else if (result.isPending) {
      _showPaymentNotification('El pago está pendiente de confirmación', Colors.orange);
      if (orderId != null) {
        navigator.pushNamedAndRemoveUntil(
          '/order-details',
          (route) => false, // Limpiar todo el stack
          arguments: orderId,
        );
      } else {
        navigator.pushNamedAndRemoveUntil(
          '/home',
          (route) => false, // Limpiar todo el stack y ir al home
        );
      }
    }
  }

  void _showPaymentNotification(String message, Color color) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantCartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: MaterialApp(
        title: 'Delixmi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: NavigationService.navigatorKey,
        home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/email-verification': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) {
          final token = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return ResetPasswordScreen(token: token);
        },
        '/home': (context) => const HomeScreen(),
        '/restaurant-detail': (context) {
          final restaurantId = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
          return RestaurantDetailScreen(restaurantId: restaurantId);
        },
        '/product-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          final product = args['product'] as Product;
          final restaurantId = args['restaurantId'] as int;
          return ProductDetailScreen(
            product: product,
            restaurantId: restaurantId,
          );
        },
        '/cart': (context) => const CartScreen(),
        '/cart-detail': (context) {
          final restaurant = ModalRoute.of(context)?.settings.arguments as dynamic;
          return CartDetailScreen(restaurant: restaurant);
        },
        '/addresses': (context) {
          final isSelectionMode = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
          return AddressesScreen(isSelectionMode: isSelectionMode);
        },
        '/address-form': (context) {
          final address = ModalRoute.of(context)?.settings.arguments as Address?;
          return AddressFormScreen(address: address);
        },
        '/checkout': (context) {
          final restaurant = ModalRoute.of(context)?.settings.arguments as dynamic;
          return CheckoutScreen(restaurant: restaurant);
        },
        '/payment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final restaurant = args?['restaurant'] as RestaurantCart?;
          final specialInstructions = args?['specialInstructions'] as String?;
          if (restaurant == null) {
            return const Text('Error: Restaurant not provided for payment');
          }
          return PaymentScreen(
            restaurant: restaurant,
            specialInstructions: specialInstructions,
          );
        },
        '/orders': (context) => const OrdersScreen(),
        '/order-details': (context) {
          final orderId = ModalRoute.of(context)?.settings.arguments as String;
          return OrderDetailsScreen(orderId: orderId);
        },
        '/order-history': (context) => const OrderHistoryScreen(),
        '/edit-profile': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as User?;
          return EditProfileScreen(user: user!);
        },
        '/change-password': (context) => const ChangePasswordScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/test-cart-badge': (context) => const CartBadgeTestScreen(),
        '/location-picker': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return LocationPickerScreen(
            initialLatitude: args?['latitude'],
            initialLongitude: args?['longitude'],
            initialAddress: args?['address'],
          );
        },
      },
      onGenerateRoute: (settings) {
        // Manejar deep links para reset password
        if (settings.name == '/reset-password') {
          final token = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(token: token),
          );
        }
        return null;
      },
      ),
    );
  }
}
