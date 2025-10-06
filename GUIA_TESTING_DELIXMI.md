# Guía de Testing - Delixmi Frontend

## 📋 Índice
1. [Configuración del Entorno](#configuración-del-entorno)
2. [Testing de Autenticación](#testing-de-autenticación)
3. [Testing de Navegación](#testing-de-navegación)
4. [Testing de Carrito de Compras](#testing-de-carrito-de-compras)
5. [Testing de Direcciones](#testing-de-direcciones)
6. [Testing de Checkout](#testing-de-checkout)
7. [Testing de UI/UX](#testing-de-uiux)
8. [Testing de Errores](#testing-de-errores)
9. [Testing de Rendimiento](#testing-de-rendimiento)
10. [Casos de Prueba Específicos](#casos-de-prueba-específicos)

## 🔧 Configuración del Entorno

### Requisitos Previos
- Flutter SDK 3.0+
- Android Studio / VS Code
- Emulador Android o dispositivo físico
- Backend Delixmi funcionando en `http://10.0.2.2:3000`

### Configuración Inicial
```bash
# Clonar el repositorio
git clone [url-del-repositorio]

# Navegar al directorio
cd delixmi_frontend

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## 🔐 Testing de Autenticación

### 1. Registro de Usuario

**Caso de Prueba 1.1: Registro Exitoso**
1. Abrir la aplicación
2. Tocar "Registrarse"
3. Completar el formulario:
   - Nombre: "Juan"
   - Apellido: "Pérez"
   - Email: "juan.perez@test.com"
   - Teléfono: "5551234567"
   - Contraseña: "123456"
   - Confirmar contraseña: "123456"
4. Tocar "Registrarse"
5. **Resultado Esperado**: Mensaje de éxito, redirección a verificación de email

**Caso de Prueba 1.2: Validación de Campos**
1. Abrir formulario de registro
2. Dejar campos vacíos
3. Tocar "Registrarse"
4. **Resultado Esperado**: Mensajes de error en campos requeridos

**Caso de Prueba 1.3: Email Inválido**
1. Completar formulario con email inválido: "email-invalido"
2. Tocar "Registrarse"
3. **Resultado Esperado**: Error "Ingresa un email válido"

### 2. Inicio de Sesión

**Caso de Prueba 2.1: Login Exitoso**
1. Abrir la aplicación
2. Tocar "Iniciar Sesión"
3. Ingresar credenciales válidas:
   - Email: "juan.perez@test.com"
   - Contraseña: "123456"
4. Tocar "Iniciar Sesión"
5. **Resultado Esperado**: Redirección a pantalla principal

**Caso de Prueba 2.2: Credenciales Incorrectas**
1. Ingresar email o contraseña incorrectos
2. Tocar "Iniciar Sesión"
3. **Resultado Esperado**: Mensaje de error "Credenciales incorrectas"

### 3. Recuperación de Contraseña

**Caso de Prueba 3.1: Solicitar Reset**
1. En pantalla de login, tocar "¿Olvidaste tu contraseña?"
2. Ingresar email: "juan.perez@test.com"
3. Tocar "Enviar"
4. **Resultado Esperado**: Mensaje de confirmación

**Caso de Prueba 3.2: Reset con Token**
1. Abrir enlace del email de reset
2. Ingresar nueva contraseña: "nueva123456"
3. Confirmar contraseña: "nueva123456"
4. Tocar "Cambiar Contraseña"
5. **Resultado Esperado**: Contraseña actualizada, redirección a login

## 🧭 Testing de Navegación

### 1. Navegación Principal

**Caso de Prueba 4.1: Bottom Navigation**
1. Iniciar sesión
2. Verificar que aparezcan 5 pestañas:
   - Inicio (activa)
   - Favoritos
   - Carrito
   - Pedidos
   - Perfil
3. Tocar cada pestaña
4. **Resultado Esperado**: Navegación fluida entre pantallas

**Caso de Prueba 4.2: Navegación a Detalles de Restaurante**
1. En pantalla principal, tocar un restaurante
2. **Resultado Esperado**: Navegación a pantalla de detalles

### 2. Navegación con Deep Links

**Caso de Prueba 4.3: Deep Link de Reset Password**
1. Abrir URL: `delixmi://reset-password?token=abc123`
2. **Resultado Esperado**: Navegación directa a pantalla de reset

## 🛒 Testing de Carrito de Compras

### 1. Agregar Productos

**Caso de Prueba 5.1: Agregar Producto**
1. Navegar a detalles de restaurante
2. Seleccionar un producto
3. Tocar botón "Agregar al Carrito"
4. **Resultado Esperado**: Producto agregado, contador actualizado

**Caso de Prueba 5.2: Modificar Cantidad**
1. Ir al carrito
2. Tocar botón "+" en un producto
3. **Resultado Esperado**: Cantidad incrementada, total actualizado

**Caso de Prueba 5.3: Eliminar Producto**
1. En el carrito, tocar botón "-" hasta llegar a 0
2. **Resultado Esperado**: Producto eliminado del carrito

### 2. Validaciones del Carrito

**Caso de Prueba 5.4: Carrito Vacío**
1. Eliminar todos los productos
2. **Resultado Esperado**: Mensaje "Tu carrito está vacío"

**Caso de Prueba 5.5: Múltiples Restaurantes**
1. Agregar productos de diferentes restaurantes
2. **Resultado Esperado**: Productos agrupados por restaurante

## 📍 Testing de Direcciones

### 1. Gestión de Direcciones

**Caso de Prueba 6.1: Agregar Dirección**
1. Ir a "Direcciones" desde el perfil
2. Tocar "Agregar Dirección"
3. Completar formulario:
   - Alias: "Casa"
   - Calle: "Av. Principal 123"
   - Número exterior: "123"
   - Colonia: "Centro"
   - Ciudad: "Ciudad de México"
   - Estado: "CDMX"
   - Código postal: "01000"
4. Tocar "Guardar"
5. **Resultado Esperado**: Dirección guardada exitosamente

**Caso de Prueba 6.2: Editar Dirección**
1. Tocar una dirección existente
2. Modificar el alias a "Casa Principal"
3. Tocar "Guardar"
4. **Resultado Esperado**: Dirección actualizada

**Caso de Prueba 6.3: Eliminar Dirección**
1. Tocar botón de eliminar en una dirección
2. Confirmar eliminación
3. **Resultado Esperado**: Dirección eliminada

### 2. Selección de Dirección

**Caso de Prueba 6.4: Seleccionar para Checkout**
1. Ir al checkout
2. Tocar "Seleccionar Dirección"
3. Elegir una dirección
4. **Resultado Esperado**: Dirección seleccionada, cálculo de envío

## 💳 Testing de Checkout

### 1. Proceso de Checkout

**Caso de Prueba 7.1: Checkout Completo con Tarjeta**
1. Tener productos en el carrito
2. Ir al checkout
3. Seleccionar dirección
4. Elegir método de pago "Tarjeta"
5. Tocar "Proceder al Pago"
6. **Resultado Esperado**: Redirección a Mercado Pago

**Caso de Prueba 7.2: Checkout con Efectivo**
1. Seguir pasos 1-3 del caso anterior
2. Elegir método de pago "Efectivo"
3. Tocar "Confirmar Pedido"
4. **Resultado Esperado**: Pedido confirmado, carrito limpiado

### 2. Validaciones de Checkout

**Caso de Prueba 7.3: Sin Dirección**
1. Ir al checkout sin seleccionar dirección
2. Tocar "Continuar"
3. **Resultado Esperado**: Error "Selecciona una dirección"

**Caso de Prueba 7.4: Carrito Vacío**
1. Ir al checkout con carrito vacío
2. **Resultado Esperado**: Mensaje "Tu carrito está vacío"

## 🎨 Testing de UI/UX

### 1. Responsividad

**Caso de Prueba 8.1: Diferentes Tamaños de Pantalla**
1. Probar en diferentes dispositivos:
   - Teléfono pequeño (320px)
   - Teléfono grande (414px)
   - Tablet (768px)
2. **Resultado Esperado**: UI se adapta correctamente

### 2. Accesibilidad

**Caso de Prueba 8.2: Navegación por Teclado**
1. Usar solo teclado para navegar
2. **Resultado Esperado**: Todos los elementos son accesibles

**Caso de Prueba 8.3: Lectores de Pantalla**
1. Activar TalkBack/VoiceOver
2. Navegar por la aplicación
3. **Resultado Esperado**: Elementos correctamente etiquetados

### 3. Estados de Carga

**Caso de Prueba 8.4: Indicadores de Carga**
1. Realizar acciones que requieran tiempo:
   - Cargar restaurantes
   - Agregar al carrito
   - Procesar pago
2. **Resultado Esperado**: Indicadores de carga visibles

## ❌ Testing de Errores

### 1. Errores de Red

**Caso de Prueba 9.1: Sin Conexión**
1. Desactivar WiFi/datos
2. Intentar cargar restaurantes
3. **Resultado Esperado**: Mensaje "Sin conexión a internet"

**Caso de Prueba 9.2: Timeout de Red**
1. Simular conexión lenta
2. Realizar operaciones
3. **Resultado Esperado**: Timeout manejado correctamente

### 2. Errores de Validación

**Caso de Prueba 9.3: Datos Inválidos**
1. Enviar datos malformados al backend
2. **Resultado Esperado**: Errores manejados graciosamente

### 3. Errores de Autenticación

**Caso de Prueba 9.4: Token Expirado**
1. Esperar a que expire el token
2. Realizar operación autenticada
3. **Resultado Esperado**: Redirección al login

## ⚡ Testing de Rendimiento

### 1. Tiempo de Carga

**Caso de Prueba 10.1: Tiempo de Inicio**
1. Medir tiempo desde tap hasta pantalla principal
2. **Resultado Esperado**: < 3 segundos

**Caso de Prueba 10.2: Tiempo de Navegación**
1. Medir tiempo entre pantallas
2. **Resultado Esperado**: < 1 segundo

### 2. Uso de Memoria

**Caso de Prueba 10.3: Fuga de Memoria**
1. Navegar extensivamente por la app
2. Monitorear uso de memoria
3. **Resultado Esperado**: Sin fugas significativas

## 🧪 Casos de Prueba Específicos

### 1. Flujo Completo de Usuario

**Caso de Prueba 11.1: Pedido Completo**
1. Registrarse
2. Verificar email
3. Iniciar sesión
4. Agregar dirección
5. Explorar restaurantes
6. Agregar productos al carrito
7. Proceder al checkout
8. Completar pago
9. **Resultado Esperado**: Pedido confirmado exitosamente

### 2. Casos Edge

**Caso de Prueba 11.2: Aplicación en Background**
1. Iniciar pedido
2. Minimizar aplicación
3. Restaurar aplicación
4. **Resultado Esperado**: Estado preservado

**Caso de Prueba 11.3: Rotación de Pantalla**
1. Rotar dispositivo durante checkout
2. **Resultado Esperado**: UI se adapta correctamente

### 3. Casos de Estrés

**Caso de Prueba 11.4: Múltiples Operaciones**
1. Realizar múltiples operaciones simultáneas
2. **Resultado Esperado**: Aplicación estable

## 📱 Herramientas de Testing

### 1. Testing Manual
- **Dispositivos**: Android/iOS físicos y emuladores
- **Herramientas**: Android Studio, Xcode
- **Métricas**: Screenshots, videos de sesiones

### 2. Testing Automatizado
```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests de integración
flutter drive --target=test_driver/app.dart

# Generar reporte de cobertura
flutter test --coverage
```

### 3. Testing de Performance
```bash
# Profile de rendimiento
flutter run --profile

# Análisis de memoria
flutter run --trace-startup
```

## 🐛 Reporte de Bugs

### Template de Bug Report
```
**Título**: [Descripción breve del problema]

**Descripción**: [Descripción detallada]

**Pasos para Reproducir**:
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

**Resultado Esperado**: [Lo que debería pasar]

**Resultado Actual**: [Lo que realmente pasa]

**Dispositivo**: [Modelo, OS, versión]

**Screenshots**: [Si aplica]

**Severidad**: [Crítica/Alta/Media/Baja]
```

## ✅ Checklist de Testing

### Pre-Release
- [ ] Todos los casos de prueba ejecutados
- [ ] Bugs críticos resueltos
- [ ] Performance aceptable
- [ ] UI/UX consistente
- [ ] Accesibilidad verificada
- [ ] Documentación actualizada

### Post-Release
- [ ] Monitoreo de crashes
- [ ] Feedback de usuarios
- [ ] Métricas de performance
- [ ] Actualizaciones de seguridad

## 📊 Métricas de Calidad

### Objetivos
- **Cobertura de Tests**: > 80%
- **Tiempo de Carga**: < 3 segundos
- **Crashes**: < 0.1%
- **Satisfacción de Usuario**: > 4.5/5

### Herramientas de Monitoreo
- Firebase Crashlytics
- Firebase Analytics
- Sentry
- Custom analytics

---

## 🎯 Conclusión

Esta guía proporciona un framework completo para testing de la aplicación Delixmi. Es importante ejecutar regularmente estos tests y mantener la documentación actualizada con nuevos casos de prueba según evolucione la aplicación.

**Recordatorios Importantes**:
- Siempre probar en dispositivos reales
- Mantener datos de prueba consistentes
- Documentar todos los bugs encontrados
- Actualizar tests cuando se agreguen nuevas funcionalidades
