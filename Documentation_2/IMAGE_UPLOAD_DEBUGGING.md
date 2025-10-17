# 🔍 **DEBUGGING DE SUBIDA DE IMÁGENES**

## 🚨 **PROBLEMA IDENTIFICADO**

**Error:** `"Solo se permiten archivos de imagen"` con código `INVALID_FILE_TYPE`

**Status:** 400 en ambos endpoints:
- `POST /api/restaurant/uploads/logo`
- `POST /api/restaurant/uploads/cover`

---

## 🔧 **SOLUCIONES IMPLEMENTADAS**

### **1. 📤 Debugging Mejorado en RestaurantService**

#### **Cambios en `lib/services/restaurant_service.dart`:**
- ✅ **Debugging detallado** del archivo (nombre, tamaño, extensión)
- ✅ **Validación de extensión** antes de enviar
- ✅ **MIME type explícito** en MultipartFile
- ✅ **Headers mejorados** con Content-Type
- ✅ **Logs detallados** para debugging

#### **Código agregado:**
```dart
// Debugging detallado del archivo
final fileSize = await imageFile.length();
final fileName = imageFile.path.split('/').last;
final fileExtension = fileName.split('.').last.toLowerCase();

debugPrint('📁 Archivo: $fileName');
debugPrint('📏 Tamaño: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
debugPrint('🔤 Extensión: $fileExtension');
debugPrint('📂 Ruta completa: ${imageFile.path}');

// Verificar que sea una imagen válida
if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
  return ApiResponse<UploadImageResponse>(
    status: 'error',
    message: 'Formato de archivo no válido. Solo se permiten JPG, JPEG y PNG.',
  );
}

// MIME type explícito
final mimeType = fileExtension == 'jpg' || fileExtension == 'jpeg' 
    ? 'image/jpeg' 
    : 'image/png';

request.files.add(
  await http.MultipartFile.fromPath(
    'image',
    imageFile.path,
    contentType: MediaType.parse(mimeType),
  ),
);
```

### **2. 🧪 Servicio de Debugging Avanzado**

#### **Nuevo archivo: `lib/services/restaurant_service_debug.dart`**
- ✅ **Prueba múltiples campos** (image, logo, file, photo)
- ✅ **Logs detallados** de cada intento
- ✅ **Identificación del campo correcto**
- ✅ **Headers de debugging** adicionales

#### **Campos probados:**
```dart
final fieldsToTest = ['image', 'logo', 'file', 'photo'];
```

### **3. 📱 Pantalla de Debugging**

#### **Nueva pantalla: `lib/screens/owner/debug_image_upload_screen.dart`**
- ✅ **Selección de imagen** desde galería
- ✅ **Prueba de logo y portada** por separado
- ✅ **Log en tiempo real** de resultados
- ✅ **Interfaz simple** para testing

#### **Acceso:**
- **Ruta:** `/debug-upload`
- **Botón en dashboard:** "Debug Upload" (temporal)

---

## 🎯 **INSTRUCCIONES DE DEBUGGING**

### **1. 🔍 Usar la Pantalla de Debug**

1. **Abrir la app** como owner
2. **Ir al dashboard** del owner
3. **Tocar "Debug Upload"** (botón naranja)
4. **Seleccionar una imagen** desde la galería
5. **Probar "Probar Logo"** y **"Probar Portada"**
6. **Revisar los logs** en la pantalla

### **2. 📊 Interpretar los Logs**

#### **Logs esperados:**
```
📁 Archivo: mi_imagen.jpg
📏 Tamaño: 2.45 MB
🔤 Extensión: jpg
📂 Ruta completa: /storage/emulated/0/.../mi_imagen.jpg
📤 Enviando archivo con MIME type: image/jpeg
🧪 Probando campo: image
📡 Response status: 200
✅ Éxito con campo: image
```

#### **Si falla:**
```
🧪 Probando campo: image
📡 Response status: 400
📡 Response body: {"status":"error","message":"Solo se permiten archivos de imagen","code":"INVALID_FILE_TYPE"}
❌ Falló con campo: image - Solo se permiten archivos de imagen
```

### **3. 🔧 Posibles Soluciones**

#### **Si todos los campos fallan:**
1. **Verificar formato** - Solo JPG, JPEG, PNG
2. **Verificar tamaño** - Máximo 5MB
3. **Verificar MIME type** - Debe ser image/jpeg o image/png
4. **Verificar headers** - Content-Type correcto

#### **Si un campo funciona:**
1. **Actualizar RestaurantService** con el campo correcto
2. **Remover debugging** temporal
3. **Probar en pantalla normal**

---

## 🚀 **PRÓXIMOS PASOS**

### **1. 🔍 Identificar el Problema**
- **Usar la pantalla de debug** para probar diferentes campos
- **Revisar logs detallados** para identificar la causa
- **Verificar si es problema de frontend o backend**

### **2. 🛠️ Implementar la Solución**
- **Si es campo incorrecto:** Actualizar RestaurantService
- **Si es MIME type:** Ajustar headers
- **Si es validación backend:** Coordinar con backend team

### **3. 🧹 Limpiar Código**
- **Remover pantalla de debug** una vez solucionado
- **Remover servicio de debug** temporal
- **Mantener mejoras** en RestaurantService

---

## 📋 **CHECKLIST DE DEBUGGING**

### **✅ Implementado:**
- [x] **Debugging mejorado** en RestaurantService
- [x] **Servicio de debug** con múltiples campos
- [x] **Pantalla de testing** para debugging
- [x] **Logs detallados** para análisis
- [x] **Validaciones frontend** mejoradas

### **🔄 En Proceso:**
- [ ] **Identificar campo correcto** del backend
- [ ] **Verificar MIME type** requerido
- [ ] **Confirmar validaciones** backend
- [ ] **Implementar solución** definitiva

### **⏳ Pendiente:**
- [ ] **Probar con diferentes imágenes**
- [ ] **Verificar con backend team**
- [ ] **Limpiar código temporal**
- [ ] **Documentar solución final**

---

## 🎉 **RESULTADO ESPERADO**

Una vez identificado el problema, deberíamos poder:

1. **✅ Subir logos** correctamente
2. **✅ Subir portadas** correctamente
3. **✅ Ver preview** de imágenes
4. **✅ Actualizar perfil** con nuevas URLs
5. **✅ Experiencia fluida** para el usuario

**¡El debugging nos ayudará a identificar exactamente qué está causando el problema!** 🔍
