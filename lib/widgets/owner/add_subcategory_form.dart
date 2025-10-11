import 'package:flutter/material.dart';
import '../../models/menu/menu_models.dart';
import '../../services/menu_service.dart';

class AddSubcategoryForm extends StatefulWidget {
  const AddSubcategoryForm({Key? key}) : super(key: key);

  @override
  State<AddSubcategoryForm> createState() => _AddSubcategoryFormState();
}

class _AddSubcategoryFormState extends State<AddSubcategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  bool _isLoadingCategories = false;
  bool _isSaving = false;
  List<Category> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
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
          // Pre-seleccionar la primera categoría si existe
          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
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

  /// Guarda la nueva subcategoría
  Future<void> _saveSubcategory() async {
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

    setState(() => _isSaving = true);

    try {
      final response = await MenuService.createSubcategory(
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        displayOrder: 0,
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          // Cerrar el modal y devolver true para indicar éxito
          Navigator.pop(context, true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subcategoría "${response.data!.name}" creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
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
            content: Text('Error al crear subcategoría: $e'),
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
                  Icons.category,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nueva Subcategoría',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
              'Organiza tu menú creando subcategorías',
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
                      value: _selectedCategoryId,
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

                    // Botón de Guardar
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveSubcategory,
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
                              'Guardar Subcategoría',
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
