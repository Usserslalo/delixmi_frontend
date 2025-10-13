import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/menu/menu_models.dart';
import '../../models/api_response.dart';
import '../../services/menu_service.dart';

class EditProductForm extends StatefulWidget {
  final MenuProduct product;
  
  const EditProductForm({
    super.key,
    required this.product,
  });

  @override
  State<EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  bool _isLoadingData = false;
  bool _isSaving = false;
  
  List<Subcategory> _subcategories = [];
  List<ModifierGroup> _modifierGroups = [];
  
  int? _selectedSubcategoryId;
  Set<int> _selectedModifierGroupIds = {};
  
  // Valores originales para comparación
  late String _originalName;
  late String _originalDescription;
  late double _originalPrice;
  late int _originalSubcategoryId;
  late Set<int> _originalModifierGroupIds;

  @override
  void initState() {
    super.initState();
    
    // Pre-cargar valores actuales del producto
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description ?? ''
    );
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(2)
    );
    
    _selectedSubcategoryId = widget.product.subcategory?.id;
    
    // Pre-seleccionar grupos de modificadores actuales
    _selectedModifierGroupIds = widget.product.modifierGroups
        .map((g) => g.id)
        .toSet();
    
    // Guardar valores originales para comparación
    _originalName = widget.product.name;
    _originalDescription = widget.product.description ?? '';
    _originalPrice = widget.product.price;
    _originalSubcategoryId = widget.product.subcategory?.id ?? 0;
    _originalModifierGroupIds = Set<int>.from(_selectedModifierGroupIds);
    
    _loadFormData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Carga subcategorías y grupos de modificadores en paralelo
  Future<void> _loadFormData() async {
    setState(() => _isLoadingData = true);

    try {
      final results = await Future.wait([
        MenuService.getSubcategories(pageSize: 100),
        MenuService.getModifierGroups(),
      ]);

      final subcategoriesResponse = results[0] as ApiResponse<List<Subcategory>>;
      final modifierGroupsResponse = results[1] as ApiResponse<List<ModifierGroup>>;

      if (subcategoriesResponse.isSuccess && subcategoriesResponse.data != null) {
        setState(() {
          _subcategories = subcategoriesResponse.data!;
        });
      }

      if (modifierGroupsResponse.isSuccess && modifierGroupsResponse.data != null) {
        setState(() {
          _modifierGroups = modifierGroupsResponse.data!;
        });
      }

      if (!subcategoriesResponse.isSuccess || !modifierGroupsResponse.isSuccess) {
        if (mounted) {
          final errorMessage = !subcategoriesResponse.isSuccess 
              ? subcategoriesResponse.message 
              : modifierGroupsResponse.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  /// Verifica si hay cambios para actualizar
  bool _hasChanges() {
    return _nameController.text.trim() != _originalName ||
           _descriptionController.text.trim() != _originalDescription ||
           double.tryParse(_priceController.text.trim()) != _originalPrice ||
           _selectedSubcategoryId != _originalSubcategoryId ||
           !_setEquals(_selectedModifierGroupIds, _originalModifierGroupIds);
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.difference(b).isEmpty;
  }

  /// Actualiza el producto
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubcategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una subcategoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar si hay cambios
    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay cambios para guardar'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final price = double.tryParse(_priceController.text.trim());
      
      if (price == null || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El precio debe ser mayor a 0'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      // Construir body solo con campos que cambiaron
      final response = await MenuService.updateProduct(
        productId: widget.product.id,
        name: _nameController.text.trim() != _originalName 
            ? _nameController.text.trim() 
            : null,
        description: _descriptionController.text.trim() != _originalDescription 
            ? _descriptionController.text.trim() 
            : null,
        price: price != _originalPrice ? price : null,
        subcategoryId: _selectedSubcategoryId != _originalSubcategoryId 
            ? _selectedSubcategoryId 
            : null,
        modifierGroupIds: !_setEquals(_selectedModifierGroupIds, _originalModifierGroupIds)
            ? _selectedModifierGroupIds.toList()
            : null,
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          // Cerrar el modal y devolver true para indicar éxito
          Navigator.pop(context, true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto "${response.data!.name}" actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          String errorMessage = response.message;
          
          // Manejo específico de errores
          if (response.code == 'INVALID_MODIFIER_GROUPS') {
            errorMessage = 'Algunos grupos de modificadores no pertenecen a tu restaurante.\n\nVerifica los grupos seleccionados.';
          } else if (response.code == 'NO_FIELDS_TO_UPDATE') {
            errorMessage = 'No se proporcionaron cambios para actualizar.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editar Producto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Modifica la información de tu producto',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Contenido del formulario
            if (_isLoadingData)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_subcategories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar datos necesarios',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown de Subcategoría
                    DropdownButtonFormField<int>(
                      initialValue: _selectedSubcategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Subcategoría',
                        hintText: 'Selecciona una subcategoría',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _subcategories.map((subcategory) {
                        return DropdownMenuItem<int>(
                          value: subcategory.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(subcategory.name),
                              if (subcategory.category != null)
                                Text(
                                  subcategory.category!.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una subcategoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto',
                        hintText: 'Ej: Pizza Hawaiana',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.trim().length > 150) {
                          return 'El nombre debe tener máximo 150 caracteres';
                        }
                        return null;
                      },
                      maxLength: 150,
                    ),
                    const SizedBox(height: 16),

                    // Campo de Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        hintText: 'Describe tu producto...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      maxLength: 1000,
                      validator: (value) {
                        if (value != null && value.trim().length > 1000) {
                          return 'La descripción debe tener máximo 1000 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de Precio
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: '\$',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio es requerido';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'El precio debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sección de Personalizaciones (Grupos de Modificadores)
                    if (_modifierGroups.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.tune, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Personalizaciones',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecciona los grupos de modificadores que aplicarán a este producto',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Lista de checkboxes para grupos de modificadores
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _modifierGroups.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final group = _modifierGroups[index];
                            final isSelected = _selectedModifierGroupIds.contains(group.id);
                            
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedModifierGroupIds.add(group.id);
                                  } else {
                                    _selectedModifierGroupIds.remove(group.id);
                                  }
                                });
                              },
                              title: Text(
                                group.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${group.options.length} opcion${group.options.length != 1 ? 'es' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: group.isRequired 
                                              ? Colors.red[100] 
                                              : Colors.blue[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          group.isRequired ? 'Obligatorio' : 'Opcional',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: group.isRequired 
                                                ? Colors.red[800] 
                                                : Colors.blue[800],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          group.isMultipleSelection 
                                              ? 'Múltiple (${group.minSelection}-${group.maxSelection})' 
                                              : 'Única',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedModifierGroupIds.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue[800]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_selectedModifierGroupIds.length} grupo${_selectedModifierGroupIds.length != 1 ? 's' : ''} seleccionado${_selectedModifierGroupIds.length != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],

                    // Botón de Actualizar
                    ElevatedButton(
                      onPressed: _isSaving ? null : _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Actualizar Producto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

