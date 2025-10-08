// Ejemplo de uso del CartService con soporte para modificadores
// Este archivo es solo para documentación y ejemplos

import '../services/cart_service.dart';

class CartWithModifiersExample {
  /// Ejemplo de agregar un producto básico al carrito (sin modificadores)
  static Future<void> addBasicProduct() async {
    final response = await CartService.addToCart(
      productId: 1,
      quantity: 2,
    );
    
    if (response.isSuccess) {
      print('✅ Producto agregado exitosamente');
    } else {
      print('❌ Error: ${response.message}');
    }
  }

  /// Ejemplo de agregar un producto con modificadores
  /// Supongamos que queremos una Pizza Margherita grande con orilla rellena de queso
  static Future<void> addProductWithModifiers() async {
    final response = await CartService.addToCart(
      productId: 1, // Pizza Margherita
      quantity: 1,
      modifierOptionIds: [
        3,  // ID 3: Tamaño Grande
        27, // ID 27: Orilla Rellena de Queso
      ],
    );
    
    if (response.isSuccess) {
      print('✅ Pizza Margherita Grande con orilla rellena agregada');
      print('📊 Respuesta: ${response.data}');
    } else {
      print('❌ Error: ${response.message}');
    }
  }

  /// Ejemplo de agregar múltiples productos con diferentes modificadores
  static Future<void> addMultipleProductsWithModifiers() async {
    // Producto 1: Pizza Hawaiana Mediana con extra queso
    final response1 = await CartService.addToCart(
      productId: 2, // Pizza Hawaiana
      quantity: 1,
      modifierOptionIds: [
        2, // ID 2: Tamaño Mediana
        5, // ID 5: Extra Queso
      ],
    );

    // Producto 2: Pizza Pepperoni Pequeña sin cebolla
    final response2 = await CartService.addToCart(
      productId: 3, // Pizza Pepperoni
      quantity: 2,
      modifierOptionIds: [
        1,  // ID 1: Tamaño Pequeña
        10, // ID 10: Sin Cebolla
      ],
    );

    if (response1.isSuccess && response2.isSuccess) {
      print('✅ Ambos productos agregados exitosamente');
    } else {
      print('❌ Error en uno o ambos productos');
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
