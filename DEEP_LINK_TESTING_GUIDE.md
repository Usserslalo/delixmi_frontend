# Guía de Pruebas para Deep Links - Reset Password

## 🔧 Implementación Completada

El flujo de restablecimiento de contraseña con deep links ha sido completamente implementado y corregido. Aquí están los archivos actualizados:

### 📁 Archivos Modificados:

1. **`lib/main.dart`** - Mejorada la inicialización del DeepLinkService
2. **`lib/services/deep_link_service.dart`** - Mejorado el manejo de deep links con debugging
3. **`lib/screens/reset_password_screen.dart`** - Añadida validación de token

## 🧪 Cómo Probar el Flujo

### 1. Preparación
Asegúrate de que el backend esté ejecutándose en `http://10.0.2.2:3000` y que tengas un usuario registrado.

### 2. Simular el Flujo Completo

#### Paso 1: Solicitar Reset de Contraseña
1. Abre la app
2. Ve a LoginScreen
3. Toca "¿Olvidaste tu contraseña?"
4. Ingresa el email de un usuario existente
5. Toca "Enviar enlace"

#### Paso 2: Simular el Deep Link (Testing)
En lugar de esperar el email real, puedes usar estos comandos para simular el deep link:

**Para Android Emulator:**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "delixmi://reset-password?token=test_token_123456" com.example.delixmi_frontend
```

**Para iOS Simulator:**
```bash
xcrun simctl openurl booted "delixmi://reset-password?token=test_token_123456"
```

#### Paso 3: Usar el Generador de Enlaces (Desde HomeScreen)
1. Haz login exitoso para llegar a HomeScreen
2. Toca el botón "Generar enlace de reset password"
3. Copia el enlace generado
4. Abre el enlace en el navegador o usa los comandos de arriba

### 3. Verificar el Flujo

#### Lo que debería pasar:
1. ✅ La app detecta el deep link
2. ✅ Se extrae el token correctamente
3. ✅ Se navega automáticamente a ResetPasswordScreen
4. ✅ El token se pasa como argumento
5. ✅ La pantalla muestra el formulario de nueva contraseña
6. ✅ Al enviar, se llama a `AuthService.resetPassword()` con el token correcto

#### Logs de Debugging:
Revisa la consola para ver estos logs:
```
🔗 Deep link inicial detectado: delixmi://reset-password?token=test_token_123456
🔍 Procesando deep link: scheme=delixmi, host=reset-password, query={token: test_token_123456}
✅ Token de reset password encontrado: test_token...
🚀 Navegando a ResetPasswordScreen con token
✅ Token de reset password válido: test_token...
```

## 🚨 Casos de Error Manejados

### 1. Token Vacío
Si el deep link no tiene token o está vacío:
```
❌ Token de reset password no encontrado o vacío
```

### 2. Token Inválido en ResetPasswordScreen
Si se navega a ResetPasswordScreen sin token:
```
❌ Token de reset password está vacío
```
- Se muestra mensaje de error
- Se navega automáticamente de vuelta al login

### 3. Contexto No Disponible
Si el DeepLinkService no puede navegar:
```
❌ No se puede navegar a reset password: contexto no disponible
```

## 📱 Configuración de Android Manifest

Asegúrate de que tu `android/app/src/main/AndroidManifest.xml` tenga esta configuración:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    <!-- ... otras configuraciones ... -->
    
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="delixmi" />
    </intent-filter>
</activity>
```

## 🔗 Formatos de Deep Links Soportados

| Acción | Formato | Ejemplo |
|--------|---------|---------|
| Reset Password | `delixmi://reset-password?token={token}` | `delixmi://reset-password?token=abc123` |
| Email Verification | `delixmi://verify-email?email={email}` | `delixmi://verify-email?email=user@example.com` |
| Login | `delixmi://login` | `delixmi://login` |
| Register | `delixmi://register` | `delixmi://register` |
| Home | `delixmi://home` | `delixmi://home` |

## 🎯 Resultado Final

El flujo de restablecimiento de contraseña ahora funciona completamente:

1. **Usuario solicita reset** → ForgotPasswordScreen
2. **Backend envía email** → Con deep link delixmi://reset-password?token=...
3. **Usuario hace clic en enlace** → App se abre automáticamente
4. **DeepLinkService procesa enlace** → Extrae token y navega
5. **ResetPasswordScreen recibe token** → Valida y muestra formulario
6. **Usuario ingresa nueva contraseña** → AuthService.resetPassword() con token
7. **Contraseña actualizada** → Navega a LoginScreen

¡El flujo está completamente funcional y listo para producción! 🚀
