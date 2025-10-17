# 📨 **PROMPT PARA EQUIPO DE BACKEND - CONFIGURAR PERFIL DE RESTAURANTE**

**Asunto:** 🔍 Verificación de APIs para Configuración de Perfil de Restaurante - Frontend Listo para Implementar

Hola Backend Team,

Estamos listos para implementar la funcionalidad de **"Configurar Perfil"** del restaurante en el frontend Flutter. Necesito verificar que tenemos todas las APIs necesarias, validaciones y funcionalidades para crear una experiencia impecable.

## 🎯 **FUNCIONALIDADES QUE VAMOS A IMPLEMENTAR**

### **📱 Frontend Flutter - Configurar Perfil:**
1. **🖼️ Subir/Actualizar Logo** - Imagen del restaurante (400x400px, máx 5MB)
2. **📸 Subir/Actualizar Portada** - Imagen de fondo (1200x400px, máx 5MB)
3. **📝 Editar Nombre** - Nombre del restaurante (máx 150 caracteres)
4. **📄 Editar Descripción** - Descripción del restaurante (máx 1000 caracteres)
5. **📞 Editar Teléfono** - Número de contacto (validación de formato)
6. **📧 Editar Email** - Correo electrónico (validación de formato)
7. **📍 Editar Dirección** - Dirección principal del restaurante
8. **📊 Ver Estadísticas** - Sucursales, categorías, productos (read-only)

---

## 🔍 **VERIFICACIONES NECESARIAS**

### **1. 🏪 API de Perfil del Restaurante**

**¿Tenemos estos endpoints funcionando?**

#### **📥 Obtener Perfil:**
```bash
GET /api/restaurant/profile
Headers: Authorization: Bearer <token>
```

**¿Devuelve esta estructura?**
```json
{
  "status": "success",
  "message": "Perfil obtenido exitosamente",
  "data": {
    "restaurant": {
      "id": 1,
      "name": "Pizzería de Ana",
      "description": "Las mejores pizzas artesanales de la ciudad",
      "logoUrl": "https://api.delixmi.com/uploads/logo_123.jpg",
      "coverPhotoUrl": "https://api.delixmi.com/uploads/cover_123.jpg",
      "phone": "+52 55 1234 5678",
      "email": "contacto@pizzeriadeana.com",
      "address": "Av. Principal 123, Ciudad de México",
      "status": "active",
      "owner": {
        "id": 16,
        "name": "Ana",
        "lastname": "García",
        "email": "ana@example.com",
        "phone": "+52 55 9876 5432"
      },
      "branches": [
        {
          "id": 1,
          "name": "Sucursal Centro",
          "address": "Av. Principal 123",
          "phone": "+52 55 1234 5678",
          "status": "active",
          "createdAt": "2024-01-15T10:00:00Z",
          "updatedAt": "2024-01-15T10:00:00Z"
        }
      ],
      "statistics": {
        "totalBranches": 1,
        "totalSubcategories": 5,
        "totalProducts": 45
      },
      "createdAt": "2024-01-15T10:00:00Z",
      "updatedAt": "2024-01-15T10:00:00Z"
    }
  }
}
```

#### **📤 Actualizar Perfil:**
```bash
PUT /api/restaurant/profile
Headers: Authorization: Bearer <token>
Content-Type: application/json
```

**¿Acepta esta estructura?**
```json
{
  "name": "Pizzería de Ana - Actualizada",
  "description": "Las mejores pizzas artesanales de la ciudad con ingredientes frescos",
  "phone": "+52 55 1234 5679",
  "email": "contacto@pizzeriadeana.com",
  "address": "Av. Principal 123, Ciudad de México, CDMX"
}
```

**¿Devuelve el perfil actualizado completo?**

### **2. 🖼️ APIs de Subida de Imágenes**

#### **📸 Subir Logo:**
```bash
POST /api/restaurant/upload-logo
Headers: Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**¿Acepta:**
- Formato: `multipart/form-data`
- Campo: `logo` (archivo)
- Validaciones: JPG/PNG, máx 5MB, dimensiones recomendadas 400x400px

**¿Devuelve:**
```json
{
  "status": "success",
  "message": "Logo subido exitosamente",
  "data": {
    "logoUrl": "https://api.delixmi.com/uploads/logo_123_new.jpg",
    "filename": "logo_123_new.jpg",
    "originalName": "mi_logo.jpg",
    "size": 2048576,
    "mimetype": "image/jpeg"
  }
}
```

#### **📸 Subir Portada:**
```bash
POST /api/restaurant/upload-cover
Headers: Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**¿Acepta:**
- Formato: `multipart/form-data`
- Campo: `cover` (archivo)
- Validaciones: JPG/PNG, máx 5MB, dimensiones recomendadas 1200x400px

**¿Devuelve:**
```json
{
  "status": "success",
  "message": "Portada subida exitosamente",
  "data": {
    "coverPhotoUrl": "https://api.delixmi.com/uploads/cover_123_new.jpg",
    "filename": "cover_123_new.jpg",
    "originalName": "mi_portada.jpg",
    "size": 3145728,
    "mimetype": "image/jpeg"
  }
}
```

