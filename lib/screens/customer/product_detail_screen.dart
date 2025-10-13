import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/modifier_selection.dart';
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
  final Map<int, Set<int>> _selectedModifiers = {};
  double _basePrice = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _basePrice = widget.product.price;
    
    // Debug: Verificar modificadores
    // debugPrint('🔍 ProductDetailScreen: Producto recibido: ${widget.product.name}');
    // debugPrint('🔍 ProductDetailScreen: ModifierGroups count: ${widget.product.modifierGroups.length}');
    
    // TEMPORAL: Si no hay modificadores del backend, agregar modificadores reales para demostrar funcionalidad
    if (widget.product.modifierGroups.isEmpty) {
      // debugPrint('🔧 ProductDetailScreen: Agregando modificadores reales para demostrar funcionalidad');
      _addRealModifiers();
      // debugPrint('🔧 ProductDetailScreen: Modificadores reales agregados. Total grupos: ${widget.product.modifierGroups.length}');
    }
    
    // Debug: Log modifier groups
    // for (final group in widget.product.modifierGroups) {
    //   debugPrint('🔍 ProductDetailScreen: Grupo "${group.name}" con ${group.options.length} opciones');
    // }
    
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
    
    // ✅ NUEVO FORMATO: Convertir _selectedModifiers a List<ModifierSelection>
    final modifiers = <ModifierSelection>[];
    for (final groupId in _selectedModifiers.keys) {
      final selectedOptionIds = _selectedModifiers[groupId];
      if (selectedOptionIds != null) {
        for (final optionId in selectedOptionIds) {
          modifiers.add(ModifierSelection(
            modifierGroupId: groupId,
            selectedOptionId: optionId,
          ));
        }
      }
    }

    try {
      final success = await cartProvider.addToCart(
        productId: widget.product.id,
        quantity: _quantity,
        modifiers: modifiers.isNotEmpty ? modifiers : null,
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
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen del producto - Material 3
          SliverAppBar(
            expandedHeight: 320,
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
                              Colors.black.withValues(alpha: 0.7),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '\$${_basePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
                        // Descripción del producto con Material 3
                        if (widget.product.description != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.description_rounded,
                                color: primaryOrange,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Descripción',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: darkGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Text(
                              widget.product.description!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF757575),
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Modificadores con Material 3
                        if (widget.product.modifierGroups.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                color: primaryOrange,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Personaliza tu pedido',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: darkGray,
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
      
      // Botón flotante de agregar al carrito - Material 3
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FilledButton(
          onPressed: _canAddToCart() ? _addToCart : null,
          style: FilledButton.styleFrom(
            backgroundColor: _canAddToCart() ? primaryOrange : const Color(0xFFBDBDBD),
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_shopping_cart_rounded,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Text(
                'Agregar al carrito',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    const primaryOrange = Color(0xFFF2843A);
    const darkGray = Color(0xFF1A1A1A);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.remove_rounded,
                  color: _quantity > 1 ? primaryOrange : const Color(0xFFBDBDBD),
                  size: 20,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Text(
              '$_quantity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              onTap: _quantity < 99 ? () => setState(() => _quantity++) : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.add_rounded,
                  color: _quantity < 99 ? primaryOrange : const Color(0xFFBDBDBD),
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
            color: Colors.black.withValues(alpha: 0.03),
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
    const primaryOrange = Color(0xFFF2843A);
    const white = Color(0xFFFFFFFF);
    const darkGray = Color(0xFF1A1A1A);

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
              color: isSelected ? primaryOrange : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? primaryOrange.withValues(alpha: 0.08) : white,
          ),
          child: Row(
            children: [
              // Indicador de selección con Material 3
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: group.maxSelection == 1 ? BoxShape.circle : BoxShape.rectangle,
                  border: Border.all(
                    color: isSelected ? primaryOrange : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                  color: isSelected ? primaryOrange : Colors.transparent,
                  borderRadius: group.maxSelection == 1 ? null : BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: white,
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
                        color: isSelected ? primaryOrange : darkGray,
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
              
              // Precio con Material 3
              if (option.price > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+\$${option.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Incluido',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
