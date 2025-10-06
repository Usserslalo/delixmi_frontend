# 🛒 SOLICITUD DE IMPLEMENTACIÓN DE CARRITO DE COMPRAS - DELIXMI

## 📋 CONTEXTO ACTUAL DEL FRONTEND

**Estado del proyecto Flutter:**
- ✅ Autenticación completa (login, registro, verificación, reset password)
- ✅ Pantalla Home con lista de restaurantes
- ✅ Pantalla de detalle de restaurante funcionando
- ✅ Menú completo con categorías, subcategorías y productos
- ✅ Parsing correcto de datos del backend
- ✅ UI responsive y moderna

**Arquitectura actual:**
- Flutter con StatefulWidget
- ApiService para comunicación con backend
- Modelos: User, Restaurant, Product, Category, Subcategory
- Navegación con rutas nombradas
- Deep linking implementado

## 🎯 OBJETIVO

Implementar un **sistema de carrito de compras completo y profesional** que permita:

1. **Agregar productos al carrito** desde la pantalla de detalle del restaurante
2. **Gestionar cantidades** (incrementar/decrementar)
3. **Calcular totales** automáticamente
4. **Persistir el carrito** entre sesiones
5. **Validar disponibilidad** de productos
6. **Manejar múltiples restaurantes** (limpiar carrito si cambia restaurante)
7. **Integrar con checkout** y pagos

## 📱 FUNCIONALIDADES ESPERADAS EN FRONTEND

### 1. **Gestión de Estado del Carrito**
- Agregar/remover productos
- Actualizar cantidades
- Calcular subtotal, impuestos, envío, total
- Validar disponibilidad
- Limpiar carrito

### 2. **UI Components**
- Botón "Agregar" en productos
- Badge con cantidad en carrito
- Pantalla de carrito completa
- Resumen de pedido
- Botón de checkout

### 3. **Persistencia**
- Guardar carrito localmente
- Sincronizar con backend
- Manejar sesiones

## 🔧 PREGUNTAS ESPECÍFICAS PARA EL BACKEND

### **1. ESTRUCTURA DE DATOS**
```
¿Cómo debe estructurarse el carrito en el backend?
- ¿Qué campos debe tener cada item del carrito?
- ¿Cómo manejar productos de diferentes restaurantes?
- ¿Qué validaciones aplicar?
```

### **2. ENDPOINTS NECESARIOS**
```
¿Qué endpoints necesito para el carrito?
- POST /api/cart/add-item
- GET /api/cart/items
- PUT /api/cart/update-item/:id
- DELETE /api/cart/remove-item/:id
- POST /api/cart/clear
- GET /api/cart/total
```

### **3. VALIDACIONES Y REGLAS DE NEGOCIO**
```
¿Qué validaciones debo implementar?
- ¿Puede un usuario tener productos de múltiples restaurantes?
- ¿Qué pasa si un producto ya no está disponible?
- ¿Cómo manejar cambios de precio?
- ¿Hay límites de cantidad por producto?
```

### **4. INTEGRACIÓN CON CHECKOUT**
```
¿Cómo se integra el carrito con el checkout?
- ¿Qué datos necesito para crear un pedido?
- ¿Cómo manejar la transición carrito → pedido?
- ¿Qué pasa con el carrito después del checkout?
```

### **5. PERSISTENCIA Y SINCRONIZACIÓN**
```
¿Cómo manejar la persistencia?
- ¿Guardar carrito en localStorage y sincronizar con backend?
- ¿Qué pasa si hay conflictos entre local y backend?
- ¿Cómo manejar usuarios no autenticados?
```

### **6. MANEJO DE ERRORES**
```
¿Qué errores puedo esperar?
- Producto no disponible
- Cambio de precio
- Restaurante cerrado
- Límites de cantidad
```

## 🎨 DISEÑO ESPERADO

### **Pantalla de Carrito:**
```
┌─────────────────────────────┐
│ ← Carrito (3 items)         │
├─────────────────────────────┤
│ 🍕 Pizzería de Ana          │
│ ├ Coca-Cola 600ml    $25.00 │
│ │   Cantidad: [2] [+/-]     │
│ ├ Sprite 600ml       $25.00 │
│ │   Cantidad: [1] [+/-]     │
├─────────────────────────────┤
│ Subtotal:           $75.00  │
│ Envío:              $15.00  │
│ Total:              $90.00  │
├─────────────────────────────┤
│ [Proceder al Pago]          │
└─────────────────────────────┘
```

### **Badge en Home:**
```
┌─────────────────┐
│ 🏠 Inicio    🛒3│
└─────────────────┘
```

## 🚀 INSTRUCCIONES PARA EL BACKEND

**Por favor, proporciona:**

1. **📋 Documentación completa** de endpoints del carrito
2. **🔧 Estructura de datos** exacta para cada request/response
3. **✅ Validaciones** y reglas de negocio
4. **🔄 Flujo completo** carrito → checkout → pedido
5. **⚠️ Manejo de errores** y casos edge
6. **🔐 Autenticación** requerida para cada endpoint
7. **📱 Ejemplos de requests/responses** en JSON
8. **🎯 Mejores prácticas** para implementación

## 💡 CONSIDERACIONES TÉCNICAS

- **Frontend:** Flutter con StatefulWidget
- **Backend:** Node.js + Express + Prisma + MySQL
- **Autenticación:** JWT tokens
- **Persistencia:** LocalStorage + API sync
- **Validaciones:** Frontend + Backend

## 🎯 RESULTADO ESPERADO

Al finalizar, necesito tener:
- ✅ Endpoints del carrito documentados
- ✅ Estructura de datos clara
- ✅ Validaciones definidas
- ✅ Flujo completo carrito → checkout
- ✅ Manejo de errores especificado
- ✅ Ejemplos de implementación

---

**🔥 URGENCIA:** Necesito esta información para implementar el carrito de compras de manera profesional y escalable. Por favor, sé muy detallado en tu respuesta.

**📞 COMUNICACIÓN:** Si necesitas más contexto del frontend o tienes preguntas, no dudes en pedirlas.
