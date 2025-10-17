# 🎨 **PROMPT FIGMA MAKE - CONFIGURAR PERFIL RESTAURANTE**

## 📱 **CONTEXTO**
App móvil Flutter "Delixmi" (delivery de comida). Rediseñar vista "Configurar Perfil" del restaurante siguiendo Material 3. **FORMATO: PANTALLAS DE CELULAR** (375x812px iPhone, 360x640px Android).

## 🎯 **ESTRUCTURA DE PANTALLA**

### **1. HEADER**
- Título: "Configurar Perfil"
- Subtítulo: "Personaliza tu restaurante"
- Gradiente naranja (#F2843A)
- Botón guardar (dinámico, solo con cambios)
- Botón regreso (flecha izquierda)

### **2. SECCIÓN IMÁGENES**
**Logo:**
- Título: "Logo del Restaurante"
- Preview: Cuadrado 150x150px, bordes redondeados
- Botón: "Cambiar Logo" + icono cámara
- Estados: vacío, con imagen, cargando

**Portada:**
- Título: "Foto de Portada"
- Preview: Rectangular 300x100px, bordes redondeados
- Botón: "Cambiar Portada" + icono cámara
- Estados: vacío, con imagen, cargando

### **3. INFORMACIÓN RESTAURANTE**
**Header:**
- Título: "Información del Restaurante"
- Subtítulo: "Personaliza los detalles"
- Card con gradiente sutil

**Campos:**
- **Nombre:** Text field, requerido, 150 chars max
- **Descripción:** Text area 4 líneas, 1000 chars max
- **Teléfono:** Text field numérico, 10-20 chars
- **Email:** Text field email, formato válido
- **Dirección:** Text area 2 líneas, 500 chars max

**Layout:** Teléfono y Email lado a lado (50% cada uno)

### **4. ESTADÍSTICAS (READ-ONLY)**
- Título: "Estadísticas del Restaurante"
- 3 cards: Sucursales, Categorías, Productos
- Iconos de colores, números destacados

## 🎨 **DISEÑO MATERIAL 3**

### **Colores:**
- Primary: #F2843A (naranja)
- Surface: #FFFBFE (blanco)
- Surface Variant: #E7E0EC (gris claro)
- On Surface: #1C1B1F (texto)
- Outline: #79747E (bordes)

### **Tipografía:**
- Títulos: 22px, w700
- Secciones: 16px, w600
- Labels: 14px, w500
- Body: 16px, w400

### **Espaciado:**
- Padding: 24px
- Entre secciones: 24px
- Entre elementos: 16px
- Border radius: 16px (campos), 20px (cards)

## 📱 **REQUISITOS MÓVIL**

### **Estados UI:**
1. Estado inicial (campos vacíos)
2. Estado con datos (campos llenos)
3. Estado carga (spinners)
4. Estado error (mensajes rojos)
5. Estado éxito (feedback verde)

### **Interacciones:**
- Tap campos: focus + teclado
- Tap imágenes: abrir galería
- Tap guardar: validar + guardar
- Scroll vertical suave

### **Validaciones:**
- Campos requeridos: asterisco rojo (*)
- Errores: texto rojo debajo
- Contadores: caracteres restantes
- Éxito: check verde

### **Accesibilidad:**
- Contraste: 4.5:1 mínimo
- Toque: 44px mínimo
- Labels descriptivos
- Iconos claros

## 🎯 **ESTILO VISUAL**
- Material 3 design system
- Cards elevadas con sombras
- Gradientes suaves
- Iconos redondeados
- Bordes redondeados consistentes
- Espaciado generoso

## 📋 **ENTREGABLES**
1. Mockup pantalla completa
2. Estados diferentes (vacío, lleno, error, éxito)
3. Componentes individuales
4. Guía colores y tipografía
5. Especificaciones técnicas

## 🎉 **OBJETIVO**
Vista moderna, limpia y profesional que se vea increíble en móvil, sea fácil de usar, siga Material 3 y refleje marca Delixmi profesionalmente.

**¡Crea una experiencia excepcional para dueños de restaurantes!** 🚀
