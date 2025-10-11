import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Obtener restaurantId de los argumentos de navegación
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final restaurantId = args?['restaurantId'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Owner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/owner_profile_edit');
            },
            tooltip: 'Editar Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _handleLogout(context);
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.business_center,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Panel de Administración del Owner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (restaurantId != null)
              Text(
                'Restaurante ID: $restaurantId',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            
            // Card para gestionar menú
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/owner_menu');
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Gestionar Mi Menú',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Administra categorías, productos y modificadores',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Card para Gestión de Grupos de Modificadores
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/owner_modifier_groups');
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.tune,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Grupos de Modificadores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crea opciones de personalización para tus productos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            ElevatedButton.icon(
              onPressed: () async {
                await _handleLogout(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
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
          ),
        );
      }
    }
  }
}
