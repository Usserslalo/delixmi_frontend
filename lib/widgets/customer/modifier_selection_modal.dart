import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ModifierSelectionModal extends StatefulWidget {
  final Product product;
  final int restaurantId;

  const ModifierSelectionModal({
    super.key,
    required this.product,
    required this.restaurantId,
  });

  @override
  State<ModifierSelectionModal> createState() => _ModifierSelectionModalState();
}

class _ModifierSelectionModalState extends State<ModifierSelectionModal> {
  // Mapa para almacenar las selecciones: groupId -> List<optionIds>
  final Map<int, List<int>> _selectedOptions = {};
  int _quantity = 1;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    // Inicializar selecciones según minSelection
    for (final group in widget.product.modifierGroups) {
      if (group.isRequired && group.options.isNotEmpty) {
        // Si es requerido, seleccionar la primera opción por defecto
        _selectedOptions[group.id] = [group.options.first.id];
      } else {
        _selectedOptions[group.id] = [];
      }
    }
  }

  void _onOptionSelected(ModifierGroup group, ModifierOption option, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (group.isSingleSelection) {
          // Para selección única, reemplazar la selección actual
          _selectedOptions[group.id] = [option.id];
        } else {
          // Para selección múltiple, agregar a la lista
          final currentSelections = _selectedOptions[group.id] ?? [];
          if (currentSelections.length < group.maxSelection) {
            _selectedOptions[group.id] = [...currentSelections, option.id];
          }
        }
      } else {
        // Remover de la selección
        final currentSelections = _selectedOptions[group.id] ?? [];
        _selectedOptions[group.id] = currentSelections.where((id) => id != option.id).toList();
      }
    });
  }

  bool _isOptionSelected(ModifierGroup group, ModifierOption option) {
    return _selectedOptions[group.id]?.contains(option.id) ?? false;
  }

  bool _canSelectMore(ModifierGroup group) {
    final currentCount = _selectedOptions[group.id]?.length ?? 0;
    return currentCount < group.maxSelection;
  }

  bool _isValidSelection() {
    for (final group in widget.product.modifierGroups) {
      final selectedCount = _selectedOptions[group.id]?.length ?? 0;
      if (selectedCount < group.minSelection || selectedCount > group.maxSelection) {
        return false;
      }
    }
    return true;
  }

  double _calculateTotalPrice() {
    double total = widget.product.price * _quantity;
    
    for (final group in widget.product.modifierGroups) {
      final selectedIds = _selectedOptions[group.id] ?? [];
      for (final optionId in selectedIds) {
        final option = group.options.firstWhere((opt) => opt.id == optionId);
        total += option.price * _quantity;
      }
    }
    
    return total;
  }

  List<int> _getSelectedOptionIds() {
    final List<int> allSelectedIds = [];
    for (final selectedIds in _selectedOptions.values) {
      allSelectedIds.addAll(selectedIds);
    }
    return allSelectedIds;
  }

  Future<void> _addToCart() async {
    if (!_isValidSelection()) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final cartProvider = context.read<CartProvider>();
      final selectedOptionIds = _getSelectedOptionIds();
      
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
              content: Text('${widget.product.name} agregado al carrito'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle para arrastrar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.product.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.product.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Precio base: ${widget.product.formattedPrice}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total: \$${_calculateTotalPrice().toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Contenido scrolleable
              Expanded(
                child: widget.product.modifierGroups.isEmpty
                    ? _buildNoModifiersContent()
                    : _buildModifiersContent(scrollController),
              ),
              
              // Footer con cantidad y botón
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Column(
                  children: [
                    // Selector de cantidad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_quantity',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _quantity < 99 ? () => setState(() => _quantity++) : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botón agregar al carrito
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isValidSelection() && !_isAdding ? _addToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isAdding
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Agregar al carrito - \$${_calculateTotalPrice().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoModifiersContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Este producto no tiene opciones adicionales',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModifiersContent(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.product.modifierGroups.length,
      itemBuilder: (context, index) {
        final group = widget.product.modifierGroups[index];
        return _buildModifierGroup(group);
      },
    );
  }

  Widget _buildModifierGroup(ModifierGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del grupo
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: group.isRequired 
                        ? Colors.red[100] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.isRequired ? 'Requerido' : 'Opcional',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: group.isRequired 
                          ? Colors.red[700] 
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Descripción de selección
            Text(
              group.isSingleSelection
                  ? 'Selecciona ${group.minSelection > 0 ? '1' : 'hasta 1'} opción'
                  : 'Selecciona ${group.minSelection}-${group.maxSelection} opciones',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Opciones
            ...group.options.map((option) => _buildModifierOption(group, option)),
            
            // Mensaje de validación si es necesario
            if (group.isRequired && (_selectedOptions[group.id]?.isEmpty ?? true)) ...[
              const SizedBox(height: 8),
              Text(
                'Debes seleccionar al menos ${group.minSelection} opción${group.minSelection > 1 ? 'es' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModifierOption(ModifierGroup group, ModifierOption option) {
    final isSelected = _isOptionSelected(group, option);
    final canSelect = isSelected || _canSelectMore(group);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: group.isSingleSelection
          ? RadioListTile<int>(
              title: Text(option.name),
              subtitle: option.price > 0 ? Text(option.formattedPrice) : null,
              value: option.id,
              groupValue: _selectedOptions[group.id]?.isNotEmpty == true 
                  ? _selectedOptions[group.id]!.first 
                  : null,
              onChanged: canSelect 
                  ? (value) => _onOptionSelected(group, option, value == option.id)
                  : null,
              contentPadding: EdgeInsets.zero,
              activeColor: Theme.of(context).colorScheme.primary,
            )
          : CheckboxListTile(
              title: Text(option.name),
              subtitle: option.price > 0 ? Text(option.formattedPrice) : null,
              value: isSelected,
              onChanged: canSelect 
                  ? (value) => _onOptionSelected(group, option, value ?? false)
                  : null,
              contentPadding: EdgeInsets.zero,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
    );
  }
}
