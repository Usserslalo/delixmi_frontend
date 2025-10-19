import 'package:flutter/material.dart';
import '../../models/menu/menu_models.dart';
import '../../services/menu_service.dart';

class EditSubcategoryForm extends StatefulWidget {
  final Subcategory subcategory;
  
  const EditSubcategoryForm({
    super.key,
    required this.subcategory,
  });

  @override
  State<EditSubcategoryForm> createState() => _EditSubcategoryFormState();
}

class _EditSubcategoryFormState extends State<EditSubcategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  
  bool _isLoadingCategories = false;
  bool _isSaving = false;
  List<Category> _categories = [];
  int? _selectedCategoryId;
  
  // Valores originales para comparación
  late String _originalName;
  late int _originalCategoryId;

  @override
  void initState() {
    super.initState();
    
    // Pre-cargar valores actuales
    _nameController = TextEditingController(text: widget.subcategory.name);
    _selectedCategoryId = widget.subcategory.category?.id;
    
    // Guardar valores originales
    _originalName = widget.subcategory.name;
    _originalCategoryId = widget.subcategory.category?.id ?? 0;
    
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Carga las categorías globales disponibles
  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final response = await MenuService.getCategories();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _categories = response.data!;
        });
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
            content: Text('Error al cargar categorías: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  /// Verifica si hay cambios
  bool _hasChanges() {
    return _nameController.text.trim() != _originalName ||
           _selectedCategoryId != _originalCategoryId;
  }

  /// Actualiza la subcategoría
  Future<void> _updateSubcategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
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
      final response = await MenuService.updateSubcategory(
        subcategoryId: widget.subcategory.id,
        name: _nameController.text.trim() != _originalName 
            ? _nameController.text.trim() 
            : null,
        categoryId: _selectedCategoryId != _originalCategoryId 
            ? _selectedCategoryId 
            : null,
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          // Cerrar el modal y devolver true para indicar éxito
          Navigator.pop(context, true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subcategoría "${response.data!.name}" actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          // Manejo específico de errores según códigos del backend
          String errorMessage = response.message;
          Color errorColor = Colors.red;
          IconData errorIcon = Icons.error;
          
          switch (response.code) {
            case 'SUBCATEGORY_NOT_FOUND':
              errorMessage = 'La subcategoría que intentas editar no fue encontrada.';
              errorColor = Colors.red;
              errorIcon = Icons.search_off;
              break;
            case 'FORBIDDEN':
              errorMessage = 'No tienes permisos para editar esta subcategoría.';
              errorColor = Colors.red;
              errorIcon = Icons.block;
              break;
            case 'CATEGORY_NOT_FOUND':
              errorMessage = 'La categoría seleccionada no fue encontrada. Por favor, selecciona otra.';
              errorColor = Colors.orange;
              errorIcon = Icons.category_outlined;
              break;
            case 'DUPLICATE_SUBCATEGORY':
              errorMessage = 'Ya existe una subcategoría con ese nombre en esta categoría.';
              errorColor = Colors.orange;
              errorIcon = Icons.warning;
              break;
            case 'NO_FIELDS_TO_UPDATE':
              errorMessage = 'No hay cambios para actualizar.';
              errorColor = Colors.blue;
              errorIcon = Icons.info;
              break;
            case 'VALIDATION_ERROR':
              if (response.errors != null && response.errors!.isNotEmpty) {
                // Mostrar el primer error de validación específico
                final firstError = response.errors!.first;
                errorMessage = firstError['message'] ?? response.message;
              }
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
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar subcategoría: ${e.toString()}'),
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
                        'Editar Subcategoría',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.subcategory.name,
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
              'Modifica el nombre o categoría de tu subcategoría',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Formulario
            if (_isLoadingCategories)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_categories.isEmpty)
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
                      'No se pudieron cargar las categorías',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _loadCategories,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
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
                    // Dropdown de Categoría Principal
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría Principal',
                        hintText: 'Selecciona una categoría',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de Nombre de Subcategoría
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Subcategoría',
                        hintText: 'Ej: Pizzas Tradicionales',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.trim().length > 100) {
                          return 'El nombre debe tener máximo 100 caracteres';
                        }
                        return null;
                      },
                      maxLength: 100,
                    ),
                    const SizedBox(height: 24),

                    // Información sobre displayOrder
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'El orden de visualización de las subcategorías se puede gestionar próximamente con drag & drop',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de Actualizar
                    ElevatedButton(
                      onPressed: _isSaving ? null : _updateSubcategory,
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
                              'Actualizar Subcategoría',
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

