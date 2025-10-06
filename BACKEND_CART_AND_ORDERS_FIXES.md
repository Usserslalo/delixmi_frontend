# 🔧 Correcciones Urgentes: Carrito y Detalles de Pedidos

## 📋 Contexto
Estamos probando el flujo completo de pedidos y hemos encontrado dos problemas críticos que necesitan ser corregidos inmediatamente.

## 🚨 Problema 1: Carrito no se limpia al crear pedido

### **Descripción del Problema:**
Cuando se crea un pedido de pago en efectivo, el carrito del restaurante específico NO se elimina del backend, aunque el frontend lo marca como eliminado localmente.

### **Comportamiento Actual:**
1. ✅ Frontend limpia el carrito localmente
2. ❌ Backend mantiene el carrito en la base de datos
3. ❌ Al recargar, el carrito vuelve a aparecer

### **Logs del Frontend:**
```
🛒 RestaurantCartProvider: Limpiando carrito del restaurante 4...
✅ RestaurantCartProvider: Carrito del restaurante 4 limpiado exitosamente
🛒 RestaurantCartProvider: Carritos restantes: 1
```

### **Logs del Backend:**
```
💵 Iniciando creación de orden de pago en efectivo...
👤 Usuario: 11, Dirección: 3, Items: 1
✅ Orden creada con ID: 6
```

### **Pregunta para Backend:**
**¿El endpoint `/api/checkout/cash-order` debería limpiar automáticamente el carrito del restaurante específico cuando se crea el pedido?**

### **Solución Esperada:**
Cuando se crea un pedido de efectivo, el backend debería:
1. Crear el pedido
2. **Eliminar automáticamente** el carrito del restaurante específico
3. Devolver confirmación de que el carrito fue limpiado

---

## 🚨 Problema 2: Endpoint de detalles de pedido no existe

### **Descripción del Problema:**
El frontend intenta obtener detalles de un pedido específico pero el endpoint no existe en el backend.

### **Endpoint que falta:**
```
GET /api/customer/orders/:orderId
```

### **Logs del Frontend:**
```
📍 OrderService: Obteniendo detalles del pedido: 6
📍 OrderService: Respuesta de detalles: error
```

### **Pregunta para Backend:**
**¿Existe el endpoint para obtener detalles de un pedido específico? Si no existe, ¿cuál es el endpoint correcto?**

### **Datos que necesitamos del pedido:**
```json
{
  "id": "6",
  "orderNumber": "DEL-123",
  "status": "pending",
  "paymentMethod": "cash",
  "paymentStatus": "pending",
  "subtotal": 95.00,
  "deliveryFee": 20.00,
  "serviceFee": 4.75,
  "total": 119.75,
  "orderPlacedAt": "2024-01-15T10:00:00Z",
  "estimatedDeliveryTime": "30-45 min",
  "restaurant": {
    "id": 4,
    "name": "Sushi Master Kenji",
    "logoUrl": "https://...",
    "branch": {
      "id": 8,
      "name": "Sucursal Principal Sushi",
      "address": "Av. Juárez 85, Centro, Ixmiquilpan, Hgo.",
      "phone": "7714567890"
    }
  },
  "deliveryAddress": {
    "id": 3,
    "alias": "Casa",
    "street": "Av. Felipe Ángeles",
    "exteriorNumber": "21",
    "neighborhood": "San Nicolás",
    "city": "Ixmiquilpan",
    "state": "Hidalgo",
    "zipCode": "42300"
  },
  "items": [
    {
      "id": "item_123",
      "quantity": 1,
      "pricePerUnit": 95.00,
      "subtotal": 95.00,
      "product": {
        "id": 29,
        "name": "Nigiri de Atún",
        "imageUrl": "https://..."
      }
    }
  ]
}
```

---

## 🎯 Soluciones Requeridas

### **Solución 1: Limpieza automática del carrito**
```javascript
// En el endpoint POST /api/checkout/cash-order
// Después de crear el pedido exitosamente:

// Limpiar carrito del restaurante específico
await CartService.clearRestaurantCart(userId, restaurantId);

// Devolver respuesta con confirmación
return {
  status: 'success',
  message: 'Pedido creado y carrito limpiado exitosamente',
  data: {
    orderId: order.id,
    orderNumber: order.orderNumber,
    cartCleared: true
  }
};
```

### **Solución 2: Endpoint de detalles de pedido**
```javascript
// Crear endpoint GET /api/customer/orders/:orderId
app.get('/api/customer/orders/:orderId', authenticateToken, async (req, res) => {
  try {
    const { orderId } = req.params;
    const userId = req.user.id;
    
    // Verificar que el pedido pertenece al usuario
    const order = await Order.findOne({
      where: { id: orderId, userId: userId },
      include: [
        { model: Restaurant, include: [{ model: Branch }] },
        { model: Address },
        { model: OrderItem, include: [{ model: Product }] }
      ]
    });
    
    if (!order) {
      return res.status(404).json({
        status: 'error',
        message: 'Pedido no encontrado'
      });
    }
    
    // Formatear respuesta
    const formattedOrder = formatOrderResponse(order);
    
    res.json({
      status: 'success',
      data: formattedOrder
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Error al obtener detalles del pedido'
    });
  }
});
```

---

## 🚀 Prioridad

**URGENTE** - Estos problemas impiden que el flujo de pedidos funcione correctamente.

### **Orden de implementación:**
1. **Primero**: Endpoint de detalles de pedido (más rápido de implementar)
2. **Segundo**: Limpieza automática del carrito (requiere más cambios)

---

## 📞 Contacto

**Desarrollador Frontend:** [Tu nombre]
**Fecha:** 15 de Enero, 2024
**Prioridad:** URGENTE
**Tiempo estimado:** 1-2 horas

---

**Nota:** Necesitamos estas correcciones para continuar con las pruebas del flujo de pedidos. Una vez implementadas, podremos proceder con la integración de Mercado Pago.
