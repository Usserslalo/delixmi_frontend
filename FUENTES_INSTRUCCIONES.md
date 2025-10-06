# Instrucciones para Configurar las Fuentes Plus Jakarta Sans

## 📋 Pasos para Descargar las Fuentes

### 1. Descargar las Fuentes desde Google Fonts

1. Ve a [Google Fonts - Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans)
2. Haz clic en "Download family"
3. Extrae el archivo ZIP descargado

### 2. Archivos Necesarios

Descarga los siguientes archivos de la familia Plus Jakarta Sans:

- `PlusJakartaSans-Regular.ttf` (peso 400)
- `PlusJakartaSans-Medium.ttf` (peso 500)
- `PlusJakartaSans-Bold.ttf` (peso 700)
- `PlusJakartaSans-ExtraBold.ttf` (peso 800)

### 3. Colocar los Archivos

1. Coloca todos los archivos `.ttf` en la carpeta `fonts/` del proyecto
2. La estructura debe quedar así:
   ```
   delixmi_frontend/
   ├── fonts/
   │   ├── PlusJakartaSans-Regular.ttf
   │   ├── PlusJakartaSans-Medium.ttf
   │   ├── PlusJakartaSans-Bold.ttf
   │   └── PlusJakartaSans-ExtraBold.ttf
   ├── lib/
   └── pubspec.yaml
   ```

### 4. Descomentar la Configuración

Una vez que tengas los archivos en la carpeta `fonts/`, descomenta las siguientes líneas:

**En `pubspec.yaml`:**
```yaml
fonts:
  - family: PlusJakartaSans
    fonts:
      - asset: fonts/PlusJakartaSans-Regular.ttf
        weight: 400
      - asset: fonts/PlusJakartaSans-Medium.ttf
        weight: 500
      - asset: fonts/PlusJakartaSans-Bold.ttf
        weight: 700
      - asset: fonts/PlusJakartaSans-ExtraBold.ttf
        weight: 800
```

**En `lib/theme.dart`:**
```dart
// Cambiar esta línea:
// fontFamily: 'PlusJakartaSans', // Comentado hasta descargar las fuentes

// Por esta:
fontFamily: 'PlusJakartaSans',
```

### 5. Ejecutar el Proyecto

Después de configurar las fuentes, ejecuta:

```bash
flutter pub get
flutter run
```

## 🎨 Resultado Esperado

Una vez configuradas las fuentes, la aplicación tendrá:

- ✅ Tipografía Plus Jakarta Sans en toda la app
- ✅ Colores personalizados según el diseño
- ✅ UI moderna y consistente
- ✅ Login screen rediseñado según especificaciones

## 📱 Características del Diseño

- **Color primario**: #F2843A (naranja)
- **Fondo claro**: #F8F7F6
- **Texto principal**: #1C130D
- **Texto secundario**: #9B6B4B
- **Campos de entrada**: #F3ECE7
- **Bordes redondeados**: 8px
- **Fuente**: Plus Jakarta Sans

## 🔧 Notas Técnicas

- Las fuentes están comentadas temporalmente para evitar errores de compilación
- El proyecto funciona correctamente con las fuentes del sistema
- Una vez descargadas las fuentes, descomenta las líneas indicadas
- La aplicación mantiene toda la funcionalidad existente
