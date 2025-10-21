import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';
import '../../services/token_manager.dart';

class ModernOwnerDashboardScreen extends StatefulWidget {
  const ModernOwnerDashboardScreen({super.key});

  @override
  State<ModernOwnerDashboardScreen> createState() => _ModernOwnerDashboardScreenState();
}

class _ModernOwnerDashboardScreenState extends State<ModernOwnerDashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  // Estado de ubicación
  bool _isLocationSet = true; // Inicialmente true para evitar bloqueos durante carga
  bool _isCheckingLocation = true;

  // Colores Material 3
  static const Color primaryOrange = Color(0xFFF2843A);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color surfaceVariantColor = Color(0xFFE7E0EC);
  static const Color outlineColor = Color(0xFF79747E);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Cargar estado inicial desde TokenManager y luego verificar
    _loadInitialLocationState();
  }

  /// Carga el estado inicial de ubicación desde TokenManager
  Future<void> _loadInitialLocationState() async {
    try {
      final isLocationSet = await TokenManager.getLocationStatus();
      if (mounted) {
        setState(() {
          _isLocationSet = isLocationSet;
          _isCheckingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocationSet = false;
          _isCheckingLocation = false;
        });
      }
    }
    // Después de cargar el estado inicial, verificar con el backend
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.closeDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  /// Verifica el estado de configuración de ubicación del restaurante
  Future<void> _checkLocationStatus() async {
    try {
      // Primero intentar obtener el estado desde TokenManager
      bool locationFromStorage = await TokenManager.getLocationStatus();
      
      // Si está configurada según el storage, verificar también con el backend
      if (locationFromStorage) {
        final response = await RestaurantService.getLocationStatus();
        if (response.isSuccess) {
          final isLocationSetFromBackend = response.data?['isLocationSet'] as bool? ?? false;
          // Sincronizar el estado local con el backend
          await TokenManager.saveLocationStatus(isLocationSetFromBackend);
          locationFromStorage = isLocationSetFromBackend;
        }
      }
      
      if (mounted) {
        setState(() {
          _isLocationSet = locationFromStorage;
          _isCheckingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocationSet = false; // En caso de error, asumir que no está configurada
          _isCheckingLocation = false;
        });
        // Actualizar el storage también en caso de error
        await TokenManager.saveLocationStatus(false);
      }
    }
  }

  /// Navega a una ruta verificando primero si la ubicación está configurada
  void _navigateWithLocationCheck(String routeName, {Map<String, dynamic>? arguments}) {
    if (!_isLocationSet) {
      // Mostrar mensaje y navegar a configuración de ubicación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Debes configurar la ubicación de tu restaurante primero')),
            ],
          ),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Configurar',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.setRestaurantLocation,
                (route) => false,
              );
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Si la ubicación está configurada, navegar normalmente
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final restaurantId = args?['restaurantId'];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: surfaceColor,
      drawer: _buildModernDrawer(context, restaurantId),
      appBar: _buildModernAppBar(context),
      body: _buildModernBody(context, restaurantId),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, size: 28),
        onPressed: _toggleDrawer,
        tooltip: 'Menú',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel Owner',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            'Delixmi Restaurant',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 24),
          onPressed: () => _showNotifications(context),
          tooltip: 'Notificaciones',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle_outlined, size: 24),
          onSelected: (value) => _handleProfileAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: primaryOrange),
                  SizedBox(width: 12),
                  Text('Mi Perfil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: primaryOrange),
                  SizedBox(width: 12),
                  Text('Configuración'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Cerrar Sesión'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernDrawer(BuildContext context, dynamic restaurantId) {
    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          _buildDrawerHeader(context, restaurantId),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerSection(
                  'Gestión del Restaurante',
                  [
                    _buildDrawerItem(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Gestionar Mi Menú',
                      subtitle: 'Categorías, productos y modificadores',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerCategories);
                      },
                      isEnabled: _isLocationSet,
                    ),
                    _buildDrawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Grupos de Modificadores',
                      subtitle: 'Opciones de personalización',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerModifierGroups);
                      },
                      isEnabled: _isLocationSet,
                    ),
                    _buildDrawerItem(
                      icon: Icons.store_rounded,
                      title: 'Configurar Perfil',
                      subtitle: 'Información del restaurante',
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.pushNamed(context, AppRoutes.ownerProfileEdit);
                        // Recargar dashboard si hubo cambios en el perfil
                        if (result == true && mounted) {
                          // El perfil se actualizó, no necesitamos hacer nada especial aquí
                        }
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.people_rounded,
                      title: 'Gestionar Empleados',
                      subtitle: 'Administrar equipo de trabajo',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerEmployeeList);
                      },
                      isEnabled: _isLocationSet,
                    ),
                    _buildDrawerItem(
                      icon: Icons.location_on_rounded,
                      title: 'Ubicación del Restaurante',
                      subtitle: 'Configurar dirección y posición',
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.pushNamed(context, AppRoutes.setRestaurantLocation);
                        // Recargar estado de ubicación si se actualizó
                        if (result == true && mounted) {
                          _checkLocationStatus();
                        }
                      },
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Análisis y Reportes',
                  [
                    _buildDrawerItem(
                      icon: Icons.analytics_rounded,
                      title: 'Analytics',
                      subtitle: 'Estadísticas de ventas',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.receipt_long_rounded,
                      title: 'Reportes',
                      subtitle: 'Informes detallados',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.trending_up_rounded,
                      title: 'Performance',
                      subtitle: 'Métricas de rendimiento',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Gestión de Pedidos',
                  [
                    _buildDrawerItem(
                      icon: Icons.receipt_rounded,
                      title: 'Todos los Pedidos',
                      subtitle: 'Gestionar órdenes del restaurante',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerOrdersList);
                      },
                      isEnabled: _isLocationSet,
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Configuración',
                  [
                    _buildDrawerItem(
                      icon: Icons.schedule_rounded,
                      title: 'Horarios',
                      subtitle: 'Configurar disponibilidad',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerWeeklySchedule);
                      },
                      isEnabled: _isLocationSet,
                    ),
                    _buildDrawerItem(
                      icon: Icons.delivery_dining_rounded,
                      title: 'Zonas de Entrega',
                      subtitle: 'Áreas de cobertura',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.payment_rounded,
                      title: 'Métodos de Pago',
                      subtitle: 'Configurar pagos',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, dynamic restaurantId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryOrange,
            primaryOrange.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mi Restaurante',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            restaurantId != null ? 'ID: $restaurantId' : 'Panel de Administración',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: outlineColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final disabledColor = outlineColor.withValues(alpha: 0.5);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled 
                        ? primaryOrange.withValues(alpha: 0.1)
                        : disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isEnabled ? primaryOrange : disabledColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? onSurfaceColor : disabledColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isEnabled ? outlineColor : disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isEnabled ? outlineColor : disabledColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Divider(color: outlineColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'Salir del panel de administración',
                      style: TextStyle(
                        fontSize: 12,
                        color: outlineColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _handleLogout(context);
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBody(BuildContext context, dynamic restaurantId) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildWelcomeSection(context, restaurantId),
        ),
        // Mostrar alerta de ubicación si no está configurada
        if (!_isCheckingLocation && !_isLocationSet)
          SliverToBoxAdapter(
            child: _buildLocationWarningBanner(context),
          ),
        SliverToBoxAdapter(
          child: _buildQuickStatsSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildQuickActionsSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildRecentActivitySection(context),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// Banner de advertencia cuando la ubicación no está configurada
  Widget _buildLocationWarningBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación Requerida',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Debes configurar la ubicación de tu restaurante para acceder a todas las funciones.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.setRestaurantLocation,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Configurar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, dynamic restaurantId) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryOrange,
            primaryOrange.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      restaurantId != null 
                          ? 'Restaurante #$restaurantId'
                          : 'Panel de Administración',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Gestiona tu restaurante de manera eficiente con todas las herramientas que necesitas.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Rápido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt_rounded,
                  title: 'Pedidos Hoy',
                  value: '12',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Productos',
                  value: '45',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Ventas Hoy',
                  value: '\$2,450',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star_rounded,
                  title: 'Rating',
                  value: '4.8',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceVariantColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: outlineColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: outlineColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context: context,
            icon: Icons.receipt_long_rounded,
            title: 'Ver Pedidos',
            subtitle: 'Gestionar órdenes del restaurante',
            color: Colors.red,
            onTap: () => _navigateWithLocationCheck(AppRoutes.ownerOrdersList),
            isEnabled: _isLocationSet,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.analytics_rounded,
            title: 'Métricas Financieras',
            subtitle: 'Ver ganancias, saldo y transacciones',
            color: Colors.green,
            onTap: () => _navigateWithLocationCheck(AppRoutes.ownerMetrics),
            isEnabled: _isLocationSet,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.restaurant_menu_rounded,
            title: 'Gestionar Mi Menú',
            subtitle: 'Administra categorías, productos y modificadores',
            color: Colors.blue,
            onTap: () => _navigateWithLocationCheck(AppRoutes.ownerCategories),
            isEnabled: _isLocationSet,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.tune_rounded,
            title: 'Grupos de Modificadores',
            subtitle: 'Crea opciones de personalización para tus productos',
            color: Colors.purple,
            onTap: () => _navigateWithLocationCheck(AppRoutes.ownerModifierGroups),
            isEnabled: _isLocationSet,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.store_rounded,
            title: 'Configurar Perfil',
            subtitle: 'Actualiza la información de tu restaurante',
            color: Colors.green,
            onTap: () async {
              await Navigator.pushNamed(context, AppRoutes.ownerProfileEdit);
              // El perfil se actualizó, no necesitamos hacer nada especial aquí
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.people_rounded,
            title: 'Gestionar Empleados',
            subtitle: 'Administrar equipo de trabajo del restaurante',
            color: Colors.indigo,
            onTap: () => _navigateWithLocationCheck(AppRoutes.ownerEmployeeList),
            isEnabled: _isLocationSet,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.schedule_rounded,
            title: 'Gestionar Horarios',
            subtitle: 'Configurar disponibilidad de sucursales',
            color: Colors.teal,
            onTap: () => _navigateWithLocationCheck(AppRoutes.ownerWeeklySchedule),
            isEnabled: _isLocationSet,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.location_on_rounded,
            title: 'Ubicación del Restaurante',
            subtitle: 'Configurar dirección y posición del negocio',
            color: Colors.orange,
            onTap: () async {
              final result = await Navigator.pushNamed(context, AppRoutes.setRestaurantLocation);
              // Recargar estado de ubicación si se actualizó
              if (result == true && mounted) {
                _checkLocationStatus();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final disabledColor = outlineColor.withValues(alpha: 0.5);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceVariantColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: outlineColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isEnabled ? color : disabledColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? onSurfaceColor : disabledColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isEnabled ? outlineColor : disabledColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: isEnabled ? outlineColor : disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad Reciente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceVariantColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: outlineColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.receipt_rounded,
                  title: 'Nuevo pedido #1234',
                  subtitle: 'Hace 5 minutos',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildActivityItem(
                  icon: Icons.edit_rounded,
                  title: 'Producto actualizado',
                  subtitle: 'Pizza Margherita - Hace 15 minutos',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildActivityItem(
                  icon: Icons.add_rounded,
                  title: 'Nueva categoría agregada',
                  subtitle: 'Postres - Hace 1 hora',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: outlineColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: outlineColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay notificaciones nuevas',
              style: TextStyle(
                fontSize: 14,
                color: outlineColor,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleProfileAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        Navigator.pushNamed(context, AppRoutes.ownerProfileEdit);
        break;
      case 'settings':
        _showComingSoon(context);
        break;
      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Próximamente disponible'),
          ],
        ),
        backgroundColor: primaryOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthService.logout();
      
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
