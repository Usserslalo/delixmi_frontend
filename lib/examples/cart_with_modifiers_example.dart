// Ejemplo de uso del CartService con soporte para modificadores
// Este archivo es solo para documentación y ejemplos

import 'package:flutter/foundation.dart';
import '../services/cart_service.dart';
import '../models/modifier_selection.dart';

class CartWithModifiersExample {
  /// Ejemplo de agregar un producto básico al carrito (sin modificadores)
  static Future<void> addBasicProduct() async {
    final response = await CartService.addToCart(
      productId: 1,
      quantity: 2,
    );
    
    if (response.isSuccess) {
      debugPrint('✅ Producto agregado exitosamente');
    } else {
      debugPrint('❌ Error: ${response.message}');
    }
  }

  /// Ejemplo de agregar un producto con modificadores
  /// Supongamos que queremos una Pizza Margherita grande con orilla rellena de queso
  static Future<void> addProductWithModifiers() async {
    // ✅ NUEVO FORMATO: Usar ModifierSelection
    final modifiers = [
      ModifierSelection(modifierGroupId: 1, selectedOptionId: 3),  // Grupo 1: Tamaño, Opción 3: Grande
      ModifierSelection(modifierGroupId: 2, selectedOptionId: 27), // Grupo 2: Extras, Opción 27: Orilla Rellena
    ];
    
    final response = await CartService.addToCart(
      productId: 1, // Pizza Margherita
      quantity: 1,
      modifiers: modifiers,
    );
    
    if (response.isSuccess) {
      debugPrint('✅ Pizza Margherita Grande con orilla rellena agregada');
      debugPrint('📊 Respuesta: ${response.data}');
    } else {
      debugPrint('❌ Error: ${response.message}');
    }
  }

  /// Ejemplo de agregar múltiples productos con diferentes modificadores
  static Future<void> addMultipleProductsWithModifiers() async {
    // Producto 1: Pizza Hawaiana Mediana con extra queso
    final modifiers1 = [
      ModifierSelection(modifierGroupId: 1, selectedOptionId: 2), // Grupo 1: Tamaño, Opción 2: Mediana
      ModifierSelection(modifierGroupId: 2, selectedOptionId: 5), // Grupo 2: Extras, Opción 5: Extra Queso
    ];
    
    final response1 = await CartService.addToCart(
      productId: 2, // Pizza Hawaiana
      quantity: 1,
      modifiers: modifiers1,
    );

    // Producto 2: Pizza Pepperoni Pequeña sin cebolla
    final modifiers2 = [
      ModifierSelection(modifierGroupId: 1, selectedOptionId: 1),  // Grupo 1: Tamaño, Opción 1: Pequeña
      ModifierSelection(modifierGroupId: 3, selectedOptionId: 10), // Grupo 3: Ingredientes, Opción 10: Sin Cebolla
    ];
    
    final response2 = await CartService.addToCart(
      productId: 3, // Pizza Pepperoni
      quantity: 2,
      modifiers: modifiers2,
    );

    if (response1.isSuccess && response2.isSuccess) {
      debugPrint('✅ Ambos productos agregados exitosamente');
    } else {
      debugPrint('❌ Error en uno o ambos productos');
    }
  }
}

/*
ESTRUCTURA DE LA RESPUESTA DEL BACKEND:

Cuando agregamos un producto con modificadores, el backend responde con:

{
  "status": "success",
  "message": "Producto agregado al carrito exitosamente",
  "data": {
    "cartItem": {
      "id": 1,
      "product": {
        "id": 1,
        "name": "Pizza Margherita",
        "description": "Salsa de tomate, mozzarella fresca y albahaca",
        "imageUrl": "https://example.com/products/margherita.jpg",
        "price": 180.00,
        "isAvailable": true
      },
      "quantity": 1,
      "priceAtAdd": 220.00, // Precio base + modificadores
      "subtotal": 220.00,
      "modifiers": [
        {
          "id": 3,
          "name": "Grande",
          "price": 20.00,
          "group": {
            "id": 1,
            "name": "Tamaño"
          }
        },
        {
          "id": 27,
          "name": "Orilla Rellena de Queso",
          "price": 20.00,
          "group": {
            "id": 2,
            "name": "Extras"
          }
        }
      ]
    },
    "action": "item_added"
  }
}

ESTRUCTURA DEL CARRITO COMPLETO:

Cuando obtenemos el carrito completo con getCart(), la respuesta incluye:

{
  "status": "success",
  "data": {
    "carts": [
      {
        "id": 1,
        "restaurant": {
          "id": 1,
          "name": "Pizzería de Ana",
          "logoUrl": "https://example.com/logos/pizzeria-ana.jpg"
        },
        "items": [
          {
            "id": 1,
            "product": { ... },
            "quantity": 1,
            "priceAtAdd": 220.00,
            "subtotal": 220.00,
            "modifiers": [
              {
                "id": 3,
                "name": "Grande",
                "price": 20.00,
                "group": {
                  "id": 1,
                  "name": "Tamaño"
                }
              }
            ]
          }
        ],
        "totals": {
          "subtotal": 220.00,
          "deliveryFee": 25.00,
          "total": 245.00
        }
      }
    ]
  }
}
*/
