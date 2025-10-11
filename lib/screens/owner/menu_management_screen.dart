import 'package:flutter/material.dart';
import '../../models/menu/menu_models.dart';
import '../../models/api_response.dart';
import '../../services/menu_service.dart';
import '../../widgets/owner/add_subcategory_form.dart';
import '../../widgets/owner/add_product_form.dart';
import '../../widgets/owner/edit_subcategory_form.dart';
import '../../widgets/owner/edit_product_form.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  bool _isLoading = false;
  List<Subcategory> _subcategories = [];
  List<MenuProduct> _products = [];
  Map<int, List<MenuProduct>> _productsBySubcategory = {};

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  /// Carga todos los datos del menú
  Future<void> _loadMenuData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar subcategorías y productos en paralelo
      final results = await Future.wait([
        MenuService.getSubcategories(pageSize: 100),
        MenuService.getProducts(pageSize: 100),
      ]);

      final subcategoriesResponse = results[0] as ApiResponse<List<Subcategory>>;
      final productsResponse = results[1] as ApiResponse<List<MenuProduct>>;

      if (subcategoriesResponse.isSuccess && subcategoriesResponse.data != null) {
        setState(() {
          _subcategories = subcategoriesResponse.data!;
        });
      }

      if (productsResponse.isSuccess && productsResponse.data != null) {
        setState(() {
          _products = productsResponse.data!;
          _organizeProductsBySubcategory();
        });
      }

      if (!subcategoriesResponse.isSuccess || !productsResponse.isSuccess) {
        if (mounted) {
          final errorMessage = !subcategoriesResponse.isSuccess 
              ? subcategoriesResponse.message 
              : productsResponse.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el menú: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Organiza los productos por subcategoría
  void _organizeProductsBySubcategory() {
    _productsBySubcategory.clear();
    
    for (var product in _products) {
      final subcategoryId = product.subcategory?.id;
      if (subcategoryId != null) {
        if (!_productsBySubcategory.containsKey(subcategoryId)) {
          _productsBySubcategory[subcategoryId] = [];
        }
        _productsBySubcategory[subcategoryId]!.add(product);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Menú'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuData,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subcategories.isEmpty
              ? _buildEmptyState()
              : _buildMenuList(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No hay subcategorías en tu menú',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza creando una subcategoría para organizar tus productos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddSubcategoryModal,
              icon: const Icon(Icons.add),
              label: const Text('Crear Primera Subcategoría'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return RefreshIndicator(
      onRefresh: _loadMenuData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = _subcategories[index];
          final products = _productsBySubcategory[subcategory.id] ?? [];
          
          return _buildSubcategoryTile(subcategory, products);
        },
      ),
    );
  }

  Widget _buildSubcategoryTile(Subcategory subcategory, List<MenuProduct> products) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(
            '${products.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          subcategory.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subcategory.category?.name ?? 'Sin categoría',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${products.length} producto${products.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            // Botón de editar subcategoría
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              onPressed: () => _showEditSubcategoryModal(subcategory),
            ),
            // Botón de eliminar subcategoría
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () => _showDeleteSubcategoryDialog(subcategory),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No hay productos en esta subcategoría',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...products.map((product) => _buildProductItem(product)).toList(),
          
          // Botón para añadir producto a esta subcategoría
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.orange),
            title: const Text(
              'Añadir producto a esta subcategoría',
              style: TextStyle(color: Colors.orange),
            ),
            onTap: () => _showAddProductModal(
              preSelectedSubcategoryId: subcategory.id,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(MenuProduct product) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: product.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  );
                },
              ),
            )
          : Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fastfood, color: Colors.grey),
            ),
      title: Text(
        product.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (product.modifierGroups.isNotEmpty)
            Text(
              '${product.modifierGroups.length} grupo${product.modifierGroups.length != 1 ? 's' : ''} de modificadores',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle de disponibilidad
          Switch(
            value: product.isAvailable,
            onChanged: (bool value) => _toggleProductAvailability(product, value),
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red[300],
            inactiveTrackColor: Colors.red[100],
          ),
          const SizedBox(width: 8),
          // Botón de editar producto
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
            onPressed: () => _showEditProductModal(product),
          ),
          // Botón de eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: () => _showDeleteProductDialog(product),
          ),
        ],
      ),
    );
  }

  /// Muestra el modal para añadir subcategoría
  Future<void> _showAddSubcategoryModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSubcategoryForm(),
    );

    // Si se creó exitosamente, refrescar la lista
    if (result == true) {
      await _loadMenuData();
    }
  }

  /// Muestra el modal para añadir producto
  Future<void> _showAddProductModal({int? preSelectedSubcategoryId}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProductForm(
        preSelectedSubcategoryId: preSelectedSubcategoryId,
      ),
    );

    // Si se creó exitosamente, refrescar la lista
    if (result == true) {
      await _loadMenuData();
    }
  }

  /// Muestra diálogo de confirmación para eliminar producto
  Future<void> _showDeleteProductDialog(MenuProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar este producto?'),
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
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('\$${product.price.toStringAsFixed(2)}'),
                  if (product.subcategory != null)
                    Text('Categoría: ${product.subcategory!.name}'),
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
      await _deleteProduct(product);
    }
  }

  /// Muestra diálogo de confirmación para eliminar subcategoría
  Future<void> _showDeleteSubcategoryDialog(Subcategory subcategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Subcategoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar esta subcategoría?'),
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
                    subcategory.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Categoría: ${subcategory.category?.name ?? 'Sin categoría'}'),
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
      await _deleteSubcategory(subcategory);
    }
  }

  /// Elimina una subcategoría
  Future<void> _deleteSubcategory(Subcategory subcategory) async {
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
              Text('Eliminando subcategoría...'),
            ],
          ),
        ),
      );

      final response = await MenuService.deleteSubcategory(subcategory.id);

      // Cerrar el diálogo de carga
      if (mounted) Navigator.pop(context);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subcategoría "${subcategory.name}" eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Refrescar la lista
          await _loadMenuData();
        }
      } else {
        if (mounted) {
          String errorMessage = response.message;
          
          // Manejo específico para subcategorías con productos
          if (response.code == 'SUBCATEGORY_HAS_PRODUCTS') {
            errorMessage = 'No se puede eliminar la subcategoría porque todavía contiene productos.\n\nElimina primero todos los productos de esta subcategoría o muévelos a otra.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 6),
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
            content: Text('Error al eliminar subcategoría: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra modal para editar subcategoría
  Future<void> _showEditSubcategoryModal(Subcategory subcategory) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditSubcategoryForm(
        subcategory: subcategory,
      ),
    );

    // Si se actualizó exitosamente, refrescar la lista
    if (result == true) {
      await _loadMenuData();
    }
  }

  /// Muestra modal para editar producto
  Future<void> _showEditProductModal(MenuProduct product) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProductForm(
        product: product,
      ),
    );

    // Si se actualizó exitosamente, refrescar la lista
    if (result == true) {
      await _loadMenuData();
    }
  }

  /// Cambia la disponibilidad de un producto
  Future<void> _toggleProductAvailability(MenuProduct product, bool isAvailable) async {
    try {
      final response = await MenuService.updateProduct(
        productId: product.id,
        isAvailable: isAvailable,
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAvailable 
                  ? 'Producto "${product.name}" activado exitosamente'
                  : 'Producto "${product.name}" desactivado exitosamente'
              ),
              backgroundColor: isAvailable ? Colors.green : Colors.orange,
            ),
          );
          // Refrescar la lista
          await _loadMenuData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar disponibilidad: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Elimina un producto
  Future<void> _deleteProduct(MenuProduct product) async {
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
              Text('Eliminando producto...'),
            ],
          ),
        ),
      );

      final response = await MenuService.deleteProduct(product.id);

      // Cerrar el diálogo de carga
      if (mounted) Navigator.pop(context);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto "${product.name}" eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Refrescar la lista
          await _loadMenuData();
        }
      } else {
        if (mounted) {
          String errorMessage = response.message;
          
          // Manejo específico para productos en uso
          if (response.code == 'PRODUCT_IN_USE') {
            errorMessage = 'No se puede eliminar el producto porque está asociado a pedidos existentes.\n\nConsidera marcar el producto como no disponible en lugar de eliminarlo.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: response.code == 'PRODUCT_IN_USE' ? SnackBarAction(
                label: 'Desactivar ahora',
                textColor: Colors.white,
                onPressed: () async {
                  // Obtener el productId del campo details
                  final productIdFromError = response.details?['productId'];
                  
                  if (productIdFromError != null) {
                    // Buscar el producto en la lista actual usando el ID del error
                    try {
                      final productToDisable = _products.firstWhere(
                        (p) => p.id == productIdFromError,
                      );
                      
                      // Desactivar el producto usando nuestro método existente
                      await _toggleProductAvailability(productToDisable, false);
                      
                      // Mostrar mensaje de éxito
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Producto "${productToDisable.name}" desactivado exitosamente'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      // Si no se encuentra el producto en la lista, mostrar mensaje alternativo
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usa el switch de disponibilidad junto al producto para desactivarlo'),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  }
                },
              ) : null,
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
            content: Text('Error al eliminar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botón para añadir subcategoría
        FloatingActionButton(
          heroTag: 'add_subcategory',
          onPressed: _showAddSubcategoryModal,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.category),
          tooltip: 'Añadir Subcategoría',
        ),
        const SizedBox(height: 16),
        // Botón para añadir producto
        FloatingActionButton(
          heroTag: 'add_product',
          onPressed: () => _showAddProductModal(),
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add),
          tooltip: 'Añadir Producto',
        ),
      ],
    );
  }
}
