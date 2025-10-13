import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/menu/menu_models.dart';
import '../../services/menu_service.dart';

class EditModifierOptionForm extends StatefulWidget {
  final ModifierOption option;
  
  const EditModifierOptionForm({
    super.key,
    required this.option,
  });

  @override
  State<EditModifierOptionForm> createState() => _EditModifierOptionFormState();
}

class _EditModifierOptionFormState extends State<EditModifierOptionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  
  bool _isSaving = false;
  
  // Valores originales para comparación
  late String _originalName;
  late double _originalPrice;

  @override
  void initState() {
    super.initState();
    
    // Pre-cargar valores actuales
    _nameController = TextEditingController(text: widget.option.name);
    _priceController = TextEditingController(
      text: widget.option.price.toStringAsFixed(2)
    );
    
    // Guardar valores originales
    _originalName = widget.option.name;
    _originalPrice = widget.option.price;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Verifica si hay cambios
  bool _hasChanges() {
    final currentPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    return _nameController.text.trim() != _originalName ||
           currentPrice != _originalPrice;
  }

  /// Actualiza la opción de modificador
  Future<void> _updateModifierOption() async {
    if (!_formKey.currentState!.validate()) {
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
      
      if (price == null || price < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El precio debe ser mayor o igual a 0'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      final response = await MenuService.updateModifierOption(
        optionId: widget.option.id,
        name: _nameController.text.trim() != _originalName 
            ? _nameController.text.trim() 
            : null,
        price: price != _originalPrice ? price : null,
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          // Cerrar el modal y devolver true para indicar éxito
          Navigator.pop(context, true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opción "${response.data!.name}" actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          String errorMessage = response.message;
          
          if (response.code == 'NO_FIELDS_TO_UPDATE') {
            errorMessage = 'No se proporcionaron cambios para actualizar.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar opción: ${e.toString()}'),
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
                        'Editar Opción',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.option.name,
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
              'Modifica el nombre o precio de la opción',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Formulario
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo de Nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Opción',
                      hintText: 'Ej: Grande, Extra Queso, Sin Cebolla',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
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
                  const SizedBox(height: 16),

                  // Campo de Precio
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Adicional',
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
                      if (price == null) {
                        return 'Ingresa un precio válido';
                      }
                      if (price < 0) {
                        return 'El precio no puede ser negativo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Información sobre el precio
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Este precio se sumará al precio base del producto cuando el cliente seleccione esta opción.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de Actualizar
                  ElevatedButton(
                    onPressed: _isSaving ? null : _updateModifierOption,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Actualizando...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 8),
                              Text(
                                'Actualizar Opción',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

