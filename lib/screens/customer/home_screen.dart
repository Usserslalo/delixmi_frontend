import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../services/coverage_service.dart';
import '../../models/restaurant.dart';
import '../../models/category.dart';
import '../../widgets/customer/restaurant_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../providers/address_provider.dart';
import '../../providers/restaurant_cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Restaurant> _restaurants = [];
  List<Category> _categories = [];
  bool _loadingRestaurants = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreRestaurants = true;
  Category? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Variables de cobertura
  bool _hasCoverage = true;
  bool _checkingCoverage = false;
  String? _coverageErrorMessage;
  
  // Referencia al provider para evitar acceso al context en dispose
  AddressProvider? _addressProvider;

  @override
  void initState() {
    super.initState();
    _loadUserToken();
    _setupScrollListener();
    
    // Cargar datos después de que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupAddressListener();
    });
  }

  void _setupAddressListener() {
    // Escuchar cambios en la dirección seleccionada
    _addressProvider = context.read<AddressProvider>();
    _addressProvider!.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    // Re-verificar cobertura cuando cambia la dirección
    debugPrint('📍 Dirección cambió, re-verificando cobertura...');
    
    // Resetear estado de cobertura para forzar nueva verificación
    setState(() {
      _hasCoverage = true; // Resetear para que se ejecute la verificación
      _coverageErrorMessage = null;
      _restaurants = []; // Limpiar lista actual
      _currentPage = 1;
      _hasMoreRestaurants = true;
    });
    
    // Ejecutar verificación completa de cobertura y carga de restaurantes
    _loadRestaurants();
  }

  @override
  void dispose() {
    // Remover listener usando la referencia guardada
    _addressProvider?.removeListener(_onAddressChanged);
    
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Asegurar que el carrito se cargue cuando cambien las dependencias
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCartSummary();
      }
    });
  }

  Future<void> _loadUserToken() async {
    try {
      await AuthService.getToken();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addressProvider = context.read<AddressProvider>();
      await addressProvider.loadAddresses();
    } catch (e) {
      ErrorHandler.logError('HomeScreen._loadAddresses', e);
    }
  }

  Future<void> _loadCartSummary() async {
    try {
      final cartProvider = context.read<RestaurantCartProvider>();
      await cartProvider.loadCartSummary();
    } catch (e) {
      ErrorHandler.logError('HomeScreen._loadCartSummary', e);
    }
  }

  Future<void> _loadInitialData() async {
    // Cargar carrito primero para que el badge se actualice inmediatamente
    await _loadCartSummary();
    
    // Luego cargar el resto de datos en paralelo
    await Future.wait<void>([
      _loadCategories(),
      _loadRestaurants(),
      _loadAddresses(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService.getCategories();
      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            _categories = response.data!.map((json) => Category.fromJson(json)).toList();
          });
        } else {
          // Usar categorías por defecto si falla la API
          setState(() {
            _categories = Category.defaultCategories;
          });
        }
      }
    } catch (e) {
      ErrorHandler.logError('HomeScreen._loadCategories', e);
      if (mounted) {
        setState(() {
          _categories = Category.defaultCategories;
        });
      }
    }
  }

  Future<void> _loadRestaurants({bool loadMore = false}) async {
    if (_loadingRestaurants || (!loadMore && !_hasMoreRestaurants)) return;

    // Obtener la dirección actual del usuario
    final addressProvider = context.read<AddressProvider>();
    final currentAddress = addressProvider.currentDeliveryAddress;

    // Si no hay dirección seleccionada, no cargar restaurantes
    if (currentAddress == null) {
      setState(() {
        _hasCoverage = false;
        _coverageErrorMessage = 'Selecciona una dirección de entrega';
        _loadingRestaurants = false;
      });
      return;
    }

    // PASO 1: Verificar cobertura ANTES de cargar restaurantes (solo en carga inicial)
    if (!loadMore) {
      setState(() {
        _checkingCoverage = true;
        _coverageErrorMessage = null;
      });

      try {
        debugPrint('🔍 Verificando cobertura para dirección: ${currentAddress.id}');
        final coverageResponse = await CoverageService.checkCoverageForAddress(currentAddress.id);
        
        if (mounted) {
          if (coverageResponse.isSuccess && coverageResponse.data.hasCoverage) {
            // ✅ HAY COBERTURA: Proceder a cargar restaurantes
            debugPrint('✅ Cobertura confirmada: ${coverageResponse.data.coveredBranches} sucursales disponibles');
            setState(() {
              _hasCoverage = true;
              _checkingCoverage = false;
              _coverageErrorMessage = null;
            });
          } else {
            // ❌ NO HAY COBERTURA: No cargar restaurantes
            debugPrint('❌ Sin cobertura en esta dirección');
            setState(() {
              _hasCoverage = false;
              _checkingCoverage = false;
              _coverageErrorMessage = null;
              _loadingRestaurants = false;
            });
            return; // Salir sin cargar restaurantes
          }
        }
      } catch (e) {
        // Error al verificar cobertura
        ErrorHandler.logError('HomeScreen._checkCoverage', e);
        debugPrint('⚠️ Error al verificar cobertura: $e');
        
        if (mounted) {
          setState(() {
            _hasCoverage = false;
            _checkingCoverage = false;
            _coverageErrorMessage = e.toString().replaceAll('Exception: ', '');
            _loadingRestaurants = false;
          });
        }
        return; // Salir sin cargar restaurantes
      }
    }

    // PASO 2: Cargar restaurantes (solo si hay cobertura)
    if (!_hasCoverage) return;

    setState(() {
      _loadingRestaurants = true;
      _errorMessage = null;
    });

    try {
      // Obtener coordenadas de la dirección actual del usuario
      final currentAddress = addressProvider.currentDeliveryAddress;
      double? latitude = currentAddress?.latitude;
      double? longitude = currentAddress?.longitude;
      
      debugPrint('📍 Enviando coordenadas para ordenamiento por proximidad: lat=$latitude, lng=$longitude');
      
      final response = await ApiService.getRestaurants(
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: 10,
        category: _selectedCategory?.name,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        latitude: latitude,
        longitude: longitude,
      );

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          final restaurantsData = response.data!['restaurants'] as List?;
          final paginationData = response.data!['pagination'];
          
          if (restaurantsData != null) {
            final newRestaurants = restaurantsData.map((json) => Restaurant.fromJson(json)).toList();
            
            setState(() {
              if (loadMore) {
                _restaurants.addAll(newRestaurants);
                _currentPage++;
              } else {
                _restaurants = newRestaurants;
                _currentPage = 1;
              }
              
              if (paginationData != null) {
                _hasMoreRestaurants = paginationData['hasNextPage'] ?? false;
              }
              
              _loadingRestaurants = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = response.message;
            _loadingRestaurants = false;
          });
        }
      }
    } catch (e) {
      ErrorHandler.logError('HomeScreen._loadRestaurants', e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar restaurantes: ${e.toString()}';
          _loadingRestaurants = false;
        });
      }
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadRestaurants(loadMore: true);
      }
    });
  }

  void _onCategorySelected(Category category) {
    setState(() {
      _selectedCategory = _selectedCategory?.id == category.id ? null : category;
      _currentPage = 1;
      _hasMoreRestaurants = true;
    });
    _loadRestaurants();
  }

  void _onSearchChanged(String query) {
    // Capitalizar la primera letra para mejorar la compatibilidad con el backend
    final formattedQuery = _formatSearchQuery(query);
    
    // Actualizar el controlador con el texto formateado si es diferente
    if (formattedQuery != query) {
      _searchController.value = TextEditingValue(
        text: formattedQuery,
        selection: TextSelection.collapsed(offset: formattedQuery.length),
      );
    }
    
    setState(() {
      _searchQuery = formattedQuery;
      _currentPage = 1;
      _hasMoreRestaurants = true;
    });
    
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == formattedQuery && mounted) {
        _loadRestaurants();
      }
    });
  }

  String _formatSearchQuery(String query) {
    if (query.isEmpty) return query;
    
    // Capitalizar la primera letra y el resto en minúsculas
    return query[0].toUpperCase() + query.substring(1).toLowerCase();
  }


  void _navigateToRestaurantDetail(Restaurant restaurant) {
    Navigator.of(context).pushNamed(
      '/restaurant-detail',
      arguments: restaurant.id,
    );
  }

  void _navigateToAddresses() {
    Navigator.of(context).pushNamed('/addresses');
  }

  Widget _buildSimpleNotificationIcon(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Colors.grey[600],
            size: 20,
          ),
          onPressed: () {
            // TODO: Implementar notificaciones
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(
          message: 'Cargando restaurantes...',
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadRestaurants(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header con dirección y notificaciones
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Dirección y notificaciones (diseño limpio)
                          Row(
                            children: [
                              // Sección de dirección simplificada
                              Expanded(
                                child: Consumer<AddressProvider>(
                                  builder: (context, addressProvider, child) {
                                    return GestureDetector(
                                      onTap: () => _navigateToAddresses(),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Entregando en',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  addressProvider.deliveryAddressText,
                                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[900],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Ícono de notificaciones simple
                              _buildSimpleNotificationIcon(context),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Barra de búsqueda
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Buscar en Delixmi...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                  size: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Filtros de categorías
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory?.id == category.id;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (category.emoji != null) ...[
                              Text(category.emoji!),
                              const SizedBox(width: 4),
                            ],
                            Text(category.name),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) => _onCategorySelected(category),
                        backgroundColor: Colors.grey[200],
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Lista de restaurantes
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: _buildRestaurantsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildRestaurantsList() {
    // Mostrar loading mientras verifica cobertura
    if (_checkingCoverage) {
      return const SliverFillRemaining(
        child: LoadingWidget(
          message: 'Verificando cobertura...',
        ),
      );
    }

    // Mostrar mensaje si NO hay cobertura
    if (!_hasCoverage) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Sin cobertura en tu zona',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _coverageErrorMessage ?? 'Lo sentimos, parece que aún no tenemos cobertura en tu dirección.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddresses(),
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Cambiar Dirección'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _loadRestaurants(),
                  child: const Text('Verificar nuevamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mostrar loading mientras carga restaurantes
    if (_loadingRestaurants && _restaurants.isEmpty) {
      return const SliverFillRemaining(
        child: LoadingWidget(
          message: 'Cargando restaurantes...',
        ),
      );
    }

    // Mostrar error si hay alguno
    if (_errorMessage != null && _restaurants.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadRestaurants(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar mensaje si no hay restaurantes pero HAY cobertura
    if (_restaurants.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No hay restaurantes disponibles',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _restaurants.length) {
            // Indicador de carga al final
            if (_loadingRestaurants) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: LoadingWidget(
                  message: 'Cargando más restaurantes...',
                  size: 20.0,
                ),
              );
            } else if (_hasMoreRestaurants) {
              return const SizedBox(height: 16);
            } else {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No hay más restaurantes',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
          }

          final restaurant = _restaurants[index];
          return RestaurantCard(
            restaurant: restaurant,
            onTap: () => _navigateToRestaurantDetail(restaurant),
          );
        },
        childCount: _restaurants.length + 1,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSimpleNavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isSelected: true,
                onTap: () {},
              ),
              _buildSimpleCartItem(),
              _buildSimpleNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Pedidos',
                isSelected: false,
                onTap: () {
                  Navigator.of(context).pushNamed('/orders');
                },
              ),
              _buildSimpleNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
                isSelected: false,
                onTap: () {
                  Navigator.of(context).pushNamed('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[600],
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCartItem() {
    return Consumer<RestaurantCartProvider>(
      builder: (context, cartProvider, child) {
        final cartItemCount = cartProvider.totalItems;
        final hasItems = cartItemCount > 0;
        
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/cart');
          },
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: hasItems 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Carrito',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: hasItems ? FontWeight.w600 : FontWeight.w500,
                      color: hasItems 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (hasItems)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }


}
