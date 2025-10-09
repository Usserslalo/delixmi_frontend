# 📋 SOLICITUD DE CAMBIOS AL BACKEND - Campo Phone

**Fecha:** 9 de Octubre de 2025  
**Para:** Equipo de Backend - Delixmi  
**De:** Equipo de Frontend  
**Prioridad:** 🔴 **ALTA**

---

## 🎯 **RESUMEN EJECUTIVO**

Solicitamos que se incluya el campo `phone` en las respuestas de los endpoints de autenticación y perfil, ya que actualmente no se está enviando aunque el usuario tenga un teléfono registrado en la base de datos.

---

## 🔍 **PROBLEMA IDENTIFICADO**

### **❌ Endpoints Afectados:**

#### **1. POST /api/auth/login**
**Respuesta actual (INCOMPLETA):**
```json
{
    "status": "success",
    "message": "Inicio de sesión exitoso",
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "user": {
            "id": 11,
            "name": "Sofía",
            "lastname": "López",
            "email": "sofia.lopez@email.com",
            "status": "active",
            "roles": [...]
            // ❌ FALTA: "phone": "444444444"
        },
        "expiresIn": "24h"
    }
}
```

#### **2. GET /api/auth/profile**
**Respuesta actual (INCOMPLETA):**
```json
{
    "status": "success",
    "message": "Perfil obtenido exitosamente",
    "data": {
        "user": {
            "id": 11,
            "name": "Sofía",
            "lastname": "López",
            "email": "sofia.lopez@email.com",
            "status": "active",
            "roles": [...]
            // ❌ FALTA: "phone": "444444444"
        }
    }
}
```

---

## ✅ **CAMBIOS SOLICITADOS**

### **🎯 Respuesta Esperada:**

#### **1. POST /api/auth/login**
```json
{
    "status": "success",
    "message": "Inicio de sesión exitoso",
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "user": {
            "id": 11,
            "name": "Sofía",
            "lastname": "López",
            "email": "sofia.lopez@email.com",
            "phone": "444444444", // ✅ AGREGAR ESTE CAMPO
            "status": "active",
            "emailVerifiedAt": "2025-09-15T10:30:00.000Z", // ✅ AGREGAR
            "phoneVerifiedAt": "2025-09-15T10:35:00.000Z", // ✅ AGREGAR
            "createdAt": "2025-09-15T10:30:00.000Z", // ✅ AGREGAR
            "updatedAt": "2025-10-09T14:30:00.000Z", // ✅ AGREGAR
            "roles": [
                {
                    "roleId": 20,
                    "roleName": "customer",
                    "roleDisplayName": "Cliente",
                    "restaurantId": null,
                    "branchId": null
                }
            ]
        },
        "expiresIn": "24h"
    }
}
```

#### **2. GET /api/auth/profile**
```json
{
    "status": "success",
    "message": "Perfil obtenido exitosamente",
    "data": {
        "user": {
            "id": 11,
            "name": "Sofía",
            "lastname": "López",
            "email": "sofia.lopez@email.com",
            "phone": "444444444", // ✅ AGREGAR ESTE CAMPO
            "status": "active",
            "emailVerifiedAt": "2025-09-15T10:30:00.000Z", // ✅ AGREGAR
            "phoneVerifiedAt": "2025-09-15T10:35:00.000Z", // ✅ AGREGAR
            "createdAt": "2025-09-15T10:30:00.000Z", // ✅ AGREGAR
            "updatedAt": "2025-10-09T14:30:00.000Z", // ✅ AGREGAR
            "roles": [
                {
                    "roleId": 20,
                    "roleName": "customer",
                    "roleDisplayName": "Cliente",
                    "restaurantId": null,
                    "branchId": null
                }
            ]
        }
    }
}
```

---

## 📊 **CAMPOS FALTANTES IDENTIFICADOS**

| Campo | Tipo | Descripción | Estado Actual | Estado Requerido |
|-------|------|-------------|---------------|------------------|
| `phone` | string | Teléfono del usuario | ❌ No enviado | ✅ Enviar |
| `emailVerifiedAt` | string (ISO) | Fecha de verificación de email | ❌ No enviado | ✅ Enviar |
| `phoneVerifiedAt` | string (ISO) | Fecha de verificación de teléfono | ❌ No enviado | ✅ Enviar |
| `createdAt` | string (ISO) | Fecha de creación del usuario | ❌ No enviado | ✅ Enviar |
| `updatedAt` | string (ISO) | Fecha de última actualización | ❌ No enviado | ✅ Enviar |

---

## 🎯 **JUSTIFICACIÓN DEL CAMBIO**

