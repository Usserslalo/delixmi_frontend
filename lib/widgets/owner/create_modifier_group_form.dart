import 'package:flutter/material.dart';
import '../../services/menu_service.dart';

class CreateModifierGroupForm extends StatefulWidget {
  const CreateModifierGroupForm({super.key});

  @override
  State<CreateModifierGroupForm> createState() => _CreateModifierGroupFormState();
}

class _CreateModifierGroupFormState extends State<CreateModifierGroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  bool _isSaving = false;
  
  // Valores por defecto según la especificación
  int _minSelection = 1;
  int _maxSelection = 1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Guarda el nuevo grupo de modificadores
  Future<void> _saveModifierGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await MenuService.createModifierGroup(
        name: _nameController.text.trim(),
        minSelection: _minSelection,
        maxSelection: _maxSelection,
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          // Cerrar el modal y devolver true para indicar éxito
          Navigator.pop(context, true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Grupo "${response.data!.name}" creado exitosamente'),
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
            content: Text('Error al crear grupo: ${e.toString()}'),
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
                  Icons.tune,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nuevo Grupo de Modificadores',
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
              'Define las opciones de personalización para tus productos',
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
                      labelText: 'Nombre del Grupo',
                      hintText: 'Ej: Tamaño, Extras, Sin Ingredientes',
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

                  // Configuración de Selección
                  const Text(
                    'Configuración de Selección',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define si este grupo es obligatorio y cuántas opciones puede seleccionar el cliente',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selección Mínima
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _minSelection > 0 ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: _minSelection > 0 ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Selección Mínima',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¿Cuántas opciones debe seleccionar el cliente como mínimo?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _minSelection.toDouble(),
                                min: 0,
                                max: 10,
                                divisions: 10,
                                label: _minSelection.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _minSelection = value.round();
                                    // Asegurar que maxSelection sea >= minSelection
                                    if (_maxSelection < _minSelection) {
                                      _maxSelection = _minSelection;
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _minSelection > 0 ? Colors.green[100] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _minSelection.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _minSelection > 0 ? Colors.green[700] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _minSelection == 0 
                              ? 'Este grupo será OPCIONAL (el cliente puede omitirlo)'
                              : 'Este grupo será OBLIGATORIO (el cliente debe seleccionar al menos $_minSelection opción${_minSelection > 1 ? 'es' : ''})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _minSelection > 0 ? Colors.green[700] : Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selección Máxima
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _maxSelection == 1 ? Icons.radio_button_checked : Icons.checklist,
                              color: _maxSelection == 1 ? Colors.blue : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Selección Máxima',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¿Cuántas opciones puede seleccionar el cliente como máximo?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _maxSelection.toDouble(),
                                min: _minSelection.toDouble(),
                                max: 10,
                                divisions: 10 - _minSelection,
                                label: _maxSelection.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _maxSelection = value.round();
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _maxSelection == 1 ? Colors.blue[100] : Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _maxSelection.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _maxSelection == 1 ? Colors.blue[700] : Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _maxSelection == 1 
                              ? 'Selección ÚNICA (el cliente elegirá una sola opción)'
                              : 'Selección MÚLTIPLE (el cliente puede elegir hasta $_maxSelection opciones)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _maxSelection == 1 ? Colors.blue[700] : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resumen de Configuración
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
                              Icons.info_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resumen de Configuración',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Los clientes ${_minSelection == 0 ? 'podrán' : 'deberán'} seleccionar entre $_minSelection y $_maxSelection opciones de este grupo.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de Guardar
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveModifierGroup,
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
                              Text('Creando Grupo...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 8),
                              Text(
                                'Crear Grupo',
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
