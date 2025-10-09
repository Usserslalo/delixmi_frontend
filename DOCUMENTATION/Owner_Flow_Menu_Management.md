# 🍕 Owner Flow - Gestión Completa del Menú

## 🎯 VEREDICTO DE VIABILIDAD: ✅ VIABLE

**Conclusión:** El backend de Delixmi **SÍ soporta completamente** el flujo de trabajo descrito para la Gestión de Menú del owner. Todos los endpoints necesarios están implementados y funcionan correctamente.

---

## 📋 Índice
1. [Resumen de la Funcionalidad](#resumen-de-la-funcionalidad)
2. [Arquitectura del Menú](#arquitectura-del-menú)
3. [Flujo de Trabajo Completo](#flujo-de-trabajo-completo)
4. [Endpoints Disponibles](#endpoints-disponibles)
5. [Modelos de Datos](#modelos-de-datos)
6. [Proceso de Construcción del Menú](#proceso-de-construcción-del-menú)
7. [Códigos de Error](#códigos-de-error)
8. [Casos de Uso Prácticos](#casos-de-uso-prácticos)

---

## 📖 Resumen de la Funcionalidad

### **Objetivo**

Permitir a los usuarios con rol de **owner** construir un menú personalizable completo para su restaurante, con capacidad de:

✅ Asignar subcategorías a categorías globales  
✅ Crear grupos de modificadores personalizados  
✅ Definir opciones de modificadores con precios  
✅ Crear productos con información completa  
✅ Asociar grupos de modificadores a productos  
✅ Gestionar el menú de forma jerárquica

### **Endpoints Involucrados (11 endpoints)**

| Método | Endpoint | Función |
|--------|----------|---------|
| `GET` | `/api/categories` | Obtener categorías globales |
| `GET` | `/api/restaurant/subcategories` | Listar subcategorías del restaurante |
| `POST` | `/api/restaurant/subcategories` | Crear subcategoría |
| `PATCH` | `/api/restaurant/subcategories/:id` | Actualizar subcategoría |
| `DELETE` | `/api/restaurant/subcategories/:id` | Eliminar subcategoría |
| `POST` | `/api/restaurant/modifier-groups` | Crear grupo de modificadores |
| `GET` | `/api/restaurant/modifier-groups` | Listar grupos de modificadores |
| `POST` | `/api/restaurant/modifier-groups/:groupId/options` | Añadir opción a grupo |
| `GET` | `/api/restaurant/products` | Listar productos |
| `POST` | `/api/restaurant/products` | Crear producto con modificadores |
| `PATCH` | `/api/restaurant/products/:productId` | Actualizar producto y modificadores |

---

## 🏗️ Arquitectura del Menú

### **Jerarquía de Datos**

```
Categoría Global (ej. "Pizzas")
  ↓
Subcategoría (ej. "Pizzas Tradicionales")
  ↓
Producto (ej. "Pizza Hawaiana")
  ↓
Asociado a → Grupo de Modificadores (ej. "Tamaño")
  ├─ Opción 1 (ej. "Personal - $0")
  ├─ Opción 2 (ej. "Mediana - $25")
  └─ Opción 3 (ej. "Grande - $45")
  ↓
Asociado a → Grupo de Modificadores (ej. "Extras")
  ├─ Opción 1 (ej. "Extra Queso - $15")
  ├─ Opción 2 (ej. "Extra Pepperoni - $20")
  └─ Opción 3 (ej. "Extra Champiñones - $12")
```

### **Relación Entre Entidades**

```
┌─────────────────────┐
│  Category (Global)  │ ← Creadas por admin (ej. "Pizzas", "Bebidas")
└─────────────────────┘
          ↓ 1:N
┌─────────────────────┐
│   Subcategory       │ ← Owner crea sus propias (ej. "Pizzas Tradicionales")
│   (Por Restaurante) │
└─────────────────────┘
          ↓ 1:N
┌─────────────────────┐
│      Product        │ ← Owner crea productos (ej. "Pizza Hawaiana")
└─────────────────────┘
          ↓ N:M
┌─────────────────────┐
│  ModifierGroup      │ ← Owner crea grupos (ej. "Tamaño")
│   (Por Restaurante) │
└─────────────────────┘
          ↓ 1:N
┌─────────────────────┐
│  ModifierOption     │ ← Owner crea opciones (ej. "Grande - $45")
└─────────────────────┘
```

---

## 🔄 Flujo de Trabajo Completo

### **Secuencia de Construcción del Menú**

El owner debe seguir este orden para construir un menú desde cero:

```
PASO 1: Consultar Categorías Globales
   ↓
PASO 2: Crear Subcategorías Propias
   ↓
PASO 3: Crear Grupos de Modificadores
   ↓
PASO 4: Añadir Opciones a los Grupos
   ↓
PASO 5: Crear Productos y Asociar Modificadores
   ↓
PASO 6: (Opcional) Actualizar Productos/Modificadores
```

### **Flujo Detallado**

```
┌────────────────────────────────────────────┐
│  PASO 1: Obtener Categorías Globales      │
│  GET /api/categories                       │
│  → Retorna: ["Pizzas", "Bebidas", etc.]   │
└────────────────────────────────────────────┘
                ↓
┌────────────────────────────────────────────┐
│  PASO 2: Crear Subcategorías               │
│  POST /api/restaurant/subcategories        │
│  Body: { categoryId: 1, name: "Pizzas      │
│         Tradicionales" }                   │
│  → Retorna: ID de subcategoría creada      │
└────────────────────────────────────────────┘
                ↓
┌────────────────────────────────────────────┐
│  PASO 3A: Crear Grupo de Modificadores    │
│  POST /api/restaurant/modifier-groups      │
│  Body: { name: "Tamaño", minSelection: 1,  │
│         maxSelection: 1 }                  │
│  → Retorna: ID del grupo creado            │
└────────────────────────────────────────────┘
                ↓
┌────────────────────────────────────────────┐
│  PASO 3B: Añadir Opciones al Grupo        │
│  POST /api/restaurant/modifier-groups/:    │
│       groupId/options                      │
│  Body: { name: "Grande", price: 45.00 }    │
│  → Retorna: Opción creada                  │
│  (Repetir para cada opción)                │
└────────────────────────────────────────────┘
                ↓
┌────────────────────────────────────────────┐
│  PASO 4: Crear Producto                    │
│  POST /api/restaurant/products             │
│  Body: {                                   │
│    subcategoryId: 1,                       │
│    name: "Pizza Hawaiana",                 │
│    price: 150.00,                          │
│    modifierGroupIds: [1, 2]  ← Asociación  │
│  }                                         │
│  → Retorna: Producto completo con          │
│             modificadores                  │
└────────────────────────────────────────────┘
                ↓
┌────────────────────────────────────────────┐
│  (OPCIONAL) Actualizar Producto            │
│  PATCH /api/restaurant/products/:id        │
│  Body: {                                   │
│    modifierGroupIds: [1, 2, 3]  ← Nuevas   │
│           asociaciones                     │
│  }                                         │
└────────────────────────────────────────────┘
```

---

## 🔌 Endpoints Disponibles

### **CATEGORÍAS GLOBALES**

---

#### **1. Obtener Categorías Globales**

**Endpoint:** `GET /api/categories`

**Método:** `GET`

**Autenticación:** No requerida

**Descripción:** Obtiene todas las categorías globales disponibles en la plataforma (ej. "Pizzas", "Bebidas", "Sushi"). El owner usa estas categorías para asignarles sus propias subcategorías.

**Headers:**
```http
(No requiere autenticación)
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Categorías obtenidas exitosamente",
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Pizzas",
        "imageUrl": null,
        "subcategories": [
          {
            "id": 1,
            "name": "Pizzas Tradicionales",
            "displayOrder": 1,
            "restaurantId": 1,
            "restaurant": {
              "id": 1,
              "name": "Pizzería de Ana"
            }
          }
        ]
      },
      {
        "id": 2,
        "name": "Bebidas",
        "imageUrl": null,
        "subcategories": []
      },
      {
        "id": 3,
        "name": "Sushi",
        "imageUrl": null,
        "subcategories": []
      }
    ]
  }
}
```

**⚠️ Nota:** Este endpoint es público y muestra subcategorías de TODOS los restaurantes. En Flutter, deberás filtrar las subcategorías para mostrar solo las del restaurante del owner.

---

### **SUBCATEGORÍAS**

---

#### **2. Listar Subcategorías del Restaurante**

**Endpoint:** `GET /api/restaurant/subcategories`

**Método:** `GET`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Obtiene todas las subcategorías que el owner ha creado para su restaurante, agrupadas por categoría global.

**Headers:**
```http
Authorization: Bearer {token}
```

**Query Parameters:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `categoryId` | Integer | No | Filtrar por categoría global específica |
| `page` | Integer | No | Número de página (default: 1) |
| `pageSize` | Integer | No | Tamaño de página (default: 20, max: 100) |

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Subcategorías obtenidas exitosamente",
  "data": {
    "subcategories": [
      {
        "id": 1,
        "name": "Pizzas Tradicionales",
        "displayOrder": 1,
        "category": {
          "id": 1,
          "name": "Pizzas"
        },
        "restaurant": {
          "id": 1,
          "name": "Pizzería de Ana"
        },
        "productsCount": 5,
        "createdAt": "2025-01-09T00:00:00.000Z",
        "updatedAt": "2025-01-09T00:00:00.000Z"
      }
    ],
    "pagination": {
      "totalSubcategories": 9,
      "currentPage": 1,
      "pageSize": 20,
      "totalPages": 1,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

**Errores Posibles:**

**401 Unauthorized:**
```json
{
  "status": "error",
  "message": "Token inválido o expirado"
}
```

**403 Forbidden:**
```json
{
  "status": "error",
  "message": "Acceso denegado. Se requieren permisos de restaurante",
  "code": "INSUFFICIENT_PERMISSIONS"
}
```

---

#### **3. Crear Subcategoría**

**Endpoint:** `POST /api/restaurant/subcategories`

**Método:** `POST`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Crea una nueva subcategoría para el menú del restaurante, asignándola a una categoría global existente.

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "categoryId": 1,
  "name": "Pizzas Tradicionales",
  "displayOrder": 1
}
```

**Campos:**

| Campo | Tipo | Requerido | Validación | Descripción |
|-------|------|-----------|------------|-------------|
| `categoryId` | Integer | Sí | Min: 1 | ID de la categoría global |
| `name` | String | Sí | 1-100 caracteres | Nombre de la subcategoría |
| `displayOrder` | Integer | No | Min: 0, Default: 0 | Orden de visualización |

**Response (201 Created):**
```json
{
  "status": "success",
  "message": "Subcategoría creada exitosamente",
  "data": {
    "subcategory": {
      "id": 10,
      "name": "Pizzas Tradicionales",
      "displayOrder": 1,
      "category": {
        "id": 1,
        "name": "Pizzas"
      },
      "restaurant": {
        "id": 1,
        "name": "Pizzería de Ana"
      },
      "createdAt": "2025-01-09T15:30:00.000Z",
      "updatedAt": "2025-01-09T15:30:00.000Z"
    }
  }
}
```

**Errores Posibles:**

**400 Bad Request - Datos inválidos:**
```json
{
  "status": "error",
  "message": "Datos de entrada inválidos",
  "errors": [
    {
      "msg": "El nombre debe tener entre 1 y 100 caracteres",
      "param": "name"
    }
  ]
}
```

**404 Not Found - Categoría no existe:**
```json
{
  "status": "error",
  "message": "Categoría no encontrada",
  "code": "CATEGORY_NOT_FOUND"
}
```

**409 Conflict - Subcategoría duplicada:**
```json
{
  "status": "error",
  "message": "Ya existe una subcategoría con este nombre en esta categoría",
  "code": "SUBCATEGORY_EXISTS"
}
```

---

### **GRUPOS DE MODIFICADORES**

---

#### **4. Listar Grupos de Modificadores**

**Endpoint:** `GET /api/restaurant/modifier-groups`

**Método:** `GET`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Obtiene todos los grupos de modificadores del restaurante con sus opciones.

**Headers:**
```http
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Grupos de modificadores obtenidos exitosamente",
  "data": {
    "modifierGroups": [
      {
        "id": 1,
        "name": "Tamaño",
        "minSelection": 1,
        "maxSelection": 1,
        "restaurant": {
          "id": 1,
          "name": "Pizzería de Ana"
        },
        "options": [
          {
            "id": 1,
            "name": "Personal (6 pulgadas)",
            "price": 0.00
          },
          {
            "id": 2,
            "name": "Mediana (10 pulgadas)",
            "price": 25.00
          },
          {
            "id": 3,
            "name": "Grande (12 pulgadas)",
            "price": 45.00
          }
        ],
        "createdAt": "2025-01-09T00:00:00.000Z",
        "updatedAt": "2025-01-09T00:00:00.000Z"
      }
    ]
  }
}
```

---

#### **5. Crear Grupo de Modificadores**

**Endpoint:** `POST /api/restaurant/modifier-groups`

**Método:** `POST`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Crea un nuevo grupo de modificadores para el restaurante (ej. "Tamaño", "Extras", "Sin Ingredientes").

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Tamaño",
  "minSelection": 1,
  "maxSelection": 1
}
```

**Campos:**

| Campo | Tipo | Requerido | Validación | Descripción |
|-------|------|-----------|------------|-------------|
| `name` | String | Sí | 1-100 caracteres | Nombre del grupo (ej. "Tamaño") |
| `minSelection` | Integer | No | 0-10, Default: 1 | Selección mínima obligatoria |
| `maxSelection` | Integer | No | 1-10, Default: 1 | Selección máxima permitida |

**⚠️ Importante:** 
- `minSelection > 0` significa que el grupo es **obligatorio** (el cliente DEBE seleccionar)
- `minSelection = 0` significa que el grupo es **opcional**
- `maxSelection = 1` significa **selección única** (radio button)
- `maxSelection > 1` significa **selección múltiple** (checkboxes)

**Response (201 Created):**
```json
{
  "status": "success",
  "message": "Grupo de modificadores creado exitosamente",
  "data": {
    "modifierGroup": {
      "id": 5,
      "name": "Tamaño",
      "minSelection": 1,
      "maxSelection": 1,
      "restaurant": {
        "id": 1,
        "name": "Pizzería de Ana"
      },
      "options": [],
      "createdAt": "2025-01-09T15:45:00.000Z",
      "updatedAt": "2025-01-09T15:45:00.000Z"
    }
  }
}
```

---

#### **6. Añadir Opción a Grupo de Modificadores**

**Endpoint:** `POST /api/restaurant/modifier-groups/:groupId/options`

**Método:** `POST`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Añade una opción de modificador a un grupo existente (ej. "Grande - $45" al grupo "Tamaño").

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Path Parameters:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `groupId` | Integer | Sí | ID del grupo de modificadores |

**Request Body:**
```json
{
  "name": "Grande (12 pulgadas)",
  "price": 45.00
}
```

**Campos:**

| Campo | Tipo | Requerido | Validación | Descripción |
|-------|------|-----------|------------|-------------|
| `name` | String | Sí | 1-100 caracteres | Nombre de la opción |
| `price` | Float | Sí | Min: 0 | Precio adicional (0 si no tiene costo) |

**Response (201 Created):**
```json
{
  "status": "success",
  "message": "Opción de modificador creada exitosamente",
  "data": {
    "modifierOption": {
      "id": 15,
      "name": "Grande (12 pulgadas)",
      "price": 45.00,
      "modifierGroup": {
        "id": 5,
        "name": "Tamaño",
        "restaurantId": 1
      },
      "createdAt": "2025-01-09T15:50:00.000Z",
      "updatedAt": "2025-01-09T15:50:00.000Z"
    }
  }
}
```

**Errores Posibles:**

**403 Forbidden - Grupo no pertenece al restaurante:**
```json
{
  "status": "error",
  "message": "No tienes permiso para añadir opciones a este grupo",
  "code": "FORBIDDEN"
}
```

**404 Not Found - Grupo no existe:**
```json
{
  "status": "error",
  "message": "Grupo de modificadores no encontrado",
  "code": "MODIFIER_GROUP_NOT_FOUND"
}
```

---

### **PRODUCTOS**

---

#### **7. Listar Productos del Restaurante**

**Endpoint:** `GET /api/restaurant/products`

**Método:** `GET`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Obtiene todos los productos del restaurante con sus modificadores asociados.

**Headers:**
```http
Authorization: Bearer {token}
```

**Query Parameters:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `subcategoryId` | Integer | No | Filtrar por subcategoría |
| `isAvailable` | Boolean | No | Filtrar por disponibilidad |
| `page` | Integer | No | Número de página (default: 1) |
| `pageSize` | Integer | No | Tamaño de página (default: 20, max: 100) |

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Productos obtenidos exitosamente",
  "data": {
    "products": [
      {
        "id": 1,
        "name": "Pizza Hawaiana",
        "description": "La clásica pizza con jamón y piña",
        "imageUrl": "http://localhost:3000/uploads/products/pizza1.jpg",
        "price": 150.00,
        "isAvailable": true,
        "tags": "pizza, jamon, pina",
        "subcategory": {
          "id": 1,
          "name": "Pizzas Tradicionales",
          "category": {
            "id": 1,
            "name": "Pizzas"
          }
        },
        "modifierGroups": [
          {
            "id": 1,
            "name": "Tamaño",
            "minSelection": 1,
            "maxSelection": 1,
            "options": [
              {
                "id": 1,
                "name": "Personal",
                "price": 0.00
              }
            ]
          }
        ],
        "createdAt": "2025-01-09T00:00:00.000Z",
        "updatedAt": "2025-01-09T00:00:00.000Z"
      }
    ],
    "pagination": {
      "totalProducts": 10,
      "currentPage": 1,
      "pageSize": 20,
      "totalPages": 1,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

---

#### **8. Crear Producto con Modificadores**

**Endpoint:** `POST /api/restaurant/products`

**Método:** `POST`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Crea un nuevo producto en el menú del restaurante y lo asocia a grupos de modificadores existentes.

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "subcategoryId": 1,
  "name": "Pizza Hawaiana",
  "description": "La clásica pizza con jamón y piña fresca",
  "imageUrl": "http://localhost:3000/uploads/products/pizza_hawaiana.jpg",
  "price": 150.00,
  "isAvailable": true,
  "modifierGroupIds": [1, 2, 3]
}
```

**Campos:**

| Campo | Tipo | Requerido | Validación | Descripción |
|-------|------|-----------|------------|-------------|
| `subcategoryId` | Integer | Sí | Min: 1 | ID de la subcategoría del restaurante |
| `name` | String | Sí | 1-150 caracteres | Nombre del producto |
| `description` | String | No | Máximo 1000 caracteres | Descripción del producto |
| `imageUrl` | String | No | Máximo 255 caracteres | URL de la imagen (de upload previo) |
| `price` | Float | Sí | Min: 0.01 | Precio base del producto |
| `isAvailable` | Boolean | No | Default: true | Disponibilidad del producto |
| `modifierGroupIds` | Array<Integer> | No | Default: [] | IDs de grupos de modificadores a asociar |

**⚠️ Nota Crítica:** `modifierGroupIds` es un array de IDs de grupos que deben pertenecer al mismo restaurante. Este campo permite asociar grupos de modificadores al crear el producto en una sola petición.

**Response (201 Created):**
```json
{
  "status": "success",
  "message": "Producto creado exitosamente",
  "data": {
    "product": {
      "id": 11,
      "name": "Pizza Hawaiana",
      "description": "La clásica pizza con jamón y piña fresca",
      "imageUrl": "http://localhost:3000/uploads/products/pizza_hawaiana.jpg",
      "price": 150.00,
      "isAvailable": true,
      "subcategory": {
        "id": 1,
        "name": "Pizzas Tradicionales",
        "category": {
          "id": 1,
          "name": "Pizzas"
        }
      },
      "restaurant": {
        "id": 1,
        "name": "Pizzería de Ana"
      },
      "modifierGroups": [
        {
          "id": 1,
          "name": "Tamaño",
          "minSelection": 1,
          "maxSelection": 1,
          "options": [
            {
              "id": 1,
              "name": "Personal",
              "price": 0.00
            },
            {
              "id": 2,
              "name": "Mediana",
              "price": 25.00
            },
            {
              "id": 3,
              "name": "Grande",
              "price": 45.00
            }
          ]
        },
        {
          "id": 2,
          "name": "Extras",
          "minSelection": 0,
          "maxSelection": 5,
          "options": [
            {
              "id": 5,
              "name": "Extra Queso",
              "price": 15.00
            }
          ]
        }
      ],
      "createdAt": "2025-01-09T16:00:00.000Z",
      "updatedAt": "2025-01-09T16:00:00.000Z"
    }
  }
}
```

**Errores Posibles:**

**400 Bad Request - Grupos inválidos:**
```json
{
  "status": "error",
  "message": "Algunos grupos de modificadores no pertenecen a este restaurante",
  "code": "INVALID_MODIFIER_GROUPS",
  "details": {
    "invalidGroupIds": [5, 7],
    "restaurantId": 1
  }
}
```

**403 Forbidden - Sin permiso para subcategoría:**
```json
{
  "status": "error",
  "message": "No tienes permiso para añadir productos a esta subcategoría",
  "code": "FORBIDDEN"
}
```

**404 Not Found - Subcategoría no existe:**
```json
{
  "status": "error",
  "message": "Subcategoría no encontrada",
  "code": "SUBCATEGORY_NOT_FOUND"
}
```

---

#### **9. Actualizar Producto y sus Modificadores**

**Endpoint:** `PATCH /api/restaurant/products/:productId`

**Método:** `PATCH`

**Autenticación:** Requerida (Token JWT)

**Roles Permitidos:** `owner`, `branch_manager`

**Descripción:** Actualiza un producto existente y/o modifica sus asociaciones con grupos de modificadores. Todos los campos son opcionales.

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Path Parameters:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `productId` | Integer | Sí | ID del producto a actualizar |

**Request Body:**
```json
{
  "name": "Pizza Hawaiana Premium",
  "price": 175.00,
  "modifierGroupIds": [1, 2, 3, 4]
}
```

**Campos:**

| Campo | Tipo | Requerido | Validación | Descripción |
|-------|------|-----------|------------|-------------|
| `subcategoryId` | Integer | No | Min: 1 | Cambiar de subcategoría |
| `name` | String | No | 1-150 caracteres | Nuevo nombre |
| `description` | String | No | Máximo 1000 caracteres | Nueva descripción |
| `imageUrl` | String | No | Máximo 255 caracteres | Nueva URL de imagen |
| `price` | Float | No | Min: 0.01 | Nuevo precio |
| `isAvailable` | Boolean | No | true/false | Cambiar disponibilidad |
| `modifierGroupIds` | Array<Integer> | No | - | **Nuevas** asociaciones de grupos |

**⚠️ COMPORTAMIENTO CRÍTICO de `modifierGroupIds`:**

Cuando se envía este campo, el backend:
1. **Elimina** todas las asociaciones existentes del producto
2. **Crea** nuevas asociaciones con los IDs proporcionados

**Ejemplos:**
```json
// Agregar más grupos (de 2 a 4 grupos)
{ "modifierGroupIds": [1, 2, 3, 4] }

// Quitar grupos (de 4 a 2 grupos)
{ "modifierGroupIds": [1, 2] }

// Quitar todos los grupos
{ "modifierGroupIds": [] }

// No modificar asociaciones (omitir el campo)
{ "name": "Nuevo Nombre" }  // modifierGroupIds no se envía
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Producto actualizado exitosamente",
  "data": {
    "product": {
      "id": 11,
      "name": "Pizza Hawaiana Premium",
      "description": "La clásica pizza con jamón y piña fresca",
      "imageUrl": "http://localhost:3000/uploads/products/pizza_hawaiana.jpg",
      "price": 175.00,
      "isAvailable": true,
      "subcategory": {
        "id": 1,
        "name": "Pizzas Tradicionales",
        "category": {
          "id": 1,
          "name": "Pizzas"
        }
      },
      "restaurant": {
        "id": 1,
        "name": "Pizzería de Ana"
      },
      "modifierGroups": [
        {
          "id": 1,
          "name": "Tamaño",
          "minSelection": 1,
          "maxSelection": 1,
          "options": [...]
        },
        {
          "id": 2,
          "name": "Extras",
          "minSelection": 0,
          "maxSelection": 5,
          "options": [...]
        },
        {
          "id": 3,
          "name": "Sin Ingredientes",
          "minSelection": 0,
          "maxSelection": 3,
          "options": [...]
        },
        {
          "id": 4,
          "name": "Tipo de Masa",
          "minSelection": 1,
          "maxSelection": 1,
          "options": [...]
        }
      ],
      "createdAt": "2025-01-09T16:00:00.000Z",
      "updatedAt": "2025-01-09T16:10:00.000Z"
    },
    "updatedFields": ["name", "price", "modifierGroupIds"]
  }
}
```

**Errores Posibles:**

**400 Bad Request - Grupos inválidos:**
```json
{
  "status": "error",
  "message": "Algunos grupos de modificadores no pertenecen a este restaurante",
  "code": "INVALID_MODIFIER_GROUPS",
  "details": {
    "invalidGroupIds": [10],
    "restaurantId": 1
  }
}
```

**400 Bad Request - Sin campos para actualizar:**
```json
{
  "status": "error",
  "message": "No se proporcionaron campos para actualizar",
  "code": "NO_FIELDS_TO_UPDATE"
}
```

**403 Forbidden - Producto de otro restaurante:**
```json
{
  "status": "error",
  "message": "No tienes permiso para editar este producto",
  "code": "FORBIDDEN"
}
```

**404 Not Found:**
```json
{
  "status": "error",
  "message": "Producto no encontrado",
  "code": "PRODUCT_NOT_FOUND"
}
```

---

## 📊 Modelos de Datos

### **Category (Categoría Global)**
```typescript
interface Category {
  id: number;
  name: string;                    // "Pizzas", "Bebidas", "Sushi"
  imageUrl: string | null;
  subcategories: Subcategory[];    // Incluye de TODOS los restaurantes
}
```

### **Subcategory (Subcategoría del Restaurante)**
```typescript
interface Subcategory {
  id: number;
  name: string;                    // "Pizzas Tradicionales"
  displayOrder: number;            // Orden de visualización
  category: {
    id: number;
    name: string;
  };
  restaurant: {
    id: number;
    name: string;
  };
  productsCount?: number;          // Solo en GET /subcategories
  createdAt: string;
  updatedAt: string;
}
```

### **ModifierGroup (Grupo de Modificadores)**
```typescript
interface ModifierGroup {
  id: number;
  name: string;                    // "Tamaño", "Extras"
  minSelection: number;            // 0-10
  maxSelection: number;            // 1-10
  restaurant: {
    id: number;
    name: string;
  };
  options: ModifierOption[];
  createdAt: string;
  updatedAt: string;
}
```

### **ModifierOption (Opción de Modificador)**
```typescript
interface ModifierOption {
  id: number;
  name: string;                    // "Grande", "Extra Queso"
  price: number;                   // Precio adicional
}
```

### **Product (Producto)**
```typescript
interface Product {
  id: number;
  name: string;
  description: string | null;
  imageUrl: string | null;
  price: number;
  isAvailable: boolean;
  tags: string | null;
  subcategory: {
    id: number;
    name: string;
    category: {
      id: number;
      name: string;
    };
  };
  restaurant: {
    id: number;
    name: string;
  };
  modifierGroups: ModifierGroup[];  // Grupos asociados al producto
  createdAt: string;
  updatedAt: string;
}
```

---

## 🛠️ Proceso de Construcción del Menú

### **Escenario Completo: Crear una Pizza Hawaiana desde Cero**

#### **PASO 1: Obtener Categorías Globales**

```http
GET /api/categories
```

**Resultado:** El owner ve que existe la categoría "Pizzas" (ID: 1)

---

#### **PASO 2: Crear Subcategoría "Pizzas Tradicionales"**

```http
POST /api/restaurant/subcategories
Authorization: Bearer {token}

{
  "categoryId": 1,
  "name": "Pizzas Tradicionales",
  "displayOrder": 1
}
```

**Resultado:** Subcategoría creada con ID: 10

---

#### **PASO 3A: Crear Grupo "Tamaño"**

```http
POST /api/restaurant/modifier-groups
Authorization: Bearer {token}

{
  "name": "Tamaño",
  "minSelection": 1,
  "maxSelection": 1
}
```

**Resultado:** Grupo creado con ID: 5

---

#### **PASO 3B: Añadir Opciones al Grupo "Tamaño"**

**Opción 1:**
```http
POST /api/restaurant/modifier-groups/5/options
Authorization: Bearer {token}

{
  "name": "Personal (6 pulgadas)",
  "price": 0.00
}
```

**Opción 2:**
```http
POST /api/restaurant/modifier-groups/5/options
Authorization: Bearer {token}

{
  "name": "Mediana (10 pulgadas)",
  "price": 25.00
}
```

**Opción 3:**
```http
POST /api/restaurant/modifier-groups/5/options
Authorization: Bearer {token}

{
  "name": "Grande (12 pulgadas)",
  "price": 45.00
}
```

**Resultado:** 3 opciones creadas en el grupo "Tamaño"

---

#### **PASO 3C: Crear Grupo "Extras"**

```http
POST /api/restaurant/modifier-groups
Authorization: Bearer {token}

{
  "name": "Extras",
  "minSelection": 0,
  "maxSelection": 5
}
```

**Resultado:** Grupo creado con ID: 6

---

#### **PASO 3D: Añadir Opciones al Grupo "Extras"**

```http
POST /api/restaurant/modifier-groups/6/options

{ "name": "Extra Queso", "price": 15.00 }

POST /api/restaurant/modifier-groups/6/options

{ "name": "Extra Pepperoni", "price": 20.00 }

POST /api/restaurant/modifier-groups/6/options

{ "name": "Extra Champiñones", "price": 12.00 }
```

**Resultado:** 3 opciones creadas en el grupo "Extras"

---

#### **PASO 4: Crear Producto "Pizza Hawaiana" con Modificadores**

```http
POST /api/restaurant/products
Authorization: Bearer {token}

{
  "subcategoryId": 10,
  "name": "Pizza Hawaiana",
  "description": "La clásica pizza con jamón y piña fresca",
  "price": 150.00,
  "isAvailable": true,
  "modifierGroupIds": [5, 6]
}
```

**Resultado:** Producto creado con:
- ✅ Información básica (nombre, precio, descripción)
- ✅ Asociado a subcategoría "Pizzas Tradicionales"
- ✅ Asociado a grupo "Tamaño" (obligatorio)
- ✅ Asociado a grupo "Extras" (opcional)

---

#### **PASO 5 (Opcional): Agregar Más Grupos al Producto**

Más adelante, si el owner crea un nuevo grupo "Sin Ingredientes":

```http
POST /api/restaurant/modifier-groups
{ "name": "Sin Ingredientes", "minSelection": 0, "maxSelection": 3 }
→ Retorna ID: 7

POST /api/restaurant/modifier-groups/7/options
{ "name": "Sin Cebolla", "price": 0.00 }
```

Luego actualizar el producto para incluir este nuevo grupo:

```http
PATCH /api/restaurant/products/11

{
  "modifierGroupIds": [5, 6, 7]
}
```

**Resultado:** El producto ahora tiene 3 grupos asociados.

---

## 🎯 Casos de Uso Prácticos

### **Caso de Uso 1: Menú Simple (Sin Modificadores)**

**Escenario:** Owner quiere crear una bebida simple sin personalizaciones.

**Flujo:**
1. Obtener categorías → Ver "Bebidas" (ID: 2)
2. Crear subcategoría → "Refrescos" en categoría "Bebidas"
3. Crear producto SIN modificadores:

```http
POST /api/restaurant/products

{
  "subcategoryId": 15,
  "name": "Coca-Cola 600ml",
  "price": 25.00,
  "modifierGroupIds": []  ← Sin modificadores
}
```

**Resultado:** Producto simple sin opciones de personalización.

---

### **Caso de Uso 2: Producto con Modificador Obligatorio**

**Escenario:** Owner quiere que el cliente DEBA elegir un tamaño.

**Configuración del grupo:**
```http
POST /api/restaurant/modifier-groups

{
  "name": "Tamaño",
  "minSelection": 1,  ← OBLIGATORIO
  "maxSelection": 1
}
```

**Resultado:** En la app del cliente, este grupo aparecerá como requerido (no puede omitirse).

---

### **Caso de Uso 3: Producto con Modificador Opcional**

**Escenario:** Owner quiere que el cliente PUEDA elegir extras pero no es obligatorio.

**Configuración del grupo:**
```http
POST /api/restaurant/modifier-groups

{
  "name": "Extras",
  "minSelection": 0,  ← OPCIONAL
  "maxSelection": 5   ← Puede elegir hasta 5
}
```

**Resultado:** En la app del cliente, este grupo aparecerá como opcional (puede saltar este paso).

---

### **Caso de Uso 4: Modificar Asociaciones de un Producto Existente**

**Escenario:** Owner quiere agregar un nuevo grupo de modificadores a un producto existente.

**Situación inicial:** Producto tiene grupos [1, 2]

**Pasos:**
1. Crear nuevo grupo "Tipo de Masa" → Obtiene ID: 8
2. Actualizar producto:

```http
PATCH /api/restaurant/products/11

{
  "modifierGroupIds": [1, 2, 8]  ← Incluye el nuevo grupo
}
```

**Resultado:** Producto ahora tiene 3 grupos asociados (1, 2, 8).

---

### **Caso de Uso 5: Reutilizar Grupos en Múltiples Productos**

**Escenario:** Owner tiene el grupo "Tamaño" y quiere usarlo en todas sus pizzas.

**Pasos:**
```http
// Crear Pizza 1
POST /api/restaurant/products
{ "name": "Pizza Hawaiana", "modifierGroupIds": [1, 2] }

// Crear Pizza 2 (reutiliza los mismos grupos)
POST /api/restaurant/products
{ "name": "Pizza Pepperoni", "modifierGroupIds": [1, 2] }

// Crear Pizza 3 (reutiliza los mismos grupos)
POST /api/restaurant/products
{ "name": "Pizza Margherita", "modifierGroupIds": [1, 2] }
```

**Resultado:** Los 3 productos comparten los mismos grupos de modificadores. Si el owner actualiza las opciones del grupo (ej. cambia precio de "Grande"), el cambio aplica a TODAS las pizzas.

---

## ⚠️ Códigos de Error

### **Tabla Completa de Errores**

| Código | Code | Endpoint | Descripción |
|--------|------|----------|-------------|
| `400` | `VALIDATION_ERROR` | Todos | Datos de entrada inválidos |
| `400` | `INVALID_MODIFIER_GROUPS` | POST/PATCH products | Grupos no pertenecen al restaurante |
| `400` | `NO_FIELDS_TO_UPDATE` | PATCH products | Body vacío |
| `401` | `INVALID_TOKEN` | Todos (privados) | Token inválido o expirado |
| `403` | `INSUFFICIENT_PERMISSIONS` | Todos (privados) | Usuario sin rol necesario |
| `403` | `FORBIDDEN` | POST/PATCH products | Producto/subcategoría de otro restaurante |
| `404` | `CATEGORY_NOT_FOUND` | POST subcategories | Categoría global no existe |
| `404` | `SUBCATEGORY_NOT_FOUND` | POST products | Subcategoría no existe |
| `404` | `PRODUCT_NOT_FOUND` | PATCH products | Producto no existe |
| `404` | `MODIFIER_GROUP_NOT_FOUND` | POST options | Grupo no existe |
| `409` | `SUBCATEGORY_EXISTS` | POST subcategories | Subcategoría duplicada |
| `500` | `INTERNAL_ERROR` | Todos | Error del servidor |

---

## 🔐 Contexto Automático del Restaurante

### **Importante para Frontend**

El owner **NO necesita** enviar el `restaurantId` en ninguna petición. El backend lo obtiene automáticamente del token JWT y la asignación de rol.

**Flujo interno del backend:**
```javascript
// 1. Extraer userId del token JWT
const userId = req.user.id;

// 2. Buscar asignación de rol owner
const ownerAssignment = userRoleAssignments.find(
  a => a.role.name === 'owner' && a.restaurantId !== null
);

// 3. Usar restaurantId automáticamente
const restaurantId = ownerAssignment.restaurantId;
```

**Beneficio:** Mayor seguridad - un owner solo puede gestionar SU restaurante.

---

## 📋 Checklist de Implementación para Frontend

### **Pantalla 1: Gestión de Subcategorías**

- [ ] Listar subcategorías existentes (GET /subcategories)
- [ ] Botón "Crear Subcategoría"
  - [ ] Dropdown para seleccionar categoría global
  - [ ] Input para nombre de subcategoría
  - [ ] Enviar POST /subcategories
- [ ] Opción de editar subcategoría
- [ ] Opción de eliminar subcategoría

---

### **Pantalla 2: Gestión de Grupos de Modificadores**

- [ ] Listar grupos existentes (GET /modifier-groups)
- [ ] Botón "Crear Grupo"
  - [ ] Input para nombre del grupo
  - [ ] Slider para minSelection (0-10)
  - [ ] Slider para maxSelection (1-10)
  - [ ] Enviar POST /modifier-groups
- [ ] Expandir grupo para ver opciones
- [ ] Botón "Añadir Opción" en cada grupo
  - [ ] Input para nombre de opción
  - [ ] Input numérico para precio
  - [ ] Enviar POST /modifier-groups/:groupId/options

---

### **Pantalla 3: Gestión de Productos**

- [ ] Listar productos existentes (GET /products)
- [ ] Botón "Crear Producto"
  - [ ] Dropdown para seleccionar subcategoría
  - [ ] Input para nombre del producto
  - [ ] TextArea para descripción
  - [ ] Input numérico para precio
  - [ ] Botón "Subir Imagen" (opcional)
  - [ ] **Checklist de grupos de modificadores**
    - [ ] Mostrar lista de grupos disponibles
    - [ ] Permitir seleccionar múltiples grupos
    - [ ] Enviar POST /products con modifierGroupIds
- [ ] Opción de editar producto
  - [ ] Permitir cambiar grupos asociados
  - [ ] Enviar PATCH /products/:id
- [ ] Opción de activar/desactivar (isAvailable)

---

## 📐 Reglas de Negocio

### **1. Subcategorías**

- ✅ Una subcategoría pertenece a UNA categoría global
- ✅ Una subcategoría pertenece a UN restaurante
- ✅ El nombre de subcategoría debe ser único por categoría en el restaurante
- ✅ El displayOrder controla el orden de visualización

### **2. Grupos de Modificadores**

- ✅ Un grupo pertenece a UN restaurante
- ✅ Un grupo puede tener múltiples opciones
- ✅ `minSelection = 0` → Grupo opcional
- ✅ `minSelection > 0` → Grupo obligatorio
- ✅ `maxSelection = 1` → Selección única (radio button)
- ✅ `maxSelection > 1` → Selección múltiple (checkboxes)
- ✅ Un grupo puede reutilizarse en múltiples productos

### **3. Opciones de Modificadores**

- ✅ Una opción pertenece a UN grupo
- ✅ El precio es adicional al precio base del producto
- ✅ Precio puede ser 0 (sin costo adicional)

### **4. Productos**

- ✅ Un producto pertenece a UNA subcategoría
- ✅ Un producto pertenece a UN restaurante
- ✅ Un producto puede tener 0, 1 o múltiples grupos de modificadores
- ✅ Los grupos se asocian mediante el array `modifierGroupIds`
- ✅ Al actualizar `modifierGroupIds`, se reemplazan TODAS las asociaciones

---

## 🔄 Diagrama de Flujo de Creación

```
┌─────────────────────────────────────────────────────┐
│  INICIO: Owner quiere crear "Pizza Hawaiana"        │
└─────────────────────────────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │  ¿Existe subcategoría         │
        │  "Pizzas Tradicionales"?      │
        └───────────────────────────────┘
              NO ↓         ↓ SÍ
        ┌────────────┐    │
        │  POST      │    │
        │  /subcats  │    │
        └────────────┘    │
              ↓           ↓
        ┌───────────────────────────────┐
        │  ¿Existe grupo "Tamaño"?       │
        └───────────────────────────────┘
              NO ↓         ↓ SÍ
        ┌────────────┐    │
        │  POST      │    │
        │  /modifier │    │
        │  -groups   │    │
        └────────────┘    │
              ↓           │
        ┌────────────┐    │
        │  POST      │    │
        │  /options  │    │
        │  (x3)      │    │
        └────────────┘    │
              ↓           ↓
        ┌───────────────────────────────┐
        │  ¿Existe grupo "Extras"?       │
        └───────────────────────────────┘
              NO ↓         ↓ SÍ
        ┌────────────┐    │
        │  Crear     │    │
        │  grupo y   │    │
        │  opciones  │    │
        └────────────┘    │
              ↓           ↓
        ┌───────────────────────────────┐
        │  POST /products                │
        │  {                             │
        │    subcategoryId: 10,          │
        │    name: "Pizza Hawaiana",     │
        │    price: 150,                 │
        │    modifierGroupIds: [5, 6]    │
        │  }                             │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │  ✅ Producto creado con        │
        │     modificadores asociados    │
        │  FIN                           │
        └───────────────────────────────┘
```

---

## 🧩 Estrategias de Implementación

### **Estrategia 1: Construcción Paso a Paso (Recomendada para UX)**

**Ventaja:** El usuario ve progreso inmediato en cada paso.

**Flujo:**
1. Pantalla "Crear Subcategoría" → POST /subcategories
2. Pantalla "Crear Grupos" → POST /modifier-groups y POST /options
3. Pantalla "Crear Producto" → Seleccionar grupos existentes + POST /products

**UX:** Wizard multi-paso con indicador de progreso.

---

### **Estrategia 2: Formulario Todo-en-Uno**

**Ventaja:** Menos pasos para el usuario.

**Flujo:**
1. Formulario único con:
   - Selección de subcategoría (o crear nueva)
   - Datos del producto
   - Selección de grupos de modificadores existentes
2. Al guardar:
   - Si la subcategoría no existe → POST /subcategories
   - POST /products con modifierGroupIds

**UX:** Formulario largo pero fluido.

---

### **Estrategia 3: Reutilización Inteligente**

**Ventaja:** Eficiencia para productos similares.

**Flujo:**
1. Crear "plantilla" de grupos de modificadores comunes (Tamaño, Extras)
2. Al crear nuevos productos del mismo tipo, reutilizar los grupos:

```http
// Pizza 1
POST /products { "name": "Hawaiana", "modifierGroupIds": [1, 2] }

// Pizza 2 (reutiliza grupos)
POST /products { "name": "Pepperoni", "modifierGroupIds": [1, 2] }

// Pizza 3 (reutiliza grupos)
POST /products { "name": "Margherita", "modifierGroupIds": [1, 2] }
```

**UX:** Botón "Duplicar Producto" que copia configuración.

---

## 📚 Guía de Implementación por Pantallas

### **Pantalla A: Gestión de Subcategorías**

**Objetivo:** Organizar el menú en secciones.

**Funcionalidad:**
1. **Listar subcategorías:**
   ```http
   GET /api/restaurant/subcategories
   ```

2. **Crear subcategoría:**
   - Mostrar dropdown con categorías globales (de GET /categories)
   - Input para nombre de subcategoría
   - Input numérico para displayOrder
   - Botón "Crear"
   ```http
   POST /api/restaurant/subcategories
   {
     "categoryId": 1,
     "name": "Pizzas Tradicionales",
     "displayOrder": 1
   }
   ```

3. **Visualización:**
   - ListView agrupado por categoría global
   - Cada subcategoría con badge del número de productos
   - Opciones de editar/eliminar

---

### **Pantalla B: Gestión de Grupos de Modificadores**

**Objetivo:** Definir opciones de personalización reutilizables.

**Funcionalidad:**

1. **Listar grupos:**
   ```http
   GET /api/restaurant/modifier-groups
   ```

2. **Crear grupo:**
   - Input para nombre del grupo
   - Slider para minSelection (0-10)
   - Slider para maxSelection (1-10)
   - Helper text explicando minSelection vs maxSelection
   - Botón "Crear Grupo"
   ```http
   POST /api/restaurant/modifier-groups
   {
     "name": "Tamaño",
     "minSelection": 1,
     "maxSelection": 1
   }
   ```

3. **Añadir opciones al grupo:**
   - Dentro de cada grupo, botón "Añadir Opción"
   - Input para nombre de opción
   - Input numérico para precio
   - Botón "Guardar Opción"
   ```http
   POST /api/restaurant/modifier-groups/5/options
   {
     "name": "Grande (12 pulgadas)",
     "price": 45.00
   }
   ```

4. **Visualización:**
   - ExpansionTile por cada grupo
   - Al expandir, mostrar lista de opciones
   - Badge con "Obligatorio" si minSelection > 0
   - Badge con "Opcional" si minSelection = 0

---

### **Pantalla C: Gestión de Productos**

**Objetivo:** Crear productos completos con modificadores.

**Funcionalidad:**

1. **Listar productos:**
   ```http
   GET /api/restaurant/products
   ```

2. **Formulario de creación:**
   - Dropdown para seleccionar subcategoría
   - Input para nombre del producto
   - TextArea para descripción
   - Input numérico para precio
   - Botón "Subir Imagen" (opcional)
   - **Sección de modificadores:**
     - Título: "Opciones de Personalización"
     - Listar todos los grupos disponibles (GET /modifier-groups)
     - Checkbox por cada grupo para asociarlo
     - Preview de grupos seleccionados
   - Botón "Crear Producto"
   ```http
   POST /api/restaurant/products
   {
     "subcategoryId": 10,
     "name": "Pizza Hawaiana",
     "description": "...",
     "price": 150.00,
     "modifierGroupIds": [5, 6]  ← IDs de grupos seleccionados
   }
   ```

3. **Visualización:**
   - Grid o ListView de productos
   - Card con imagen, nombre, precio
   - Badge de disponibilidad (Disponible/No disponible)
   - Número de grupos de modificadores asociados
   - Opciones de editar/eliminar

---

## 🎨 Recomendaciones de UI/UX

### **1. Wizard para Primer Producto**

Si el restaurante no tiene productos, mostrar un wizard guiado:

```
Paso 1/5: Crear una subcategoría
→ Explica qué es una subcategoría
→ Muestra ejemplos ("Pizzas Tradicionales", "Bebidas Frías")

Paso 2/5: Crear grupo de modificadores
→ Explica qué es un grupo
→ Muestra ejemplos ("Tamaño", "Extras")

Paso 3/5: Añadir opciones al grupo
→ Explica qué son las opciones
→ Muestra ejemplos ("Grande - $45")

Paso 4/5: Crear tu primer producto
→ Formulario completo
→ Asociar grupos creados

Paso 5/5: ¡Menú listo!
→ Resumen
→ Botón "Ver mi menú"
```

---

### **2. Templates de Menú**

Ofrecer templates predefinidos:

**Template "Pizzería Básica":**
- Subcategorías: "Pizzas", "Bebidas", "Postres"
- Grupos: "Tamaño" (obligatorio), "Extras" (opcional)
- Productos de ejemplo: Pizza Pepperoni, Coca-Cola

**Implementación:**
Crear múltiples subcategorías, grupos y productos con una secuencia de llamadas API.

---

### **3. Vista Previa del Menú**

Botón "Vista Previa" que muestra cómo verán los clientes el menú:
- Usa GET /restaurants/:id (endpoint público)
- Simula la experiencia del cliente
- Permite verificar antes de publicar

---

### **4. Drag & Drop para Ordenamiento**

Permitir reordenar subcategorías arrastrando:
- Actualizar displayOrder de cada subcategoría
- Enviar PATCH /subcategories/:id con nuevo displayOrder

---

## 🔧 Flujos Avanzados

### **Flujo 1: Importar Producto de Otro Restaurante (Inspiración)**

```
1. Owner ve menú de otro restaurante (GET /restaurants/:id)
2. Owner ve un producto que le gusta
3. App copia solo la estructura (nombre, precio estimado)
4. Owner crea su propia versión:
   - POST /subcategories (si no existe)
   - POST /modifier-groups (copia grupos)
   - POST /products (nuevo producto inspirado)
```

---

### **Flujo 2: Duplicar Producto Existente**

```
1. Owner selecciona producto existente
2. Botón "Duplicar"
3. App precarga formulario con datos del producto original
4. Owner modifica nombre/precio
5. POST /products con mismos modifierGroupIds
```

**Ejemplo:**
```http
// Producto original
{ "id": 1, "name": "Pizza Hawaiana", "modifierGroupIds": [1, 2] }

// Duplicar
POST /products
{
  "name": "Pizza Hawaiana Especial",  ← Nombre nuevo
  "price": 180.00,                    ← Precio diferente
  "subcategoryId": 1,
  "modifierGroupIds": [1, 2]          ← Mismos grupos
}
```

---

### **Flujo 3: Gestión Masiva de Disponibilidad**

```
Escenario: Owner se queda sin champiñones y quiere desactivar 
           todos los productos que los incluyen.

Solución: Endpoint especial ya implementado:
POST /api/restaurant/products/deactivate-by-tag
{
  "tag": "champinones"
}

→ Todos los productos con tag "champinones" se marcan como 
  isAvailable: false
```

---

## 📊 Resumen de Capacidades del Backend

### **✅ Capacidades Confirmadas:**

1. ✅ **Crear jerarquía completa:** Categoría → Subcategoría → Producto
2. ✅ **Modificadores flexibles:** Grupos reutilizables con opciones
3. ✅ **Asociación en creación:** Producto se puede crear con modificadores
4. ✅ **Actualización de asociaciones:** Agregar/quitar grupos a producto existente
5. ✅ **Validación de pertenencia:** Backend verifica que grupos pertenezcan al restaurante
6. ✅ **Contexto automático:** No se necesita enviar restaurantId
7. ✅ **Paginación:** Soporte para catálogos grandes
8. ✅ **Filtros:** Por subcategoría, disponibilidad, etc.

---

### **✅ Características Avanzadas:**

1. ✅ **Actualización selectiva:** Solo se actualizan campos enviados
2. ✅ **Reemplazo completo de asociaciones:** modifierGroupIds reemplaza todo
3. ✅ **Validación cruzada:** Verifica que subcategorías/grupos sean del mismo restaurante
4. ✅ **Respuesta completa:** Include de relaciones en respuestas
5. ✅ **Gestión por tags:** Desactivación masiva de productos

---

## 🎉 Conclusión de Viabilidad

### **VEREDICTO FINAL: ✅ COMPLETAMENTE VIABLE**

El backend de Delixmi tiene **todos los endpoints necesarios** y la **lógica completa** para soportar la construcción de un menú personalizable por parte del owner.

**Endpoints verificados:**
- ✅ Categorías globales (GET /categories)
- ✅ CRUD de subcategorías (GET, POST, PATCH, DELETE)
- ✅ CRUD de grupos de modificadores (GET, POST, PATCH, DELETE)
- ✅ CRUD de opciones (POST, PATCH, DELETE)
- ✅ CRUD de productos CON asociación a modificadores (GET, POST, PATCH, DELETE)

**Funcionalidad clave confirmada:**
- ✅ Campo `modifierGroupIds` en POST /products (línea 1715)
- ✅ Campo `modifierGroupIds` en PATCH /products (línea 1963)
- ✅ Creación de asociaciones en ProductModifier (líneas 1857-1862)
- ✅ Actualización de asociaciones en PATCH (líneas 2174-2190)
- ✅ Validación de grupos del mismo restaurante (líneas 1796-1818, 2084-2108)

**No se requieren cambios en el backend.**

El equipo de frontend puede proceder con la implementación siguiendo esta especificación técnica.

---

**Fecha de Verificación:** 9 de Enero, 2025  
**Auditor:** Arquitecto de Software Backend Delixmi  
**Estado:** ✅ Aprobado para Implementación Frontend

