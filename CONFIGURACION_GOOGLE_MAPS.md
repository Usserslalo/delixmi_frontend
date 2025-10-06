# 🗺️ Configuración de Google Maps para Delixmi

## ⚠️ IMPORTANTE: Configuración Requerida

Para que Google Maps funcione correctamente en la aplicación, necesitas configurar una API Key de Google Maps. Actualmente la app está usando un **placeholder temporal** para evitar crashes.

## 🔧 Pasos para Configurar Google Maps

### 1. Obtener API Key de Google Maps

1. **Ve a [Google Cloud Console](https://console.cloud.google.com/)**
2. **Crea un proyecto** o selecciona uno existente
3. **Habilita las siguientes APIs:**
   - Maps SDK for Android
   - Places API
   - Geocoding API
4. **Crea credenciales** → API Key
5. **Restringe la API Key** (recomendado para producción):
   - Aplicaciones Android: Agrega el SHA-1 fingerprint de tu app
   - APIs: Restringe solo a las APIs que necesitas

### 2. Configurar la API Key en Android

1. **Abre el archivo:** `android/app/src/main/AndroidManifest.xml`
2. **Busca la línea:**
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY" />
   ```
3. **Reemplaza** `YOUR_GOOGLE_MAPS_API_KEY` con tu API Key real:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" />
   ```

### 3. Obtener SHA-1 Fingerprint (Para Restricciones)

**En Windows:**
```bash
cd android
./gradlew signingReport
```

**En macOS/Linux:**
```bash
cd android
./gradlew signingReport
```

Busca la línea que dice `SHA1:` y copia el valor.

### 4. Activar Google Maps Real

Una vez configurada la API Key:

1. **Cambia el import en `lib/main.dart`:**
   ```dart
   // Cambiar de:
   import 'screens/customer/location_picker_screen_temp.dart';
   
   // A:
   import 'screens/customer/location_picker_screen.dart';
   ```

2. **Cambia la ruta en `lib/main.dart`:**
   ```dart
   // Cambiar de:
   return LocationPickerScreenTemp(
   
   // A:
   return LocationPickerScreen(
   ```

3. **Cambia el import en `lib/screens/customer/address_form_screen.dart`:**
   ```dart
   // Cambiar de:
   import 'location_picker_screen_temp.dart';
   
   // A:
   import 'location_picker_screen.dart';
   ```

4. **Cambia la clase en `address_form_screen.dart`:**
   ```dart
   // Cambiar de:
   LocationPickerScreenTemp(
   
   // A:
   LocationPickerScreen(
   ```

## 🎨 Características del Diseño Actual

### ✅ Lo que ya está implementado:

- **Diseño Material Design moderno** con:
  - Cards con sombras sutiles
  - Botones con gradientes
  - Tipografía moderna
  - Colores consistentes
  - Espaciado profesional

- **Funcionalidad completa:**
  - Selección de ubicación por GPS
  - Geocodificación de direcciones
  - Validación de permisos
  - Manejo de errores
  - Interfaz responsive

- **Placeholder temporal:**
  - Mapa visual con patrón
  - Botón de ubicación actual
  - Misma funcionalidad que el mapa real
  - No causa crashes

## 🚀 Resultado Final

Una vez configurado Google Maps, tendrás:

- **Mapa interactivo** con Google Maps
- **Selección por toque** en el mapa
- **Ubicación actual** con botón GPS
- **Diseño profesional** tipo apps top
- **Sin crashes** ni errores

## 🔍 Troubleshooting

### Si el mapa no se carga:
1. Verifica que la API Key esté correcta
2. Asegúrate de que las APIs estén habilitadas
3. Verifica las restricciones de la API Key
4. Revisa los logs de la consola

### Si hay errores de permisos:
1. Verifica que los permisos estén en AndroidManifest.xml
2. Solicita permisos en tiempo de ejecución
3. Verifica la configuración del dispositivo

## 📱 Estado Actual

- ✅ **App funcional** con placeholder
- ✅ **Diseño moderno** implementado
- ✅ **Sin crashes**
- ⏳ **Pendiente:** Configurar API Key para mapa real

¡La app está lista para usar! Solo necesitas configurar la API Key para activar el mapa real de Google Maps.
