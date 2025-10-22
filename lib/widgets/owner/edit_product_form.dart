import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  bool _modifierGroupsInitialized = false; // Control para evitar sobreescribir la selección
  
  // Variables para manejo de imagen
  File? _selectedImage;
  String? _uploadedImageUrl;
  String? _currentImageUrl; // URL actual del producto
  bool _isUploadingImage = false;
  
  // Valores originales para comparación
  late String _originalName;
  late String _originalDescription;
  late double _originalPrice;
  late int _originalSubcategoryId;
  late Set<int> _originalModifierGroupIds;
  late String? _originalImageUrl;

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
    // NOTA: El endpoint GET ahora incluye modifierGroups correctamente
    _selectedModifierGroupIds = widget.product.modifierGroups
        .map((g) => g.id)
        .toSet();
    _modifierGroupsInitialized = true; // Ya siempre inicializados desde el producto
    
    debugPrint('🔍 EditProductForm: Modificadores del producto inicializados:');
    debugPrint('🔍 Product modifierGroups: ${widget.product.modifierGroups.map((g) => '${g.id}:${g.name}').toList()}');
    debugPrint('🔍 Selected modifier group IDs: $_selectedModifierGroupIds');
    debugPrint('🔍 ModifierGroups initialized: $_modifierGroupsInitialized');
    
    // Inicializar imagen actual
    _currentImageUrl = widget.product.imageUrl;
    
    // Guardar valores originales para comparación
    _originalName = widget.product.name;
    _originalDescription = widget.product.description ?? '';
    _originalPrice = widget.product.price;
    _originalSubcategoryId = widget.product.subcategory?.id ?? 0;
    _originalModifierGroupIds = Set<int>.from(_selectedModifierGroupIds);
    _originalImageUrl = widget.product.imageUrl;
    
    _loadFormData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // NOTA: Ya no necesitamos _loadCompleteProduct() porque el backend
  // ahora incluye modifierGroups en el endpoint GET /api/restaurant/products

  /// Carga subcategorías y grupos de modificadores
  /// NOTA: Los modifierGroups del producto ya vienen incluidos desde el endpoint GET actualizado
  Future<void> _loadFormData() async {
    setState(() => _isLoadingData = true);

    try {
      // Cargar datos básicos (ya no necesitamos llamada adicional para modifierGroups)
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
        // Mantener la selección inicializada desde el producto (endpoint GET ya incluye modifierGroups)
        final currentSelectedIds = Set<int>.from(_selectedModifierGroupIds);
        
        setState(() {
          _modifierGroups = modifierGroupsResponse.data!;
          // Asegurar que la selección se mantenga después de cargar los grupos
          _selectedModifierGroupIds = currentSelectedIds;
        });
        
        debugPrint('🔍 EditProductForm: Modificadores cargados del servidor (manteniendo selección):');
        debugPrint('🔍 Available modifier groups: ${_modifierGroups.map((g) => '${g.id}:${g.name}').toList()}');
        debugPrint('🔍 Currently selected modifier group IDs: $_selectedModifierGroupIds');
        
        // Validar que todos los IDs seleccionados existen en la lista cargada
        final availableIds = _modifierGroups.map((g) => g.id).toSet();
        final invalidIds = _selectedModifierGroupIds.difference(availableIds);
        if (invalidIds.isNotEmpty) {
          debugPrint('⚠️ EditProductForm: Algunos IDs seleccionados no existen en la lista cargada: $invalidIds');
          // Remover IDs que no existen
          setState(() {
            _selectedModifierGroupIds.removeAll(invalidIds);
          });
        }
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
           !_setEquals(_selectedModifierGroupIds, _originalModifierGroupIds) ||
           _getCurrentImageUrl() != _originalImageUrl;
  }
  
  /// Obtiene la URL actual de la imagen (ya sea la nueva subida o la existente)
  String? _getCurrentImageUrl() {
    if (_uploadedImageUrl != null) {
      return _uploadedImageUrl;
    }
    return _currentImageUrl;
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.difference(b).isEmpty;
  }

  /// Selecciona imagen del producto
  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Mostrar opciones de selección
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
            // No resetear _uploadedImageUrl aquí para mantener la imagen actual
          });
          
          // Subir imagen automáticamente
          await _uploadImage();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Sube la imagen seleccionada al servidor
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final response = await MenuService.uploadProductImage(_selectedImage!);
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _uploadedImageUrl = response.data!.imageUrl;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Imagen subida exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
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
            case 'NO_FILE_PROVIDED':
              errorMessage = 'No se seleccionó ningún archivo';
              break;
            case 'FILE_TOO_LARGE':
              errorMessage = 'El archivo es demasiado grande. El tamaño máximo permitido es 5MB';
              errorColor = Colors.orange;
              errorIcon = Icons.info;
              break;
            case 'INVALID_FILE_TYPE':
              errorMessage = 'Solo se permiten archivos JPG, JPEG y PNG';
              errorColor = Colors.orange;
              errorIcon = Icons.info;
              break;
            case 'TOO_MANY_FILES':
              errorMessage = 'Solo se permite subir un archivo a la vez';
              break;
            case 'UNAUTHORIZED':
              errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente';
              errorColor = Colors.red;
              errorIcon = Icons.lock;
              break;
            case 'FORBIDDEN':
              errorMessage = 'No tienes permisos para subir imágenes';
              errorColor = Colors.red;
              errorIcon = Icons.block;
              break;
            case 'FILE_INTEGRITY_ERROR':
              errorMessage = 'Error al procesar el archivo. El archivo no pudo ser guardado correctamente en el servidor. Por favor, intenta subir el archivo nuevamente.';
              errorColor = Colors.orange;
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
              backgroundColor: errorColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        // Reset image selection on upload failure
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _selectedImage = null;
      });
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  /// Remueve la imagen seleccionada o actual
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
      _currentImageUrl = null;
    });
  }

  /// Construye el widget de imagen
  Widget _buildImageWidget() {
    // Si hay imagen seleccionada (nueva)
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay para mostrar estado de subida
          if (_isUploadingImage)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Subiendo...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Indicador de éxito
          if (_uploadedImageUrl != null && !_isUploadingImage)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          // Botón para eliminar
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isUploadingImage ? null : _removeImage,
              ),
            ),
          ),
        ],
      );
    }
    
    // Si hay imagen actual (del producto existente)
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _currentImageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar imagen',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Botón para eliminar imagen actual
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _removeImage,
              ),
            ),
          ),
          // Indicador de imagen actual
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Actual',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // Estado sin imagen
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Toca para seleccionar imagen',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          Text(
            'JPG, PNG (máx. 5MB)',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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

    // Validar que si hay imagen seleccionada, esté subida
    if (_selectedImage != null && _uploadedImageUrl == null && !_isUploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Espera a que termine de subirse la imagen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isUploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Espera a que termine de subirse la imagen'),
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
      final currentImageUrl = _getCurrentImageUrl();
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
        imageUrl: currentImageUrl != _originalImageUrl ? currentImageUrl : null,
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
          // Manejo específico de errores según códigos del backend
          String errorMessage = response.message;
          Color errorColor = Colors.red;
          IconData errorIcon = Icons.error;
          
          switch (response.code) {
            case 'PRODUCT_NOT_FOUND':
              errorMessage = 'El producto que intentas editar no fue encontrado.';
              errorColor = Colors.red;
              errorIcon = Icons.search_off;
              break;
            case 'FORBIDDEN':
              errorMessage = 'No tienes permisos para editar este producto.';
              errorColor = Colors.red;
              errorIcon = Icons.block;
              break;
            case 'SUBCATEGORY_NOT_FOUND':
              errorMessage = 'La subcategoría seleccionada no fue encontrada. Por favor, selecciona otra.';
              errorColor = Colors.orange;
              errorIcon = Icons.category_outlined;
              break;
            case 'INVALID_SUBCATEGORY':
              errorMessage = 'La subcategoría debe pertenecer al mismo restaurante del producto.';
              errorColor = Colors.orange;
              errorIcon = Icons.warning;
              break;
            case 'INVALID_MODIFIER_GROUPS':
              errorMessage = 'Algunos grupos de modificadores no pertenecen a tu restaurante. Verifica los grupos seleccionados.';
              errorColor = Colors.orange;
              errorIcon = Icons.tune;
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Padding adicional para evitar overflow
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
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
                              Text(
                                subcategory.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subcategory.category != null)
                                Text(
                                  subcategory.category!.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
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

                    // Sección de Imagen del Producto
                    const Text(
                      'Imagen del Producto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cambia la imagen actual de tu producto (opcional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Widget de selección de imagen
                    InkWell(
                      onTap: _selectedImage == null && !_isUploadingImage ? _selectImage : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _uploadedImageUrl != null || _currentImageUrl != null
                                ? Colors.green[300]! 
                                : Colors.grey[300]!,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildImageWidget(),
                      ),
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

