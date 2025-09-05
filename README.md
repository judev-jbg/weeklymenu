# Weekly Menu 📅🍽️

Aplicación móvil desarrollada en Flutter para la planificación semanal de menús con notificaciones push automáticas.

## ✨ Características Principales

- **Sistema de autenticación** con roles (Usuario/Administrador)
- **Planificación de menús semanales** con sistema de arrastrar y soltar
- **Notificaciones push automáticas** a las 20:00 horas
- **Gestión de listas de compras** con ingredientes
- **Temas claro/oscuro** automáticos
- **Sistema completo de administración** para usuarios admin
- **Arquitectura limpia** con GetX para gestión de estado

## 🛠️ Tecnologías Utilizadas

- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Notificaciones**: Firebase Cloud Messaging
- **Gestión de Estado**: GetX
- **Base de datos**: PostgreSQL con RLS (Row Level Security)

## 📱 Funcionalidades

### Para Usuarios Regulares:

- Planificación de menús semanales (9 días)
- Asignación y edición de menús por día
- Lista de compras con ingredientes
- Gestión de menús pendientes via notificaciones
- Edición de perfil personal

### Para Administradores:

- Todas las funcionalidades de usuario regular
- Gestión completa de usuarios (CRUD)
- Gestión de catálogo de menús (CRUD)
- Gestión de ingredientes por categorías (CRUD)
- Panel de administración completo

## 🚀 Configuración e Instalación

### Prerrequisitos:

- Flutter 3.x instalado
- Cuenta de Supabase configurada
- Proyecto de Firebase para notificaciones
- Android Studio / Xcode para desarrollo

### Pasos de instalación:

1. **Clonar el repositorio**

```bash
git clone [url-del-repo]
cd weekly_menu
```
