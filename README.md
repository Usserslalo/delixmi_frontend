# Delixmi - App de Delivery

Una aplicación Flutter moderna para servicios de delivery con arquitectura limpia y consumo de APIs REST.

## 🚀 Características

- ✅ **Autenticación segura** con JWT y almacenamiento encriptado
- ✅ **UI moderna** con Material Design 3
- ✅ **Arquitectura limpia** con separación de responsabilidades
- ✅ **Manejo de estado** con Provider
- ✅ **Navegación fluida** entre pantallas
- ✅ **Splash screen** con verificación de autenticación
- ✅ **Manejo de errores** robusto
- ✅ **Validación de formularios**

## 📱 Pantallas Implementadas

### 1. Splash Screen
- Pantalla de bienvenida con logo de Delixmi
- Verificación automática de autenticación
- Navegación inteligente según estado del usuario

### 2. Login Screen
- Formulario de inicio de sesión moderno
- Validación de email y contraseña
- Indicador de carga durante autenticación
- Manejo de errores con SnackBar
- Enlaces para recuperar contraseña y registro

### 3. Home Screen
- Pantalla principal después del login
- Información del estado de sesión
- Botón de cerrar sesión
- Vista previa de funcionalidades futuras

## 🏗️ Arquitectura

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── user.dart            # Modelo de usuario
│   └── auth_response.dart   # Respuesta de autenticación
├── services/                 # Servicios de negocio
│   ├── api_service.dart     # Cliente HTTP para API
│   └── auth_service.dart    # Servicio de autenticación
├── screens/                  # Pantallas de la aplicación
│   ├── login_screen.dart    # Pantalla de inicio de sesión
│   └── home_screen.dart     # Pantalla principal
└── widgets/                  # Componentes reutilizables
    └── custom_text_field.dart # Campo de texto personalizado
```

## 🛠️ Tecnologías Utilizadas

- **Flutter 3.9.0+** - Framework de desarrollo
- **Dart** - Lenguaje de programación
- **Material Design 3** - Sistema de diseño
- **HTTP** - Cliente HTTP para APIs
- **Flutter Secure Storage** - Almacenamiento seguro
- **Provider** - Manejo de estado

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.1.1
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.9.0 o superior
- Dart SDK
- Android Studio / VS Code
- Emulador de Android o dispositivo físico

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd delixmi_frontend
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar el backend**
   - Asegúrate de que tu backend Laravel esté ejecutándose en `http://localhost:3000`
   - Para emulador de Android, usa `http://10.0.2.2:3000`

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🔧 Configuración del Backend

La aplicación está configurada para conectarse a un backend Laravel en:
- **URL base**: `http://10.0.2.2:3000/api`
- **Endpoint de login**: `POST /auth/login`

### Estructura esperada de respuesta del login:
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "1",
    "email": "usuario@ejemplo.com",
    "name": "Nombre Usuario",
    "phone": "123456789",
    "avatar": "url_avatar"
  },
  "message": "Login exitoso"
}
```

## 🧪 Testing

Ejecutar tests:
```bash
flutter test
```

Ejecutar análisis de código:
```bash
flutter analyze
```

## 📱 Funcionalidades Implementadas

### ✅ Completadas
- [x] Estructura de proyecto con arquitectura limpia
- [x] Configuración de dependencias
- [x] Modelos de datos (User, AuthResponse)
- [x] Servicio de API con manejo de errores
- [x] Servicio de autenticación
- [x] Pantalla de login con validación
- [x] Pantalla de home temporal
- [x] Splash screen con verificación de auth
- [x] Navegación entre pantallas
- [x] Almacenamiento seguro de tokens
- [x] Manejo de errores y estados de carga
- [x] UI moderna con Material Design 3

### 🔄 Próximas funcionalidades
- [ ] Pantalla de registro
- [ ] Recuperación de contraseña
- [ ] Catálogo de productos
- [ ] Carrito de compras
- [ ] Historial de pedidos
- [ ] Perfil de usuario
- [ ] Sistema de pagos
- [ ] Notificaciones push
- [ ] Geolocalización
- [ ] Chat con repartidores

## 🎨 Diseño

La aplicación utiliza Material Design 3 con:
- **Color primario**: Verde (#2E7D32) para temática de delivery
- **Componentes**: Cards, botones elevados, campos de texto modernos
- **Tipografía**: Roboto con diferentes pesos
- **Iconografía**: Material Icons

## 🔒 Seguridad

- Tokens JWT almacenados de forma segura
- Validación de entrada en formularios
- Manejo seguro de errores sin exponer información sensible
- HTTPS para comunicación con el backend

## 📞 Soporte

Para soporte técnico o consultas:
- Email: soporte@delixmi.com
- Documentación: [Wiki del proyecto]
- Issues: [GitHub Issues]

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

**Desarrollado con ❤️ para Delixmi**