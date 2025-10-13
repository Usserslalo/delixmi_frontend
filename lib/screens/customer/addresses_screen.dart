import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../widgets/customer/address_card.dart';

class AddressesScreen extends StatefulWidget {
  final bool isSelectionMode;
  final Address? selectedAddress;

  const AddressesScreen({
    super.key,
    this.isSelectionMode = false,
    this.selectedAddress,
  });

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar direcciones al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryOrange = Color(0xFFF2843A);
    const darkGray = Color(0xFF1A1A1A);
    const white = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        title: Text(
          widget.isSelectionMode ? 'Seleccionar Dirección' : 'Mis Direcciones',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: darkGray,
          ),
        ),
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!widget.isSelectionMode)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.add_rounded, color: primaryOrange, size: 28),
                onPressed: () => _navigateToAddAddress(),
                tooltip: 'Agregar dirección',
              ),
            ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          if (addressProvider.isLoading && addressProvider.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (addressProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error al cargar direcciones',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      addressProvider.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => addressProvider.loadAddresses(),
                        icon: const Icon(Icons.refresh_rounded, size: 22),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (addressProvider.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 64,
                        color: primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes direcciones guardadas',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Agrega una dirección para recibir tus pedidos y ver restaurantes disponibles',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToAddAddress(),
                        icon: const Icon(Icons.add_location_rounded, size: 22),
                        label: const Text('Agregar Primera Dirección'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Barra de búsqueda con Material 3
              if (addressProvider.addresses.length > 3)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: addressProvider.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Buscar direcciones...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF757575),
                      ),
                      suffixIcon: addressProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                addressProvider.clearSearchQuery();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryOrange, width: 2),
                      ),
                      filled: true,
                      fillColor: white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

              // Lista de direcciones
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => addressProvider.loadAddresses(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: addressProvider.filteredAddresses.length,
                    itemBuilder: (context, index) {
                      final address = addressProvider.filteredAddresses[index];
                      final isSelected = widget.isSelectionMode &&
                          addressProvider.selectedAddress?.id == address.id;

                      return AddressCard(
                        address: address,
                        isSelected: isSelected,
                        isSelectionMode: widget.isSelectionMode,
                        onTap: widget.isSelectionMode
                            ? () => _selectAddress(address)
                            : () => _selectAndReturnToHome(address),
                        onEdit: widget.isSelectionMode
                            ? null
                            : () => _navigateToEditAddress(address),
                        onDelete: widget.isSelectionMode
                            ? null
                            : () => _showDeleteDialog(address),
                      );
                    },
                  ),
                ),
              ),

              // Botón de confirmar selección con Material 3
              if (widget.isSelectionMode && addressProvider.selectedAddress != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: white,
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmSelection(addressProvider.selectedAddress!),
                        icon: const Icon(Icons.check_circle_rounded, size: 22),
                        label: const Text('Confirmar Dirección'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToAddAddress() async {
    // Nuevo flujo: primero mapa, luego formulario
    final geocodeResult = await Navigator.of(context).pushNamed(AppRoutes.locationPicker);
    
    if (geocodeResult != null && mounted) {
      // Navegar al formulario con los datos pre-llenados
      final success = await Navigator.of(context).pushNamed(
        AppRoutes.addressForm,
        arguments: geocodeResult,
      );
      
      // Si se guardó exitosamente, recargar direcciones
      if (success == true && mounted) {
        context.read<AddressProvider>().loadAddresses();
      }
    }
  }

  void _navigateToEditAddress(Address address) {
    Navigator.of(context).pushNamed(
      AppRoutes.addressForm,
      arguments: address,
    );
  }

  void _selectAddress(Address address) {
    context.read<AddressProvider>().selectAddress(address);
  }

  void _selectAndReturnToHome(Address address) {
    // Seleccionar la dirección en el provider
    context.read<AddressProvider>().selectAddress(address);
    
    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dirección de entrega cambiada a "${address.alias}"'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Regresar a la pantalla anterior (HomeScreen)
    Navigator.of(context).pop();
  }

  void _confirmSelection(Address address) {
    Navigator.of(context).pop(address);
  }

  void _showDeleteDialog(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dirección'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la dirección "${address.alias}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAddress(address);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress(Address address) async {
    final addressProvider = context.read<AddressProvider>();
    final success = await addressProvider.deleteAddress(addressId: address.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dirección "${address.alias}" eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${addressProvider.errorMessage ?? 'No se pudo eliminar la dirección'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
