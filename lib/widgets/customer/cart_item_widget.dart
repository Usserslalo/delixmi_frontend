import 'package:flutter/material.dart';
import '../../models/cart_item.dart';

class CartItemWidget extends StatefulWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateButtonPress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Eliminar Producto',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que quieres eliminar este producto del carrito?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.item.productImage.isNotEmpty
                            ? Image.network(
                                widget.item.productImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.restaurant_rounded,
                                    color: colorScheme.primary,
                                    size: 20,
                                  );
                                },
                              )
                            : Icon(
                                Icons.restaurant_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.productName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cantidad: ${widget.item.quantity}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Botón Cancelar
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Botón Eliminar
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Llamar directamente al callback sin mostrar otro diálogo
                widget.onRemove();
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_rounded,
                    size: 18,
                    color: colorScheme.onError,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Eliminar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila principal: Imagen + Info + Botón eliminar
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      // Imagen del producto - Compacta y limpia
                            Container(
                        width: 80,
                        height: 80,
                              decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: colorScheme.surfaceContainerHighest,
                              ),
                              child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                                child: widget.item.productImage.isNotEmpty
                                    ? Image.network(
                                        widget.item.productImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                              Icons.restaurant_rounded,
                                              color: colorScheme.primary,
                                      size: 32,
                                          );
                                        },
                                      )
                              : Icon(
                                          Icons.restaurant_rounded,
                                          color: colorScheme.primary,
                                  size: 32,
                                        ),
                                      ),
                              ),
                      
                      const SizedBox(width: 16),
                            
                      // Información del producto - Expandida para mostrar todo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                            // Nombre del producto - Completo y visible
                            Text(
                                          widget.item.productName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                fontSize: 16,
                                height: 1.3,
                                          ),
                                          maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                            
                            // Descripción del producto - NUEVO: Mostrar descripción si existe
                            if (widget.item.productDescription.isNotEmpty) ...[
                              const SizedBox(height: 6),
                                                  Text(
                                        widget.item.productDescription,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                  height: 1.3,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                            ],
                            
                            const SizedBox(height: 8),
                            
                            // Modificadores - DISEÑO EXTENDIDO Y COMPLETO
                            if (widget.item.modifiers.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                  ],
                                ],
                              ),
                            ),
                            
                      const SizedBox(width: 12),
                      
                      // Botón eliminar - Limpio y funcional
                      IconButton(
                                onPressed: () {
                                  _animateButtonPress();
                          _showDeleteConfirmationDialog(context);
                                },
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                          minimumSize: const Size(40, 40),
                          maximumSize: const Size(40, 40),
                          backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                  // SECCIÓN DE MODIFICADORES EXTENDIDA - USANDO TODO EL ANCHO
                  if (widget.item.modifiers.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header de Personalización
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 18,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Personalización',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Modificadores con diseño extendido
                          ...widget.item.modifiers.map((modifier) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Indicador visual mejorado
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Nombre del modificador - Expandido
                                Expanded(
                                  child: Text(
                                    modifier.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Precio del modificador - Destacado
                                if (modifier.price > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colorScheme.primary.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '+\$${modifier.price.toStringAsFixed(2)}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Fila inferior: Controles de cantidad + Precio final
                  // MANTENIENDO EXACTAMENTE COMO ESTABA - SIN CAMBIOS
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                colorScheme.primaryContainer.withValues(alpha: 0.1),
                                colorScheme.secondaryContainer.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Controles de cantidad mejorados
                              _buildPremiumQuantityControls(theme),
                              
                              const Spacer(),
                              
                              // Subtotal con diseño premium
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.primary.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_rounded,
                                      color: colorScheme.onPrimary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${widget.item.subtotal.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onPrimary,
                                        fontSize: 16,
                                ),
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
        );
      },
    );
  }

  Widget _buildPremiumQuantityControls(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón decrementar premium
          _buildPremiumButton(
            icon: Icons.remove_rounded,
            onPressed: widget.item.quantity <= 1 
                ? null 
                : () {
                    _animateButtonPress();
                    widget.onQuantityChanged(widget.item.quantity - 1);
                  },
            color: widget.item.quantity <= 1 
                ? colorScheme.surfaceContainerHighest
                : colorScheme.error,
            isEnabled: widget.item.quantity > 1,
            colorScheme: colorScheme,
          ),
          
          // Separador vertical
          Container(
            height: 32,
            width: 1,
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
          
          // Cantidad actual con diseño premium
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '${widget.item.quantity}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
          
          // Separador vertical
          Container(
            height: 32,
            width: 1,
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
          
          // Botón incrementar premium
          _buildPremiumButton(
            icon: Icons.add_rounded,
            onPressed: () {
              _animateButtonPress();
              widget.onQuantityChanged(widget.item.quantity + 1);
            },
            color: colorScheme.primary,
            isEnabled: true,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required bool isEnabled,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: isEnabled 
                ? LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isEnabled ? null : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isEnabled ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            color: isEnabled 
                ? colorScheme.onPrimary 
                : colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}