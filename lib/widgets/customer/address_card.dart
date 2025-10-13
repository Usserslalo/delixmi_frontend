import 'package:flutter/material.dart';
import '../../models/address.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryOrange = Color(0xFFF2843A);
    const darkGray = Color(0xFF1A1A1A);
    const white = Color(0xFFFFFFFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryOrange : const Color(0xFFE0E0E0),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Área principal clickeable
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con alias y acciones
                  Row(
                    children: [
                      // Icono de tipo de dirección
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryOrange.withValues(alpha: 0.15)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getAddressIcon(address.alias),
                          color: isSelected ? primaryOrange : darkGray,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Alias y dirección
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.alias,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? primaryOrange : darkGray,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address.shortAddress,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF757575),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Indicador de selección
                      if (isSelectionMode)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? primaryOrange : const Color(0xFFE0E0E0),
                              width: 2,
                            ),
                            color: isSelected ? primaryOrange : Colors.transparent,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: white,
                                    size: 16,
                                    key: ValueKey('check'),
                                  )
                                : const SizedBox(
                                    key: ValueKey('empty'),
                                  ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Dirección completa
                  Text(
                    address.fullAddress,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF757575),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Referencias si existen
                  if (address.references != null && address.references!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryOrange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: primaryOrange,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address.references!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: primaryOrange,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Acciones con Material 3
          if (!isSelectionMode)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Botón editar
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryOrange,
                        side: const BorderSide(
                          color: primaryOrange,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Botón eliminar
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(
                          color: Color(0xFFD32F2F),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getAddressIcon(String alias) {
    final lowercaseAlias = alias.toLowerCase();
    
    if (lowercaseAlias.contains('casa') || lowercaseAlias.contains('hogar')) {
      return Icons.home;
    } else if (lowercaseAlias.contains('oficina') || lowercaseAlias.contains('trabajo')) {
      return Icons.work;
    } else if (lowercaseAlias.contains('escuela') || lowercaseAlias.contains('universidad')) {
      return Icons.school;
    } else if (lowercaseAlias.contains('familia') || lowercaseAlias.contains('padres')) {
      return Icons.family_restroom;
    } else {
      return Icons.location_on;
    }
  }
}

class AddressCardCompact extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback? onTap;

  const AddressCardCompact({
    super.key,
    required this.address,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue[200]! : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.location_on,
                  color: isSelected ? Colors.blue[600] : Colors.grey[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              
              // Información de la dirección
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.alias,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue[700] : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.shortAddress,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Indicador de selección
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.blue[600],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}