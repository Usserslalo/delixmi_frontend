import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../../config/app_routes.dart';

/// Overlay que muestra los pasos de onboarding para nuevos usuarios
class OnboardingOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const OnboardingOverlay({
    super.key,
    this.onComplete,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentStep = 0;
  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: '¡Bienvenido a Delixmi!',
      description: 'Para comenzar a disfrutar de tus comidas favoritas, necesitamos que configures una dirección de entrega.',
      icon: Icons.location_on_rounded,
      primaryColor: const Color(0xFFF2843A),
      secondaryColor: const Color(0xFFFFF3E0),
      buttonText: 'Agregar mi dirección',
      action: OnboardingAction.navigateToAddress,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Iniciar animaciones
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final currentStepData = _steps[_currentStep];
    
    // Ejecutar acción específica del paso
    switch (currentStepData.action) {
      case OnboardingAction.navigateToAddress:
        _navigateToAddressForm();
        break;
      case OnboardingAction.complete:
        _completeOnboarding();
        break;
      case OnboardingAction.next:
        _goToNextStep();
        break;
    }
  }

  void _goToNextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      
      // Reiniciar animaciones para el nuevo paso
      _fadeController.reset();
      _scaleController.reset();
      _fadeController.forward();
      _scaleController.forward();
    }
  }

  void _navigateToAddressForm() async {
    // Nuevo flujo: primero mapa, luego formulario
    final geocodeResult = await Navigator.of(context).pushNamed(AppRoutes.locationPicker);
    
    if (geocodeResult != null && mounted) {
      // Navegar al formulario con los datos pre-llenados
      final success = await Navigator.of(context).pushNamed(
        AppRoutes.addressForm,
        arguments: geocodeResult,
      );
      
      // Si se guardó exitosamente, marcar dirección agregada y completar onboarding
      if (success == true && mounted) {
        await OnboardingService.instance.markAddressAdded();
        await OnboardingService.instance.completeOnboarding();
        
        // Cerrar el overlay
        _fadeController.reverse().then((_) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      }
    }
  }

  void _completeOnboarding() async {
    // Marcar onboarding como completado
    await OnboardingService.instance.completeOnboarding();
    
    // Cerrar el overlay
    _fadeController.reverse().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final currentStepData = _steps[_currentStep];
    
    return WillPopScope(
      // Bloquear el botón de atrás
      onWillPop: () async => false,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              color: Colors.black.withOpacity(0.85 * _fadeAnimation.value),
              child: Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ícono del paso
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: currentStepData.secondaryColor,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: currentStepData.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              currentStepData.icon,
                              size: 40,
                              color: currentStepData.primaryColor,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Título
                          Text(
                            currentStepData.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Descripción
                          Text(
                            currentStepData.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botón principal
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: _nextStep,
                              style: FilledButton.styleFrom(
                                backgroundColor: currentStepData.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                currentStepData.buttonText,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          // Indicadores de progreso
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _steps.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index <= _currentStep
                                      ? currentStepData.primaryColor
                                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      ),
    );
  }
}

/// Datos para cada paso del onboarding
class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String buttonText;
  final OnboardingAction action;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.buttonText,
    this.action = OnboardingAction.next,
  });
}

/// Acciones que puede realizar cada paso del onboarding
enum OnboardingAction {
  next,
  navigateToAddress,
  complete,
}
