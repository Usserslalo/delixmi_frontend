import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/owner/restaurant_profile.dart';
import '../../services/restaurant_service.dart';
import '../../theme.dart';

class ModernEditProfileScreen extends StatefulWidget {
  const ModernEditProfileScreen({super.key});

  @override
  State<ModernEditProfileScreen> createState() => _ModernEditProfileScreenState();
}

class _ModernEditProfileScreenState extends State<ModernEditProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  bool _isUploadingLogo = false;
  bool _isUploadingCover = false;
  bool _hasChanges = false;
  
  RestaurantProfile? _restaurantProfile;
  String? _newLogoUrl;
  String? _newCoverPhotoUrl;
  File? _selectedLogoFile;
  File? _selectedCoverFile;
  
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Usar colores del tema principal de la app
  static const Color primaryOrange = AppTheme.primaryColor;
  static const Color surfaceColor = AppTheme.backgroundLight;
  static const Color onSurfaceColor = AppTheme.textLight;
  static const Color surfaceVariantColor = AppTheme.inputLight;
  static const Color outlineColor = AppTheme.textMutedLight;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _loadRestaurantProfile();
    
    // Listener para detectar cambios
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _hasActualChanges();
    });
  }

  bool _hasActualChanges() {
    if (_restaurantProfile == null) return false;
    
    return _nameController.text.trim() != _restaurantProfile!.name ||
           _descriptionController.text.trim() != (_restaurantProfile!.description ?? '') ||
           _phoneController.text.trim() != (_restaurantProfile!.phone ?? '') ||
           _emailController.text.trim() != (_restaurantProfile!.email ?? '') ||
           _addressController.text.trim() != (_restaurantProfile!.address ?? '') ||
           _selectedLogoFile != null ||
           _selectedCoverFile != null;
  }

  /// Carga el perfil actual del restaurante
  Future<void> _loadRestaurantProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await RestaurantService.getProfile();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _restaurantProfile = response.data;
          _nameController.text = response.data!.name;
          _descriptionController.text = response.data!.description ?? '';
          _phoneController.text = response.data!.phone ?? '';
          _emailController.text = response.data!.email ?? '';
          _addressController.text = response.data!.address ?? '';
          _newLogoUrl = response.data!.logoUrl;
          _newCoverPhotoUrl = response.data!.coverPhotoUrl;
        });
        
        _animationController.forward();
      } else {
        _showErrorSnackBar('Error: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar el perfil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Selecciona y sube el logo
  Future<void> _changeLogo() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);
    
    // Verificar tamaño del archivo (máximo 5 MB)
    final fileSize = await imageFile.length();
    if (fileSize > 5 * 1024 * 1024) {
      _showErrorSnackBar('La imagen es demasiado grande. Máximo 5 MB.');
      return;
    }

    setState(() {
      _selectedLogoFile = imageFile;
      _isUploadingLogo = true;
      _hasChanges = true;
    });

    try {
      // Subir la imagen
      final uploadResponse = await RestaurantService.uploadLogo(imageFile);
      
      if (uploadResponse.isSuccess && uploadResponse.data != null) {
        setState(() {
          _newLogoUrl = uploadResponse.data!.logoUrl;
        });
        
        // Actualizar el perfil con la nueva URL
        await _updateProfileImages(logoUrl: _newLogoUrl);
        
        _showSuccessSnackBar('Logo actualizado exitosamente');
      } else {
        _showErrorSnackBar('Error: ${uploadResponse.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error al subir logo: $e');
    } finally {
      setState(() => _isUploadingLogo = false);
    }
  }

  /// Selecciona y sube la portada
  Future<void> _changeCover() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 400,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);
    
    // Verificar tamaño del archivo (máximo 5 MB)
    final fileSize = await imageFile.length();
    if (fileSize > 5 * 1024 * 1024) {
      _showErrorSnackBar('La imagen es demasiado grande. Máximo 5 MB.');
      return;
    }

    setState(() {
      _selectedCoverFile = imageFile;
      _isUploadingCover = true;
      _hasChanges = true;
    });

    try {
      // Subir la imagen
      final uploadResponse = await RestaurantService.uploadCover(imageFile);
      
      if (uploadResponse.isSuccess && uploadResponse.data != null) {
        setState(() {
          _newCoverPhotoUrl = uploadResponse.data!.coverPhotoUrl;
        });
        
        // Actualizar el perfil con la nueva URL
        await _updateProfileImages(coverPhotoUrl: _newCoverPhotoUrl);
        
        _showSuccessSnackBar('Portada actualizada exitosamente');
      } else {
        _showErrorSnackBar('Error: ${uploadResponse.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error al subir portada: $e');
    } finally {
      setState(() => _isUploadingCover = false);
    }
  }

  /// Actualiza el perfil con las nuevas URLs de imágenes
  Future<void> _updateProfileImages({String? logoUrl, String? coverPhotoUrl}) async {
    try {
      final response = await RestaurantService.updateProfile(
        logoUrl: logoUrl,
        coverPhotoUrl: coverPhotoUrl,
      );
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _restaurantProfile = response.data;
        });
      }
    } catch (e) {
      debugPrint('Error al actualizar URLs de imágenes: $e');
    }
  }

  /// Guarda los cambios en nombre y descripción
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verificar si hay cambios
      if (!_hasActualChanges()) {
        _showInfoSnackBar('No hay cambios para guardar');
        setState(() => _isLoading = false);
        return;
      }

      final response = await RestaurantService.updateProfile(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _restaurantProfile = response.data;
          _selectedLogoFile = null;
          _selectedCoverFile = null;
          _hasChanges = false;
        });

        _showSuccessSnackBar('Perfil actualizado exitosamente');
        
        // Volver a la pantalla anterior después de un breve delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        _showErrorSnackBar('Error: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error al guardar cambios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildModernAppBar(context),
      body: _isLoading && _restaurantProfile == null
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: _buildModernBody(context),
            ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, size: 24),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Volver',
      ),
      title: const Text(
        'Configurar Perfil',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        if (_hasChanges)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryOrange,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeaderSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildImagesSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildFormSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildStatisticsSection(context),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100), // Espacio para el botón flotante
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryOrange,
            primaryOrange.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personaliza tu restaurante',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _restaurantProfile?.name ?? 'Cargando...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imágenes del Restaurante',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Logo Section
          _buildImageCard(
            title: 'Logo del Restaurante',
            subtitle: 'Tamaño recomendado: 400x400px',
            imageUrl: _newLogoUrl,
            selectedFile: _selectedLogoFile,
            isUploading: _isUploadingLogo,
            onTap: _changeLogo,
            aspectRatio: 1.0,
            icon: Icons.restaurant_rounded,
          ),
          
          const SizedBox(height: 16),
          
          // Cover Section
          _buildImageCard(
            title: 'Foto de Portada',
            subtitle: 'Tamaño recomendado: 1200x400px',
            imageUrl: _newCoverPhotoUrl,
            selectedFile: _selectedCoverFile,
            isUploading: _isUploadingCover,
            onTap: _changeCover,
            aspectRatio: 3.0,
            icon: Icons.photo_library_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required String title,
    required String subtitle,
    required String? imageUrl,
    required File? selectedFile,
    required bool isUploading,
    required VoidCallback onTap,
    required double aspectRatio,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: outlineColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: outlineColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Image Preview
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: surfaceVariantColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: outlineColor.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Image or placeholder
                    if (selectedFile != null)
                      Image.file(selectedFile, fit: BoxFit.cover)
                    else if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder(icon);
                        },
                      )
                    else
                      _buildImagePlaceholder(icon),
                    
                    // Upload overlay
                    if (isUploading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Upload button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : onTap,
                icon: Icon(
                  isUploading ? Icons.upload_rounded : Icons.camera_alt_rounded, 
                  size: 18,
                ),
                label: Text(
                  isUploading ? 'Subiendo...' : 'Cambiar Imagen',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(IconData icon) {
    return Container(
      color: surfaceVariantColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: outlineColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: outlineColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: outlineColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Información del Restaurante',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personaliza los detalles de tu restaurante',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: outlineColor,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Nombre del restaurante
                _buildCleanTextField(
                  controller: _nameController,
                  label: 'Nombre del Restaurante',
                  hint: 'Ej: Restaurante El Buen Sabor',
                  isRequired: true,
                  maxLength: 150,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.trim().length > 150) {
                      return 'El nombre debe tener máximo 150 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Descripción
                _buildCleanTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describe tu restaurante, especialidades, ambiente...',
                  maxLines: 4,
                  maxLength: 1000,
                  validator: (value) {
                    if (value != null && value.trim().length > 1000) {
                      return 'La descripción debe tener máximo 1000 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Teléfono
                _buildCleanTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  hint: '555-1234',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 10 || value.trim().length > 20) {
                        return 'El teléfono debe tener entre 10 y 20 caracteres';
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Email
                _buildCleanTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'correo@ejemplo.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Ingresa un email válido';
                      }
                      if (value.trim().length > 150) {
                        return 'El email debe tener máximo 150 caracteres';
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Dirección
                _buildCleanTextField(
                  controller: _addressController,
                  label: 'Dirección',
                  hint: 'Calle, número, colonia, ciudad...',
                  maxLines: 2,
                  maxLength: 500,
                  validator: (value) {
                    if (value != null && value.trim().length > 500) {
                      return 'La dirección debe tener máximo 500 caracteres';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label con asterisco si es requerido
        Text(
          isRequired ? '$label *' : label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        
        // Campo de texto usando el tema de la app
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          validator: validator,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: onSurfaceColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: surfaceVariantColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: outlineColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: outlineColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: primaryOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 16,
            ),
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: outlineColor.withValues(alpha: 0.7),
            ),
            counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: outlineColor,
            ),
            errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    if (_restaurantProfile == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas del Restaurante',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: outlineColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.store_rounded,
                    label: 'Sucursales',
                    value: _restaurantProfile!.statistics.totalBranches.toString(),
                    color: Colors.blue,
                  ),
                  _buildStatItem(
                    icon: Icons.category_rounded,
                    label: 'Categorías',
                    value: _restaurantProfile!.statistics.totalSubcategories.toString(),
                    color: Colors.green,
                  ),
                  _buildStatItem(
                    icon: Icons.fastfood_rounded,
                    label: 'Productos',
                    value: _restaurantProfile!.statistics.totalProducts.toString(),
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: outlineColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
