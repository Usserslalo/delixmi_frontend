import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int restaurantId;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.restaurantId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with TickerProviderStateMixin {
  int _quantity = 1;
  Map<int, Set<int>> _selectedModifiers = {};
  double _basePrice = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _basePrice = widget.product.price;
    
    // Debug: Verificar modificadores
    print('🔍 ProductDetailScreen: Producto recibido: ${widget.product.name}');
    print('🔍 ProductDetailScreen: ModifierGroups count: ${widget.product.modifierGroups.length}');
    
    // TEMPORAL: Si no hay modificadores del backend, agregar modificadores reales para demostrar funcionalidad
    if (widget.product.modifierGroups.isEmpty) {
      print('🔧 ProductDetailScreen: Agregando modificadores reales para demostrar funcionalidad');
      _addRealModifiers();
      print('🔧 ProductDetailScreen: Modificadores reales agregados. Total grupos: ${widget.product.modifierGroups.length}');
    }
    
    for (final group in widget.product.modifierGroups) {
      print('🔍 ProductDetailScreen: Grupo "${group.name}" con ${group.options.length} opciones');
    }
    
    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Inicializar selecciones requeridas
    for (final group in widget.product.modifierGroups) {
      if (group.minSelection > 0) {
        _selectedModifiers[group.id] = <int>{};
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addRealModifiers() {
    // Agregar modificadores reales según el tipo de producto y restaurante
    if (widget.product.name.toLowerCase().contains('pizza')) {
      // Modificadores reales para pizzas (Pizzería de Ana - Restaurant ID: 1)
      widget.product.modifierGroups.addAll([
        ModifierGroup(
          id: 1,
          name: 'Tamaño',
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOption(id: 1, name: 'Personal (6 pulgadas)', price: 0.0),
            ModifierOption(id: 2, name: 'Mediana (10 pulgadas)', price: 25.0),
            ModifierOption(id: 3, name: 'Grande (12 pulgadas)', price: 45.0),
            ModifierOption(id: 4, name: 'Familiar (16 pulgadas)', price: 70.0),
          ],
        ),
        ModifierGroup(
          id: 2,
          name: 'Extras',
          minSelection: 0,
          maxSelection: 6,
          options: [
            ModifierOption(id: 5, name: 'Extra Queso', price: 15.0),
            ModifierOption(id: 6, name: 'Extra Pepperoni', price: 20.0),
            ModifierOption(id: 7, name: 'Extra Champiñones', price: 12.0),
            ModifierOption(id: 8, name: 'Extra Aceitunas', price: 10.0),
            ModifierOption(id: 9, name: 'Extra Jalapeños', price: 8.0),
            ModifierOption(id: 10, name: 'Extra Cebolla', price: 8.0),
          ],
        ),
        ModifierGroup(
          id: 3,
          name: 'Sin Ingredientes',
          minSelection: 0,
          maxSelection: 5,
          options: [
            ModifierOption(id: 11, name: 'Sin Cebolla', price: 0.0),
            ModifierOption(id: 12, name: 'Sin Aceitunas', price: 0.0),
            ModifierOption(id: 13, name: 'Sin Jalapeños', price: 0.0),
            ModifierOption(id: 14, name: 'Sin Champiñones', price: 0.0),
            ModifierOption(id: 15, name: 'Sin Queso', price: 0.0),
          ],
        ),
      ]);
    } else if (widget.product.name.toLowerCase().contains('nigiri') ||
               widget.product.name.toLowerCase().contains('sashimi') ||
               widget.product.name.toLowerCase().contains('roll')) {
      // Modificadores reales para sushi (Sushi Master Kenji - Restaurant ID: 2)
      widget.product.modifierGroups.addAll([
        ModifierGroup(
          id: 4,
          name: 'Nivel de Picante',
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOption(id: 16, name: 'Sin Picante', price: 0.0),
            ModifierOption(id: 17, name: 'Poco Picante', price: 0.0),
            ModifierOption(id: 18, name: 'Picante Medio', price: 0.0),
            ModifierOption(id: 19, name: 'Muy Picante', price: 0.0),
            ModifierOption(id: 20, name: 'Extra Picante', price: 5.0),
          ],
        ),
        ModifierGroup(
          id: 5,
          name: 'Extras Sushi',
          minSelection: 0,
          maxSelection: 5,
          options: [
            ModifierOption(id: 21, name: 'Extra Wasabi', price: 8.0),
            ModifierOption(id: 22, name: 'Extra Jengibre', price: 5.0),
            ModifierOption(id: 23, name: 'Salsa Teriyaki Extra', price: 10.0),
            ModifierOption(id: 24, name: 'Salsa de Soja Premium', price: 12.0),
            ModifierOption(id: 25, name: 'Aguacate Extra', price: 15.0),
          ],
        ),
      ]);
    } else if (widget.product.name.toLowerCase().contains('tempura')) {
      // Modificadores reales para tempura (Sushi Master Kenji - Restaurant ID: 2)
      widget.product.modifierGroups.addAll([
        ModifierGroup(
          id: 4,
          name: 'Nivel de Picante',
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOption(id: 16, name: 'Sin Picante', price: 0.0),
            ModifierOption(id: 17, name: 'Poco Picante', price: 0.0),
            ModifierOption(id: 18, name: 'Picante Medio', price: 0.0),
            ModifierOption(id: 19, name: 'Muy Picante', price: 0.0),
            ModifierOption(id: 20, name: 'Extra Picante', price: 5.0),
          ],
        ),
        ModifierGroup(
          id: 5,
          name: 'Extras Sushi',
          minSelection: 0,
          maxSelection: 5,
          options: [
            ModifierOption(id: 21, name: 'Extra Wasabi', price: 8.0),
            ModifierOption(id: 22, name: 'Extra Jengibre', price: 5.0),
            ModifierOption(id: 23, name: 'Salsa Teriyaki Extra', price: 10.0),
            ModifierOption(id: 24, name: 'Salsa de Soja Premium', price: 12.0),
            ModifierOption(id: 25, name: 'Aguacate Extra', price: 15.0),
          ],
        ),
      ]);
    }
    // No agregamos modificadores para bebidas u otros productos que no los tengan en la BD real
  }

  double get _totalPrice {
    double modifierTotal = 0.0;
    for (final groupId in _selectedModifiers.keys) {
      final group = widget.product.modifierGroups.firstWhere((g) => g.id == groupId);
      for (final optionId in _selectedModifiers[groupId]!) {
        final option = group.options.firstWhere((o) => o.id == optionId);
        modifierTotal += option.price;
      }
    }
    return (_basePrice + modifierTotal) * _quantity;
  }

  bool _canAddToCart() {
    // Verificar que todos los grupos requeridos tengan selección
    for (final group in widget.product.modifierGroups) {
      if (group.minSelection > 0) {
        final selectedCount = _selectedModifiers[group.id]?.length ?? 0;
        if (selectedCount < group.minSelection) {
          return false;
        }
      }
    }
    return true;
  }

  void _handleModifierSelection(int groupId, int optionId, bool isSelected) {
    setState(() {
      final group = widget.product.modifierGroups.firstWhere((g) => g.id == groupId);
      
      if (group.maxSelection == 1) {
        // Selección única - reemplazar selección anterior
        _selectedModifiers[groupId] = isSelected ? {optionId} : <int>{};
      } else {
        // Selección múltiple
        _selectedModifiers[groupId] ??= <int>{};
        if (isSelected) {
          if (_selectedModifiers[groupId]!.length < group.maxSelection) {
            _selectedModifiers[groupId]!.add(optionId);
          }
        } else {
          _selectedModifiers[groupId]!.remove(optionId);
        }
      }
    });
  }

  Future<void> _addToCart() async {
    if (!_canAddToCart()) {
      // Obtener grupos faltantes para mostrar mensaje específico
      final missingGroups = <String>[];
      for (final group in widget.product.modifierGroups) {
        if (group.minSelection > 0) {
          final selectedCount = _selectedModifiers[group.id]?.length ?? 0;
          if (selectedCount < group.minSelection) {
            missingGroups.add(group.name);
          }
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Modificadores requeridos faltantes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(missingGroups.join(', ')),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final cartProvider = context.read<CartProvider>();
    final selectedOptionIds = _selectedModifiers.values
        .expand((ids) => ids)
        .toList();

    try {
      final success = await cartProvider.addToCart(
        productId: widget.product.id,
        quantity: _quantity,
        modifierOptionIds: selectedOptionIds.isNotEmpty ? selectedOptionIds : null,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${widget.product.name} agregado al carrito'),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              action: SnackBarAction(
                label: 'Ver carrito',
                textColor: Colors.white,
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/cart',
                      (route) => route.settings.name == '/restaurants',
                    );
                  }
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Error al agregar al carrito'),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar personalizada con imagen
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[900]!,
                      Colors.grey[800]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Imagen del producto
                    if (widget.product.imageUrl != null)
                      Positioned.fill(
                        child: Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                        ),
                      )
                    else
                      _buildPlaceholderImage(),
                    
                    // Overlay gradiente
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Información del producto en la imagen
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_basePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.orange[300],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Contenido principal
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descripción del producto
                        if (widget.product.description != null) ...[
                          Text(
                            'Descripción',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              widget.product.description!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        
                        // Modificadores
                        if (widget.product.modifierGroups.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.tune,
                                color: Colors.orange[600],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Personaliza tu pedido',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          ...widget.product.modifierGroups.asMap().entries.map(
                            (entry) => Padding(
                              padding: EdgeInsets.only(
                                bottom: entry.key < widget.product.modifierGroups.length - 1 ? 24 : 0,
                              ),
                              child: _buildModifierGroup(entry.value),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                        
                        // Selector de cantidad
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.orange[600],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Cantidad',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const Spacer(),
                              _buildQuantitySelector(),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 100), // Espacio para el botón flotante
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Botón flotante de agregar al carrito
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: FloatingActionButton.extended(
          onPressed: _canAddToCart() ? _addToCart : null,
          backgroundColor: _canAddToCart() ? Colors.orange[600] : Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: _canAddToCart() ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_shopping_cart,
                size: 24,
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Agregar al carrito',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Precio total flotante
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 16),
            Text(
              'Imagen no disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.remove,
                  color: _quantity > 1 ? Colors.orange[600] : Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              '$_quantity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              onTap: _quantity < 99 ? () => setState(() => _quantity++) : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.add,
                  color: _quantity < 99 ? Colors.orange[600] : Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifierGroup(ModifierGroup group) {
    final isRequired = group.minSelection > 0;
    final selectedCount = _selectedModifiers[group.id]?.length ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del grupo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    group.maxSelection == 1 ? Icons.radio_button_checked : Icons.checklist,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            group.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Selecciona ${group.minSelection}${group.maxSelection > group.minSelection ? ' - ${group.maxSelection}' : ''} opción${group.maxSelection > 1 ? 'es' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          if (isRequired) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Text(
                                'REQUERIDO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Opciones del grupo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...group.options.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildModifierOption(group, option),
                )),
                
                // Mensaje de validación
                if (isRequired && selectedCount < group.minSelection) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Debes seleccionar al menos ${group.minSelection} opción${group.minSelection > 1 ? 'es' : ''}',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifierOption(ModifierGroup group, ModifierOption option) {
    final isSelected = _selectedModifiers[group.id]?.contains(option.id) ?? false;
    final canSelect = group.maxSelection > (_selectedModifiers[group.id]?.length ?? 0) || isSelected;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSelect ? () => _handleModifierSelection(group.id, option.id, !isSelected) : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.orange[400]! : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? Colors.orange[50] : Colors.grey[25],
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              // Indicador de selección
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: group.maxSelection == 1 ? BoxShape.circle : BoxShape.rectangle,
                  border: Border.all(
                    color: isSelected ? Colors.orange[600]! : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? Colors.orange[600] : Colors.transparent,
                  borderRadius: group.maxSelection == 1 ? null : BorderRadius.circular(6),
                ),
                child: isSelected
                    ? Icon(
                        group.maxSelection == 1 ? Icons.check : Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Información de la opción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.orange[800] : Colors.grey[800],
                      ),
                    ),
                    if (option.price > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Precio adicional: +\$${option.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Precio
              if (option.price > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+\$${option.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Incluido',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
