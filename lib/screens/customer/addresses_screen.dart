import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectionMode ? 'Seleccionar Dirección' : 'Mis Direcciones'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (!widget.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToAddAddress(),
              tooltip: 'Agregar dirección',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar direcciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    addressProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => addressProvider.loadAddresses(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (addressProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes direcciones guardadas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega una dirección para recibir tus pedidos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToAddAddress(),
                    child: const Text('Agregar Primera Dirección'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Barra de búsqueda
              if (addressProvider.addresses.length > 3)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: addressProvider.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Buscar direcciones...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: addressProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                addressProvider.clearSearchQuery();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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

              // Botón de confirmar selección
              if (widget.isSelectionMode && addressProvider.selectedAddress != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _confirmSelection(addressProvider.selectedAddress!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirmar Dirección',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  void _navigateToAddAddress() {
    Navigator.of(context).pushNamed('/address-form');
  }

  void _navigateToEditAddress(Address address) {
    Navigator.of(context).pushNamed(
      '/address-form',
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
