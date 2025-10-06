# 🔗 Guía de Configuración de Deep Linking para Delixmi

## 📋 Resumen

Este documento explica cómo configurar deep linking para la aplicación Delixmi, permitiendo que los usuarios accedan directamente a pantallas específicas mediante enlaces profundos.

## 🎯 Funcionalidades Implementadas

### ✅ Deep Links Soportados

1. **Reset Password**: `delixmi://reset-password?token=TOKEN`
2. **Email Verification**: `delixmi://verify-email?email=EMAIL`
3. **Login**: `delixmi://login`
4. **Register**: `delixmi://register`
5. **Home**: `delixmi://home`

## 📱 Configuración por Plataforma

### 🤖 Android

#### 1. Configurar AndroidManifest.xml

Agregar la siguiente configuración en `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    
    <!-- Configuración existente -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep Link para Delixmi -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="delixmi" />
    </intent-filter>
    
    <!-- Deep Link HTTP/HTTPS (opcional) -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="delixmi.app" />
    </intent-filter>
</activity>
```

### 🍎 iOS

#### 1. Configurar Info.plist

Agregar la siguiente configuración en `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>delixmi.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>delixmi</string>
        </array>
    </dict>
</array>

<!-- Configuración para Universal Links (opcional) -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:delixmi.app</string>
</array>
```

## 🧪 Pruebas de Deep Linking

### 📱 En Dispositivo Real

#### Android
```bash
# Reset password
adb shell am start -W -a android.intent.action.VIEW -d "delixmi://reset-password?token=test123" com.example.delixmi_frontend

# Email verification
adb shell am start -W -a android.intent.action.VIEW -d "delixmi://verify-email?email=test@example.com" com.example.delixmi_frontend

# Login
adb shell am start -W -a android.intent.action.VIEW -d "delixmi://login" com.example.delixmi_frontend
```

#### iOS
```bash
# Reset password
xcrun simctl openurl booted "delixmi://reset-password?token=test123"

# Email verification
xcrun simulator openurl booted "delixmi://verify-email?email=test@example.com"

# Login
xcrun simctl openurl booted "delixmi://login"
```

### 🖥️ En Emulador/Simulador

#### Android Emulator
```bash
# Abrir desde terminal
adb shell am start -W -a android.intent.action.VIEW -d "delixmi://reset-password?token=test123"
```

#### iOS Simulator
```bash
# Abrir desde terminal
xcrun simctl openurl booted "delixmi://reset-password?token=test123"
```

### 🌐 Desde Navegador Web

Para probar desde un navegador web (solo en desarrollo):

```html
<!DOCTYPE html>
<html>
<head>
    <title>Pruebas Deep Link Delixmi</title>
</head>
<body>
    <h1>Pruebas de Deep Linking</h1>
    
    <h2>Reset Password</h2>
    <a href="delixmi://reset-password?token=test123">Reset Password</a>
    
    <h2>Email Verification</h2>
    <a href="delixmi://verify-email?email=test@example.com">Email Verification</a>
    
    <h2>Login</h2>
    <a href="delixmi://login">Login</a>
    
    <h2>Register</h2>
    <a href="delixmi://register">Register</a>
    
    <h2>Home</h2>
    <a href="delixmi://home">Home</a>
</body>
</html>
```

## 🔧 Implementación Técnica

### 📁 Archivos Modificados

1. **`pubspec.yaml`**: Agregada dependencia `app_links: ^3.4.5`
2. **`lib/main.dart`**: Inicialización del servicio de deep links
3. **`lib/services/deep_link_service.dart`**: Servicio principal para manejo de deep links
4. **`lib/screens/home_screen.dart`**: Botones de prueba para generar enlaces

### 🏗️ Arquitectura

```dart
DeepLinkService
├── initialize(BuildContext) - Inicializa el servicio
├── _initDeepLinks() - Configura listeners
├── _handleDeepLink(Uri) - Procesa enlaces recibidos
├── _navigateToResetPassword(String) - Navega a reset password
├── _navigateToEmailVerification(String) - Navega a verificación
├── generateResetPasswordLink(String) - Genera enlace de prueba
└── generateEmailVerificationLink(String) - Genera enlace de prueba
```

## 🚀 Flujo de Funcionamiento

### 1. **Inicialización**
```dart
// En SplashScreen
DeepLinkService.initialize(context);
```

### 2. **Recepción de Enlace**
```dart
// El servicio detecta automáticamente los enlaces
_appLinks.uriLinkStream.listen((link) {
  _handleDeepLink(link);
});
```

### 3. **Procesamiento**
```dart
// Identifica el tipo de enlace y navega
if (link.scheme == 'delixmi' && link.host == 'reset-password') {
  final token = link.queryParameters['token'];
  _navigateToResetPassword(token);
}
```

### 4. **Navegación**
```dart
// Navega a la pantalla correspondiente
Navigator.of(_context!).pushNamedAndRemoveUntil(
  '/reset-password',
  (route) => false,
  arguments: token,
);
```

## 🔒 Consideraciones de Seguridad

### ✅ Implementadas

1. **Validación de esquema**: Solo acepta enlaces con esquema `delixmi://`
2. **Validación de parámetros**: Verifica que los parámetros requeridos estén presentes
3. **Navegación segura**: Usa `pushNamedAndRemoveUntil` para limpiar el stack

### ⚠️ Recomendaciones

1. **Validar tokens**: Implementar validación de tokens en el backend
2. **Expiración**: Los tokens deben tener tiempo de expiración
3. **Rate limiting**: Implementar límites de intentos
4. **Logging**: Registrar intentos de acceso para auditoría

## 🐛 Solución de Problemas

### Problema: Los deep links no funcionan

**Solución**:
1. Verificar que la configuración de `AndroidManifest.xml` e `Info.plist` esté correcta
2. Reiniciar la aplicación después de cambios en configuración
3. Verificar que el esquema `delixmi://` esté registrado

### Problema: La navegación no funciona correctamente

**Solución**:
1. Verificar que `DeepLinkService.initialize()` se llame en `SplashScreen`
2. Asegurar que el contexto esté disponible cuando se recibe el enlace
3. Verificar que las rutas estén definidas en `main.dart`

### Problema: Los parámetros no se pasan correctamente

**Solución**:
1. Verificar el formato del enlace: `delixmi://reset-password?token=VALUE`
2. Asegurar que los nombres de parámetros coincidan
3. Verificar que los parámetros no estén vacíos

## 📚 Referencias

- [Flutter Deep Linking Documentation](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [App Links Package](https://pub.dev/packages/app_links)
- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)

## 🎯 Próximos Pasos

1. **Configurar Universal Links** para iOS (enlaces web que abren la app)
2. **Implementar validación de tokens** en el backend
3. **Agregar analytics** para tracking de deep links
4. **Implementar fallbacks** para cuando la app no esté instalada
5. **Agregar tests automatizados** para deep linking

---

**Nota**: Esta configuración está optimizada para desarrollo y testing. Para producción, se recomienda implementar validaciones adicionales y configurar Universal Links/App Links apropiadamente.
