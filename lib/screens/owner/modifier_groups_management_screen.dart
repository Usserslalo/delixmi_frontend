import 'package:flutter/material.dart';
import '../../models/menu/menu_models.dart';
import '../../services/menu_service.dart';
import '../../widgets/owner/create_modifier_group_form.dart';
import '../../widgets/owner/add_modifier_option_form.dart';
import '../../widgets/owner/edit_modifier_group_form.dart';
import '../../widgets/owner/edit_modifier_option_form.dart';

class ModifierGroupsManagementScreen extends StatefulWidget {
  const ModifierGroupsManagementScreen({super.key});

  @override
  State<ModifierGroupsManagementScreen> createState() => _ModifierGroupsManagementScreenState();
}

class _ModifierGroupsManagementScreenState extends State<ModifierGroupsManagementScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<ModifierGroup> _modifierGroups = [];

  @override
  void initState() {
    super.initState();
    _loadModifierGroups();
  }

  /// Carga los grupos de modificadores
  Future<void> _loadModifierGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await MenuService.getModifierGroups();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _modifierGroups = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar grupos de modificadores: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Muestra el modal para crear un nuevo grupo
  Future<void> _showCreateGroupModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateModifierGroupForm(),
    );

    // Si se creó exitosamente, refrescar la lista
    if (result == true) {
      await _loadModifierGroups();
    }
  }

  /// Muestra el modal para añadir opción a un grupo
  Future<void> _showAddOptionModal(ModifierGroup group) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddModifierOptionForm(groupId: group.id),
    );

    // Si se añadió exitosamente, refrescar la lista
    if (result == true) {
      await _loadModifierGroups();
    }
  }

  /// Muestra el modal para editar un grupo
  Future<void> _showEditGroupModal(ModifierGroup group) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditModifierGroupForm(group: group),
    );

    // Si se actualizó exitosamente, refrescar la lista
    if (result == true) {
      await _loadModifierGroups();
    }
  }

  /// Muestra el modal para editar una opción
  Future<void> _showEditOptionModal(ModifierOption option) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditModifierOptionForm(option: option),
    );

    // Si se actualizó exitosamente, refrescar la lista
    if (result == true) {
      await _loadModifierGroups();
    }
  }

  /// Muestra diálogo de confirmación para eliminar grupo
  Future<void> _showDeleteGroupDialog(ModifierGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Grupo de Modificadores'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar este grupo?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${group.options.length} opciones'),
                  Text(
                    'Tipo: ${group.minSelection > 0 ? 'Obligatorio' : 'Opcional'}',
                    style: TextStyle(
                      color: group.minSelection > 0 ? Colors.red[600] : Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteGroup(group);
    }
  }

  /// Elimina un grupo de modificadores
  Future<void> _deleteGroup(ModifierGroup group) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Eliminando grupo...'),
            ],
          ),
        ),
      );

      final response = await MenuService.deleteModifierGroup(group.id);

      // Cerrar el diálogo de carga
      if (mounted) Navigator.pop(context);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Grupo "${group.name}" eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Refrescar la lista
          await _loadModifierGroups();
        }
      } else {
        if (mounted) {
          // Manejo específico de errores según códigos del backend
          String errorMessage = response.message;
          Color backgroundColor = Colors.red;
          Duration duration = const Duration(seconds: 3);
          IconData errorIcon = Icons.error;
          
          switch (response.code) {
            case 'MODIFIER_GROUP_NOT_FOUND':
              errorMessage = 'El grupo de modificadores que intentas eliminar no fue encontrado.';
              backgroundColor = Colors.red;
              errorIcon = Icons.search_off;
              break;
            case 'FORBIDDEN':
              errorMessage = 'No tienes permisos para eliminar este grupo de modificadores.';
              backgroundColor = Colors.red;
              errorIcon = Icons.block;
              break;
            case 'GROUP_HAS_OPTIONS':
              final optionsCount = response.details?['optionsCount'] ?? 0;
              final options = (response.details?['options'] as List<dynamic>?)
                  ?.map((o) => o['name'] as String)
                  .toList() ?? [];
              
              errorMessage = 'No se puede eliminar el grupo porque tiene $optionsCount opcion${optionsCount != 1 ? 'es' : ''}';
              if (options.isNotEmpty) {
                errorMessage += ':\n\n';
                errorMessage += options.take(3).join(', ');
                if (options.length > 3) {
                  errorMessage += ' y ${options.length - 3} más';
                }
              }
              errorMessage += '\n\nElimina primero todas las opciones del grupo.';
              
              backgroundColor = Colors.orange;
              duration = const Duration(seconds: 6);
              errorIcon = Icons.warning;
              break;
            case 'GROUP_ASSOCIATED_TO_PRODUCTS':
              final productsCount = response.details?['productsCount'] ?? 0;
              final products = (response.details?['products'] as List<dynamic>?)
                  ?.map((p) => p['name'] as String)
                  .toList() ?? [];
              
              errorMessage = 'No se puede eliminar el grupo porque está asociado a $productsCount producto${productsCount != 1 ? 's' : ''}';
              if (products.isNotEmpty) {
                errorMessage += ':\n\n';
                errorMessage += products.take(3).join(', ');
                if (products.length > 3) {
                  errorMessage += ' y ${products.length - 3} más';
                }
              }
              errorMessage += '\n\nDesasocia primero los productos o edítalos para usar otro grupo.';
              
              backgroundColor = Colors.orange;
              duration = const Duration(seconds: 6);
              errorIcon = Icons.warning;
              break;
            default:
              // Usar el mensaje por defecto del servidor
              break;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(errorIcon, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: backgroundColor,
              duration: duration,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar el diálogo de carga si está abierto
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar grupo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos de Modificadores'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupModal,
        backgroundColor: Colors.orange,
        tooltip: 'Crear Grupo de Modificadores',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar grupos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadModifierGroups,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_modifierGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay grupos de modificadores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer grupo para personalizar productos',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateGroupModal,
              icon: const Icon(Icons.add),
              label: const Text('Crear Primer Grupo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadModifierGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modifierGroups.length,
        itemBuilder: (context, index) {
          final group = _modifierGroups[index];
          return _buildModifierGroupCard(group);
        },
      ),
    );
  }

  Widget _buildModifierGroupCard(ModifierGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Icon(
            Icons.tune,
            color: Colors.orange[700],
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                // Badge de tipo (Obligatorio/Opcional)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: group.minSelection > 0 ? Colors.red[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.minSelection > 0 ? 'Obligatorio' : 'Opcional',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: group.minSelection > 0 ? Colors.red[700] : Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Badge de selección (Única/Múltiple)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.maxSelection == 1 ? 'Única' : 'Múltiple',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${group.options.length} opciones disponibles',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        children: [
          if (group.options.isEmpty)
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.orange),
              title: const Text('Sin opciones'),
              subtitle: const Text('Añade opciones para que este grupo sea útil'),
              trailing: ElevatedButton(
                onPressed: () => _showAddOptionModal(group),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Añadir Opción'),
              ),
            )
          else
            ...group.options.map((option) => ListTile(
              leading: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
              title: Text(option.name),
              subtitle: Text(
                option.price > 0 
                    ? '+\$${option.price.toStringAsFixed(2)}'
                    : 'Sin costo adicional',
                style: TextStyle(
                  color: option.price > 0 ? Colors.green[600] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                    onPressed: () => _showEditOptionModal(option),
                    tooltip: 'Editar opción',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    onPressed: () => _showDeleteOptionDialog(option),
                    tooltip: 'Eliminar opción',
                  ),
                ],
              ),
            )),
          
          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primera fila: Editar y Añadir Opción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditGroupModal(group),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar Grupo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddOptionModal(group),
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Opción'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Segunda fila: Eliminar Grupo
                OutlinedButton.icon(
                  onPressed: () => _showDeleteGroupDialog(group),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar Grupo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de confirmación para eliminar opción
  Future<void> _showDeleteOptionDialog(ModifierOption option) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Opción'),
        content: Text('¿Estás seguro de que quieres eliminar "${option.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteOption(option);
    }
  }

  /// Elimina una opción de modificador
  Future<void> _deleteOption(ModifierOption option) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Eliminando opción...'),
            ],
          ),
        ),
      );

      final response = await MenuService.deleteModifierOption(option.id);

      // Cerrar el diálogo de carga
      if (mounted) Navigator.pop(context);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opción "${option.name}" eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Refrescar la lista
          await _loadModifierGroups();
        }
      } else {
        if (mounted) {
          // Manejo específico de errores según códigos del backend
          String errorMessage = response.message;
          Color errorColor = Colors.red;
          IconData errorIcon = Icons.error;
          
          switch (response.code) {
            case 'MODIFIER_OPTION_NOT_FOUND':
              errorMessage = 'La opción que intentas eliminar no fue encontrada.';
              errorColor = Colors.red;
              errorIcon = Icons.search_off;
              break;
            case 'OPTION_IN_USE_IN_CARTS':
              final cartItemsCount = response.details?['cartItemsCount'] ?? 0;
              errorMessage = 'No se puede eliminar la opción porque está siendo usada en $cartItemsCount carrito${cartItemsCount != 1 ? 's' : ''} de compra activos.\n\nEspera a que se complete el pedido o contacta al soporte técnico.';
              errorColor = Colors.orange;
              errorIcon = Icons.shopping_cart;
              break;
            case 'FORBIDDEN':
              errorMessage = 'No tienes permisos para eliminar esta opción de modificador.';
              errorColor = Colors.red;
              errorIcon = Icons.block;
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'No tienes permisos para eliminar opciones de modificadores.';
              errorColor = Colors.red;
              errorIcon = Icons.block;
              break;
            default:
              // Usar el mensaje por defecto del servidor
              break;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(errorIcon, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: errorColor,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar el diálogo de carga si está abierto
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar opción: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
