import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../services/geocoding_service.dart';
import 'location_picker_screen.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? address; // null para crear, no null para editar
  final ReverseGeocodeResult? prefilledData; // Datos pre-llenados del mapa

  const AddressFormScreen({
    super.key,
    this.address,
    this.prefilledData,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _referencesController = TextEditingController();
  final _streetController = TextEditingController();
  final _exteriorNumberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  bool _isLoading = false;
  ReverseGeocodeResult? _geocodeResult;
  String? _selectedAliasOption;
  bool _isCustomAlias = false;

  // Opciones predefinidas de alias
  final List<Map<String, dynamic>> _aliasOptions = [
    {'value': 'Casa', 'icon': Icons.home_rounded, 'label': 'Casa'},
    {'value': 'Trabajo', 'icon': Icons.work_rounded, 'label': 'Trabajo'},
    {'value': 'Oficina', 'icon': Icons.business_rounded, 'label': 'Oficina'},
    {'value': 'Escuela', 'icon': Icons.school_rounded, 'label': 'Escuela'},
    {'value': 'Gimnasio', 'icon': Icons.fitness_center_rounded, 'label': 'Gimnasio'},
    {'value': 'Otro', 'icon': Icons.edit_rounded, 'label': 'Otro'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _referencesController.dispose();
    _streetController.dispose();
    _exteriorNumberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.address != null) {
      // Modo edición: cargar datos de la dirección existente
      final address = widget.address!;
      
      // Verificar si el alias es una opción predefinida
      final aliasOption = _aliasOptions.firstWhere(
        (option) => option['value'] == address.alias,
        orElse: () => _aliasOptions.last, // "Otro"
      );
      
      if (aliasOption['value'] == 'Otro') {
        _selectedAliasOption = 'Otro';
        _isCustomAlias = true;
        _aliasController.text = address.alias;
      } else {
        _selectedAliasOption = address.alias;
        _isCustomAlias = false;
      }
      
      _referencesController.text = address.references ?? '';
      _streetController.text = address.street;
      _exteriorNumberController.text = address.exteriorNumber;
      _neighborhoodController.text = address.neighborhood;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _zipCodeController.text = address.zipCode;
      
      // Crear ReverseGeocodeResult desde la dirección existente
      _geocodeResult = ReverseGeocodeResult(
        street: address.street,
        exteriorNumber: address.exteriorNumber,
        neighborhood: address.neighborhood,
        city: address.city,
        state: address.state,
        zipCode: address.zipCode,
        formattedAddress: address.fullAddress,
        latitude: address.latitude,
        longitude: address.longitude,
        hasMinimumData: true,
      );
    } else if (widget.prefilledData != null) {
      // Modo creación con datos pre-llenados del mapa
      _geocodeResult = widget.prefilledData;
      _streetController.text = _geocodeResult!.street ?? '';
      _exteriorNumberController.text = _geocodeResult!.exteriorNumber ?? '';
      _neighborhoodController.text = _geocodeResult!.neighborhood ?? '';
      _cityController.text = _geocodeResult!.city ?? '';
      _stateController.text = _geocodeResult!.state ?? '';
      _zipCodeController.text = _geocodeResult!.zipCode ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.address == null ? 'Nueva Dirección' : 'Editar Dirección',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
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
              _buildSectionHeader('Información Básica', Icons.edit_note),
              const SizedBox(height: 16),
              
              // Dropdown de Alias con Material 3
              _buildAliasDropdown(theme, colorScheme),
              
              // Campo personalizado si selecciona "Otro"
              if (_isCustomAlias) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _aliasController,
                  label: 'Nombre personalizado *',
                  hint: 'Ej: Casa de mis padres, Apartamento...',
                  prefixIcon: Icons.edit_rounded,
                  validator: _validateAlias,
                  maxLength: 50,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Ubicación detectada (editable)
              _buildSectionHeader('Ubicación del Mapa (Editable)', Icons.location_on),
              const SizedBox(height: 8),
              Text(
                'Verifica y ajusta los datos si son incorrectos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              if (_geocodeResult != null)
                _buildEditableLocationFields(theme, colorScheme)
              else
                _buildNoLocationCard(theme, colorScheme),
              
              const SizedBox(height: 24),
              
              // Referencias
              _buildSectionHeader('Referencias (Opcional)', Icons.notes),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _referencesController,
                label: 'Referencias',
                hint: 'Ej: Casa azul con portón negro, frente al parque...',
                prefixIcon: Icons.description,
                maxLines: 3,
                maxLength: 500,
              ),
              
              const SizedBox(height: 32),
              
              // Botones de acción con Material 3
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      child: Text(
                        'Cancelar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2843A),
                        foregroundColor: const Color(0xFFFFFFFF),
                        disabledBackgroundColor: const Color(0xFFF2843A).withValues(alpha: 0.5),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Guardando...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  widget.address == null ? 'Guardar Dirección' : 'Actualizar',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildAliasDropdown(ThemeData theme, ColorScheme colorScheme) {
    const primaryOrange = Color(0xFFF2843A);
    const darkGray = Color(0xFF1A1A1A);
    const white = Color(0xFFFFFFFF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de dirección *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _aliasOptions.map((option) {
            final isSelected = _selectedAliasOption == option['value'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedAliasOption = option['value'];
                  _isCustomAlias = option['value'] == 'Otro';
                  if (!_isCustomAlias) {
                    _aliasController.clear();
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryOrange : white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryOrange : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option['icon'],
                      size: 20,
                      color: isSelected ? white : darkGray,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option['label'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? white : darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    const primaryOrange = Color(0xFFF2843A);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: primaryOrange,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableLocationFields(ThemeData theme, ColorScheme colorScheme) {
    const primaryOrange = Color(0xFFF2843A);

    return Column(
      children: [
        _buildTextField(
          controller: _streetController,
          label: 'Calle',
          hint: 'Nombre de la calle',
          prefixIcon: Icons.straighten,
          maxLength: 255,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _exteriorNumberController,
          label: 'Número Exterior',
          hint: 'Ej: 123, S/N',
          prefixIcon: Icons.numbers,
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _neighborhoodController,
          label: 'Colonia',
          hint: 'Nombre de la colonia',
          prefixIcon: Icons.location_city,
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
                maxLength: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'Estado',
                hint: 'Estado',
                prefixIcon: Icons.map,
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
          keyboardType: TextInputType.number,
          maxLength: 5,
        ),
        const SizedBox(height: 16),
        // Botón para cambiar ubicación
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _selectLocationOnMap,
            icon: const Icon(Icons.edit_location_alt, size: 18),
            label: const Text('Cambiar Ubicación en el Mapa'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: primaryOrange, width: 1.5),
              foregroundColor: primaryOrange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoLocationCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange[300]!,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Sin ubicación',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona tu ubicación en el mapa para continuar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectLocationOnMap,
              icon: const Icon(Icons.map, size: 20),
              label: const Text('Seleccionar en el Mapa'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
    const primaryOrange = Color(0xFFF2843A);
    const lightGray = Color(0xFFF5F5F5);

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
        prefixIcon: Icon(prefixIcon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: lightGray,
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

  Future<void> _selectLocationOnMap() async {
    final result = await Navigator.of(context).push<ReverseGeocodeResult>(
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLatitude: _geocodeResult?.latitude,
          initialLongitude: _geocodeResult?.longitude,
          prefilledData: _geocodeResult,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _geocodeResult = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación actualizada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado un alias
    if (_selectedAliasOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un tipo de dirección'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Si es "Otro", validar que haya escrito un alias personalizado
    if (_isCustomAlias && _aliasController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe un nombre para tu dirección'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_geocodeResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una ubicación en el mapa'),
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
      
      // Determinar el alias final
      final finalAlias = _isCustomAlias 
          ? _aliasController.text.trim() 
          : _selectedAliasOption!;

      bool success;

      if (widget.address == null) {
        // Crear nueva dirección con valores editables
        success = await addressProvider.createAddress(
          alias: finalAlias,
          street: _streetController.text.trim().isEmpty ? 'Sin calle' : _streetController.text.trim(),
          exteriorNumber: _exteriorNumberController.text.trim().isEmpty ? 'S/N' : _exteriorNumberController.text.trim(),
          interiorNumber: null,
          neighborhood: _neighborhoodController.text.trim().isEmpty ? 'Sin colonia' : _neighborhoodController.text.trim(),
          city: _cityController.text.trim().isEmpty ? 'Sin ciudad' : _cityController.text.trim(),
          state: _stateController.text.trim().isEmpty ? 'Sin estado' : _stateController.text.trim(),
          zipCode: _zipCodeController.text.trim().isEmpty ? '00000' : _zipCodeController.text.trim(),
          references: _referencesController.text.trim().isEmpty 
              ? null 
              : _referencesController.text.trim(),
          latitude: _geocodeResult!.latitude,
          longitude: _geocodeResult!.longitude,
        );
      } else {
        // Actualizar dirección existente con valores editables
        success = await addressProvider.updateAddress(
          addressId: widget.address!.id,
          alias: finalAlias,
          street: _streetController.text.trim().isEmpty ? 'Sin calle' : _streetController.text.trim(),
          exteriorNumber: _exteriorNumberController.text.trim().isEmpty ? 'S/N' : _exteriorNumberController.text.trim(),
          interiorNumber: null,
          neighborhood: _neighborhoodController.text.trim().isEmpty ? 'Sin colonia' : _neighborhoodController.text.trim(),
          city: _cityController.text.trim().isEmpty ? 'Sin ciudad' : _cityController.text.trim(),
          state: _stateController.text.trim().isEmpty ? 'Sin estado' : _stateController.text.trim(),
          zipCode: _zipCodeController.text.trim().isEmpty ? '00000' : _zipCodeController.text.trim(),
          references: _referencesController.text.trim().isEmpty 
              ? null 
              : _referencesController.text.trim(),
          latitude: _geocodeResult!.latitude,
          longitude: _geocodeResult!.longitude,
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
          Navigator.of(context).pop(true); // Retornar true para indicar éxito
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

