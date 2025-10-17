import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../services/coverage_service.dart';
import '../../services/onboarding_service.dart';
import '../../services/dashboard_service.dart';
import '../../models/restaurant.dart';
import '../../models/category.dart';
import '../../models/address.dart';
import '../../widgets/customer/restaurant_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/onboarding/onboarding_overlay.dart';
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
  List<Address> _addresses = [];
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
  
  // Variables de onboarding
  bool _showOnboarding = false;
  bool _checkingOnboarding = true;
  
  // Variables para dashboard API optimizado
  bool _loadingDashboard = false;
  int? _lastAddressId; // Para evitar bucles infinitos en cambio de dirección

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
    // Solo reaccionar si realmente cambió la dirección seleccionada
    final currentAddress = _addressProvider?.currentDeliveryAddress;
    if (currentAddress?.id == _lastAddressId) {
      debugPrint('📍 Misma dirección, ignorando cambio...');
      return;
    }
    
    _lastAddressId = currentAddress?.id;
    debugPrint('📍 Dirección cambió, recargando datos...');
    
    // Resetear estado de cobertura para forzar nueva verificación
    setState(() {
      _hasCoverage = true; // Resetear para que se ejecute la verificación
      _coverageErrorMessage = null;
      _restaurants = []; // Limpiar lista actual
      _currentPage = 1;
      _hasMoreRestaurants = true;
    });
    
    // Cargar dashboard optimizado
    _loadDashboardData();
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
      
      // Solo cargar si no están ya cargadas
      if (addressProvider.addresses.isEmpty) {
        await addressProvider.loadAddresses();
      }
      
      setState(() {
        _addresses = addressProvider.addresses;
      });
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
    // Verificar si debe mostrar onboarding para usuarios nuevos
    await _checkOnboardingStatus();
    
    // Cargar dashboard optimizado
    await _loadDashboardData();
  }

  /// Método optimizado: Una sola llamada API para todos los datos
  Future<void> _loadDashboardData() async {
    // Evitar múltiples llamadas simultáneas
    if (_loadingDashboard) {
      debugPrint('🔄 Dashboard ya está cargando, ignorando llamada...');
      return;
    }
    
    try {
      setState(() {
        _loadingDashboard = true;
        _isLoading = true;
      });

      // Obtener coordenadas del usuario
      final addressProvider = context.read<AddressProvider>();
      final currentAddress = addressProvider.currentDeliveryAddress;
      
      double? latitude = currentAddress?.latitude;
      double? longitude = currentAddress?.longitude;
      int? addressId = currentAddress?.id;

      debugPrint('🚀 Cargando dashboard...');

      final response = await DashboardService.getDashboard(
        latitude: latitude,
        longitude: longitude,
        addressId: addressId,
      );

      if (response.isSuccess && response.data != null) {
        // Parsear respuesta unificada
        final dashboardData = DashboardService.parseDashboardResponse(response.data!);
        
        setState(() {
          _categories = dashboardData['categories'] as List<Category>;
          _restaurants = dashboardData['restaurants'] as List<Restaurant>;
          _hasCoverage = true; // Dashboard incluye cobertura
          _loadingDashboard = false;
          _isLoading = false;
        });

        // Cargar direcciones por separado solo si no están cargadas
        if (_addresses.isEmpty) {
          await _loadAddresses();
        }
        
        // Cargar carrito por separado
        await _loadCartSummary();

        debugPrint('✅ Dashboard cargado exitosamente');
      } else {
        debugPrint('❌ Error en dashboard API: ${response.message}');
        // Fallback a métodos individuales
        await _loadDataFallback();
      }
    } catch (e) {
      debugPrint('❌ Error cargando dashboard: $e');
      // Fallback a métodos individuales
      await _loadDataFallback();
    }
  }

  /// Método de fallback: Múltiples llamadas API individuales
  Future<void> _loadDataFallback() async {
    debugPrint('🔄 Usando métodos individuales...');
    
    setState(() {
      _loadingDashboard = false;
      _isLoading = true;
    });
    
    // Cargar carrito primero para que el badge se actualice inmediatamente
    await _loadCartSummary();
    
    // Luego cargar el resto de datos en paralelo
    await Future.wait<void>([
      _loadCategories(),
      _loadRestaurants(),
      _loadAddresses(),
    ]);
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final shouldShow = await OnboardingService.instance.shouldShowOnboarding();
      debugPrint('🔍 Verificando onboarding: $shouldShow');
      
      if (mounted) {
        setState(() {
          _showOnboarding = shouldShow;
          _checkingOnboarding = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error verificando onboarding: $e');
      if (mounted) {
        setState(() {
          _showOnboarding = false;
          _checkingOnboarding = false;
        });
      }
    }
  }

  void _onOnboardingComplete() {
    debugPrint('✅ Onboarding completado');
    setState(() {
      _showOnboarding = false;
    });
    
    // Recargar datos después del onboarding
    _loadInitialData();
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
    
    // Cargar dashboard optimizado
    _loadDashboardData();
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
        // Cargar dashboard optimizado
        _loadDashboardData();
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
    Navigator.of(context).pushNamed(AppRoutes.addresses);
  }

  Widget _buildNotificationButton(BuildContext context) {
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);

    return IconButton(
      icon: Badge(
        isLabelVisible: true,
        label: const Text('3'),
        backgroundColor: primaryOrange,
        textColor: white,
        child: const Icon(
          Icons.notifications_outlined,
          color: darkGray,
          size: 24,
        ),
      ),
      onPressed: () {
        // TODO: Navegar a notificaciones
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificaciones - Próximamente'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      tooltip: 'Notificaciones',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _checkingOnboarding) {
      return Scaffold(
        body: const LoadingWidget(
          message: 'Cargando...',
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          body: RefreshIndicator(
        onRefresh: () => _loadDashboardData(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header con dirección y notificaciones
            SliverAppBar(
              expandedHeight: 115.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFFFFFFF),
              surfaceTintColor: const Color(0xFFFFFFFF),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Dirección y notificaciones (diseño limpio)
                          Row(
                            children: [
                              // Sección de dirección simplificada
                              Expanded(
                                child: Consumer<AddressProvider>(
                                  builder: (context, addressProvider, child) {
                                    return InkWell(
                                      onTap: () => _navigateToAddresses(),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2843A),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.location_on_rounded,
                                              color: Color(0xFFFFFFFF),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Entregar en',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                    color: const Color(0xFF757575),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  addressProvider.deliveryAddressText,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF1A1A1A),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Color(0xFFF2843A),
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Botón de notificaciones con Material 3
                              _buildNotificationButton(context),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Barra de búsqueda con Material 3
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF1A1A1A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Buscar restaurantes o platillos...',
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF757575),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF757575),
                                  size: 22,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          color: Color(0xFF757575),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
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
            
            // Filtros de categorías con Material 3
            SliverToBoxAdapter(
              child: Container(
                height: 52,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory?.id == category.id;
                    const primaryOrange = Color(0xFFF2843A);
                    const darkGray = Color(0xFF1A1A1A);
                    const white = Color(0xFFFFFFFF);
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (category.emoji != null) ...[
                              Text(
                                category.emoji!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(category.displayNameOrName),
                            if (category.hasRestaurants) ...[
                              const SizedBox(width: 4),
                              Text(
                                category.restaurantCountText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? white : const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) => _onCategorySelected(category),
                        backgroundColor: white,
                        selectedColor: primaryOrange,
                        checkmarkColor: white,
                        side: BorderSide(
                          color: isSelected ? primaryOrange : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? white : darkGray,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        showCheckmark: false,
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
        ),
        
        // Overlay de onboarding para usuarios nuevos
        if (_showOnboarding)
          OnboardingOverlay(
            onComplete: _onOnboardingComplete,
          ),
        
      ],
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
    const primaryOrange = Color(0xFFF2843A);

    return Consumer<RestaurantCartProvider>(
      builder: (context, cartProvider, child) {
        final cartItemCount = cartProvider.totalItems;
        
        return NavigationBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          height: 70,
          selectedIndex: 0, // Inicio siempre seleccionado en HomeScreen
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: primaryOrange.withValues(alpha: 0.15),
          destinations: [
            // Inicio
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            // Carrito con badge
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartItemCount > 0,
                label: Text('$cartItemCount'),
                backgroundColor: primaryOrange,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartItemCount > 0,
                label: Text('$cartItemCount'),
                backgroundColor: primaryOrange,
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Carrito',
            ),
            // Pedidos
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Pedidos',
            ),
            // Perfil
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                // Ya estamos en Inicio, no hacer nada
                break;
              case 1:
                Navigator.of(context).pushNamed(AppRoutes.cart);
                break;
              case 2:
                Navigator.of(context).pushNamed(AppRoutes.orders);
                break;
              case 3:
                Navigator.of(context).pushNamed(AppRoutes.profile);
                break;
            }
          },
        );
      },
    );
  }

}
