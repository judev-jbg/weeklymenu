# Weekly Menu - Aplicación Colaborativa de Planificación de Menús

Una aplicación Flutter colaborativa para la planificación semanal de menús, donde todos los usuarios comparten y gestionan la misma lista de comidas de forma global.

## 🌟 Características Principales

### Sistema Colaborativo Global

- **Lista única compartida**: Todos los usuarios ven y pueden modificar la misma planificación semanal de menús
- **Gestión colaborativa**: Cualquier usuario puede asignar menús a los días de la semana
- **Tracking de asignaciones**: Se registra qué usuario asignó cada menú para mantener transparencia
- **Actualización en tiempo real**: Los cambios se reflejan inmediatamente para todos los usuarios

### Gestión Inteligente de Semanas

- **Reset automático**: Cada viernes a las 00:00 GMT se crea automáticamente la planificación para la siguiente semana (lunes a domingo)
- **Vista de 9 días**: Los usuarios siempre ven desde el sábado actual hasta el domingo de la semana siguiente
- **Preservación de fin de semana**: Los sábados y domingos no se resetean, manteniendo las asignaciones previas

### Funcionalidades de Usuario

- **Lista de compras individual**: Cada usuario mantiene su propia lista de ingredientes
- **Gestión de menús**: Crear, buscar y asignar menús a días específicos
- **Notificaciones push**: Recordatorios diarios personalizados
- **Autenticación segura**: Sistema de roles (usuario/administrador)
- **Interfaz intuitiva**: Tema claro/oscuro adaptativo

## 🛠️ Tecnologías Utilizadas

### Frontend

- **Flutter** - Framework de desarrollo multiplataforma
- **GetX** - Gestión de estado y navegación
- **Firebase Messaging** - Notificaciones push

### Backend

- **Supabase** - Backend como servicio (BaaS)
- **PostgreSQL** - Base de datos relacional
- **pg_cron** - Automatización de tareas programadas
- **Row Level Security (RLS)** - Seguridad a nivel de base de datos

### Integraciones

- **Flutter Local Notifications** - Notificaciones locales
- **Timezone** - Manejo de zonas horarias
- **Flutter SVG** - Iconos y gráficos vectoriales

## 🚀 Instalación y Configuración

### Prerrequisitos

- Flutter SDK (versión 3.0+)
- Dart SDK
- Cuenta de Supabase
- Proyecto de Firebase (para notificaciones)

### Configuración del Backend

1. **Crear proyecto en Supabase**
   ```bash
   # Ejecutar las migraciones SQL en el orden:
   # 1. db/auth.sql
   # 2. db/menus.sql
   # 3. db/shopping_list.sql
   # 4. db/notifications.sql
   ```
2. **Habilitar extensiones requeridas**

   ```sql
   -- En el SQL Editor de Supabase
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS pg_cron;
   ```

3. **Programar el cron job**
   ```sql
   -- Crear la semana automáticamente cada viernes
   SELECT cron.schedule(
    'create-new-week',
    '0 0 * * 5',
    'SELECT create_new_week();'
   );
   ```
4. **Configurar variables de entorno**
   ```bash
   # Crear archivo .env en la raíz del proyecto
    SUPABASE_BASE_URL=tu_url_de_supabase
    SUPABASE_KEY=tu_anon_key_de_supabase
   ```

### Configuración del Frontend

1. **Clonar el repositorio**

   ```bash
    git clone https://github.com/judev-jbg/weeklymenu.git
    cd weekly_menu
   ```

2. **Instalar dependencias**

   ```bash
    flutter pub get
   ```

3. **Configurar Firebase**

   - Añadir google-services.json en android/app/
   - Configurar notificaciones push según la documentación de Firebase

4. **Ejecutar la aplicación**
   ```bash
    flutter run
   ```

## 📱 Funcionalidades Detalladas

### Sistema de Menús Colaborativo

- Visualización global: Todos los usuarios ven la misma lista de 9 días
- Asignación de menús: Buscar y asignar menús existentes o crear nuevos
- Gestión de estados: Marcar menús como completados o no completados
- Reordenamiento: Reorganizar menús entre diferentes días

### Lista de Compras colaborativo

- Gestión global: Cada usuario ve la lista global
- Swipe para eliminar: Deslizar elementos para confirmar compra
- Búsqueda de ingredientes: Sistema inteligente con autocompletado
- Creación rápida: Agregar nuevos ingredientes al vuelo

### Sistema de Notificaciones

- Recordatorios diarios: Notificaciones a las 20:00 sobre el menú del día
- Notificaciones informativas: Avisos cuando no hay menú asignado
- Historial: Visualización de notificaciones pasadas
- Gestión personalizada: Marcar como leído/no leído

### Administración (Solo Admins)

- Gestión de usuarios: Crear, editar y eliminar usuarios
- Administración de menús: CRUD completo de menús disponibles
- Gestión de ingredientes: Mantenimiento del catálogo de ingredientes
- Configuración de roles: Asignar permisos de administrador

## 🔄 Flujo de Trabajo Semanal

1. **Viernes 00:00 GMT:**

- Se ejecuta automáticamente create_new_week()
- Se crean 7 nuevos registros (lunes a domingo siguiente)
- Los menús se inicializan sin asignación

2. **Durante la semana:**

- Los usuarios ven 9 días: sábado actual + 7 días nuevos
- Cualquier usuario puede asignar menús a cualquier día
- Las asignaciones son visibles para todos inmediatamente

3. **Gestión individual:**

- Cada usuario gestiona su propia lista de compras
- Las notificaciones son personalizadas por usuario
- El seguimiento de menús completados es individual

## 🏗️ Arquitectura del Proyecto

```
lib/
├── core/                   # Configuración base
│   ├── controllers/        # Controladores globales (tema)
│   ├── enums/             # Enumeraciones
│   ├── routes/            # Configuración de rutas
│   └── theme/             # Temas y estilos
├── data/                  # Capa de datos
│   ├── models/            # Modelos de datos
│   └── services/          # Servicios de API
└── presentation/          # Capa de presentación
    ├── controllers/       # Controladores de GetX
    ├── views/            # Pantallas principales
    └── widgets/          # Componentes reutilizables
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu funcionalidad (git checkout -b feature/AmazingFeature)
3. Commit tus cambios (git commit -m 'Add some AmazingFeature')
4. Push a la rama (git push origin feature/AmazingFeature)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo LICENSE para más detalles.

## 🆘 Soporte

Para reportar bugs o solicitar nuevas funcionalidades, por favor abre un issue en el repositorio.

## 🙏 Reconocimientos

- <u>Supabase</u> - Backend como servicio
- <u>Flutter</u> - Framework de desarrollo
- <u>GetX</u> - Gestión de estado
- <u>Firebase</u> - Servicios de Google

### Desarrollado con ❤️ para una mejor planificación colaborativa de menús
