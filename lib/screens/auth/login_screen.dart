import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Intentando login con email: ${_emailController.text.trim()}');
      
      final response = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('📡 Respuesta del login: ${response.status}');
      print('📡 Mensaje: ${response.message}');
      print('📡 Código: ${response.code}');
      print('📡 Datos: ${response.data}');

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          print('✅ Login exitoso, parseando usuario...');
          final userData = response.data!['user'];
          print('👤 Datos del usuario: $userData');
          final user = User.fromJson(userData);
          print('👤 Usuario parseado: ${user.fullName}');
          print('👤 Roles: ${user.roles.map((r) => r.roleName).toList()}');
          print('👤 isRestaurantOwner: ${user.isRestaurantOwner}');
          print('👤 isCustomer: ${user.isCustomer}');
          
          // Navegar al home del cliente
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print('❌ Login fallido: ${response.message}');
          // Manejar errores específicos
          _handleLoginError(response);
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

  void _handleLoginError(dynamic response) {
    String message = response.message;
    
    switch (response.code) {
      case 'ACCOUNT_NOT_VERIFIED':
        message = 'Tu cuenta no está verificada. Por favor, revisa tu email y activa tu cuenta.';
        break;
      case 'INVALID_CREDENTIALS':
        message = 'Credenciales incorrectas. Verifica tu email y contraseña.';
        break;
      case 'USER_NOT_FOUND':
        message = 'No existe una cuenta con este email.';
        break;
      case 'RATE_LIMIT_EXCEEDED':
        message = 'Demasiados intentos fallidos. Intenta más tarde.';
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
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
                              'Tu plataforma de delivery favorita',
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
                                  height: 56, // h-14 en Tailwind = 56px
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
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
                                      suffixIcon: const Icon(
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
                                  height: 56, // h-14 en Tailwind = 56px
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleLogin(),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Ingresa tu contraseña',
                                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: IconButton(
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
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                                    // Enlace de olvidé mi contraseña
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed('/forgot-password');
                                        },
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Botón de login
                            SizedBox(
                              width: double.infinity,
                              height: 48, // h-12 en Tailwind = 48px
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
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
                                      'Iniciar Sesión',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botón de debug temporal
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/debug-backend');
                            },
                            icon: const Icon(Icons.bug_report, size: 16),
                            label: const Text('Debug Backend'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Acción inferior - Enlaces de registro y restaurante
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        // Enlace de registro
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              const TextSpan(text: '¿No tienes cuenta? '),
                              WidgetSpan(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/register');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.primary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Regístrate aquí',
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
                      ],
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
