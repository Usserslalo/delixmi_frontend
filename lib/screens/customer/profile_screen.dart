import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/auth_service.dart';
import '../../models/auth/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // debugPrint('🔍 ProfileScreen: Cargando datos del usuario...');
      final user = await AuthService.getCurrentUser();
      // debugPrint('🔍 ProfileScreen: Usuario obtenido: ${user?.fullName ?? "null"}');
      // debugPrint('🔍 ProfileScreen: Usuario phone: "${user?.phone ?? "null"}"');
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
      
      // Si no hay usuario O si el teléfono está vacío, obtener desde backend
      if (user == null || (user.phone.isEmpty)) {
        // debugPrint('🔍 ProfileScreen: Usuario sin datos completos, obteniendo desde backend...');
        await _loadProfileFromBackend();
      }
    } catch (e) {
      // debugPrint('❌ ProfileScreen: Error al cargar usuario: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfileFromBackend() async {
    try {
      // debugPrint('🔍 ProfileScreen: Obteniendo perfil desde backend...');
      final response = await AuthService.getProfile();
      if (response.isSuccess && response.data != null) {
        // debugPrint('✅ ProfileScreen: Perfil obtenido desde backend: ${response.data!.fullName}');
        // debugPrint('✅ ProfileScreen: Phone desde backend: "${response.data!.phone}"');
        if (mounted) {
          setState(() {
            _currentUser = response.data;
          });
        }
      } else {
        // debugPrint('❌ ProfileScreen: Error al obtener perfil del backend: ${response.message}');
      }
    } catch (e) {
      // debugPrint('❌ ProfileScreen: Error al obtener perfil del backend: $e');
    }
  }

  Future<void> _logout() async {
    try {
      // Mostrar diálogo de confirmación
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Mostrar indicador de carga
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Realizar logout
        await AuthService.logout();

        // Cerrar el diálogo de carga
        if (mounted) {
          Navigator.of(context).pop();
          
          // Navegar a login y limpiar historial
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Cerrar el diálogo de carga si está abierto
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del usuario
            _buildUserInfo(),
            
            const SizedBox(height: 32),
            
            // Opciones del perfil
            _buildProfileOptions(),
            
            const SizedBox(height: 32),
            
            // Botón de cerrar sesión
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar y información principal
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _currentUser?.initials ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.fullName ?? 'Usuario',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentUser?.email ?? 'Sin email',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        // Indicador de verificación de email
                        if (_currentUser?.isEmailVerified == true)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    // Teléfono (siempre mostrar, pero indicar si está vacío)
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentUser?.phone.isNotEmpty == true 
                                ? _currentUser!.phone
                                : 'No registrado',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: _currentUser?.phone.isNotEmpty == true 
                                  ? Colors.grey[600] 
                                  : Colors.grey[400],
                              fontStyle: _currentUser?.phone.isNotEmpty == true 
                                  ? FontStyle.normal 
                                  : FontStyle.italic,
                            ),
                          ),
                        ),
                        // Indicador de verificación de teléfono (solo si hay teléfono)
                        if (_currentUser?.phone.isNotEmpty == true && _currentUser!.isPhoneVerified == true)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Antigüedad del cliente
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _currentUser?.memberSince ?? 'Cliente',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Botón de editar perfil
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToEditProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text(
                'Editar Perfil',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Mis Direcciones
        _buildOptionTile(
          icon: Icons.location_on_outlined,
          title: 'Mis Direcciones',
          subtitle: 'Gestiona tus direcciones de entrega',
          onTap: () => _navigateToAddresses(),
        ),
        
        const SizedBox(height: 12),
        
        // Historial de Pedidos
        _buildOptionTile(
          icon: Icons.receipt_long_outlined,
          title: 'Historial de Pedidos',
          subtitle: 'Ve tus pedidos anteriores',
          onTap: () => _navigateToOrderHistory(),
        ),
        
        const SizedBox(height: 12),
        
        // Cambiar Contraseña
        _buildOptionTile(
          icon: Icons.lock_outline,
          title: 'Cambiar Contraseña',
          subtitle: 'Actualiza tu contraseña de seguridad',
          onTap: () => _navigateToChangePassword(),
        ),
        
        const SizedBox(height: 12),
        
        // Ayuda y Soporte
        _buildOptionTile(
          icon: Icons.help_outline,
          title: 'Ayuda y Soporte',
          subtitle: 'Centro de ayuda y contacto',
          onTap: () => _navigateToHelpSupport(),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red[200]!),
          ),
        ),
        child: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToAddresses() {
    Navigator.of(context).pushNamed(AppRoutes.addresses);
  }

  void _navigateToOrderHistory() {
    Navigator.of(context).pushNamed(AppRoutes.orderHistory);
  }

  Future<void> _navigateToEditProfile() async {
    // debugPrint('🔍 ProfileScreen: Intentando navegar a editar perfil...');
    // debugPrint('🔍 ProfileScreen: Usuario actual: ${_currentUser?.fullName ?? "null"}');
    
    if (_currentUser == null) {
      // debugPrint('❌ ProfileScreen: No hay usuario, no se puede editar perfil');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo cargar la información del usuario'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    try {
      // debugPrint('🔍 ProfileScreen: Navegando a /edit-profile...');
      final updatedUser = await Navigator.of(context).pushNamed(
        '/edit-profile',
        arguments: _currentUser,
      ) as User?;
      
      if (updatedUser != null) {
        // debugPrint('✅ ProfileScreen: Usuario actualizado: ${updatedUser.fullName}');
        setState(() {
          _currentUser = updatedUser;
        });
      } else {
        // debugPrint('🔍 ProfileScreen: No se actualizó el usuario');
      }
    } catch (e) {
      // debugPrint('❌ ProfileScreen: Error al navegar a editar perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir la pantalla de edición: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToChangePassword() {
    Navigator.of(context).pushNamed(AppRoutes.changePassword);
  }

  void _navigateToHelpSupport() {
    Navigator.of(context).pushNamed(AppRoutes.helpSupport);
  }
}
