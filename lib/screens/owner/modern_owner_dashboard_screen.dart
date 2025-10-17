import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_routes.dart';
import '../../services/auth_service.dart';

class ModernOwnerDashboardScreen extends StatefulWidget {
  const ModernOwnerDashboardScreen({super.key});

  @override
  State<ModernOwnerDashboardScreen> createState() => _ModernOwnerDashboardScreenState();
}

class _ModernOwnerDashboardScreenState extends State<ModernOwnerDashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

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
                        Navigator.pushNamed(context, AppRoutes.ownerMenu);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Grupos de Modificadores',
                      subtitle: 'Opciones de personalización',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.ownerModifierGroups);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.store_rounded,
                      title: 'Configurar Perfil',
                      subtitle: 'Información del restaurante',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.ownerProfileEdit);
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
                      title: 'Pedidos Activos',
                      subtitle: 'Órdenes en progreso',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.history_rounded,
                      title: 'Historial',
                      subtitle: 'Pedidos completados',
                      onTap: () => _showComingSoon(context),
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
                      onTap: () => _showComingSoon(context),
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
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(width: 16),
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
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: outlineColor,
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
            icon: Icons.restaurant_menu_rounded,
            title: 'Gestionar Mi Menú',
            subtitle: 'Administra categorías, productos y modificadores',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, AppRoutes.ownerMenu),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.tune_rounded,
            title: 'Grupos de Modificadores',
            subtitle: 'Crea opciones de personalización para tus productos',
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, AppRoutes.ownerModifierGroups),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: Icons.store_rounded,
            title: 'Configurar Perfil',
            subtitle: 'Actualiza la información de tu restaurante',
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, AppRoutes.ownerProfileEdit),
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: outlineColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: outlineColor,
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
