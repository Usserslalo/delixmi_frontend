import '../models/user.dart';
import '../models/address.dart';
import '../models/product.dart';
import '../models/restaurant.dart';

class DataValidationService {
  /// Validar datos de usuario
  static ValidationResult validateUser(User user) {
    final errors = <String>[];

    if (user.name.trim().isEmpty) {
      errors.add('El nombre es requerido');
    }

    if (user.lastname.trim().isEmpty) {
      errors.add('El apellido es requerido');
    }

    if (user.email.trim().isEmpty) {
      errors.add('El email es requerido');
    } else if (!_isValidEmail(user.email)) {
      errors.add('El email no es válido');
    }

    if (user.phone.trim().isEmpty) {
      errors.add('El teléfono es requerido');
    } else if (!_isValidPhone(user.phone)) {
      errors.add('El teléfono no es válido');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validar datos de dirección
  static ValidationResult validateAddress(Address address) {
    final errors = <String>[];

    if (address.alias.trim().isEmpty) {
      errors.add('El alias es requerido');
    }

    if (address.street.trim().isEmpty) {
      errors.add('La calle es requerida');
    }

    if (address.exteriorNumber.trim().isEmpty) {
      errors.add('El número exterior es requerido');
    }

    if (address.neighborhood.trim().isEmpty) {
      errors.add('La colonia es requerida');
    }

    if (address.city.trim().isEmpty) {
      errors.add('La ciudad es requerida');
    }

    if (address.state.trim().isEmpty) {
      errors.add('El estado es requerido');
    }

    if (address.zipCode.trim().isEmpty) {
      errors.add('El código postal es requerido');
    } else if (!_isValidZipCode(address.zipCode)) {
      errors.add('El código postal no es válido');
    }

    if (address.latitude == 0.0 && address.longitude == 0.0) {
      errors.add('La ubicación es requerida');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validar datos de producto
  static ValidationResult validateProduct(Product product) {
    final errors = <String>[];

    if (product.name.trim().isEmpty) {
      errors.add('El nombre del producto es requerido');
    }

    if (product.description?.trim().isEmpty ?? true) {
      errors.add('La descripción es requerida');
    }

    if (product.price <= 0) {
      errors.add('El precio debe ser mayor a 0');
    }

    if (product.subcategoryId <= 0) {
      errors.add('La subcategoría es requerida');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validar datos de restaurante
  static ValidationResult validateRestaurant(Restaurant restaurant) {
    final errors = <String>[];

    if (restaurant.name.trim().isEmpty) {
      errors.add('El nombre del restaurante es requerido');
    }

    if (restaurant.description?.trim().isEmpty ?? true) {
      errors.add('La descripción es requerida');
    }

    if (restaurant.status.trim().isEmpty) {
      errors.add('El estado es requerido');
    }

    if (restaurant.rating != null && (restaurant.rating! < 0 || restaurant.rating! > 5)) {
      errors.add('La calificación debe estar entre 0 y 5');
    }

    if (restaurant.deliveryTime != null && restaurant.deliveryTime! <= 0) {
      errors.add('El tiempo de entrega debe ser mayor a 0');
    }

    if (restaurant.deliveryFee != null && restaurant.deliveryFee! < 0) {
      errors.add('La tarifa de entrega no puede ser negativa');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validar email
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validar teléfono
  static bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return phoneRegex.hasMatch(cleanPhone);
  }

  /// Validar código postal
  static bool _isValidZipCode(String zipCode) {
    final zipRegex = RegExp(r'^\d{5}$');
    return zipRegex.hasMatch(zipCode.trim());
  }

  /// Validar coordenadas
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 && latitude <= 90 && 
           longitude >= -180 && longitude <= 180 &&
           (latitude != 0.0 || longitude != 0.0);
  }

  /// Validar URL
  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(url);
  }

  /// Validar fecha
  static bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validar número
  static bool isValidNumber(String number) {
    return double.tryParse(number) != null;
  }

  /// Validar entero
  static bool isValidInteger(String number) {
    return int.tryParse(number) != null;
  }

  /// Sanitizar texto
  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitizar email
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitizar teléfono
  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join('\n');
}
