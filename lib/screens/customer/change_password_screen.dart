import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Limpiar formulario
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          
          // Regresar a la pantalla anterior
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar la contraseña: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña actual es requerida';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La nueva contraseña es requerida';
    }
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    // Verificar requisitos de contraseña
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    
    if (!hasUppercase || !hasLowercase || !hasNumber || !hasSpecial) {
      return 'La contraseña debe contener al menos:\n• 1 letra mayúscula\n• 1 letra minúscula\n• 1 número\n• 1 carácter especial';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu nueva contraseña';
    }
    
    if (value != _newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  bool _getPasswordRequirement(String password, String requirement) {
    switch (requirement) {
      case 'length':
        return password.length >= 8;
      case 'uppercase':
        return RegExp(r'[A-Z]').hasMatch(password);
      case 'lowercase':
        return RegExp(r'[a-z]').hasMatch(password);
      case 'number':
        return RegExp(r'[0-9]').hasMatch(password);
      case 'special':
        return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              
              const SizedBox(height: 32),
              
              // Form Fields
              _buildFormFields(),
              
              const SizedBox(height: 24),
              
              // Password Requirements
              _buildPasswordRequirements(),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Colors.orange[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Cambiar tu contraseña',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por seguridad, ingresa tu contraseña actual y crea una nueva contraseña segura.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contraseña Actual
        _buildPasswordField(
          controller: _currentPasswordController,
          label: 'Contraseña actual',
          hint: 'Ingresa tu contraseña actual',
          validator: _validateCurrentPassword,
          isObscured: !_showCurrentPassword,
          onToggleVisibility: () {
            setState(() {
              _showCurrentPassword = !_showCurrentPassword;
            });
          },
        ),
        
        const SizedBox(height: 20),
        
        // Nueva Contraseña
        _buildPasswordField(
          controller: _newPasswordController,
          label: 'Nueva contraseña',
          hint: 'Ingresa tu nueva contraseña',
          validator: _validateNewPassword,
          isObscured: !_showNewPassword,
          onToggleVisibility: () {
            setState(() {
              _showNewPassword = !_showNewPassword;
            });
          },
          onChanged: (value) {
            // Actualizar la UI cuando cambie la contraseña
            setState(() {});
          },
        ),
        
        const SizedBox(height: 20),
        
        // Confirmar Nueva Contraseña
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirmar nueva contraseña',
          hint: 'Confirma tu nueva contraseña',
          validator: _validateConfirmPassword,
          isObscured: !_showConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _showConfirmPassword = !_showConfirmPassword;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isObscured,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _newPasswordController.text;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requisitos de la contraseña:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(
            'Mínimo 8 caracteres',
            _getPasswordRequirement(password, 'length'),
          ),
          _buildRequirementItem(
            '1 letra mayúscula',
            _getPasswordRequirement(password, 'uppercase'),
          ),
          _buildRequirementItem(
            '1 letra minúscula',
            _getPasswordRequirement(password, 'lowercase'),
          ),
          _buildRequirementItem(
            '1 número',
            _getPasswordRequirement(password, 'number'),
          ),
          _buildRequirementItem(
            '1 carácter especial',
            _getPasswordRequirement(password, 'special'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green[700] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Cambiar Contraseña',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
