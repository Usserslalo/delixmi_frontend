# 🍕 Solicitud de Implementación: Flujo Completo de Pedidos

## 📋 Contexto
Estamos implementando el flujo completo de pedidos en la aplicación móvil Delixmi y necesitamos trabajar en sincronía con el backend para asegurar una implementación correcta y robusta.

## 🎯 Funcionalidades Requeridas

### 1. **Confirmación de Pedido (Vista de Confirmación Final)**
Necesitamos una vista de confirmación antes de procesar el pedido definitivamente.

**Preguntas para Backend:**
- ¿Existe un endpoint para crear un pedido en estado "pendiente" antes de la confirmación final?
- ¿Debemos enviar el pedido completo o solo una "reserva" temporal?
- ¿Cómo manejamos la expiración de pedidos no confirmados?
- ¿Qué datos necesitamos enviar en esta confirmación?

### 2. **Procesamiento Real de Pedidos**
Actualmente el frontend simula el procesamiento, necesitamos integración real.

**Preguntas para Backend:**
- ¿Cuál es el endpoint para crear un pedido definitivo?
- ¿Qué estructura de datos necesitamos enviar?
- ¿Qué validaciones se realizan en el backend?
- ¿Cómo manejamos errores de validación?
- ¿Qué respuesta devuelve el endpoint exitoso?

### 3. **Limpieza del Carrito**
Después de un pedido exitoso, el carrito debe limpiarse.

**Preguntas para Backend:**
- ¿El backend limpia automáticamente el carrito al crear un pedido?
- ¿Necesitamos llamar un endpoint específico para limpiar el carrito?
- ¿Cómo identificamos qué productos del carrito pertenecen al pedido procesado?

### 4. **Historial de Pedidos**
Los usuarios deben poder ver sus pedidos realizados.

**Preguntas para Backend:**
- ¿Cuál es el endpoint para obtener el historial de pedidos del usuario?
- ¿Qué estructura de datos devuelve?
- ¿Incluye estados de pedido (pendiente, confirmado, en preparación, en camino, entregado)?
- ¿Cómo paginamos los resultados?
- ¿Incluye detalles de productos, precios, fechas, etc.?

### 5. **Estados de Pedidos**
Necesitamos manejar diferentes estados de pedidos.

**Preguntas para Backend:**
- ¿Qué estados de pedido existen en el sistema?
- ¿Cómo actualizamos el estado de un pedido?
- ¿Hay notificaciones push cuando cambia el estado?
- ¿Cómo calculamos tiempos estimados de entrega?

## 🔄 Flujo Propuesto

### **Paso 1: Confirmación de Pedido**
```
Frontend → Backend: POST /api/orders/confirm
Body: {
  "restaurantId": 123,
  "items": [...],
  "deliveryAddress": {...},
  "paymentMethod": "cash|card",
  "total": 150.00,
  "estimatedDeliveryTime": "30-45 min"
}

Backend → Frontend: {
  "status": "success",
  "orderId": "ORD-123456",
  "confirmationToken": "abc123",
  "expiresAt": "2024-01-15T10:30:00Z"
}
```

### **Paso 2: Procesamiento Definitivo**
```
Frontend → Backend: POST /api/orders/process
Body: {
  "orderId": "ORD-123456",
  "confirmationToken": "abc123"
}

Backend → Frontend: {
  "status": "success",
  "orderId": "ORD-123456",
  "orderNumber": "DEL-789",
  "estimatedDeliveryTime": "30-45 min",
  "paymentStatus": "pending|completed"
}
```

### **Paso 3: Limpieza del Carrito**
```
Frontend → Backend: DELETE /api/cart/clear
Headers: { "Authorization": "Bearer token" }

Backend → Frontend: {
  "status": "success",
  "message": "Carrito limpiado exitosamente"
}
```

