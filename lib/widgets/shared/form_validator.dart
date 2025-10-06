import 'package:flutter/material.dart';
import '../../services/error_handler.dart';

class FormValidator {
  static final FormValidator _instance = FormValidator._internal();
  factory FormValidator() => _instance;
  FormValidator._internal();

  final Map<String, String> _errors = {};

  /// Valida un formulario completo
  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  /// Valida un campo específico
  String? validateField(String value, ValidationRule rule, {String? fieldName}) {
    switch (rule.type) {
      case ValidationType.required:
        return ErrorHandler.validateRequired(value, fieldName: fieldName);
      case ValidationType.email:
        return ErrorHandler.validateEmail(value);
      case ValidationType.phone:
        return ErrorHandler.validatePhone(value);
      case ValidationType.password:
        return ErrorHandler.validatePassword(value);
      case ValidationType.confirmPassword:
        return null; // Se maneja por separado
      case ValidationType.minLength:
        return _validateMinLength(value, rule.minLength ?? 3, fieldName);
      case ValidationType.maxLength:
        return _validateMaxLength(value, rule.maxLength ?? 100, fieldName);
      case ValidationType.numeric:
        return _validateNumeric(value, fieldName);
      case ValidationType.alpha:
        return _validateAlpha(value, fieldName);
      case ValidationType.alphanumeric:
        return _validateAlphanumeric(value, fieldName);
      case ValidationType.url:
        return _validateUrl(value, fieldName);
      case ValidationType.date:
        return _validateDate(value, fieldName);
      case ValidationType.custom:
        return rule.validator?.call(value);
    }
  }

  /// Valida confirmación de contraseña
  String? validatePasswordConfirmation(String value, String password) {
    return ErrorHandler.validatePasswordConfirmation(value, password);
  }

  /// Valida longitud mínima
  String? _validateMinLength(String value, int minLength, String? fieldName) {
    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Valida longitud máxima
  String? _validateMaxLength(String value, int maxLength, String? fieldName) {
    if (value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede tener más de $maxLength caracteres';
    }
    return null;
  }

  /// Valida que sea numérico
  String? _validateNumeric(String value, String? fieldName) {
    if (value.isNotEmpty && double.tryParse(value) == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }
    return null;
  }

  /// Valida que sea alfabético
  String? _validateAlpha(String value, String? fieldName) {
    if (value.isNotEmpty && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '${fieldName ?? 'Este campo'} solo puede contener letras';
    }
    return null;
  }

  /// Valida que sea alfanumérico
  String? _validateAlphanumeric(String value, String? fieldName) {
    if (value.isNotEmpty && !RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return '${fieldName ?? 'Este campo'} solo puede contener letras y números';
    }
    return null;
  }

  /// Valida URL
  String? _validateUrl(String value, String? fieldName) {
    if (value.isNotEmpty) {
      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );
      if (!urlRegex.hasMatch(value)) {
        return '${fieldName ?? 'Este campo'} debe ser una URL válida';
      }
    }
    return null;
  }

  /// Valida fecha
  String? _validateDate(String value, String? fieldName) {
    if (value.isNotEmpty) {
      try {
        DateTime.parse(value);
      } catch (e) {
        return '${fieldName ?? 'Este campo'} debe ser una fecha válida';
      }
    }
    return null;
  }

  /// Limpia errores
  void clearErrors() {
    _errors.clear();
  }

  /// Obtiene errores
  Map<String, String> get errors => Map.unmodifiable(_errors);

  /// Verifica si hay errores
  bool get hasErrors => _errors.isNotEmpty;
}

/// Reglas de validación
class ValidationRule {
  final ValidationType type;
  final int? minLength;
  final int? maxLength;
  final String? Function(String)? validator;

  const ValidationRule._({
    required this.type,
    this.minLength,
    this.maxLength,
    this.validator,
  });

  static const ValidationRule required = ValidationRule._(type: ValidationType.required);
  static const ValidationRule email = ValidationRule._(type: ValidationType.email);
  static const ValidationRule phone = ValidationRule._(type: ValidationType.phone);
  static const ValidationRule password = ValidationRule._(type: ValidationType.password);
  static const ValidationRule confirmPassword = ValidationRule._(type: ValidationType.confirmPassword);
  
  static ValidationRule withMinLength(int length) => ValidationRule._(
    type: ValidationType.minLength,
    minLength: length,
  );
  
  static ValidationRule withMaxLength(int length) => ValidationRule._(
    type: ValidationType.maxLength,
    maxLength: length,
  );
  
  static const ValidationRule numeric = ValidationRule._(type: ValidationType.numeric);
  static const ValidationRule alpha = ValidationRule._(type: ValidationType.alpha);
  static const ValidationRule alphanumeric = ValidationRule._(type: ValidationType.alphanumeric);
  static const ValidationRule url = ValidationRule._(type: ValidationType.url);
  static const ValidationRule date = ValidationRule._(type: ValidationType.date);
  
  static ValidationRule custom(String? Function(String) validator) => ValidationRule._(
    type: ValidationType.custom,
    validator: validator,
  );
}

enum ValidationType {
  required,
  email,
  phone,
  password,
  confirmPassword,
  minLength,
  maxLength,
  numeric,
  alpha,
  alphanumeric,
  url,
  date,
  custom,
}

/// Widget de campo de texto con validación
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final ValidationRule validationRule;
  final String? fieldName;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const ValidatedTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    required this.validationRule,
    this.fieldName,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.onTap,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateField);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateField);
    super.dispose();
  }

  void _validateField() {
    if (widget.controller.text.isNotEmpty) {
      setState(() {
        _errorText = FormValidator().validateField(
          widget.controller.text,
          widget.validationRule,
          fieldName: widget.fieldName ?? widget.label,
        );
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        errorText: _errorText,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[500]!),
        ),
      ),
      validator: (value) => FormValidator().validateField(
        value ?? '',
        widget.validationRule,
        fieldName: widget.fieldName ?? widget.label,
      ),
    );
  }
}

/// Widget de campo de contraseña con confirmación
class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? fieldName;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.fieldName,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      label: widget.label,
      controller: widget.controller,
      validationRule: ValidationRule.password,
      fieldName: widget.fieldName,
      obscureText: _obscureText,
      prefixIcon: widget.prefixIcon ?? const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      onChanged: widget.onChanged,
    );
  }
}

/// Widget de campo de confirmación de contraseña
class ConfirmPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextEditingController passwordController;
  final String? fieldName;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const ConfirmPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.passwordController,
    this.fieldName,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.prefixIcon ?? const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[500]!),
        ),
      ),
      validator: (value) => FormValidator().validatePasswordConfirmation(
        value ?? '',
        widget.passwordController.text,
      ),
    );
  }
}
