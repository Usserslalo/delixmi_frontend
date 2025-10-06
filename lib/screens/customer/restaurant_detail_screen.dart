import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  RestaurantDetail? _restaurant;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetail();
  }

  Future<void> _loadRestaurantDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Cargando detalles del restaurante ID: ${widget.restaurantId}');
      final response = await ApiService.getRestaurantDetail(
        restaurantId: widget.restaurantId,
      );

      print('📡 Respuesta del servidor: ${response.status}');
      print('📡 Datos recibidos: ${response.data}');
      print('📡 Mensaje: ${response.message}');

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          print('✅ Respuesta exitosa, parseando datos...');
          try {
            final restaurant = RestaurantDetail.fromJson(response.data!);
            print('✅ Restaurante parseado: ${restaurant.name}');
            print('✅ Categorías: ${restaurant.categories.length}');
            setState(() {
              _restaurant = restaurant;
              _isLoading = false;
            });
          } catch (parseError) {
            print('❌ Error al parsear: $parseError');
            setState(() {
              _errorMessage = 'Error al procesar datos del restaurante: $parseError';
              _isLoading = false;
            });
          }
        } else {
          print('❌ Respuesta fallida: ${response.message}');
          // Usar datos de prueba si falla la API
          print('🔄 Cargando datos de prueba...');
          _loadMockData();
        }
      }
    } catch (e) {
      print('❌ Error en la petición: $e');
      // Usar datos de prueba si falla la conexión
      print('🔄 Cargando datos de prueba...');
      _loadMockData();
    }
  }

  void _loadMockData() {
    // Datos de prueba para demostrar la funcionalidad
    final mockRestaurant = RestaurantDetail(
      id: widget.restaurantId,
      name: 'Pizzería de Ana',
      description: 'Las mejores pizzas artesanales de la región, con ingredientes frescos y recetas tradicionales',
      logoUrl: null,
      coverPhotoUrl: null,
      status: 'active',
      categories: [
        Category(
          id: 1,
          name: 'Pizzas',
          description: 'Pizzas artesanales',
          subcategories: [
            Subcategory(
              id: 1,
              name: 'Pizzas Tradicionales',
              description: 'Nuestras pizzas clásicas',
              categoryId: 1,
              products: [
                Product(
                  id: 1,
                  name: 'Pizza Hawaiana',
                  description: 'Deliciosa pizza con jamón, piña y queso mozzarella',
                  price: 150.00,
                  imageUrl: null,
                  isAvailable: true,
                  subcategoryId: 1,
                ),
                Product(
                  id: 2,
                  name: 'Pizza Margherita',
                  description: 'Pizza clásica con tomate, mozzarella y albahaca fresca',
                  price: 120.00,
                  imageUrl: null,
                  isAvailable: true,
                  subcategoryId: 1,
                ),
                Product(
                  id: 3,
                  name: 'Pizza Pepperoni',
                  description: 'Pizza con pepperoni, queso mozzarella y salsa de tomate',
                  price: 140.00,
                  imageUrl: null,
                  isAvailable: true,
                  subcategoryId: 1,
                ),
              ],
            ),
            Subcategory(
              id: 2,
              name: 'Pizzas Especiales',
              description: 'Nuestras creaciones únicas',
              categoryId: 1,
              products: [
                Product(
                  id: 4,
                  name: 'Pizza Deluxe',
                  description: 'Pizza con pepperoni, champiñones, pimientos y aceitunas',
                  price: 180.00,
                  imageUrl: null,
                  isAvailable: true,
                  subcategoryId: 2,
                ),
                Product(
                  id: 5,
                  name: 'Pizza Vegetariana',
                  description: 'Pizza con champiñones, pimientos, cebolla y aceitunas',
                  price: 160.00,
                  imageUrl: null,
                  isAvailable: true,
                  subcategoryId: 2,
                ),
              ],
            ),
          ],
        ),
        Category(
          id: 2,
          name: 'Bebidas',
          description: 'Bebidas refrescantes',
          subcategories: [
            Subcategory(
              id: 3,
              name: 'Refrescos',
              description: 'Bebidas gaseosas',
              categoryId: 2,
              products: [
                Product(
                  id: 6,
                  name: 'Coca Cola',
                  description: 'Refresco de cola 355ml',
                  price: 25.00,
                  imageUrl: null,
                  isAvailable: true,
                  subcategoryId: 3,
                ),
                Product(
                  id: 7,
                  name: 'Sprite',
                  description: 'Refresco de lima-limón 355ml',
                  price: 25.00,
                  imageUrl: null,
                  isAvailable: true,
                  subcategoryId: 3,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    setState(() {
      _restaurant = mockRestaurant;
      _isLoading = false;
    });
  }

  Future<void> _addToCart(Product product) async {
    final cartProvider = context.read<CartProvider>();
    
    try {
      final success = await cartProvider.addToCart(
        productId: product.id,
        quantity: 1,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} agregado al carrito'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Ver carrito',
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${cartProvider.errorMessage ?? 'No se pudo agregar al carrito'}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar al carrito: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
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
                onPressed: _loadRestaurantDetail,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_restaurant == null) {
      return const Scaffold(
        body: Center(
          child: Text('Restaurante no encontrado'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen del restaurante
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _restaurant!.coverPhotoUrl != null
                  ? Image.network(
                      _restaurant!.coverPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Implementar favoritos
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Implementar compartir
                },
              ),
            ],
          ),
          
          // Información del restaurante
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y rating
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _restaurant!.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _restaurant!.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // TODO: Agregar rating cuando esté disponible en el modelo
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Información adicional
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.delivery_dining,
                        label: '25-30 min',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.attach_money,
                        label: 'Envío gratis',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.star,
                        label: '4.5',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Categorías del menú
          if (_restaurant!.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _restaurant!.categories.length,
                  itemBuilder: (context, index) {
                    final category = _restaurant!.categories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
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
          
          // Productos de la categoría seleccionada
          if (_restaurant!.categories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = _restaurant!.categories[_selectedCategoryIndex];
                    final subcategories = category.subcategories;
                    
                    // Flatten all products from all subcategories
                    final allProducts = <Product>[];
                    for (final subcategory in subcategories) {
                      allProducts.addAll(subcategory.products);
                    }
                    
                    if (index >= allProducts.length) return null;
                    
                    final product = allProducts[index];
                    return _buildProductCard(product);
                  },
                  childCount: _restaurant!.categories[_selectedCategoryIndex].subcategories
                      .expand((sub) => sub.products)
                      .length,
                ),
              ),
            ),
          
          // Espacio inferior para el botón flotante
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      
      // Botón flotante para ver carrito
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final itemCount = cartProvider.getItemCountByRestaurant(widget.restaurantId);
          
          return Stack(
            children: [
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text('Ver carrito${itemCount > 0 ? ' ($itemCount)' : ''}'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              if (itemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Imagen del producto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fastfood,
                            size: 40,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.fastfood,
                      size: 40,
                      color: Colors.grey[400],
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Agregar',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
