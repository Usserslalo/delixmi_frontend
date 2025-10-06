import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Estados de validación en tiempo real
  bool _isPasswordValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isNameValid = false;
  bool _isLastnameValid = false;
  
  // Detalles de validación de contraseña
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    // Agregar listeners para validación en tiempo real
    _nameController.addListener(_validateNameRealTime);
    _lastnameController.addListener(_validateLastnameRealTime);
    _emailController.addListener(_validateEmailRealTime);
    _phoneController.addListener(_validatePhoneRealTime);
    _passwordController.addListener(_validatePasswordRealTime);
    _confirmPasswordController.addListener(_validateConfirmPasswordRealTime);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateNameRealTime);
    _lastnameController.removeListener(_validateLastnameRealTime);
    _emailController.removeListener(_validateEmailRealTime);
    _phoneController.removeListener(_validatePhoneRealTime);
    _passwordController.removeListener(_validatePasswordRealTime);
    _confirmPasswordController.removeListener(_validateConfirmPasswordRealTime);
    
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Limpiar el teléfono antes de enviarlo
      String cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await AuthService.register(
        name: _nameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        email: _emailController.text.trim(),
        phone: cleanPhone,
        password: _passwordController.text,
      );

      if (mounted) {
        if (response.isSuccess) {
          // Navegar a la pantalla de verificación de email
          Navigator.of(context).pushReplacementNamed(
            '/email-verification',
            arguments: _emailController.text.trim(),
          );
          
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Manejar errores específicos
          _handleRegisterError(response);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleRegisterError(dynamic response) {
    String message = response.message;
    
    switch (response.code) {
      case 'USER_EXISTS':
        message = 'Ya existe una cuenta con este email o teléfono.';
        break;
      case 'INVALID_EMAIL':
        message = 'El formato del email no es válido.';
        break;
      case 'INVALID_PHONE':
        message = 'El formato del teléfono no es válido.';
        break;
      case 'WEAK_PASSWORD':
        message = 'La contraseña debe tener al menos 8 caracteres con: 1 mayúscula, 1 minúscula, 1 número y 1 carácter especial.';
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _validateNameRealTime() {
    final value = _nameController.text;
    setState(() {
      _isNameValid = value.isNotEmpty && value.length >= 2;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  void _validateLastnameRealTime() {
    final value = _lastnameController.text;
    setState(() {
      _isLastnameValid = value.isNotEmpty && value.length >= 2;
    });
  }

  String? _validateLastname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tus apellidos';
    }
    if (value.length < 2) {
      return 'Los apellidos deben tener al menos 2 caracteres';
    }
    return null;
  }

  void _validateEmailRealTime() {
    final value = _emailController.text;
    setState(() {
      _isEmailValid = value.isNotEmpty && RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }
    return null;
  }

  void _validatePhoneRealTime() {
    final value = _phoneController.text;
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    setState(() {
      _isPhoneValid = cleanPhone.length == 10 && 
                     !cleanPhone.startsWith('0') && 
                     !cleanPhone.startsWith('1');
    });
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu número de teléfono';
    }
    
    // Limpiar el número (remover espacios, guiones, paréntesis)
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Validar longitud exacta de 10 dígitos para formato mexicano
    if (cleanPhone.length != 10) {
      return 'El número de teléfono debe tener exactamente 10 dígitos';
    }
    
    // Validar que sea un número válido
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleanPhone)) {
      return 'El formato del número de teléfono no es válido';
    }
    
    // Validar que no empiece con 0 o 1 (números mexicanos válidos)
    if (cleanPhone.startsWith('0') || cleanPhone.startsWith('1')) {
      return 'El número de teléfono no puede empezar con 0 o 1';
    }
    
    return null;
  }

  void _validatePasswordRealTime() {
    final value = _passwordController.text;
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _isPasswordValid = _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    // Validar requisitos del backend: 1 mayúscula, 1 minúscula, 1 número, 1 especial
    bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!hasUpperCase) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }
    if (!hasLowerCase) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }
    if (!hasDigits) {
      return 'La contraseña debe contener al menos un número';
    }
    if (!hasSpecialCharacters) {
      return 'La contraseña debe contener al menos un carácter especial (!@#\$%^&*(),.?":{}|<>)';
    }
    
    return null;
  }

  void _validateConfirmPasswordRealTime() {
    // La validación de confirmación se maneja en el validator
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos de contraseña:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem(
            'Al menos 8 caracteres',
            _hasMinLength,
          ),
          _buildRequirementItem(
            'Una letra mayúscula',
            _hasUppercase,
          ),
          _buildRequirementItem(
            'Una letra minúscula',
            _hasLowercase,
          ),
          _buildRequirementItem(
            'Un número',
            _hasNumber,
          ),
          _buildRequirementItem(
            'Un carácter especial',
            _hasSpecialChar,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Colors.green : Colors.grey,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Encabezado con imagen de fondo
                  Column(
                    children: [
                      Stack(
                        children: [
                          // Imagen de fondo
                          Container(
                            width: double.infinity,
                            height: 224, // h-56 en Tailwind = 224px
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCe0WKeiuWzOTPZ251sWkP7Edw4UgWxceMA8oigv7iAtwLp4bKowI0jy9-98kIE0akOgz_ys3ROPC-LCJYfIK72Qo1971hW3Gi21epdUWPi7ShwXFBZASdMkCM2t2ZH314gxtS5PYs9am9xZjNFQaDP_s0QjsBk6l5WPdTRV4ryyOM8hky8H0sEVolGgtjau08M4E3dGbl44Hl2IFXCxi4Md4e8RTKZ8yLPagFH3hAa4sCKen_zgR9pb-6YcbMsEoUmoClb3-pzCfAm'
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Overlay para mejor legibilidad del texto
                          Container(
                            width: double.infinity,
                            height: 224,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Contenido central - Logo, eslogan y formulario
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Título y eslogan
                        Column(
                          children: [
                            Text(
                              'Delixmi',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu cuenta y comienza a pedir',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Formulario
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo de nombre
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre(s)',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: _nameController.text.isNotEmpty
                                        ? Border.all(
                                            color: _isNameValid ? Colors.green : Colors.red,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _nameController,
                                    textInputAction: TextInputAction.next,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Tu nombre',
                                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: _nameController.text.isNotEmpty
                                          ? Icon(
                                              _isNameValid ? Icons.check_circle : Icons.error,
                                              color: _isNameValid ? Colors.green : Colors.red,
                                              size: 20,
                                            )
                                          : const Icon(
                                              Icons.person_outline,
                                              color: Color(0xFF9B6B4B),
                                              size: 20,
                                            ),
                                    ),
                                    validator: _validateName,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Campo de apellidos
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Apellidos',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: _lastnameController.text.isNotEmpty
                                        ? Border.all(
                                            color: _isLastnameValid ? Colors.green : Colors.red,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _lastnameController,
                                    textInputAction: TextInputAction.next,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Tus apellidos',
                                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: _lastnameController.text.isNotEmpty
                                          ? Icon(
                                              _isLastnameValid ? Icons.check_circle : Icons.error,
                                              color: _isLastnameValid ? Colors.green : Colors.red,
                                              size: 20,
                                            )
                                          : const Icon(
                                              Icons.person_outline,
                                              color: Color(0xFF9B6B4B),
                                              size: 20,
                                            ),
                                    ),
                                    validator: _validateLastname,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Campo de email
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Correo electrónico',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: _emailController.text.isNotEmpty
                                        ? Border.all(
                                            color: _isEmailValid ? Colors.green : Colors.red,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'tucorreo@ejemplo.com',
                                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: _emailController.text.isNotEmpty
                                          ? Icon(
                                              _isEmailValid ? Icons.check_circle : Icons.error,
                                              color: _isEmailValid ? Colors.green : Colors.red,
                                              size: 20,
                                            )
                                          : const Icon(
                                              Icons.mail_outline,
                                              color: Color(0xFF9B6B4B),
                                              size: 20,
                                            ),
                                    ),
                                    validator: _validateEmail,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Campo de teléfono
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Número de teléfono',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: _phoneController.text.isNotEmpty
                                        ? Border.all(
                                            color: _isPhoneValid ? Colors.green : Colors.red,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: '5512345678',
                                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: _phoneController.text.isNotEmpty
                                          ? Icon(
                                              _isPhoneValid ? Icons.check_circle : Icons.error,
                                              color: _isPhoneValid ? Colors.green : Colors.red,
                                              size: 20,
                                            )
                                          : const Icon(
                                              Icons.phone_outlined,
                                              color: Color(0xFF9B6B4B),
                                              size: 20,
                                            ),
                                    ),
                                    validator: _validatePhone,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Campo de contraseña
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contraseña',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: _passwordController.text.isNotEmpty
                                        ? Border.all(
                                            color: _isPasswordValid ? Colors.green : Colors.red,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Ej: MiPass123!',
                                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: _passwordController.text.isNotEmpty
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _isPasswordValid ? Icons.check_circle : Icons.error,
                                                  color: _isPasswordValid ? Colors.green : Colors.red,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: Icon(
                                                    _obscurePassword 
                                                      ? Icons.visibility_off_outlined
                                                      : Icons.visibility_outlined,
                                                    color: const Color(0xFF9B6B4B),
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword = !_obscurePassword;
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
                                          : IconButton(
                                              icon: Icon(
                                                _obscurePassword 
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                                color: const Color(0xFF9B6B4B),
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                            ),
                                    ),
                                    validator: _validatePassword,
                                  ),
                                ),
                                
                                // Indicadores de requisitos de contraseña
                                if (_passwordController.text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildPasswordRequirements(),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Campo de confirmar contraseña
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confirmar contraseña',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleRegister(),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Ej: MiPass123!',
                                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword 
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                          color: const Color(0xFF9B6B4B),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: _validateConfirmPassword,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Botón de registro
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Registrarse',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Acción inferior - Enlace para ir al login
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: '¿Ya tienes una cuenta? '),
                          WidgetSpan(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed('/login');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Inicia sesión aquí',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
