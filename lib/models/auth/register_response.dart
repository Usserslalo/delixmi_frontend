import 'user.dart';

/// Respuesta especializada para el registro de usuario
/// Maneja casos específicos como EMAIL_SEND_ERROR donde el usuario se crea pero falla el envío del correo
class RegisterResponse {
  final bool isSuccess;
  final String message;
  final String? errorCode;
  final User? user;
  final bool requiresEmailResend;

  RegisterResponse({
    required this.isSuccess,
    required this.message,
    this.errorCode,
    this.user,
    this.requiresEmailResend = false,
  });

  /// Constructor para registro exitoso
  factory RegisterResponse.success({
    required String message,
    required User user,
  }) {
    return RegisterResponse(
      isSuccess: true,
      message: message,
      user: user,
    );
  }

  /// Constructor para error de envío de email (usuario creado pero correo falló)
  factory RegisterResponse.emailSendError({
    required String message,
    required User user,
  }) {
    return RegisterResponse(
      isSuccess: false,
      message: message,
      errorCode: 'EMAIL_SEND_ERROR',
      user: user,
      requiresEmailResend: true,
    );
  }

  /// Constructor para otros errores
  factory RegisterResponse.error({
    required String message,
    String? errorCode,
  }) {
    return RegisterResponse(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
    );
  }

  /// Indica si el usuario fue creado exitosamente (incluso con errores de email)
  bool get userWasCreated => user != null;

  /// Indica si se requiere reenvío de email de verificación
  bool get needsEmailResend => requiresEmailResend;
}
