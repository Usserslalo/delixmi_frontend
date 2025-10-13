import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
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
            // debugPrint('🔍 Cargando detalles del restaurante ID: ${widget.restaurantId}');
            final response = await ApiService.getRestaurantDetail(
              restaurantId: widget.restaurantId,
            );

      // debugPrint('📡 Respuesta del servidor: ${response.status}');
      // debugPrint('📡 Datos recibidos: ${response.data}');
      // debugPrint('📡 Mensaje: ${response.message}');

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          // debugPrint('✅ Respuesta exitosa, parseando datos...');
          try {
            final restaurant = RestaurantDetail.fromJson(response.data!);
            // debugPrint('✅ Restaurante parseado: ${restaurant.name}');
            // debugPrint('✅ Categorías: ${restaurant.categories.length}');
            
            // Debug: Log restaurant structure
            // int totalProducts = 0;
            // for (final category in restaurant.categories) {
            //   for (final subcategory in category.subcategories) {
            //     totalProducts += subcategory.products.length;
            //     debugPrint('📦 Categoría "${category.name}" > "${subcategory.name}": ${subcategory.products.length} productos');
            //     for (final product in subcategory.products) {
            //       debugPrint('  - ${product.name} (modificadores: ${product.modifierGroups.length})');
            //     }
            //   }
            // }
            // debugPrint('📊 Total de productos en el restaurante: $totalProducts');
            
            setState(() {
              _restaurant = restaurant;
              _isLoading = false;
            });
          } catch (parseError) {
            // debugPrint('❌ Error al parsear: $parseError');
            setState(() {
              _errorMessage = 'Error al procesar datos del restaurante: $parseError';
              _isLoading = false;
            });
          }
        } else {
          // debugPrint('❌ Respuesta fallida: ${response.message}');
          // Usar datos de prueba si falla la API
          // debugPrint('🔄 Cargando datos de prueba...');
          _loadMockData();
        }
      }
    } catch (e) {
      // debugPrint('❌ Error en la petición: $e');
      // Usar datos de prueba si falla la conexión
      // debugPrint('🔄 Cargando datos de prueba...');
      _loadMockData();
    }
  }

  void _loadMockData() {
    // Datos de prueba para demostrar la funcionalidad
    RestaurantDetail mockRestaurant;
    
    // debugPrint('🔍 RestaurantDetailScreen: Cargando mock data para restaurantId: ${widget.restaurantId}');
    
    // Crear datos diferentes según el restaurantId
    if (widget.restaurantId == 1) {
      // Pizzería de Ana
      // debugPrint('🔍 RestaurantDetailScreen: Cargando Pizzería de Ana');
      mockRestaurant = RestaurantDetail(
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
                  modifierGroups: [
                    ModifierGroup(
                      id: 1,
                      name: 'Tamaño',
                      minSelection: 1,
                      maxSelection: 1,
                      options: [
                        ModifierOption(id: 1, name: 'Pequeña', price: 0.0),
                        ModifierOption(id: 2, name: 'Mediana', price: 20.0),
                        ModifierOption(id: 3, name: 'Grande', price: 40.0),
                      ],
                    ),
                    ModifierGroup(
                      id: 2,
                      name: 'Extras',
                      minSelection: 0,
                      maxSelection: 3,
                      options: [
                        ModifierOption(id: 5, name: 'Extra Queso', price: 15.0),
                        ModifierOption(id: 27, name: 'Orilla Rellena de Queso', price: 25.0),
                        ModifierOption(id: 8, name: 'Champiñones Extra', price: 10.0),
                      ],
                    ),
                  ],
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
    } else if (widget.restaurantId == 2) {
      // Sushi Master Kenji
      // debugPrint('🔍 RestaurantDetailScreen: Cargando Sushi Master Kenji');
      mockRestaurant = RestaurantDetail(
        id: widget.restaurantId,
        name: 'Sushi Master Kenji',
        description: 'Auténtico sushi japonés preparado por maestros sushiman con ingredientes frescos importados de Japón',
        logoUrl: null,
        coverPhotoUrl: null,
        status: 'active',
        categories: [
          Category(
            id: 1,
            name: 'Sushi',
            description: 'Sushi fresco y tradicional',
            subcategories: [
              Subcategory(
                id: 1,
                name: 'Rolls Tradicionales',
                description: 'Nuestros rolls clásicos',
                categoryId: 1,
                products: [
                  Product(
                    id: 1,
                    name: 'California Roll',
                    description: 'Roll clásico con cangrejo, aguacate y pepino',
                    price: 180.00,
                    imageUrl: null,
                    isAvailable: true,
                    subcategoryId: 1,
                    modifierGroups: [
                      ModifierGroup(
                        id: 1,
                        name: 'Cantidad',
                        minSelection: 1,
                        maxSelection: 1,
                        options: [
                          ModifierOption(id: 1, name: '6 piezas', price: 0.0),
                          ModifierOption(id: 2, name: '8 piezas', price: 30.0),
                          ModifierOption(id: 3, name: '12 piezas', price: 60.0),
                        ],
                      ),
                      ModifierGroup(
                        id: 2,
                        name: 'Extras',
                        minSelection: 0,
                        maxSelection: 2,
                        options: [
                          ModifierOption(id: 4, name: 'Salsa de Soja Premium', price: 15.0),
                          ModifierOption(id: 5, name: 'Wasabi Extra', price: 10.0),
                          ModifierOption(id: 6, name: 'Jengibre Extra', price: 8.0),
                        ],
                      ),
                    ],
                  ),
                  Product(
                    id: 2,
                    name: 'Dragon Roll',
                    description: 'Roll con anguila, aguacate y salsa especial',
                    price: 220.00,
                    imageUrl: null,
                    isAvailable: true,
                    subcategoryId: 1,
                    modifierGroups: [
                      ModifierGroup(
                        id: 1,
                        name: 'Cantidad',
                        minSelection: 1,
                        maxSelection: 1,
                        options: [
                          ModifierOption(id: 1, name: '6 piezas', price: 0.0),
                          ModifierOption(id: 2, name: '8 piezas', price: 35.0),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Category(
            id: 2,
            name: 'Bebidas Japonesas',
            description: 'Bebidas tradicionales japonesas',
            subcategories: [
              Subcategory(
                id: 2,
                name: 'Sake',
                description: 'Sake tradicional japonés',
                categoryId: 2,
                products: [
                  Product(
                    id: 3,
                    name: 'Sake Premium',
                    description: 'Sake de alta calidad importado de Japón',
                    price: 150.00,
                    imageUrl: null,
                    isAvailable: true,
                    subcategoryId: 2,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      // Restaurante no encontrado
      mockRestaurant = RestaurantDetail(
        id: widget.restaurantId,
        name: 'Restaurante No Encontrado',
        description: 'Este restaurante no está disponible',
        logoUrl: null,
        coverPhotoUrl: null,
        status: 'inactive',
        categories: [],
      );
    }

    setState(() {
      _restaurant = mockRestaurant;
      _isLoading = false;
    });
  }

  void _navigateToProductDetail(Product product) {
    // Debug: Verificar producto antes de navegar
    // debugPrint('🔍 RestaurantDetailScreen: Navegando a detalles de: ${product.name}');
    // debugPrint('🔍 RestaurantDetailScreen: ModifierGroups count: ${product.modifierGroups.length}');
    // Debug: Log modifier groups
    // for (final group in product.modifierGroups) {
    //   debugPrint('🔍 RestaurantDetailScreen: Grupo "${group.name}" con ${group.options.length} opciones');
    // }
    
    Navigator.of(context).pushNamed(
      '/product-detail',
      arguments: {
        'product': product,
        'restaurantId': widget.restaurantId,
      },
    );
  }

  /// Construye el botón + para agregar al carrito
  Widget _buildAddToCartButton(Product product) {
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isProductInCart(product.id, widget.restaurantId);
        final quantity = cartProvider.getProductQuantity(product.id, widget.restaurantId);
        
        return Container(
          decoration: BoxDecoration(
            color: primaryOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _handleAddToCart(product),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isInCart ? Icons.check_rounded : Icons.add_rounded,
                      color: white,
                      size: 18,
                    ),
                    if (isInCart) ...[
                      const SizedBox(width: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        child: Text('$quantity'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Maneja la lógica de agregar al carrito
  Future<void> _handleAddToCart(Product product) async {
    try {
      // debugPrint('🛒 RestaurantDetailScreen: Intentando agregar ${product.name} al carrito');
      
      // Verificar si el producto tiene modificadores requeridos
      final hasRequiredModifiers = product.modifierGroups.any((group) => group.minSelection > 0);
      
      if (hasRequiredModifiers) {
        // debugPrint('🛒 RestaurantDetailScreen: Producto tiene modificadores requeridos, navegando a detalles');
        // Si tiene modificadores requeridos, navegar a la pantalla de detalles
        _navigateToProductDetail(product);
        return;
      }
      
      // Si no tiene modificadores requeridos, agregar directamente al carrito
      // debugPrint('🛒 RestaurantDetailScreen: Producto sin modificadores requeridos, agregando directamente');
      final cartProvider = context.read<CartProvider>();
      
      final success = await cartProvider.addToCart(
        productId: product.id,
        quantity: 1,
        modifiers: null, // Sin modificadores
      );
      
      if (mounted) {
        if (success) {
          // Mostrar feedback visual de éxito con animación
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${product.name} agregado al carrito'),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Verificar si es error de modificadores requeridos
          if (cartProvider.isModifiersRequiredError) {
            // Navegar a detalles del producto para seleccionar modificadores
            // debugPrint('🛒 RestaurantDetailScreen: Modificadores requeridos, navegando a detalles');
            _navigateToProductDetail(product);
          } else {
            // Mostrar error genérico
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Error al agregar ${product.name} al carrito'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      // debugPrint('❌ RestaurantDetailScreen: Error al agregar al carrito: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error inesperado: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Método mantenido para uso futuro si se necesita agregar directamente al carrito
  // void _addToCart(Product product) {
  //   // Si el producto tiene modificadores, mostrar el modal de selección
  //   if (product.modifierGroups.isNotEmpty) {
  //     showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       backgroundColor: Colors.transparent,
  //       builder: (context) => ModifierSelectionModal(
  //         product: product,
  //         restaurantId: widget.restaurantId,
  //       ),
  //     );
  //   } else {
  //     // Si no tiene modificadores, agregar directamente al carrito
  //     _addProductDirectly(product);
  //   }
  // }

  // Método mantenido para uso futuro si se necesita agregar directamente al carrito
  // Future<void> _addProductDirectly(Product product) async {
  //   final cartProvider = context.read<CartProvider>();
  //   
  //   try {
  //     final success = await cartProvider.addToCart(
  //       productId: product.id,
  //       quantity: 1,
  //     );
  //
  //     if (mounted) {
  //       if (success) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('${product.name} agregado al carrito'),
  //             duration: const Duration(seconds: 2),
  //             action: SnackBarAction(
  //               label: 'Ver carrito',
  //               onPressed: () {
  //                 Navigator.of(context).pushNamed('/cart');
  //               },
  //             ),
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error: ${cartProvider.errorMessage ?? 'No se pudo agregar al carrito'}'),
  //             backgroundColor: Colors.red,
  //             duration: const Duration(seconds: 3),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error al agregar al carrito: $e'),
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   }
  // }

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

    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen del restaurante - Material 3
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: white,
            surfaceTintColor: white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: darkGray),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen del restaurante
                  _restaurant!.coverPhotoUrl != null
                      ? Image.network(
                          _restaurant!.coverPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                  // Gradiente para mejor legibilidad
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border_rounded, color: darkGray),
                  onPressed: () {
                    // TODO: Favoritos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favoritos - Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Agregar a favoritos',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, color: darkGray),
                  onPressed: () {
                    // TODO: Compartir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compartir - Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Compartir restaurante',
                ),
              ),
            ],
          ),
          
          // Información del restaurante con Material 3
          SliverToBoxAdapter(
            child: Container(
              color: white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del restaurante
                  Text(
                    _restaurant!.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descripción
                  Text(
                    _restaurant!.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Información adicional (chips)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        icon: Icons.schedule_rounded,
                        label: '25-30 min',
                        context: context,
                      ),
                      _buildInfoChip(
                        icon: Icons.delivery_dining_rounded,
                        label: 'Envío gratis',
                        context: context,
                      ),
                      _buildInfoChip(
                        icon: Icons.star_rounded,
                        label: '4.5',
                        context: context,
                      ),
                      _buildStatusChip(context),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Divider
                  Divider(
                    color: const Color(0xFFE0E0E0),
                    thickness: 1,
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
          
          // Categorías del menú con Material 3
          if (_restaurant!.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: white,
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Menú',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _restaurant!.categories.length,
                        itemBuilder: (context, index) {
                          final category = _restaurant!.categories[index];
                          final isSelected = _selectedCategoryIndex == index;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategoryIndex = index;
                                });
                              },
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                  Navigator.of(context).pushNamed(AppRoutes.cart);
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

  Widget _buildStatusChip(BuildContext context) {
    final isOpen = _restaurant?.status == 'active';
    const successGreen = Color(0xFF2E7D32);
    const warningOrange = Color(0xFFF57C00);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOpen 
            ? successGreen.withValues(alpha: 0.1)
            : warningOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOpen 
              ? successGreen.withValues(alpha: 0.3)
              : warningOrange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 16,
            color: isOpen ? successGreen : warningOrange,
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'Abierto' : 'Cerrado',
            style: TextStyle(
              fontSize: 13,
              color: isOpen ? successGreen : warningOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    const darkGray = Color(0xFF1A1A1A);
    const lightGray = Color(0xFFF5F5F5);
    const mediumGray = Color(0xFF757575);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: mediumGray,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);
    const mediumGray = Color(0xFF757575);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.productDetail,
            arguments: {
              'product': product,
              'restaurantId': widget.restaurantId,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Imagen del producto
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.restaurant_rounded,
                              size: 40,
                              color: mediumGray,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.restaurant_rounded,
                        size: 40,
                        color: mediumGray,
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
                        color: darkGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description ?? 'Sin descripción',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mediumGray,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                        _buildAddToCartButton(product),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
