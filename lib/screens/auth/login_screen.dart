import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/auth_service.dart';
import '../../models/auth/user.dart' as auth_user;
import '../../utils/auth_error_handler.dart';

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

  /// Maneja la lógica de login y redirección
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Realizar login
      final loginResponse = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Obtener el rol principal del usuario
      final user = loginResponse.data.user;
      
      if (user.roles.isEmpty) {
        // Caso raro: usuario sin roles
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Usuario sin roles asignados'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      final primaryRole = user.roles.first.roleName;
      
      // Redirigir según el rol
      _redirectByRole(primaryRole, user);
      
    } catch (e) {
      if (mounted) {
        // Usar el nuevo manejador de errores
        AuthErrorHandler.showAuthErrorSnackBar(
          context, 
          null, // El error no viene con código específico desde el catch
          e.toString()
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  /// Redirige al usuario a la pantalla correcta según su rol
  void _redirectByRole(String roleName, auth_user.User user) {
    // Logging para debugging
    // debugPrint('🔑 Redirigiendo usuario con rol: $roleName');
    
    switch (roleName) {
      // ===== ROLES DE PLATAFORMA =====
      case 'super_admin':
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminDashboard, (route) => false);
        break;
        
      case 'platform_manager':
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.platformDashboard, (route) => false);
        break;
        
      case 'support_agent':
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.supportDashboard, (route) => false);
        break;
      
      // ===== ROLES DE RESTAURANTE =====
      case 'owner':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.ownerDashboard,
          (route) => false,
          arguments: {
            'restaurantId': user.roles.first.restaurantId,
          },
        );
        break;
        
      case 'branch_manager':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.branchDashboard,
          (route) => false,
          arguments: {
            'restaurantId': user.roles.first.restaurantId,
            'branchId': user.roles.first.branchId,
          },
        );
        break;
        
      case 'order_manager':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.ordersDashboard,
          (route) => false,
          arguments: {
            'restaurantId': user.roles.first.restaurantId,
            'branchId': user.roles.first.branchId,
          },
        );
        break;
        
      case 'kitchen_staff':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.kitchenDashboard,
          (route) => false,
          arguments: {
            'branchId': user.roles.first.branchId,
          },
        );
        break;
      
      // ===== ROLES DE REPARTIDORES =====
      case 'driver_platform':
      case 'driver_restaurant':
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.driverDashboard, (route) => false);
        break;
      
      // ===== ROL DE CLIENTE =====
      case 'customer':
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerHome, (route) => false);
        break;
      
      // ===== ROL NO RECONOCIDO =====
      default:
        // debugPrint('⚠️ Rol no reconocido: $roleName');
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.unsupportedRole, (route) => false);
        break;
    }
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
                                // M3: Eliminado Container wrapper, aplicado estilo M3 directamente
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: 'tucorreo@ejemplo.com',
                                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                    filled: true, // M3: Activado color de fondo del tema
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0), // M3: Bordes más redondeados
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.mail_outline,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant, // M3: Color del tema
                                      size: 20,
                                    ),
                                  ),
                                  validator: _validateEmail,
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
                                // M3: Eliminado Container wrapper, aplicado estilo M3 directamente
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: 'Ingresa tu contraseña',
                                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                                    filled: true, // M3: Activado color de fondo del tema
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0), // M3: Bordes más redondeados
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    suffixIcon: IconButton(
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
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Enlace de olvidé mi contraseña
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
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
                              // M3: Reemplazado ElevatedButton por FilledButton
                              child: FilledButton(
                                onPressed: _isLoading ? null : _handleLogin,
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
                                    Navigator.of(context).pushNamed(AppRoutes.register);
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