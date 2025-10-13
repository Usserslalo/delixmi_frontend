// Guía de Integración de Modificadores de Productos
// Este archivo documenta cómo usar la nueva funcionalidad de modificadores

/*
INTEGRACIÓN DE MODIFICADORES DE PRODUCTOS - GUÍA COMPLETA
========================================================

## 1. ESTRUCTURA DE DATOS

### Product Model
El modelo Product ahora incluye un campo `modifierGroups`:

```dart
class Product {
  // ... otros campos ...
  final List<ModifierGroup> modifierGroups;
}
```

### ModifierGroup Model
Representa un grupo de modificadores (ej: "Tamaño", "Extras"):

```dart
class ModifierGroup {
  final int id;
  final String name;           // "Tamaño", "Extras", etc.
  final int minSelection;      // Mínimo de opciones requeridas
  final int maxSelection;      // Máximo de opciones permitidas
  final List<ModifierOption> options;
}
```

### ModifierOption Model
Representa una opción individual dentro de un grupo:

```dart
class ModifierOption {
  final int id;
  final String name;           // "Grande", "Extra Queso", etc.
  final double price;          // Precio adicional (puede ser 0)
}
```

## 2. FLUJO DE USUARIO

### Pantalla de Detalle del Restaurante
Cuando un usuario toca "Agregar" en un producto:

1. **Verificación de Modificadores**: Se verifica si `product.modifierGroups.isNotEmpty`
2. **Producto SIN modificadores**: Se agrega directamente al carrito
3. **Producto CON modificadores**: Se muestra el modal de selección

```dart
void _addToCart(Product product) {
  if (product.modifierGroups.isNotEmpty) {
    // Mostrar modal de selección
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModifierSelectionModal(
        product: product,
        restaurantId: widget.restaurantId,
      ),
    );
  } else {
    // Agregar directamente
    _addProductDirectly(product);
  }
}
```

### Modal de Selección de Modificadores
El modal permite:

1. **Selección de Opciones**: Radio buttons para selección única, checkboxes para múltiple
2. **Validación**: Respeta `minSelection` y `maxSelection` de cada grupo
3. **Cálculo de Precio**: Muestra precio base + modificadores seleccionados
4. **Selector de Cantidad**: Permite elegir cantidad del producto
5. **Agregar al Carrito**: Llama al servicio con los modificadores seleccionados

## 3. SERVICIOS ACTUALIZADOS

### CartService.addToCart()
Ahora acepta modificadores:

```dart
static Future<ApiResponse<Map<String, dynamic>>> addToCart({
  required int productId,
  required int quantity,
  List<int>? modifierOptionIds,  // ← NUEVO PARÁMETRO
}) async
```

### CartProvider.addToCart()
También actualizado para soportar modificadores:

```dart
Future<bool> addToCart({
  required int productId,
  required int quantity,
  List<int>? modifierOptionIds,  // ← NUEVO PARÁMETRO
}) async
```

## 4. VISUALIZACIÓN EN EL CARRITO

### RestaurantCartWidget
Ahora muestra los modificadores seleccionados:

```dart
// Para cada item en el carrito
if (item.modifiers.isNotEmpty) {
  // Mostrar modificadores como:
  // "+ Extra Queso ($15.00)"
  // "+ Orilla Rellena ($25.00)"
}
```

## 5. EJEMPLO DE DATOS DE PRUEBA

```dart
Product(
  id: 1,
  name: 'Pizza Hawaiana',
  price: 150.00,
  modifierGroups: [
    ModifierGroup(
      id: 1,
      name: 'Tamaño',
      minSelection: 1,    // Requerido
      maxSelection: 1,    // Solo uno
      options: [
        ModifierOption(id: 1, name: 'Pequeña', price: 0.0),
        ModifierOption(id: 2, name: 'Mediana', price: 20.0),
        ModifierOption(id: 3, name: 'Grande', price: 40.0),
      ],
    ),
    ModifierGroup(
      id: 2,
      name: 'Extras',
      minSelection: 0,    // Opcional
      maxSelection: 3,    // Hasta 3
      options: [
        ModifierOption(id: 5, name: 'Extra Queso', price: 15.0),
        ModifierOption(id: 27, name: 'Orilla Rellena', price: 25.0),
      ],
    ),
  ],
)
```

## 6. ESTRUCTURA DE RESPUESTA DEL BACKEND

Cuando se agrega un producto con modificadores, el backend responde:

```json
{
  "status": "success",
  "data": {
    "cartItem": {
      "id": 1,
      "product": { ... },
      "quantity": 1,
      "priceAtAdd": 220.00,  // Precio base + modificadores
      "subtotal": 220.00,
      "modifiers": [
        {
          "id": 3,
          "name": "Grande",
          "price": 40.00,
          "group": {
            "id": 1,
            "name": "Tamaño"
          }
        },
        {
          "id": 5,
          "name": "Extra Queso",
          "price": 15.00,
          "group": {
            "id": 2,
            "name": "Extras"
          }
        }
      ]
    }
  }
}
```

## 7. COMPATIBILIDAD

- **Retrocompatibilidad**: Productos sin modificadores siguen funcionando igual
- **Opcional**: El parámetro `modifierOptionIds` es opcional en todos los servicios
- **Fallback**: Si no hay modificadores, se envía `null` o lista vacía

## 8. TESTING

Para probar la funcionalidad:

1. **Producto sin modificadores**: Debe agregarse directamente al carrito
2. **Producto con modificadores**: Debe mostrar el modal de selección
3. **Selección válida**: Debe agregar al carrito con modificadores
4. **Selección inválida**: Debe mostrar errores de validación
5. **Visualización**: El carrito debe mostrar los modificadores seleccionados

## 9. ARCHIVOS MODIFICADOS

- `lib/models/product.dart` - Agregados ModifierGroup y ModifierOption
- `lib/models/cart_item.dart` - Soporte para modificadores en items
- `lib/models/cart_modifier.dart` - Modelo para modificadores del carrito
- `lib/services/cart_service.dart` - Soporte para modifierOptionIds
- `lib/providers/cart_provider.dart` - Soporte para modificadores
- `lib/widgets/customer/modifier_selection_modal.dart` - Modal de selección
- `lib/screens/customer/restaurant_detail_screen.dart` - Integración del modal
- `lib/widgets/customer/restaurant_cart_widget.dart` - Visualización de modificadores

## 10. PRÓXIMOS PASOS

1. **Backend**: Asegurar que el backend devuelva modifierGroups en la respuesta de productos
2. **Validación**: Implementar validación más robusta en el frontend
3. **UI/UX**: Mejorar el diseño del modal según feedback de usuarios
4. **Testing**: Crear tests unitarios para la funcionalidad de modificadores
5. **Performance**: Optimizar el renderizado de productos con muchos modificadores
*/
