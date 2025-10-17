import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../services/onboarding_service.dart';

class AddressProvider extends ChangeNotifier {
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isEmpty => _addresses.isEmpty;
  bool get isNotEmpty => _addresses.isNotEmpty;

  /// Direcciones filtradas por búsqueda
  List<Address> get filteredAddresses {
    if (_searchQuery.isEmpty) return _addresses;
    
    final lowercaseQuery = _searchQuery.toLowerCase();
    return _addresses.where((address) {
      return address.alias.toLowerCase().contains(lowercaseQuery) ||
             address.street.toLowerCase().contains(lowercaseQuery) ||
             address.neighborhood.toLowerCase().contains(lowercaseQuery) ||
             address.city.toLowerCase().contains(lowercaseQuery) ||
             address.state.toLowerCase().contains(lowercaseQuery) ||
             address.zipCode.contains(_searchQuery);
    }).toList();
  }

  /// Cargar todas las direcciones del usuario
  Future<void> loadAddresses() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('📍 AddressProvider: Cargando direcciones...');
      final response = await AddressService.getAddresses();

      if (response.isSuccess && response.data != null) {
        _addresses = response.data!
            .map((addressJson) => Address.fromJson(addressJson))
            .toList();
        debugPrint('📍 AddressProvider: Direcciones cargadas - ${_addresses.length} direcciones');
        
        // Establecer la primera dirección como seleccionada si no hay ninguna seleccionada
        if (_selectedAddress == null && _addresses.isNotEmpty) {
          _selectedAddress = _addresses.first;
          debugPrint('📍 AddressProvider: Primera dirección establecida como seleccionada: ${_selectedAddress!.alias}');
        }
      } else {
        _setError(response.message);
        debugPrint('❌ AddressProvider: Error al cargar direcciones: ${response.message}');
      }
    } catch (e) {
      _setError('Error al cargar direcciones: $e');
      debugPrint('❌ AddressProvider: Excepción al cargar direcciones: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear una nueva dirección
  Future<bool> createAddress({
    required String alias,
    required String street,
    required String exteriorNumber,
    String? interiorNumber,
    required String neighborhood,
    required String city,
    required String state,
    required String zipCode,
    String? references,
    required double latitude,
    required double longitude,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('📍 AddressProvider: Creando dirección $alias...');
      final response = await AddressService.createAddress(
        alias: alias,
        street: street,
        exteriorNumber: exteriorNumber,
        interiorNumber: interiorNumber,
        neighborhood: neighborhood,
        city: city,
        state: state,
        zipCode: zipCode,
        references: references,
        latitude: latitude,
        longitude: longitude,
      );

      if (response.isSuccess && response.data != null) {
        // Manejar diferentes formatos de respuesta del backend
        Map<String, dynamic> addressData;
        if (response.data!.containsKey('data') && response.data!['data'] is Map<String, dynamic>) {
          addressData = response.data!['data'] as Map<String, dynamic>;
        } else if (response.data!.containsKey('address') && response.data!['address'] is Map<String, dynamic>) {
          addressData = response.data!['address'] as Map<String, dynamic>;
        } else {
          addressData = response.data!;
        }
        
        final newAddress = Address.fromJson(addressData);
        _addresses.add(newAddress);
        
        // Actualizar el estado del onboarding cuando se agrega la primera dirección
        if (_addresses.length == 1) {
          await OnboardingService.instance.markAddressAdded();
          debugPrint('🎉 AddressProvider: Primera dirección agregada - Onboarding marcado como completado');
        }
        
        debugPrint('✅ AddressProvider: Dirección creada exitosamente');
        return true;
      } else {
        _setError(response.message);
        debugPrint('❌ AddressProvider: Error al crear dirección: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al crear dirección: $e');
      debugPrint('❌ AddressProvider: Excepción al crear dirección: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar una dirección existente
  Future<bool> updateAddress({
    required int addressId,
    required String alias,
    required String street,
    required String exteriorNumber,
    String? interiorNumber,
    required String neighborhood,
    required String city,
    required String state,
    required String zipCode,
    String? references,
    required double latitude,
    required double longitude,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('📍 AddressProvider: Actualizando dirección $addressId...');
      final response = await AddressService.updateAddress(
        addressId: addressId,
        alias: alias,
        street: street,
        exteriorNumber: exteriorNumber,
        interiorNumber: interiorNumber,
        neighborhood: neighborhood,
        city: city,
        state: state,
        zipCode: zipCode,
        references: references,
        latitude: latitude,
        longitude: longitude,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('📍 AddressProvider: Respuesta de actualización exitosa');
        debugPrint('📍 AddressProvider: Datos recibidos: ${response.data}');
        
        // Manejar diferentes formatos de respuesta del backend
        Map<String, dynamic> addressData;
        if (response.data!.containsKey('data') && response.data!['data'] is Map<String, dynamic>) {
          addressData = response.data!['data'] as Map<String, dynamic>;
          debugPrint('📍 AddressProvider: Usando datos anidados en "data"');
        } else if (response.data!.containsKey('address') && response.data!['address'] is Map<String, dynamic>) {
          addressData = response.data!['address'] as Map<String, dynamic>;
          debugPrint('📍 AddressProvider: Usando datos anidados en "address"');
        } else {
          addressData = response.data!;
          debugPrint('📍 AddressProvider: Usando datos en nivel raíz');
        }
        
        final updatedAddress = Address.fromJson(addressData);
        debugPrint('📍 AddressProvider: Dirección parseada - ID: ${updatedAddress.id}, Alias: ${updatedAddress.alias}');
        debugPrint('📍 AddressProvider: Dirección parseada - Street: ${updatedAddress.street}, City: ${updatedAddress.city}');
        
        final index = _addresses.indexWhere((addr) => addr.id == addressId);
        if (index != -1) {
          _addresses[index] = updatedAddress;
          // Actualizar dirección seleccionada si es la misma
          if (_selectedAddress?.id == addressId) {
            _selectedAddress = updatedAddress;
          }
          debugPrint('✅ AddressProvider: Dirección actualizada en la lista - Índice: $index');
        } else {
          debugPrint('⚠️ AddressProvider: No se encontró la dirección con ID $addressId en la lista');
        }
        debugPrint('✅ AddressProvider: Dirección actualizada exitosamente');
        return true;
      } else {
        _setError(response.message);
        debugPrint('❌ AddressProvider: Error al actualizar dirección: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar dirección: $e');
      debugPrint('❌ AddressProvider: Excepción al actualizar dirección: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar una dirección
  Future<bool> deleteAddress({
    required int addressId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('📍 AddressProvider: Eliminando dirección $addressId...');
      final response = await AddressService.deleteAddress(addressId: addressId);

      if (response.isSuccess) {
        _addresses.removeWhere((addr) => addr.id == addressId);
        // Limpiar dirección seleccionada si es la eliminada
        if (_selectedAddress?.id == addressId) {
          _selectedAddress = null;
        }
        debugPrint('✅ AddressProvider: Dirección eliminada exitosamente');
        return true;
      } else {
        _setError(response.message);
        debugPrint('❌ AddressProvider: Error al eliminar dirección: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar dirección: $e');
      debugPrint('❌ AddressProvider: Excepción al eliminar dirección: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Seleccionar una dirección
  void selectAddress(Address address) {
    _selectedAddress = address;
    _safeNotifyListeners();
    debugPrint('📍 AddressProvider: Dirección seleccionada: ${address.alias}');
  }

  /// Limpiar dirección seleccionada
  void clearSelectedAddress() {
    _selectedAddress = null;
    _safeNotifyListeners();
    debugPrint('📍 AddressProvider: Dirección seleccionada limpiada');
  }

  /// Actualizar consulta de búsqueda
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _safeNotifyListeners();
  }

  /// Limpiar consulta de búsqueda
  void clearSearchQuery() {
    _searchQuery = '';
    _safeNotifyListeners();
  }

  /// Obtener dirección por ID
  Address? getAddressById(int id) {
    try {
      return _addresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verificar si una dirección existe
  bool hasAddress(int id) {
    return _addresses.any((address) => address.id == id);
  }

  /// Obtener la primera dirección disponible
  Address? get firstAddress {
    return _addresses.isNotEmpty ? _addresses.first : null;
  }

  /// Obtener la dirección de entrega actual (seleccionada o primera disponible)
  Address? get currentDeliveryAddress {
    return _selectedAddress ?? (_addresses.isNotEmpty ? _addresses.first : null);
  }

  /// Obtener el texto de dirección de entrega para mostrar en la UI
  String get deliveryAddressText {
    final address = currentDeliveryAddress;
    if (address == null) {
      return 'Selecciona una dirección';
    }
    return address.alias.isNotEmpty ? address.alias : address.street;
  }

  /// Obtener dirección por alias
  Address? getAddressByAlias(String alias) {
    try {
      return _addresses.firstWhere((address) => address.alias == alias);
    } catch (e) {
      return null;
    }
  }

  /// Validar si hay direcciones válidas
  bool get hasValidAddresses {
    return _addresses.any((address) => address.isValid);
  }

  /// Obtener direcciones válidas
  List<Address> get validAddresses {
    return _addresses.where((address) => address.isValid).toList();
  }

  /// Obtener direcciones por ciudad
  List<Address> getAddressesByCity(String city) {
    return _addresses.where((address) => address.city == city).toList();
  }

  /// Obtener direcciones por estado
  List<Address> getAddressesByState(String state) {
    return _addresses.where((address) => address.state == state).toList();
  }

  /// Obtener direcciones por código postal
  List<Address> getAddressesByZipCode(String zipCode) {
    return _addresses.where((address) => address.zipCode == zipCode).toList();
  }

  /// Calcular distancia desde una dirección a coordenadas específicas
  double calculateDistanceFromAddress({
    required Address address,
    required double latitude,
    required double longitude,
  }) {
    return AddressService.calculateDistance(
      lat1: address.latitude,
      lng1: address.longitude,
      lat2: latitude,
      lng2: longitude,
    );
  }

  /// Obtener la dirección más cercana a coordenadas específicas
  Address? getNearestAddress({
    required double latitude,
    required double longitude,
  }) {
    if (_addresses.isEmpty) return null;

    Address? nearestAddress;
    double minDistance = double.infinity;

    for (final address in _addresses) {
      final distance = calculateDistanceFromAddress(
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestAddress = address;
      }
    }

    return nearestAddress;
  }

  /// Validar zona de cobertura para una dirección
  Future<bool> validateCoverageArea(Address address) async {
    try {
      return await AddressService.validateCoverageArea(
        latitude: address.latitude,
        longitude: address.longitude,
      );
    } catch (e) {
      // Log error without using debugPrint in production
      debugPrint('❌ Error al validar zona de cobertura: $e');
      return false;
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  /// Notificar cambios de manera segura, evitando llamadas durante el build
  void _safeNotifyListeners() {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Limpiar estado del provider
  void clear() {
    _addresses = [];
    _selectedAddress = null;
    _errorMessage = null;
    _searchQuery = '';
    _isLoading = false;
    _safeNotifyListeners();
  }
}
