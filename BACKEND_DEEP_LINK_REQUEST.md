# 🔗 Solicitud para el Equipo de Backend - Deep Links en Email de Reset Password

## 📋 **Problema Identificado**

Actualmente, el email de restablecimiento de contraseña está enviando enlaces **HTTPS** que abren en el navegador web, pero necesitamos que abran directamente la app móvil.

### ❌ **Enlace Actual (Incorrecto):**
```
https://3171158e5a22.ngrok-free.app/reset-password?token=b5074c565403631e7370f1d043c8656fd9568db98af0f05714f44e6195c3539e
```

### ✅ **Enlace Requerido (Correcto):**
```
delixmi://reset-password?token=b5074c565403631e7370f1d043c8656fd9568db98af0f05714f44e6195c3539e
```

---

## 🎯 **Cambios Necesarios en el Backend**

### 1. **Modificar la Generación de Enlaces en el Email**

**Archivo:** `app/Http/Controllers/AuthController.php` (o similar)

**Método:** `forgotPassword()` o `sendResetPasswordEmail()`

#### ❌ **Código Actual:**
```php
$resetUrl = url("/reset-password?token=" . $token);
// o
$resetUrl = config('app.url') . "/reset-password?token=" . $token;
```

#### ✅ **Código Corregido:**
```php
// Para móvil, usar deep link
$resetUrl = "delixmi://reset-password?token=" . $token;

// Opcional: También incluir enlace web como respaldo
$webUrl = url("/reset-password?token=" . $token);
```

### 2. **Actualizar la Plantilla de Email**

**Archivo:** `resources/views/emails/reset-password.blade.php` (o similar)

#### ✅ **Botón Principal (Deep Link):**
```html
<a href="delixmi://reset-password?token={{ $token }}" 
   style="background-color: #F2843A; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block;">
   Restablecer contraseña
</a>
```

#### ✅ **Enlace de Respaldo (Web):**
```html
<p>Si el botón no funciona, copia y pega este enlace en tu navegador:</p>
<p>{{ url("/reset-password?token=" . $token) }}</p>
```

### 3. **Detección de Plataforma (Opcional pero Recomendado)**

Si quieres ser más inteligente, puedes detectar si el usuario está en móvil:

```php
public function forgotPassword(Request $request)
{
    $userAgent = $request->header('User-Agent');
    $isMobile = $this->isMobile($userAgent);
    
    if ($isMobile) {
        $resetUrl = "delixmi://reset-password?token=" . $token;
    } else {
        $resetUrl = url("/reset-password?token=" . $token);
    }
    
    // Enviar email con el enlace apropiado
}

private function isMobile($userAgent)
{
    return preg_match('/Mobile|Android|iPhone|iPad/', $userAgent);
}
```

---

## 📱 **Configuración Adicional Requerida**

### **Para Desarrollo Local:**

Si estás usando ngrok o similar, también necesitas configurar el enlace web para que redirija al deep link:

**Archivo:** `routes/web.php`
```php
Route::get('/reset-password', function (Request $request) {
    $token = $request->query('token');
    
    if ($token) {
        // Redirigir al deep link
        return redirect("delixmi://reset-password?token=" . $token);
    }
    
    return view('reset-password-web'); // Vista web de respaldo
});
```

---

## 🧪 **Testing**

### **Para Probar los Cambios:**

1. **Enviar email de reset** desde la app móvil
2. **Abrir el email** en el dispositivo móvil
3. **Hacer clic en "Restablecer contraseña"**
4. **Verificar** que se abra la app directamente (no el navegador)

### **Enlaces de Prueba:**
```
delixmi://reset-password?token=test_token_123456
```

---

## 📋 **Checklist de Implementación**

- [ ] Modificar generación de enlaces en `forgotPassword()`
- [ ] Actualizar plantilla de email con deep link
- [ ] Añadir enlace web de respaldo
- [ ] Probar en dispositivo móvil real
- [ ] Verificar que la app se abra automáticamente
- [ ] Confirmar que el token se pase correctamente

---

## 🔧 **Archivos que Probablemente Necesiten Cambios**

1. **Controlador de Auth:** `app/Http/Controllers/AuthController.php`
2. **Plantilla de Email:** `resources/views/emails/reset-password.blade.php`
3. **Mail Class:** `app/Mail/ResetPasswordMail.php` (si existe)
4. **Configuración:** `config/mail.php` (si es necesario)

---

## 💡 **Nota Importante**

El deep link `delixmi://` ya está completamente implementado en el frontend móvil. Solo necesitamos que el backend genere los enlaces correctos en los emails.

**El frontend móvil está listo y funcionando correctamente.** ✅

---

## 🚀 **Resultado Esperado**

Después de estos cambios:
1. Usuario solicita reset password
2. Recibe email con enlace `delixmi://reset-password?token=...`
3. Hace clic en el botón
4. **La app se abre automáticamente**
5. Se muestra la pantalla ResetPasswordScreen
6. Usuario puede cambiar su contraseña

¿Necesitas ayuda con algún archivo específico o tienes preguntas sobre la implementación?
