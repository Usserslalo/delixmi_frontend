import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';
import '../../services/metrics_service.dart';
import '../../services/token_manager.dart';
import '../../models/owner/dashboard_summary_models.dart';

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

  // Estado del dashboard
  DashboardSummary? _dashboardData;
  bool _isLoadingDashboard = true;
  String? _dashboardError;

  // Colores Material 3
  static const Color primaryOrange = Color(0xFFF2843A);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
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
    // Cargar datos del dashboard
    _loadDashboardData();
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

  /// Carga los datos del dashboard usando el endpoint "cerebro"
  Future<void> _loadDashboardData() async {
    try {
      debugPrint('🚀 Cargando datos del dashboard...');
      
      final response = await MetricsService.getDashboardSummary();
      
      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            _dashboardData = response.data!;
            _isLoadingDashboard = false;
            _dashboardError = null;
          });
          debugPrint('✅ Dashboard data cargado exitosamente');
        } else {
          setState(() {
            _isLoadingDashboard = false;
            _dashboardError = response.message;
          });
          debugPrint('❌ Error cargando dashboard: ${response.message}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error en _loadDashboardData: $e');
      if (mounted) {
        setState(() {
          _isLoadingDashboard = false;
          _dashboardError = 'Error interno: ${e.toString()}';
        });
      }
    }
  }

  /// Refresca los datos del dashboard
  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoadingDashboard = true;
      _dashboardError = null;
    });
    await _loadDashboardData();
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
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryOrange,
              primaryOrange.withValues(alpha: 0.9),
              primaryOrange.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 24),
          onPressed: _toggleDrawer,
          tooltip: 'Menú',
          color: Colors.white,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panel Owner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Delixmi Restaurant',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Indicador de pedidos pendientes con diseño premium
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.receipt_long_rounded, size: 22),
                onPressed: () => _navigateWithLocationCheck(AppRoutes.ownerOrdersList),
                tooltip: 'Pedidos Pendientes',
                color: Colors.white,
              ),
              if (_isLocationSet) // Solo mostrar si está configurado
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () => _showNotifications(context),
            tooltip: 'Notificaciones',
            color: Colors.white,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined, size: 22),
            onSelected: (value) => _handleProfileAction(context, value),
            color: Colors.white,
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
                  'Operaciones Principales',
                  [
                    _buildDrawerItem(
                      icon: Icons.receipt_rounded,
                      title: 'Gestión de Pedidos',
                      subtitle: 'Gestionar órdenes del restaurante',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerOrdersList);
                      },
                      isEnabled: _isLocationSet,
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics_rounded,
                      title: 'Métricas Financieras',
                      subtitle: 'Ganancias, saldo y transacciones',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerMetrics);
                      },
                      isEnabled: _isLocationSet,
                    ),
                  ],
                ),
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
                      icon: Icons.schedule_rounded,
                      title: 'Gestionar Horarios',
                      subtitle: 'Configurar disponibilidad',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateWithLocationCheck(AppRoutes.ownerWeeklySchedule);
                      },
                      isEnabled: _isLocationSet,
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Configuración',
                  [
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
    // Mostrar loading state si está cargando el dashboard
    if (_isLoadingDashboard) {
      return _buildLoadingState();
    }

    // Mostrar error state si hay error
    if (_dashboardError != null) {
      return _buildErrorState();
    }

    // Mostrar dashboard normal con datos
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: CustomScrollView(
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
            child: _buildProductionMetricsSection(context),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  /// Estado de carga del dashboard
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando Dashboard...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: onSurfaceColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Obteniendo datos en tiempo real',
            style: TextStyle(
              fontSize: 14,
              color: onSurfaceColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de error del dashboard
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar el Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: onSurfaceColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _dashboardError ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: onSurfaceColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
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
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          // Hero Card Principal
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryOrange,
                  primaryOrange.withValues(alpha: 0.9),
                  primaryOrange.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryOrange.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: primaryOrange.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¡Bienvenido!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurantId != null 
                                ? 'Restaurante #$restaurantId'
                                : 'Panel de Administración',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Sección de Saldo de Billetera
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo Actual',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${_dashboardData?.data.financials.walletBalance.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Gestiona tu restaurante de manera eficiente con todas las herramientas que necesitas.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryOrange.withValues(alpha: 0.1),
                      primaryOrange.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryOrange.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Estado Operacional',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLocationSet 
                        ? [Colors.green, Colors.greenAccent]
                        : [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isLocationSet ? Colors.green : Colors.red).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLocationSet ? Icons.check_circle_rounded : Icons.error_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLocationSet ? 'Operativo' : 'Configuración Pendiente',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt_rounded,
                  title: 'Pedidos Pendientes',
                  value: _dashboardData?.data.operations.pendingOrdersCount.toString() ?? '0',
                  color: Colors.red,
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerOrdersList),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Ventas Hoy',
                  value: '\$${_dashboardData?.data.financials.todaySales.toStringAsFixed(0) ?? '0'}',
                  color: Colors.green,
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerMetrics),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Productos Activos',
                  value: _dashboardData?.data.quickStats.activeProductsCount.toString() ?? '0',
                  color: Colors.blue,
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerCategories),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule_rounded,
                  title: 'Horario',
                  value: _dashboardData?.data.storeStatus.statusText ?? 'Cerrado',
                  color: _dashboardData?.data.storeStatus.isOpen == true ? Colors.green : Colors.red,
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerWeeklySchedule),
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
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.05),
                color.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: onSurfaceColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: outlineColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withValues(alpha: 0.15),
                      Colors.purple.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: Colors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Acciones Críticas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: onSurfaceColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Primera fila: Acciones más críticas para producción
          Row(
            children: [
              Expanded(
                child: _buildPremiumActionCard(
                  context: context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Pedidos',
                  subtitle: 'Gestionar pedidos en tiempo real',
                  gradientColors: [Colors.red, Colors.redAccent],
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerOrdersList),
                  isEnabled: _isLocationSet,
                  badgeCount: _dashboardData?.data.operations.pendingOrdersCount ?? 0,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildPremiumActionCard(
                  context: context,
                  icon: Icons.analytics_rounded,
                  title: 'Métricas',
                  subtitle: 'Ver ganancias y transacciones',
                  gradientColors: [Colors.green, Colors.greenAccent],
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerMetrics),
                  isEnabled: _isLocationSet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Segunda fila: Gestión del menú
          Row(
            children: [
              Expanded(
                child: _buildPremiumActionCard(
                  context: context,
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Mi Menú',
                  subtitle: 'Productos y categorías',
                  gradientColors: [Colors.blue, Colors.blueAccent],
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerCategories),
                  isEnabled: _isLocationSet,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildPremiumActionCard(
                  context: context,
                  icon: Icons.people_rounded,
                  title: 'Empleados',
                  subtitle: 'Gestionar equipo',
                  gradientColors: [Colors.indigo, Colors.indigoAccent],
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerEmployeeList),
                  isEnabled: _isLocationSet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tercera fila: Configuración
          Row(
            children: [
              Expanded(
                child: _buildPremiumActionCard(
                  context: context,
                  icon: Icons.schedule_rounded,
                  title: 'Horarios',
                  subtitle: 'Disponibilidad',
                  gradientColors: [Colors.teal, Colors.tealAccent],
                  onTap: () => _navigateWithLocationCheck(AppRoutes.ownerWeeklySchedule),
                  isEnabled: _isLocationSet,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildPremiumActionCard(
                  context: context,
                  icon: Icons.store_rounded,
                  title: 'Perfil',
                  subtitle: 'Configuración',
                  gradientColors: [Colors.orange, Colors.orangeAccent],
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.ownerProfileEdit);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool isEnabled = true,
    int? badgeCount,
  }) {
    final disabledColor = outlineColor.withValues(alpha: 0.5);
    final primaryColor = gradientColors[0];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isEnabled 
                  ? [
                      Colors.white,
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                    ]
                  : [
                      Colors.grey.shade100,
                      Colors.grey.shade200,
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isEnabled 
                  ? primaryColor.withValues(alpha: 0.2)
                  : disabledColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isEnabled 
                    ? primaryColor.withValues(alpha: 0.15)
                    : disabledColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Badge de notificación
              if (badgeCount != null && badgeCount > 0 && isEnabled)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono premium
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isEnabled 
                              ? [
                                  primaryColor.withValues(alpha: 0.15),
                                  primaryColor.withValues(alpha: 0.1),
                                ]
                              : [
                                  disabledColor.withValues(alpha: 0.15),
                                  disabledColor.withValues(alpha: 0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEnabled 
                              ? primaryColor.withValues(alpha: 0.2)
                              : disabledColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isEnabled 
                                ? primaryColor.withValues(alpha: 0.1)
                                : disabledColor.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isEnabled ? primaryColor : disabledColor,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isEnabled ? onSurfaceColor : disabledColor,
                              letterSpacing: -0.1,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: isEnabled ? outlineColor : disabledColor,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flecha de navegación premium
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isEnabled 
                          ? [
                              primaryColor.withValues(alpha: 0.1),
                              primaryColor.withValues(alpha: 0.05),
                            ]
                          : [
                              disabledColor.withValues(alpha: 0.1),
                              disabledColor.withValues(alpha: 0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isEnabled 
                          ? primaryColor.withValues(alpha: 0.2)
                          : disabledColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: isEnabled ? primaryColor : disabledColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProductionMetricsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.1),
                      Colors.blue.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Métricas de Producción',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withValues(alpha: 0.03),
                  Colors.purple.withValues(alpha: 0.03),
                  Colors.indigo.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Métricas de rendimiento
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.receipt_rounded,
                        label: 'Pedidos Entregados',
                        value: '${_dashboardData?.data.operations.deliveredTodayCount ?? 0}',
                        color: Colors.blue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            outlineColor.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.trending_up_rounded,
                        label: 'Ganancias Hoy',
                        value: '\$${_dashboardData?.data.financials.todayEarnings.toStringAsFixed(0) ?? '0'}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.people_rounded,
                        label: 'Empleados Activos',
                        value: '${_dashboardData?.data.quickStats.activeEmployeesCount ?? 0}',
                        color: Colors.orange,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            outlineColor.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.category_rounded,
                        label: 'Categorías',
                        value: '${_dashboardData?.data.quickStats.totalCategories ?? 0}',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Botón para ver métricas detalladas
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.1),
                        Colors.blue.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateWithLocationCheck(AppRoutes.ownerMetrics),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                size: 18,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Ver Métricas Detalladas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.blue.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: onSurfaceColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: outlineColor,
            fontWeight: FontWeight.w600,
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
