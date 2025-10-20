import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/api_response.dart';
import '../../models/owner/employee_models.dart';
import '../../services/employee_service.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  const AddEditEmployeeScreen({super.key});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;
  bool _isInitialized = false;
  
  // Mode detection
  String _mode = 'create';
  Employee? _employee;
  
  // Form state
  int? _selectedRoleId;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Don't access context-dependent widgets in initState
    // Initialize what we can here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize screen after dependencies are available
    _initializeScreen();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _initializeScreen() {
    // Only initialize once to avoid multiple calls
    if (_isInitialized) return;
    _isInitialized = true;
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _mode = args['mode'] as String? ?? 'create';
      if (_mode == 'edit' && args['employee'] != null) {
        _employee = args['employee'] as Employee;
        _populateForm();
      }
    }
    // _mode defaults to 'create' if no args provided
    
    // Trigger rebuild after initialization
    if (mounted) {
      setState(() {});
    }
  }

  void _populateForm() {
    if (_employee != null) {
      _nameController.text = _employee!.name;
      _lastnameController.text = _employee!.lastname;
      _emailController.text = _employee!.email;
      _phoneController.text = _employee!.phone;
      _selectedStatus = _employee!.status;
      _selectedRoleId = _employee!.role?.id;
      
      // Trigger rebuild to update UI with populated data
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      ApiResponse<Map<String, dynamic>> response;

      if (_mode == 'create') {
        response = await EmployeeService.createEmployee(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          phone: _phoneController.text.trim(),
          roleId: _selectedRoleId!,
        );
      } else {
        // Edit mode - check if we have changes and assignmentId
        if (_selectedRoleId == null && _selectedStatus == null) {
          setState(() {
            _errorMessage = 'Debe cambiar al menos el rol o el estado del empleado.';
            _isSaving = false;
          });
          return;
        }

        if (_employee?.assignmentId == null) {
          setState(() {
            _errorMessage = 'Error: No se puede actualizar el empleado. Falta información de asignación.';
            _isSaving = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Error: No se puede actualizar el empleado. Falta información de asignación.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Check if there are actual changes
        bool hasChanges = false;
        if (_selectedRoleId != null && _employee?.role?.id != _selectedRoleId) {
          hasChanges = true;
        }
        if (_selectedStatus != null && _employee?.status != _selectedStatus) {
          hasChanges = true;
        }

        if (!hasChanges) {
          setState(() {
            _errorMessage = 'No hay cambios para actualizar.';
            _isSaving = false;
          });
          return;
        }

        response = await EmployeeService.updateEmployee(
          assignmentId: _employee!.assignmentId!,
          roleId: _selectedRoleId != _employee?.role?.id ? _selectedRoleId : null,
          status: _selectedStatus != _employee?.status ? _selectedStatus : null,
        );
      }

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mode == 'create' 
                  ? 'Empleado creado exitosamente' 
                  : 'Empleado actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  void _handleError(ApiResponse<Map<String, dynamic>> response) {
    String errorMessage = response.message;
    Color errorColor = Colors.red;
    IconData errorIcon = Icons.error;

    // Handle specific error codes based on the documentation
    switch (response.code) {
      case 'VALIDATION_ERROR':
        if (response.details is List) {
          final details = response.details as List;
          errorMessage = details.map((detail) => detail['message']).join('\n');
        }
        errorColor = Colors.orange;
        errorIcon = Icons.warning;
        break;
      case 'INVALID_EMPLOYEE_ROLE':
        errorMessage = 'Rol no válido para empleados. Selecciona un rol válido.';
        break;
      case 'INVALID_ROLE_ID':
        errorMessage = 'Rol no encontrado. Verifica que el rol sea correcto.';
        break;
      case 'EMAIL_ALREADY_EXISTS':
        errorMessage = 'El email ya está registrado. Usa un email diferente.';
        break;
      case 'PHONE_ALREADY_EXISTS':
        errorMessage = 'El teléfono ya está registrado. Usa un teléfono diferente.';
        break;
      case 'INSUFFICIENT_PERMISSIONS':
        errorMessage = 'No tienes permisos para realizar esta acción.';
        break;
      case 'RESTAURANT_LOCATION_REQUIRED':
        errorMessage = 'Debes configurar la ubicación del restaurante primero.';
        break;
      case 'USER_NOT_FOUND':
        errorMessage = 'Usuario no encontrado.';
        break;
      case 'ASSIGNMENT_NOT_FOUND':
        errorMessage = 'Asignación de empleado no encontrada.';
        break;
      case 'FORBIDDEN_ACCESS':
        errorMessage = 'No tienes permisos para actualizar este empleado.';
        break;
      case 'OWNER_NOT_FOUND':
        errorMessage = 'Usuario owner no encontrado.';
        break;
      case 'NO_RESTAURANT_ASSIGNED':
        errorMessage = 'No tienes un restaurante asignado para actualizar empleados.';
        break;
      case 'NOT_FOUND':
        errorMessage = 'Error: recurso no encontrado.';
        break;
      case 'INTERNAL_ERROR':
        errorMessage = 'Error interno del servidor.';
        break;
    }

    setState(() {
      _errorMessage = errorMessage;
      _isSaving = false;
    });

    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: Text(_mode == 'create' ? 'Agregar Empleado' : 'Editar Empleado'),
        backgroundColor: const Color(0xFFF2843A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Name and Lastname
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFF2843A)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              if (value.trim().length > 100) {
                                return 'El nombre no puede superar los 100 caracteres';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastnameController,
                            decoration: InputDecoration(
                              labelText: 'Apellido*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFF2843A)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El apellido es requerido';
                              }
                              if (value.trim().length > 100) {
                                return 'El apellido no puede superar los 100 caracteres';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF2843A)),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El email es requerido';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                          return 'El email debe tener un formato válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF2843A)),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es requerido';
                        }
                        if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value.trim())) {
                          return 'El teléfono debe tener entre 10 y 15 dígitos numéricos';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Password (only for create mode)
                    if (_mode == 'create')
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña*',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFF2843A)),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          helperText: 'Mínimo 8 caracteres',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es requerida';
                          }
                          if (value.length < 8) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                          }
                          if (value.length > 255) {
                            return 'La contraseña es demasiado larga';
                          }
                          return null;
                        },
                      ),
                    if (_mode == 'create') const SizedBox(height: 16),
                    
                    // Role selection
                    DropdownButtonFormField<int>(
                      value: _selectedRoleId,
                      decoration: InputDecoration(
                        labelText: 'Rol*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF2843A)),
                        ),
                        prefixIcon: const Icon(Icons.work),
                      ),
                      items: ValidEmployeeRoles.roleList.map((role) {
                        return DropdownMenuItem<int>(
                          value: role.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                role.displayName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (role.description != null)
                                Text(
                                  role.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Debe seleccionar un rol';
                        }
                        if (!ValidEmployeeRoles.isValidRoleId(value)) {
                          return 'Debe seleccionar un rol válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Status selection (only for edit mode)
                    if (_mode == 'edit') ...[
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFF2843A)),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Activo'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactivo'),
                          ),
                          DropdownMenuItem(
                            value: 'suspended',
                            child: Text('Suspendido'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Save button
                    FilledButton(
                      onPressed: _isSaving ? null : _saveEmployee,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF2843A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _mode == 'create' ? 'Crear Empleado' : 'Actualizar Empleado',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
