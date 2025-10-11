# 🔧 PROMPT PARA EQUIPO DE BACKEND - Revisión Completa de APIs de Gestión de Menú

## 📋 CONTEXTO

El frontend de gestión de menú para el panel del `owner` está implementado y funcional, pero hemos identificado **funcionalidades críticas faltantes** que requieren endpoints adicionales o documentación actualizada. Necesitamos una revisión exhaustiva del backend para asegurar que todas las APIs estén implementadas y correctamente documentadas.

## 🎯 OBJETIVO PRINCIPAL

**Documentar TODAS las funcionalidades existentes** en `DOCUMENTATION/Owner_Flow_Menu_Management.md` y **implementar las que falten** para tener un sistema CRUD completo de gestión de menú.

---

## 🚨 FUNCIONALIDADES CRÍTICAS FALTANTES

### **1. GESTIÓN DE PRODUCTOS**

#### **❌ ELIMINAR PRODUCTO (Parcialmente Implementado)**
- **Endpoint:** `DELETE /api/restaurant/products/:productId`
- **Estado Actual:** ✅ Existe pero necesita refinamiento
- **Problema:** Devuelve error 409 `PRODUCT_IN_USE` cuando hay pedidos asociados
- **Necesidad:** 
  - ✅ Mantener el comportamiento actual (no eliminar si hay pedidos)
  - ❌ **FALTA:** Endpoint para desactivar producto como alternativa

#### **❌ ACTIVAR/DESACTIVAR PRODUCTO (NO EXISTE)**
- **Endpoint:** `PATCH /api/restaurant/products/:productId/availability`
- **Body:** `{ "isAvailable": boolean }`
- **Comportamiento:** 
  - Marcar producto como disponible/no disponible
  - Productos desactivados NO aparecen en menú del cliente
  - **ALTERNATIVA:** Permitir este campo en el endpoint general `PATCH /api/restaurant/products/:productId`

#### **❌ EDITAR PRODUCTO EXISTENTE (NO EXISTE)**
- **Endpoint:** `PATCH /api/restaurant/products/:productId`
- **Body:** 
  ```json
  {
    "name": "string",
    "description": "string", 
    "price": "number",
    "subcategoryId": "number",
    "modifierGroupIds": ["number"],
    "imageUrl": "string",
    "isAvailable": "boolean"
  }
  ```
- **Comportamiento:** Actualizar todos los campos de un producto existente

#### **❌ SUBIR IMAGEN DE PRODUCTO (NO EXISTE)**
- **Endpoint:** `POST /api/restaurant/products/:productId/image` 
- **O Alternativa:** `POST /api/uploads/product-image`
- **Comportamiento:** 
  - Subir imagen y devolver URL
  - URL se usa luego en `PATCH /api/restaurant/products/:productId`

#### **❌ OBTENER PRODUCTO INDIVIDUAL (NO EXISTE)**
- **Endpoint:** `GET /api/restaurant/products/:productId`
- **Comportamiento:** Obtener datos completos de un solo producto para edición

---

### **2. GESTIÓN DE SUBCATEGORÍAS**

#### **❌ ELIMINAR SUBCATEGORÍA (NO EXISTE)**
- **Endpoint:** `DELETE /api/restaurant/subcategories/:subcategoryId`
- **Comportamiento:** 
  - Solo eliminar si NO tiene productos asociados
  - Error específico si tiene productos: `SUBCATEGORY_HAS_PRODUCTS`

#### **❌ ACTIVAR/DESACTIVAR SUBCATEGORÍA (NO EXISTE)**
- **Endpoint:** `PATCH /api/restaurant/subcategories/:subcategoryId/availability`
- **Body:** `{ "isAvailable": boolean }`
- **Comportamiento:** 
  - Desactivar subcategoría = desactivar TODOS sus productos
  - Subcategorías desactivadas NO aparecen en menú del cliente

#### **❌ EDITAR SUBCATEGORÍA EXISTENTE (NO EXISTE)**
- **Endpoint:** `PATCH /api/restaurant/subcategories/:subcategoryId`
- **Body:** 
  ```json
  {
    "name": "string",
    "categoryId": "number",
    "isAvailable": "boolean"
  }
  ```

#### **❌ OBTENER SUBCATEGORÍA INDIVIDUAL (NO EXISTE)**
- **Endpoint:** `GET /api/restaurant/subcategories/:subcategoryId`
- **Comportamiento:** Obtener datos completos de una subcategoría para edición

---

### **3. GESTIÓN DE GRUPOS DE MODIFICADORES**

#### **❌ EDITAR GRUPO DE MODIFICADORES (NO EXISTE)**
- **Endpoint:** `PATCH /api/restaurant/modifier-groups/:groupId`
- **Body:** 
  ```json
  {
    "name": "string",
    "minSelection": "number",
    "maxSelection": "number"
  }
  ```

#### **❌ EDITAR OPCIÓN DE MODIFICADOR (NO EXISTE)**
- **Endpoint:** `PATCH /api/restaurant/modifier-options/:optionId`
- **Body:** 
  ```json
  {
    "name": "string",
    "price": "number"
  }
  ```

---

## 🔍 FUNCIONALIDADES ADICIONALES RECOMENDADAS

### **4. MEJORAS DE UX/UI**

