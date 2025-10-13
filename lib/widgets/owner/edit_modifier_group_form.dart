import 'package:flutter/material.dart';
import '../../models/menu/menu_models.dart';
import '../../services/menu_service.dart';

class EditModifierGroupForm extends StatefulWidget {
  final ModifierGroup group;
  
  const EditModifierGroupForm({
    super.key,
    required this.group,
  });

  @override
  State<EditModifierGroupForm> createState() => _EditModifierGroupFormState();
}

class _EditModifierGroupFormState extends State<EditModifierGroupForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  
  bool _isSaving = false;
  
  late int _minSelection;
  late int _maxSelection;
  
  // Valores originales para comparación
  late String _originalName;
  late int _originalMinSelection;
  late int _originalMaxSelection;

  @override
  void initState() {
    super.initState();
    
    // Pre-cargar valores actuales
    _nameController = TextEditingController(text: widget.group.name);
    _minSelection = widget.group.minSelection;
    _maxSelection = widget.group.maxSelection;
    
    // Guardar valores originales
    _originalName = widget.group.name;
    _originalMinSelection = widget.group.minSelection;
    _originalMaxSelection = widget.group.maxSelection;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Verifica si hay cambios
  bool _hasChanges() {
    return _nameController.text.trim() != _originalName ||
           _minSelection != _originalMinSelection ||
           _maxSelection != _originalMaxSelection;
  }

  /// Actualiza el grupo de modificadores
  Future<void> _updateModifierGroup() async {
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
      final response = await MenuService.updateModifierGroup(
        groupId: widget.group.id,
        name: _nameController.text.trim() != _originalName 
            ? _nameController.text.trim() 
            : null,
        minSelection: _minSelection != _originalMinSelection 
            ? _minSelection 
            : null,
        maxSelection: _maxSelection != _originalMaxSelection 
            ? _maxSelection 
            : null,
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          // Cerrar el modal y devolver true para indicar éxito
          Navigator.pop(context, true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Grupo "${response.data!.name}" actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          String errorMessage = response.message;
          
          if (response.code == 'NO_FIELDS_TO_UPDATE') {
            errorMessage = 'No se proporcionaron cambios para actualizar.';
          } else if (response.code == 'INVALID_SELECTION_RANGE') {
            errorMessage = 'La selección mínima no puede ser mayor que la selección máxima.';
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
            content: Text('Error al actualizar grupo: ${e.toString()}'),
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
                        'Editar Grupo de Modificadores',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.group.name,
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
              'Modifica las opciones de personalización',
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

                  // Botón de Actualizar
                  ElevatedButton(
                    onPressed: _isSaving ? null : _updateModifierGroup,
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
                                'Actualizar Grupo',
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