### **✅ Impacto en Frontend:**
1. **ProfileScreen** necesita mostrar el teléfono del usuario
2. **EditProfileScreen** necesita el teléfono actual para edición
3. **Indicadores de verificación** necesitan las fechas de verificación
4. **Antigüedad del cliente** necesita la fecha de creación

### **✅ Funcionalidades Afectadas:**
- ✅ Vista "Mi Perfil" con información completa
- ✅ Edición de perfil con datos actuales
- ✅ Indicadores de verificación (email, teléfono)
- ✅ Cálculo de antigüedad del cliente
- ✅ Validaciones de campos existentes

---

## 🔧 **IMPLEMENTACIÓN SUGERIDA**

### **📋 Checklist para Backend:**

#### **1. Verificar Base de Datos:**
- [ ] Confirmar que el campo `phone` existe en la tabla de usuarios
- [ ] Verificar que el usuario de prueba (ID: 11) tiene teléfono registrado
- [ ] Confirmar que los campos de verificación existen

#### **2. Actualizar Endpoints:**
- [ ] **POST /api/auth/login** - Incluir todos los campos del usuario
- [ ] **GET /api/auth/profile** - Incluir todos los campos del usuario
- [ ] **PUT /api/auth/profile** - Asegurar que devuelve todos los campos actualizados

#### **3. Validaciones:**
- [ ] Manejar casos cuando `phone` es `NULL`
- [ ] Manejar casos cuando las fechas de verificación son `NULL`
- [ ] Asegurar formato ISO para las fechas

---

## 🧪 **TESTING SUGERIDO**

### **✅ Casos de Prueba:**

#### **1. Usuario con Teléfono:**
```json
{
    "user": {
        "phone": "444444444",
        "phoneVerifiedAt": "2025-09-15T10:35:00.000Z"
    }
}
```

#### **2. Usuario sin Teléfono:**
```json
{
    "user": {
        "phone": null,
        "phoneVerifiedAt": null
    }
}
```

#### **3. Usuario con Email No Verificado:**
```json
{
    "user": {
        "emailVerifiedAt": null,
        "phoneVerifiedAt": null
    }
}
```

---

## 📅 **CRONOGRAMA SUGERIDO**

### **🚀 Fase 1: Implementación (1-2 días)**
- [ ] Actualizar endpoints de login y perfil
- [ ] Verificar campos en base de datos
- [ ] Testing básico

### **🧪 Fase 2: Testing (1 día)**
- [ ] Testing con usuario de prueba
- [ ] Verificar casos edge (campos NULL)
- [ ] Testing de integración con frontend

### **🚀 Fase 3: Deploy (1 día)**
- [ ] Deploy a entorno de desarrollo
- [ ] Verificación con frontend
- [ ] Deploy a producción

---

## 🔍 **VALIDACIÓN POST-IMPLEMENTACIÓN**

### **✅ Checklist de Verificación:**

#### **1. Login Endpoint:**
- [ ] Campo `phone` incluido en respuesta
- [ ] Campos de verificación incluidos
- [ ] Fechas en formato ISO correcto
- [ ] Manejo de campos NULL

#### **2. Profile Endpoint:**
- [ ] Campo `phone` incluido en respuesta
- [ ] Todos los campos del usuario incluidos
- [ ] Consistencia con login endpoint

#### **3. Frontend Integration:**
- [ ] ProfileScreen muestra teléfono correctamente
- [ ] EditProfileScreen carga teléfono actual
- [ ] Indicadores de verificación funcionan
- [ ] Antigüedad del cliente se calcula correctamente

---

## 📞 **CONTACTO**

**Para consultas sobre esta solicitud:**
- **Frontend Team:** Disponible para testing y verificación
- **Prioridad:** Alta - Bloquea funcionalidades del perfil
- **Tiempo estimado:** 2-3 días

---

## 🎯 **RESUMEN**

### **✅ Cambios Solicitados:**
1. **Agregar campo `phone`** a respuestas de login y perfil
2. **Agregar campos de verificación** (`emailVerifiedAt`, `phoneVerifiedAt`)
3. **Agregar campos de fecha** (`createdAt`, `updatedAt`)
4. **Manejar casos NULL** apropiadamente

### **🎯 Impacto:**
- **Frontend:** Funcionalidades completas del perfil
- **UX:** Información completa del usuario
- **Funcionalidad:** Edición de perfil completamente funcional

---

**📋 Solicitud generada:** 9 de Octubre de 2025  
**🎯 Prioridad:** ALTA  
**⏰ Tiempo estimado:** 2-3 días  
**✅ Estado:** PENDIENTE DE IMPLEMENTACIÓN

---

**¡Gracias por la colaboración!** 🙏
