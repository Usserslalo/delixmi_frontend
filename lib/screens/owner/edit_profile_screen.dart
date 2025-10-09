import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/owner/restaurant_profile.dart';
import '../../services/restaurant_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  bool _isUploadingLogo = false;
  bool _isUploadingCover = false;
  
  RestaurantProfile? _restaurantProfile;
  String? _newLogoUrl;
  String? _newCoverPhotoUrl;
  File? _selectedLogoFile;
  File? _selectedCoverFile;
  
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRestaurantProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          _newLogoUrl = response.data!.logoUrl;
          _newCoverPhotoUrl = response.data!.coverPhotoUrl;
        });
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
            content: Text('Error al cargar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// PASO A: Selecciona y sube el logo
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen es demasiado grande. Máximo 5 MB.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedLogoFile = imageFile;
      _isUploadingLogo = true;
    });

    try {
      // PASO A: Subir la imagen
      final uploadResponse = await RestaurantService.uploadLogo(imageFile);
      
      if (uploadResponse.isSuccess && uploadResponse.data != null) {
        setState(() {
          _newLogoUrl = uploadResponse.data!.logoUrl;
        });
        
        // PASO B: Actualizar el perfil con la nueva URL
        await _updateProfileImages(logoUrl: _newLogoUrl);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logo actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${uploadResponse.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingLogo = false);
    }
  }

  /// PASO A: Selecciona y sube la portada
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen es demasiado grande. Máximo 5 MB.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedCoverFile = imageFile;
      _isUploadingCover = true;
    });

    try {
      // PASO A: Subir la imagen
      final uploadResponse = await RestaurantService.uploadCover(imageFile);
      
      if (uploadResponse.isSuccess && uploadResponse.data != null) {
        setState(() {
          _newCoverPhotoUrl = uploadResponse.data!.coverPhotoUrl;
        });
        
        // PASO B: Actualizar el perfil con la nueva URL
        await _updateProfileImages(coverPhotoUrl: _newCoverPhotoUrl);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Portada actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${uploadResponse.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir portada: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingCover = false);
    }
  }

  /// PASO B: Actualiza el perfil con las nuevas URLs de imágenes
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
      final hasNameChanged = _nameController.text.trim() != _restaurantProfile?.name;
      final hasDescriptionChanged = _descriptionController.text.trim() != (_restaurantProfile?.description ?? '');

      if (!hasNameChanged && !hasDescriptionChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay cambios para guardar'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final response = await RestaurantService.updateProfile(
        name: hasNameChanged ? _nameController.text.trim() : null,
        description: hasDescriptionChanged ? _descriptionController.text.trim() : null,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _restaurantProfile = response.data;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Volver a la pantalla anterior
          Navigator.pop(context, true);
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
            content: Text('Error al guardar cambios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil del Restaurante'),
        elevation: 0,
      ),
      body: _isLoading && _restaurantProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Logo
                    _buildLogoSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Sección de Portada
                    _buildCoverSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Campo de Nombre
                    _buildNameField(),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de Descripción
                    _buildDescriptionField(),
                    
                    const SizedBox(height: 24),
                    
                    // Estadísticas (Read-only)
                    if (_restaurantProfile != null) _buildStatistics(),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de Guardar
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logo del Restaurante',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Stack(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedLogoFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedLogoFile!, fit: BoxFit.cover),
                      )
                    : _newLogoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _newLogoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.restaurant, size: 60, color: Colors.grey);
                              },
                            ),
                          )
                        : const Icon(Icons.restaurant, size: 60, color: Colors.grey),
              ),
              if (_isUploadingLogo)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: _isUploadingLogo ? null : _changeLogo,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cambiar Logo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Tamaño recomendado: 400x400 px (máx. 5 MB)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto de Portada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _selectedCoverFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedCoverFile!, fit: BoxFit.cover),
                    )
                  : _newCoverPhotoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _newCoverPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.photo, size: 60, color: Colors.grey);
                            },
                          ),
                        )
                      : const Icon(Icons.photo, size: 60, color: Colors.grey),
            ),
            if (_isUploadingCover)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: _isUploadingCover ? null : _changeCover,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cambiar Portada'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Tamaño recomendado: 1200x400 px (máx. 5 MB)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nombre del Restaurante',
        hintText: 'Ej: Pizzería de Ana',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.restaurant_menu),
      ),
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
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descripción',
        hintText: 'Describe tu restaurante...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      maxLength: 1000,
      validator: (value) {
        if (value != null && value.trim().length > 1000) {
          return 'La descripción debe tener máximo 1000 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildStatistics() {
    final stats = _restaurantProfile!.statistics;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.store,
                  'Sucursales',
                  stats.totalBranches.toString(),
                ),
                _buildStatItem(
                  Icons.category,
                  'Subcategorías',
                  stats.totalSubcategories.toString(),
                ),
                _buildStatItem(
                  Icons.fastfood,
                  'Productos',
                  stats.totalProducts.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Guardar Cambios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