### **3. ✅ Validaciones Necesarias**

**¿Tenemos estas validaciones implementadas?**

#### **📝 Validaciones de Campos:**
- **Nombre**: Requerido, máx 150 caracteres, sin caracteres especiales
- **Descripción**: Opcional, máx 1000 caracteres
- **Teléfono**: Formato válido de teléfono mexicano/internacional
- **Email**: Formato válido de email
- **Dirección**: Máx 500 caracteres

#### **🖼️ Validaciones de Imágenes:**
- **Logo**: JPG/PNG, máx 5MB, dimensiones 400x400px recomendadas
- **Portada**: JPG/PNG, máx 5MB, dimensiones 1200x400px recomendadas
- **Compresión**: ¿Se comprimen automáticamente?
- **CDN**: ¿Las imágenes se sirven desde CDN?

#### **🔒 Validaciones de Seguridad:**
- **Autenticación**: ¿Solo el owner del restaurante puede editar?
- **Rate Limiting**: ¿Límites en subida de imágenes?
- **File Scanning**: ¿Escaneo de malware en imágenes?

### **4. 🔄 Flujo de Actualización**

**¿Funciona este flujo?**

#### **Para Imágenes:**
```
1. Frontend sube imagen → POST /api/restaurant/upload-logo
2. Backend procesa y guarda → Devuelve URL
3. Frontend actualiza perfil → PUT /api/restaurant/profile (con logoUrl)
4. Backend actualiza registro → Devuelve perfil completo
```

#### **Para Datos de Texto:**
```
1. Frontend envía datos → PUT /api/restaurant/profile
2. Backend valida campos → Actualiza en BD
3. Backend devuelve → Perfil actualizado completo
```

---

## 📋 **CHECKLIST DE VERIFICACIÓN**

### **✅ APIs Necesarias:**
- [ ] `GET /api/restaurant/profile` - Obtener perfil completo
- [ ] `PUT /api/restaurant/profile` - Actualizar datos de texto
- [ ] `POST /api/restaurant/upload-logo` - Subir logo
- [ ] `POST /api/restaurant/upload-cover` - Subir portada

### **✅ Validaciones:**
- [ ] **Nombre**: Requerido, máx 150 caracteres
- [ ] **Descripción**: Opcional, máx 1000 caracteres
- [ ] **Teléfono**: Formato válido
- [ ] **Email**: Formato válido
- [ ] **Dirección**: Máx 500 caracteres
- [ ] **Logo**: JPG/PNG, máx 5MB, 400x400px
- [ ] **Portada**: JPG/PNG, máx 5MB, 1200x400px

### **✅ Funcionalidades:**
- [ ] **Autenticación**: Solo owner puede editar
- [ ] **Compresión**: Imágenes se optimizan
- [ ] **CDN**: Imágenes servidas desde CDN
- [ ] **Rate Limiting**: Límites en subida
- [ ] **Error Handling**: Mensajes de error claros

### **✅ Respuestas:**
- [ ] **Estructura JSON**: Consistente con frontend
- [ ] **Códigos HTTP**: 200, 400, 401, 403, 500 apropiados
- [ ] **Mensajes**: Claros y en español
- [ ] **Timestamps**: Formato ISO 8601

---

## 🚀 **IMPLEMENTACIÓN FRONTEND LISTA**

### **✅ Ya Tenemos Implementado:**
- **UI moderna** con Material 3
- **Formularios** con validación
- **Subida de imágenes** con ImagePicker
- **Estados de loading** y error
- **Modelos de datos** completos
- **Servicios** para todas las APIs

### **🎨 Diseño Moderno:**
- **Cards elegantes** para cada sección
- **Preview de imágenes** antes de subir
- **Indicadores de progreso** durante subida
- **Validación en tiempo real** de formularios
- **Feedback visual** para todas las acciones

---

## 📞 **RESPUESTA SOLICITADA**

**¿Pueden confirmar:**

1. **¿Todos los endpoints están funcionando?** (GET, PUT, POST upload)
2. **¿Las validaciones están implementadas?** (campos de texto e imágenes)
3. **¿Los formatos de respuesta coinciden?** (JSON structure)
4. **¿Hay algún endpoint faltante?** (que necesitemos agregar)
5. **¿Hay limitaciones especiales?** (rate limits, file sizes, etc.)
6. **¿Las imágenes se optimizan automáticamente?** (compresión, CDN)

### **📋 Si falta algo:**
**¿Pueden implementar lo que falta antes de que procedamos con el frontend?**

### **📋 Si está todo listo:**
**¡Procedemos con la implementación del frontend moderno!**

---

## 🎯 **OBJETIVO**

**Crear una experiencia impecable** para que los owners puedan:
- ✅ **Configurar su perfil** de manera intuitiva
- ✅ **Subir imágenes** de alta calidad
- ✅ **Editar información** con validación en tiempo real
- ✅ **Ver estadísticas** de su restaurante
- ✅ **Guardar cambios** con feedback inmediato

**Con esta información podremos implementar un flujo perfecto entre frontend y backend.** 🚀

---

**Frontend Team** 🎨  
**Esperando confirmación para proceder** ⏳