### **Paso 4: Obtener Historial**
```
Frontend → Backend: GET /api/orders/history
Headers: { "Authorization": "Bearer token" }
Query: { "page": 1, "limit": 20 }

Backend → Frontend: {
  "status": "success",
  "orders": [...],
  "pagination": {...}
}
```

## 📊 Estructura de Datos Esperada

### **Pedido (Order)**
```json
{
  "id": "ORD-123456",
  "orderNumber": "DEL-789",
  "userId": 123,
  "restaurantId": 456,
  "restaurantName": "Sushi Master Kenji",
  "items": [
    {
      "productId": 789,
      "productName": "Nigiri de Atún",
      "quantity": 2,
      "unitPrice": 95.00,
      "subtotal": 190.00
    }
  ],
  "deliveryAddress": {
    "id": 101,
    "alias": "Casa",
    "fullAddress": "Calle Hidalgo, 125, Centro, Ixmiquilpan, Hidalgo, 42300",
    "latitude": 20.480377,
    "longitude": -99.218668
  },
  "paymentMethod": "cash",
  "paymentStatus": "pending",
  "orderStatus": "confirmed",
  "subtotal": 190.00,
  "deliveryFee": 25.00,
  "serviceFee": 9.50,
  "total": 224.50,
  "estimatedDeliveryTime": "30-45 min",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### **Historial de Pedidos**
```json
{
  "status": "success",
  "orders": [
    {
      "id": "ORD-123456",
      "orderNumber": "DEL-789",
      "restaurantName": "Sushi Master Kenji",
      "status": "delivered",
      "total": 224.50,
      "createdAt": "2024-01-15T10:00:00Z",
      "itemsCount": 2
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalOrders": 23,
    "hasNext": true,
    "hasPrev": false
  }
}
```

## 🔐 Validaciones y Seguridad

### **Preguntas de Seguridad:**
- ¿Qué validaciones de autorización necesitamos?
- ¿Cómo verificamos que el usuario puede pedir de ese restaurante?
- ¿Validamos la zona de cobertura de entrega?
- ¿Cómo manejamos pagos con tarjeta?
- ¿Hay límites de tiempo para confirmar pedidos?

### **Validaciones de Negocio:**
- ¿El restaurante está abierto?
- ¿Los productos están disponibles?
- ¿La dirección está en zona de cobertura?
- ¿El monto mínimo del pedido se cumple?
- ¿Hay restricciones por horario de entrega?

## 🚨 Manejo de Errores

### **Errores Comunes Esperados:**
- Restaurante cerrado
- Producto no disponible
- Dirección fuera de cobertura
- Error de pago
- Timeout de confirmación
- Carrito vacío
- Usuario no autenticado

### **Preguntas:**
- ¿Qué códigos de error específicos devuelve cada endpoint?
- ¿Cómo estructuramos los mensajes de error?
- ¿Hay errores que requieren reintento automático?

## 📱 Integración con Frontend

### **Estados de UI Necesarios:**
- Cargando confirmación
- Confirmación pendiente (con countdown)
- Procesando pedido
- Pedido exitoso
- Error en pedido
- Carrito vacío
- Historial cargando
- Historial vacío

### **Notificaciones:**
- ¿Hay notificaciones push para cambios de estado?
- ¿Cómo configuramos los webhooks?
- ¿Qué eventos notificamos al usuario?

## 🎯 Próximos Pasos

1. **Backend responde** con la documentación de APIs
2. **Frontend implementa** según especificaciones exactas
3. **Testing conjunto** de flujo completo
4. **Ajustes** basados en pruebas reales

## 📞 Contacto

**Desarrollador Frontend:** [Tu nombre]
**Fecha:** 15 de Enero, 2024
**Prioridad:** Alta
**Tiempo estimado:** 2-3 días después de recibir documentación

---

**Nota:** Necesitamos trabajar en sincronía para evitar implementaciones incorrectas. Preferimos esperar la documentación correcta antes de codificar.
