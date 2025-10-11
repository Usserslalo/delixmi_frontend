import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/menu_service.dart';

class AddModifierOptionForm extends StatefulWidget {
  final int groupId;
  
  const AddModifierOptionForm({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<AddModifierOptionForm> createState() => _AddModifierOptionFormState();
}

class _AddModifierOptionFormState extends State<AddModifierOptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Establecer precio por defecto en 0
    _priceController.text = '0.00';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Guarda la nueva opción de modificador
  Future<void> _saveModifierOption() async {
    if (!_formKey.currentState!.validate()) {
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

      final response = await MenuService.addModifierOption(
        groupId: widget.groupId,
        name: _nameController.text.trim(),
        price: price,
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          // Cerrar el modal y devolver true para indicar éxito
          Navigator.pop(context, true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opción "${response.data!.name}" añadida exitosamente'),
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
            content: Text('Error al añadir opción: ${e.toString()}'),
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
                  Icons.add_circle_outline,
                  color: Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nueva Opción',
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
              'Añade una nueva opción de personalización',
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

                  // Ejemplos de opciones
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ejemplos de Opciones',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildExampleOption('Grande (12 pulgadas)', '45.00'),
                        _buildExampleOption('Extra Queso', '15.00'),
                        _buildExampleOption('Sin Cebolla', '0.00'),
                        _buildExampleOption('Mediana (10 pulgadas)', '25.00'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de Guardar
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveModifierOption,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                              Text('Añadiendo Opción...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text(
                                'Añadir Opción',
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

  Widget _buildExampleOption(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
              ),
            ),
          ),
          Text(
            '\$${price}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
