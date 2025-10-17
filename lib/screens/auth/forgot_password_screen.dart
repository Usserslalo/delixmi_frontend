import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/auth_error_handler.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  
  // Estado de validación en tiempo real
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    // Agregar listener para validación en tiempo real
    _emailController.addListener(_validateEmailRealTime);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmailRealTime);
    _emailController.dispose();
    super.dispose();
  }
  
  void _validateEmailRealTime() {
    final value = _emailController.text;
    setState(() {
      _isEmailValid = value.isNotEmpty && RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    });
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        if (response.isSuccess) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navegar de vuelta al login después de un breve delay
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else {
          // Manejar errores específicos
          _handleForgotPasswordError(response);
        }
      }
    } catch (e) {
      if (mounted) {
        AuthErrorHandler.showAuthErrorSnackBar(
          context, 
          null, 
          'Error inesperado: ${e.toString()}'
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

  void _handleForgotPasswordError(dynamic response) {
    if (mounted) {
      AuthErrorHandler.showAuthErrorSnackBar(
        context, 
        response.code, 
        response.message
      );
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
                              'Restablece tu contraseña',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Te enviaremos un enlace para restablecer tu contraseña',
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
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleForgotPassword(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: 'tucorreo@ejemplo.com',
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
                                        color: _emailController.text.isNotEmpty
                                            ? (_isEmailValid ? Colors.green : Colors.red)
                                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                        width: _emailController.text.isNotEmpty ? 2 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder( // M3: Borde cuando está enfocado
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: _emailController.text.isNotEmpty
                                            ? (_isEmailValid ? Colors.green : Colors.red)
                                            : Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
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
                                        : Icon( // M3: Color de ícono del tema
                                            Icons.mail_outline,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            size: 20,
                                          ),
                                  ),
                                  validator: _validateEmail,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Botón de enviar enlace
                            SizedBox(
                              width: double.infinity,
                              height: 48, // h-12 en Tailwind = 48px
                              // M3: Reemplazado ElevatedButton por FilledButton
                              child: FilledButton(
                                onPressed: _isLoading ? null : _handleForgotPassword,
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
                                      'Enviar enlace',
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