#### **🎯 ORDENAMIENTO PERSONALIZADO**
- **Endpoint:** `PATCH /api/restaurant/subcategories/reorder`
- **Body:** `{ "subcategoryIds": [1, 3, 2, 4] }`
- **Comportamiento:** Definir orden de visualización de subcategorías

- **Endpoint:** `PATCH /api/restaurant/products/reorder`
- **Body:** `{ "productIds": [5, 1, 3, 2] }`
- **Comportamiento:** Definir orden de productos dentro de subcategorías

#### **📊 ESTADÍSTICAS DE MENÚ**
- **Endpoint:** `GET /api/restaurant/menu/stats`
- **Response:** 
  ```json
  {
    "totalProducts": 25,
    "availableProducts": 23,
    "totalSubcategories": 8,
    "availableSubcategories": 7,
    "totalModifierGroups": 5
  }
  ```

#### **🔄 OPERACIONES MASIVAS**
- **Endpoint:** `PATCH /api/restaurant/products/bulk-availability`
- **Body:** 
  ```json
  {
    "productIds": [1, 2, 3],
    "isAvailable": false
  }
  ```
- **Comportamiento:** Activar/desactivar múltiples productos a la vez

---

## 📝 TAREAS ESPECÍFICAS PARA BACKEND

### **TAREA 1: AUDITORÍA DE ENDPOINTS EXISTENTES**
```bash
# Verificar qué endpoints YA EXISTEN pero no están documentados
grep -r "products" routes/
grep -r "subcategories" routes/
grep -r "modifier" routes/
```

### **TAREA 2: DOCUMENTACIÓN COMPLETA**
Actualizar `DOCUMENTATION/Owner_Flow_Menu_Management.md` con:
- ✅ Todos los endpoints existentes (con ejemplos completos)
- ❌ Nuevos endpoints a implementar
- 🔍 Códigos de error específicos y mensajes
- 📋 Reglas de negocio claras

### **TAREA 3: IMPLEMENTACIÓN DE ENDPOINTS FALTANTES**
Prioridad **ALTA:**
1. `PATCH /api/restaurant/products/:productId` (editar producto)
2. `PATCH /api/restaurant/products/:productId/availability` (activar/desactivar)
3. `DELETE /api/restaurant/subcategories/:subcategoryId` (eliminar subcategoría)
4. `PATCH /api/restaurant/subcategories/:subcategoryId` (editar subcategoría)

Prioridad **MEDIA:**
5. `POST /api/restaurant/products/:productId/image` (subir imagen)
6. `GET /api/restaurant/products/:productId` (obtener producto individual)
7. `GET /api/restaurant/subcategories/:subcategoryId` (obtener subcategoría individual)

### **TAREA 4: CONSISTENCIA DE ERRORES**
Asegurar que todos los endpoints devuelvan:
```json
{
  "status": "error|success",
  "message": "Descripción clara del resultado",
  "code": "ERROR_CODE_ESPECÍFICO",
  "suggestion": "Acción sugerida para el usuario"
}
```

**Códigos de error específicos necesarios:**
- `PRODUCT_IN_USE` (ya existe)
- `SUBCATEGORY_HAS_PRODUCTS`
- `PRODUCT_NOT_FOUND`
- `SUBCATEGORY_NOT_FOUND`
- `INVALID_MODIFIER_GROUP`

---

## 🧪 CRITERIOS DE ACEPTACIÓN

### **✅ FUNCIONALIDADES BÁSICAS**
- [ ] Owner puede eliminar productos (solo si no hay pedidos)
- [ ] Owner puede desactivar/activar productos
- [ ] Owner puede editar productos existentes
- [ ] Owner puede subir imágenes de productos
- [ ] Owner puede eliminar subcategorías (solo si no hay productos)
- [ ] Owner puede desactivar/activar subcategorías
- [ ] Owner puede editar subcategorías existentes

### **✅ DOCUMENTACIÓN COMPLETA**
- [ ] Todos los endpoints documentados en `Owner_Flow_Menu_Management.md`
- [ ] Ejemplos de request/response para cada endpoint
- [ ] Códigos de error específicos documentados
- [ ] Reglas de negocio claras

### **✅ CONSISTENCIA**
- [ ] Todos los endpoints siguen el mismo patrón de respuesta
- [ ] Manejo de errores consistente
- [ ] Validaciones apropiadas en todos los endpoints

---

## 🚀 ENTREGABLES ESPERADOS

1. **📋 Documento actualizado:** `DOCUMENTATION/Owner_Flow_Menu_Management.md`
2. **🔧 Endpoints implementados:** Todos los marcados como "NO EXISTE"
3. **✅ Pruebas:** Confirmación de que todos los endpoints funcionan correctamente
4. **📝 Changelog:** Lista de cambios realizados

---

## 📞 COMUNICACIÓN

**Una vez completado, notificar al equipo de frontend para:**
- ✅ Actualizar `MenuService` con los nuevos endpoints
- ✅ Implementar las funcionalidades faltantes en la UI
- ✅ Realizar pruebas de integración completas

---

**⏰ PRIORIDAD:** **ALTA** - Estas funcionalidades son críticas para el MVP del panel de owner.

**📅 TIMELINE SUGERIDO:** 2-3 días para implementación completa.

---

*Este prompt fue generado por el equipo de frontend basándose en la implementación actual y las necesidades identificadas del usuario final.*
