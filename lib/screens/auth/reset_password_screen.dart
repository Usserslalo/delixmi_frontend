import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTokenValid = true;
  
  // Estados de validación en tiempo real
  bool _isPasswordValid = false;
  
  // Detalles de validación de contraseña
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _validateToken();
    // Agregar listeners para validación en tiempo real
    _passwordController.addListener(_validatePasswordRealTime);
    _confirmPasswordController.addListener(_validateConfirmPasswordRealTime);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePasswordRealTime);
    _confirmPasswordController.removeListener(_validateConfirmPasswordRealTime);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  void _validateConfirmPasswordRealTime() {
    // La validación de confirmación se maneja en el validator
    setState(() {});
  }

  void _validateToken() {
    if (widget.token.isEmpty) {
      setState(() {
        _isTokenValid = false;
      });
      // debugPrint('❌ Token de reset password está vacío');
      
      // Mostrar error y navegar de vuelta al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enlace de restablecimiento no válido. Solicita uno nuevo.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    } else {
      // debugPrint('✅ Token de reset password válido: ${widget.token.substring(0, 10)}...');
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.resetPassword(
        token: widget.token,
        newPassword: _passwordController.text,
      );

      if (mounted) {
        if (response.isSuccess) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada. Ya puedes iniciar sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navegar al login después de un breve delay
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else {
          // Manejar errores específicos
          _handleResetPasswordError(response);
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

  void _handleResetPasswordError(dynamic response) {
    String message = response.message;
    
    switch (response.code) {
      case 'INVALID_TOKEN':
        message = 'El enlace de restablecimiento no es válido o ha expirado.';
        break;
      case 'TOKEN_EXPIRED':
        message = 'El enlace de restablecimiento ha expirado. Solicita uno nuevo.';
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nueva contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    // Validar requisitos del backend
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
      return 'La contraseña debe contener al menos un carácter especial';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu nueva contraseña';
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
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), // M3: Color del tema
        borderRadius: BorderRadius.circular(12), // M3: Borde más redondeado
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)), // M3: Borde del tema
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos de contraseña:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant, // M3: Color del tema
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
            color: isValid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, // M3: Colores del tema
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith( // M3: Usar textTheme
              fontSize: 12,
              color: isValid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, // M3: Colores del tema
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si el token no es válido, mostrar loading mientras se navega de vuelta
    if (!_isTokenValid) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Validando enlace...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

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
                              'Crea tu nueva contraseña',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ingresa una contraseña segura para tu cuenta',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Formulario
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo de nueva contraseña
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nueva contraseña',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // M3: Eliminado Container wrapper, aplicado estilo M3 directamente
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: 'Ej: MiPass123!',
                                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                    filled: true, // M3: Activado color de fondo del tema
                                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), // M3: Color de fondo
                                    border: OutlineInputBorder( // M3: Borde redondeado
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide.none, // M3: Sin borde visible por defecto
                                    ),
                                    enabledBorder: OutlineInputBorder( // M3: Borde cuando está habilitado
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: _passwordController.text.isNotEmpty
                                            ? (_isPasswordValid ? Colors.green : Colors.red)
                                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                        width: _passwordController.text.isNotEmpty ? 2 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder( // M3: Borde cuando está enfocado
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: _passwordController.text.isNotEmpty
                                            ? (_isPasswordValid ? Colors.green : Colors.red)
                                            : Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
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
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant, // M3: Color del tema
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
                                              color: Theme.of(context).colorScheme.onSurfaceVariant, // M3: Color del tema
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
                                
                                // Indicadores de requisitos de contraseña
                                if (_passwordController.text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildPasswordRequirements(),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Campo de confirmar nueva contraseña
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confirmar nueva contraseña',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // M3: Eliminado Container wrapper, aplicado estilo M3 directamente
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleResetPassword(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: 'Ej: MiPass123!',
                                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                    filled: true, // M3: Activado color de fondo del tema
                                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), // M3: Color de fondo
                                    border: OutlineInputBorder( // M3: Borde redondeado
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide.none, // M3: Sin borde visible por defecto
                                    ),
                                    enabledBorder: OutlineInputBorder( // M3: Borde cuando está habilitado
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder( // M3: Borde cuando está enfocado
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword 
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant, // M3: Color del tema
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
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Botón de guardar contraseña
                            SizedBox(
                              width: double.infinity,
                              height: 48, // h-12 en Tailwind = 48px
                              // M3: Reemplazado ElevatedButton por FilledButton
                              child: FilledButton(
                                onPressed: _isLoading ? null : _handleResetPassword,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0), // M3: Bordes más redondeados
                                  ),
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
                                      'Guardar contraseña',
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
                  
                  // Acción inferior - Enlace para volver al login
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: '¿Recordaste tu contraseña? '),
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
