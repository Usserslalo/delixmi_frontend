import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar el estado del onboarding de nuevos usuarios
class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _hasAddressKey = 'has_address';
  static const String _firstLoginKey = 'first_login';

  static OnboardingService? _instance;
  static OnboardingService get instance => _instance ??= OnboardingService._();
  
  OnboardingService._();

  /// Verifica si el usuario ya completó el onboarding
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Marca el onboarding como completado
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  /// Verifica si es la primera vez que el usuario hace login
  Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLoginKey) ?? true;
  }

  /// Marca que el usuario ya no es nuevo (después del primer login)
  Future<void> markFirstLoginCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLoginKey, false);
  }

  /// Verifica si el usuario ya tiene una dirección configurada
  Future<bool> hasAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasAddressKey) ?? false;
  }

  /// Marca que el usuario ya tiene una dirección
  Future<void> markAddressAdded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasAddressKey, true);
  }

  /// Verifica si debe mostrar el onboarding
  /// Se muestra si el usuario NO tiene direcciones, independientemente de si es primera vez
  Future<bool> shouldShowOnboarding() async {
    final hasUserAddress = await hasAddress();

    // Mostrar onboarding si:
    // - NO tiene ninguna dirección configurada
    // El onboarding es OBLIGATORIO hasta que agregue al menos una dirección
    return !hasUserAddress;
  }

  /// Completa todo el flujo de onboarding
  Future<void> completeOnboarding() async {
    await markFirstLoginCompleted();
    await markOnboardingCompleted();
  }

  /// Resetea el estado del onboarding (útil para testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_hasAddressKey);
    await prefs.remove(_firstLoginKey);
  }

  /// Resetea el onboarding para un nuevo usuario (después del registro)
  Future<void> resetForNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLoginKey, true);
    await prefs.setBool(_onboardingCompletedKey, false);
    await prefs.setBool(_hasAddressKey, false);
  }

  /// Obtiene el progreso actual del onboarding
  Future<Map<String, bool>> getOnboardingProgress() async {
    return {
      'isFirstLogin': await isFirstLogin(),
      'hasCompletedOnboarding': await isOnboardingCompleted(),
      'hasAddress': await hasAddress(),
      'shouldShowOnboarding': await shouldShowOnboarding(),
    };
  }
}
