import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../services/address_service.dart';
import 'location_picker_screen.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? address; // null para crear, no null para editar

  const AddressFormScreen({
    super.key,
    this.address,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _streetController = TextEditingController();
  final _exteriorNumberController = TextEditingController();
  final _interiorNumberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _referencesController = TextEditingController();

  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _streetController.dispose();
    _exteriorNumberController.dispose();
    _interiorNumberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.address != null) {
      final address = widget.address!;
      _aliasController.text = address.alias;
      _streetController.text = address.street;
      _exteriorNumberController.text = address.exteriorNumber;
      _interiorNumberController.text = address.interiorNumber ?? '';
      _neighborhoodController.text = address.neighborhood;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _zipCodeController.text = address.zipCode;
      _referencesController.text = address.references ?? '';
      _latitude = address.latitude;
      _longitude = address.longitude;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Nueva Dirección' : 'Editar Dirección'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información básica
              _buildSectionHeader('Información Básica'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _aliasController,
                label: 'Alias',
                hint: 'Ej: Casa, Oficina, etc.',
                prefixIcon: Icons.label_outline,
                validator: _validateAlias,
                maxLength: 50,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _streetController,
                label: 'Calle',
                hint: 'Nombre de la calle',
                prefixIcon: Icons.straighten,
                validator: _validateStreet,
                maxLength: 255,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _exteriorNumberController,
                      label: 'Número Exterior',
                      hint: '123',
                      prefixIcon: Icons.numbers,
                      validator: _validateExteriorNumber,
                      maxLength: 50,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _interiorNumberController,
                      label: 'Número Interior (Opcional)',
                      hint: 'A, B, 1, etc.',
                      prefixIcon: Icons.home,
                      maxLength: 50,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Ubicación
              _buildSectionHeader('Ubicación'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _neighborhoodController,
                label: 'Colonia',
                hint: 'Nombre de la colonia',
                prefixIcon: Icons.location_city,
                validator: _validateNeighborhood,
                maxLength: 150,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'Ciudad',
                      hint: 'Ciudad',
                      prefixIcon: Icons.location_city,
                      validator: _validateCity,
                      maxLength: 100,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: 'Estado',
                      hint: 'Estado',
                      prefixIcon: Icons.map,
                      validator: _validateState,
                      maxLength: 100,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _zipCodeController,
                label: 'Código Postal',
                hint: '12345',
                prefixIcon: Icons.local_post_office,
                validator: _validateZipCode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                onChanged: _onZipCodeChanged,
              ),
              
              const SizedBox(height: 24),
              
              // Selección de ubicación con mapa
              _buildSectionHeader('Ubicación en el Mapa'),
              const SizedBox(height: 16),
              
              // Contenedor moderno para la selección de ubicación
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _latitude != null && _longitude != null 
                        ? Colors.green[300]! 
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header con icono y estado
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _latitude != null && _longitude != null 
                            ? Colors.green[50] 
                            : Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _latitude != null && _longitude != null 
                                  ? Colors.green[100] 
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _latitude != null && _longitude != null 
                                  ? Icons.location_on 
                                  : Icons.location_off,
                              color: _latitude != null && _longitude != null 
                                  ? Colors.green[600] 
                                  : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _latitude != null && _longitude != null 
                                      ? 'Ubicación confirmada' 
                                      : 'Selecciona tu ubicación',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _latitude != null && _longitude != null 
                                        ? Colors.green[700] 
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _latitude != null && _longitude != null 
                                      ? 'Tu ubicación ha sido verificada en el mapa' 
                                      : 'Toca el botón para seleccionar en el mapa',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Botón de acción
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _selectLocationOnMap,
                          icon: Icon(
                            _latitude != null && _longitude != null 
                                ? Icons.edit_location_alt 
                                : Icons.map_outlined,
                            size: 20,
                          ),
                          label: Text(
                            _latitude != null && _longitude != null 
                                ? 'Cambiar ubicación' 
                                : 'Seleccionar en el mapa',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _latitude != null && _longitude != null 
                                ? Colors.blue[600] 
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Referencias
              _buildSectionHeader('Referencias (Opcional)'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _referencesController,
                label: 'Referencias',
                hint: 'Ej: Frente al parque, casa azul, etc.',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
                maxLength: 500,
              ),
              
              const SizedBox(height: 32),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(widget.address == null ? 'Crear Dirección' : 'Actualizar Dirección'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }


  // Validadores
  String? _validateAlias(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El alias es requerido';
    }
    if (value.length > 50) {
      return 'El alias no puede tener más de 50 caracteres';
    }
    return null;
  }

  String? _validateStreet(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La calle es requerida';
    }
    if (value.length > 255) {
      return 'La calle no puede tener más de 255 caracteres';
    }
    return null;
  }

  String? _validateExteriorNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número exterior es requerido';
    }
    if (value.length > 50) {
      return 'El número exterior no puede tener más de 50 caracteres';
    }
    return null;
  }

  String? _validateNeighborhood(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La colonia es requerida';
    }
    if (value.length > 150) {
      return 'La colonia no puede tener más de 150 caracteres';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La ciudad es requerida';
    }
    if (value.length > 100) {
      return 'La ciudad no puede tener más de 100 caracteres';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El estado es requerido';
    }
    if (value.length > 100) {
      return 'El estado no puede tener más de 100 caracteres';
    }
    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El código postal es requerido';
    }
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      return 'El código postal debe tener 5 dígitos';
    }
    return null;
  }

  void _onZipCodeChanged(String value) {
    if (value.length == 5) {
      _getCoordinatesFromZipCode(value);
    }
  }

  Future<void> _getCoordinatesFromZipCode(String zipCode) async {
    try {
      final coordinates = await AddressService.getCoordinatesFromZipCode(zipCode: zipCode);
      if (coordinates != null) {
        setState(() {
          _latitude = coordinates['latitude'];
          _longitude = coordinates['longitude'];
        });
      }
    } catch (e) {
      debugPrint('Error al obtener coordenadas del código postal: $e');
    }
  }

  Future<void> _selectLocationOnMap() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
          initialAddress: _getFormattedAddress(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'] as double;
        _longitude = result['longitude'] as double;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación seleccionada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _getFormattedAddress() {
    final parts = <String>[];
    
    if (_streetController.text.isNotEmpty) {
      parts.add(_streetController.text.trim());
    }
    
    if (_exteriorNumberController.text.isNotEmpty) {
      parts.add(_exteriorNumberController.text.trim());
    }
    
    if (_neighborhoodController.text.isNotEmpty) {
      parts.add(_neighborhoodController.text.trim());
    }
    
    if (_cityController.text.isNotEmpty) {
      parts.add(_cityController.text.trim());
    }
    
    if (_stateController.text.isNotEmpty) {
      parts.add(_stateController.text.trim());
    }

    return parts.join(', ');
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, obtén las coordenadas GPS de la ubicación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final addressProvider = context.read<AddressProvider>();
      bool success;

      if (widget.address == null) {
        // Crear nueva dirección
        success = await addressProvider.createAddress(
          alias: _aliasController.text.trim(),
          street: _streetController.text.trim(),
          exteriorNumber: _exteriorNumberController.text.trim(),
          interiorNumber: _interiorNumberController.text.trim().isEmpty 
              ? null 
              : _interiorNumberController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          references: _referencesController.text.trim().isEmpty 
              ? null 
              : _referencesController.text.trim(),
          latitude: _latitude!,
          longitude: _longitude!,
        );
      } else {
        // Actualizar dirección existente
        success = await addressProvider.updateAddress(
          addressId: widget.address!.id,
          alias: _aliasController.text.trim(),
          street: _streetController.text.trim(),
          exteriorNumber: _exteriorNumberController.text.trim(),
          interiorNumber: _interiorNumberController.text.trim().isEmpty 
              ? null 
              : _interiorNumberController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          references: _referencesController.text.trim().isEmpty 
              ? null 
              : _referencesController.text.trim(),
          latitude: _latitude!,
          longitude: _longitude!,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.address == null 
                  ? 'Dirección creada exitosamente' 
                  : 'Dirección actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${addressProvider.errorMessage ?? 'No se pudo guardar la dirección'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar dirección: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

