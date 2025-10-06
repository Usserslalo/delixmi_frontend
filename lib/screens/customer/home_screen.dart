import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../models/restaurant.dart';
import '../../models/category.dart';
import '../../widgets/customer/restaurant_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/cart_badge.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserToken();
    _setupScrollListener();
    
    // Cargar datos después de que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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

    setState(() {
      _loadingRestaurants = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRestaurants(
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: 10,
        category: _selectedCategory?.name,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
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
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _hasMoreRestaurants = true;
    });
    
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == query && mounted) {
        _loadRestaurants();
      }
    });
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
                          // Dirección y notificaciones
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Consumer<AddressProvider>(
                                  builder: (context, addressProvider, child) {
                                    return GestureDetector(
                                      onTap: () => _navigateToAddresses(),
                                      child: Row(
                                        children: [
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
                              Stack(
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
                              ),
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
    if (_loadingRestaurants && _restaurants.isEmpty) {
      return const SliverFillRemaining(
        child: LoadingWidget(
          message: 'Cargando restaurantes...',
        ),
      );
    }

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
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Inicio',
                isSelected: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.favorite_border,
                label: 'Favoritos',
                isSelected: false,
                onTap: () {
                  // TODO: Implementar favoritos
                },
              ),
              NavigationCartBadge(
                icon: Icons.shopping_cart_outlined,
                label: 'Carrito',
                isSelected: false,
                onTap: () {
                  Navigator.of(context).pushNamed('/cart');
                },
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Pedidos',
                isSelected: false,
                onTap: () {
                  Navigator.of(context).pushNamed('/orders');
                },
              ),
              _buildNavItem(
                icon: Icons.person_outline,
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

  Widget _buildNavItem({
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
                : Colors.grey[500],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

}
