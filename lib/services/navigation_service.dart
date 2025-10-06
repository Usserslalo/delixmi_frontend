import 'package:flutter/material.dart';
import '../models/address.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navegar a una ruta
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navegar a una ruta y reemplazar la actual
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navegar a una ruta y limpiar el stack
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Volver a la pantalla anterior
  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  /// Volver a la pantalla anterior si es posible
  static Future<bool> maybePop<T extends Object?>([T? result]) async {
    return await navigatorKey.currentState!.maybePop<T>(result);
  }

  /// Obtener el contexto actual
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Verificar si se puede volver
  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  /// Navegar a la pantalla de inicio
  static Future<void> goToHome() {
    return pushNamedAndRemoveUntil('/home');
  }

  /// Navegar al login
  static Future<void> goToLogin() {
    return pushNamedAndRemoveUntil('/login');
  }

  /// Navegar al registro
  static Future<void> goToRegister() {
    return pushNamed('/register');
  }

  /// Navegar a la verificación de email
  static Future<void> goToEmailVerification(String email) {
    return pushNamed('/email-verification', arguments: email);
  }

  /// Navegar al reset de contraseña
  static Future<void> goToResetPassword(String token) {
    return pushNamed('/reset-password', arguments: token);
  }

  /// Navegar a los detalles del restaurante
  static Future<void> goToRestaurantDetail(int restaurantId) {
    return pushNamed('/restaurant-detail', arguments: restaurantId);
  }

  /// Navegar al carrito
  static Future<void> goToCart() {
    return pushNamed('/cart');
  }

  /// Navegar a las direcciones
  static Future<void> goToAddresses({bool isSelectionMode = false}) {
    return pushNamed('/addresses', arguments: isSelectionMode);
  }

  /// Navegar al formulario de dirección
  static Future<void> goToAddressForm({Address? address}) {
    return pushNamed('/address-form', arguments: address);
  }

  /// Navegar al checkout
  static Future<void> goToCheckout({int? restaurantId}) {
    return pushNamed('/checkout', arguments: restaurantId);
  }

  /// Mostrar un diálogo
  static Future<T?> showDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return showGeneralDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      barrierLabel: barrierLabel,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Mostrar un bottom sheet
  static Future<T?> showBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    RouteSettings? routeSettings,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorKey.currentContext!,
      builder: builder,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      routeSettings: routeSettings,
    );
  }

  /// Mostrar un snackbar
  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          action: action,
        ),
      );
    }
  }

  /// Mostrar un snackbar de éxito
  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Mostrar un snackbar de error
  static void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// Mostrar un snackbar de advertencia
  static void showWarningSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  /// Mostrar un snackbar de información
  static void showInfoSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }
}
