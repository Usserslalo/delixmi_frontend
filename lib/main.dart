import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'config/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/unsupported_role_screen.dart';
import 'screens/common/placeholder_screen.dart';
import 'screens/owner/modern_owner_dashboard_screen.dart';
import 'screens/owner/modern_edit_profile_screen.dart' as owner_screens;
import 'screens/owner/menu_management_screen.dart';
import 'screens/owner/modifier_groups_management_screen.dart';
import 'screens/owner/categories_list_screen.dart';
import 'screens/owner/subcategories_list_screen.dart';
import 'screens/owner/products_list_screen.dart';
import 'screens/owner/set_restaurant_location_screen.dart';
import 'screens/owner/branch_list_screen_for_schedules.dart';
import 'screens/owner/weekly_schedule_screen.dart';
import 'screens/owner/edit_single_day_schedule_screen.dart';
import 'screens/owner/edit_weekly_schedule_screen.dart';
import 'screens/owner/employee_list_screen.dart';
import 'screens/owner/add_edit_employee_screen.dart';
import 'screens/driver/driver_dashboard_screen.dart';
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
import 'models/auth/user.dart';
import 'models/restaurant_cart.dart';
import 'services/geocoding_service.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_cart_provider.dart';
import 'providers/address_provider.dart';
import 'providers/checkout_provider.dart';
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
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    // Manejar deep links cuando la app está abierta
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
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
    
    // Verificar si es un deep link de reset password
    if (link.contains('reset-password')) {
      debugPrint('🔑 Deep link de reset password detectado');
      _handleResetPasswordDeepLink(link);
      return;
    }
    
    // Si no es reset password, procesar como deep link de pago
    final result = PaymentService.processDeepLink(link);
    debugPrint('🔗 Resultado del pago: $result');
    
    // Extraer order ID del deep link (usar external_reference)
    final orderId = PaymentService.extractOrderId(link);
    debugPrint('🔗 Order ID extraído: $orderId');
    
    // Intentar manejar el deep link con retry
    _handleDeepLinkWithRetry(link, result, orderId, 0);
  }

  void _handleResetPasswordDeepLink(String link) {
    try {
      // Extraer el token del query parameter
      final uri = Uri.parse(link);
      final token = uri.queryParameters['token'];
      
      if (token == null || token.isEmpty) {
        debugPrint('❌ Token de reset password no encontrado en el deep link');
        _showResetPasswordError('Enlace de restablecimiento no válido');
        return;
      }
      
      // Validar formato del token (64 caracteres hexadecimales)
      if (!RegExp(r'^[a-f0-9]{64}$', caseSensitive: false).hasMatch(token)) {
        debugPrint('❌ Token de reset password con formato inválido: $token');
        _showResetPasswordError('Enlace de restablecimiento no válido');
        return;
      }
      
      debugPrint('✅ Token de reset password válido: ${token.substring(0, 10)}... (${token.length} caracteres)');
      
      // Navegar a la pantalla de reset password con retry
      _navigateToResetPasswordWithRetry(token, 0);
      
    } catch (e) {
      debugPrint('❌ Error al procesar deep link de reset password: $e');
      _showResetPasswordError('Error al procesar el enlace');
    }
  }

  void _navigateToResetPasswordWithRetry(String token, int retryCount) {
    final navigator = NavigationService.navigatorKey.currentState;
    
    if (navigator == null) {
      if (retryCount < 5) {
        debugPrint('❌ Navigator no disponible para reset password, reintentando en 500ms... (intento ${retryCount + 1}/5)');
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToResetPasswordWithRetry(token, retryCount + 1);
        });
        return;
      } else {
        debugPrint('❌ Navigator no disponible después de 5 intentos. No se puede navegar a reset password.');
        _showResetPasswordError('Error al abrir la pantalla de restablecimiento');
        return;
      }
    }

    debugPrint('✅ Navigator disponible, navegando a ResetPasswordScreen...');
    
    // Navegar a la pantalla de reset password
    navigator.pushNamed(
      AppRoutes.resetPassword,
      arguments: token,
    );
  }

  void _showResetPasswordError(String message) {
    final navigator = NavigationService.navigatorKey.currentState;
    final context = navigator?.context;
    
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
      if (route.settings.name == AppRoutes.payment || route.settings.name == AppRoutes.checkout) {
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
          AppRoutes.orderDetails,
          (route) => false, // Limpiar todo el stack
          arguments: orderId,
        );
      } else {
        debugPrint('⚠️ Deep link de pago exitoso sin orderId. Navegando a lista de pedidos.');
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.orders,
          (route) => false, // Limpiar todo el stack
        );
      }
    } else if (result.isFailure) {
      _showPaymentNotification('El pago fue rechazado', Colors.red);
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false, // Limpiar todo el stack y ir al home
      );
    } else if (result.isPending) {
      _showPaymentNotification('El pago está pendiente de confirmación', Colors.orange);
      if (orderId != null) {
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.orderDetails,
          (route) => false, // Limpiar todo el stack
          arguments: orderId,
        );
      } else {
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.home,
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
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
      ],
      child: MaterialApp(
        title: 'Delixmi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: NavigationService.navigatorKey,
        home: const SplashScreen(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.emailVerification: (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.resetPassword: (context) {
          final token = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return ResetPasswordScreen(token: token);
        },
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.restaurantDetail: (context) {
          final restaurantId = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
          return RestaurantDetailScreen(restaurantId: restaurantId);
        },
        AppRoutes.productDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          final product = args['product'] as Product;
          final restaurantId = args['restaurantId'] as int;
          return ProductDetailScreen(
            product: product,
            restaurantId: restaurantId,
          );
        },
        AppRoutes.cart: (context) => const CartScreen(),
        AppRoutes.cartDetail: (context) {
          final restaurant = ModalRoute.of(context)?.settings.arguments as dynamic;
          return CartDetailScreen(restaurant: restaurant);
        },
        AppRoutes.addresses: (context) {
          final isSelectionMode = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
          return AddressesScreen(isSelectionMode: isSelectionMode);
        },
        AppRoutes.addressForm: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Address) {
            // Modo edición: recibe una dirección existente
            return AddressFormScreen(address: args);
          } else if (args is ReverseGeocodeResult) {
            // Modo creación: recibe datos pre-llenados del mapa
            return AddressFormScreen(prefilledData: args);
          } else {
            // Sin argumentos: modo creación sin datos
            return const AddressFormScreen();
          }
        },
        AppRoutes.checkout: (context) {
          final restaurant = ModalRoute.of(context)?.settings.arguments as dynamic;
          return CheckoutScreen(restaurant: restaurant);
        },
        AppRoutes.payment: (context) {
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
        AppRoutes.orders: (context) => const OrdersScreen(),
        AppRoutes.orderDetails: (context) {
          final orderId = ModalRoute.of(context)?.settings.arguments as String;
          return OrderDetailsScreen(orderId: orderId);
        },
        AppRoutes.orderHistory: (context) => const OrderHistoryScreen(),
        AppRoutes.editProfile: (context) {
          final user = ModalRoute.of(context)?.settings.arguments as User?;
          return EditProfileScreen(user: user!);
        },
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.helpSupport: (context) => const HelpSupportScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.testCartBadge: (context) => const CartBadgeTestScreen(),
        
        // ===== RUTAS DE AUTENTICACIÓN =====
        AppRoutes.unsupportedRole: (context) => const UnsupportedRoleScreen(),
        
        // ===== RUTAS DE CLIENTE =====
        AppRoutes.customerHome: (context) => const HomeScreen(),
        
        // ===== RUTAS DE OWNER =====
        AppRoutes.ownerDashboard: (context) => const ModernOwnerDashboardScreen(),
        AppRoutes.ownerProfileEdit: (context) => const owner_screens.ModernEditProfileScreen(),
        AppRoutes.ownerMenu: (context) => const MenuManagementScreen(),
        AppRoutes.ownerModifierGroups: (context) => const ModifierGroupsManagementScreen(),
        AppRoutes.ownerCategories: (context) => const CategoriesListScreen(),
        AppRoutes.ownerSubcategories: (context) => const SubcategoriesListScreen(),
        AppRoutes.ownerProducts: (context) => const ProductsListScreen(),
        AppRoutes.setRestaurantLocation: (context) => const SetRestaurantLocationScreen(),
        AppRoutes.ownerBranchesListForSchedules: (context) => const BranchListScreenForSchedules(),
        AppRoutes.ownerWeeklySchedule: (context) => const WeeklyScheduleScreen(),
        AppRoutes.ownerEditSingleDaySchedule: (context) => const EditSingleDayScheduleScreen(),
        AppRoutes.ownerEditWeeklySchedule: (context) => const EditWeeklyScheduleScreen(),
        AppRoutes.ownerEmployeeList: (context) => const EmployeeListScreen(),
        AppRoutes.ownerAddEditEmployee: (context) => const AddEditEmployeeScreen(),
        
        // ===== RUTAS DE REPARTIDOR =====
        AppRoutes.driverDashboard: (context) => const DriverDashboardScreen(),
        
        // ===== RUTAS DE ADMIN (Placeholder) =====
        AppRoutes.adminDashboard: (context) => const PlaceholderScreen(
          title: 'Panel de Administrador',
        ),
        
        // ===== OTROS ROLES (Placeholders) =====
        AppRoutes.platformDashboard: (context) => const PlaceholderScreen(
          title: 'Gestor de Plataforma',
        ),
        AppRoutes.supportDashboard: (context) => const PlaceholderScreen(
          title: 'Agente de Soporte',
        ),
        AppRoutes.branchDashboard: (context) => const PlaceholderScreen(
          title: 'Gestor de Sucursal',
        ),
        AppRoutes.ordersDashboard: (context) => const PlaceholderScreen(
          title: 'Gestor de Pedidos',
        ),
        AppRoutes.kitchenDashboard: (context) => const PlaceholderScreen(
          title: 'Personal de Cocina',
        ),
        AppRoutes.locationPicker: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is ReverseGeocodeResult) {
            // Recibe datos pre-llenados
            return LocationPickerScreen(
              initialLatitude: args.latitude,
              initialLongitude: args.longitude,
              prefilledData: args,
            );
          } else if (args is Map<String, dynamic>) {
            // Formato antiguo por compatibilidad
            return LocationPickerScreen(
              initialLatitude: args['latitude'] as double?,
              initialLongitude: args['longitude'] as double?,
            );
          } else {
            // Sin argumentos: ubicación por defecto
            return const LocationPickerScreen();
          }
        },
      },
      onGenerateRoute: (settings) {
        // Manejar deep links para reset password
        if (settings.name == AppRoutes.resetPassword) {
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
