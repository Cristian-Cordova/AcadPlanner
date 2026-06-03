# Documentación AcadPlanner

## Portada

**Materia:** Desarrollo de aplicaciones en iOS  
**Proyecto:** AcadPlanner  
**Tema:** Aplicación iOS en SwiftUI con SQLite, Firebase y arquitectura preparada para Microsoft Graph  
**Alumno:** Cristian Cordova  
**Profesor:** Martin Oswaldo Valdes Alvarado  
**Fecha:** Junio 2026

## Índice

1. Introducción  
2. Objetivo general  
3. Alcance del MVP  
4. Arquitectura general del proyecto  
5. Diseño de modelos de datos  
6. Subsistema de persistencia local con SQLite  
7. Respaldo remoto con Firebase Firestore  
8. Control de estado con MVVM y repositorios  
9. Interfaz de usuario con SwiftUI  
10. Integración preparada con Microsoft Calendar  
11. Seguridad y manejo de configuración sensible  
12. Plan de pruebas y resultados  
13. Limitaciones actuales  
14. Conclusiones  
15. Bibliografía

## 1. Introducción

AcadPlanner es una aplicación móvil nativa para iOS desarrollada con SwiftUI. Su objetivo principal es apoyar la organización académica de un estudiante mediante el registro de materias, tareas, proyectos, exámenes, prácticas, lecturas y exposiciones. La aplicación permite clasificar cada actividad por materia, estado, prioridad, tipo y fecha de entrega.

El proyecto fue diseñado como un MVP académico sólido, pero con una base preparada para escalar hacia una aplicación más profesional. Para lograrlo, se implementó una arquitectura por capas basada en MVVM, repositorios, fuentes de datos locales y fuentes de datos remotas.

La solución técnica se fundamenta en tres decisiones principales:

- Uso de SQLite como almacenamiento local offline-first.
- Uso de Firebase Firestore como respaldo remoto.
- Preparación de una integración externa con Microsoft Calendar mediante Microsoft Graph.

Durante el desarrollo se priorizó que la aplicación funcionara de forma estable aunque el dispositivo no tuviera conexión a internet. Por esa razón, los datos principales viven primero en SQLite y después se intenta hacer respaldo en Firebase. Esta decisión permite que la app conserve su funcionalidad base incluso si el servicio remoto falla temporalmente.

La integración con Microsoft Graph quedó preparada a nivel arquitectónico, pero no fue activada completamente debido a una limitación externa: la cuenta disponible no tenía permisos para crear un App Registration en Microsoft Entra ID ni acceso a un sandbox activo de Microsoft 365 Developer Program. Esta limitación no afecta el funcionamiento principal del MVP, ya que SQLite y Firebase sí se encuentran implementados.

## 2. Objetivo general

Desarrollar una aplicación iOS funcional para gestionar tareas académicas por materia, aplicando SwiftUI, MVVM, SQLite, Firebase y una arquitectura preparada para consumo de API externa mediante Microsoft Graph.

Objetivos específicos:

- Crear una interfaz clara para consultar tareas y materias.
- Implementar formularios para crear y editar tareas académicas.
- Implementar formularios para crear y editar materias.
- Mantener los datos disponibles localmente mediante SQLite.
- Respaldar materias y tareas en Firebase Firestore.
- Separar responsabilidades mediante ViewModels, repositorios, servicios y data sources.
- Preparar el flujo de integración con Microsoft Calendar sin comprometer secretos ni credenciales.

## 3. Alcance del MVP

El MVP de AcadPlanner incluye las funciones necesarias para demostrar una aplicación académica funcional con persistencia local y respaldo remoto.

Funciones incluidas:

- Dashboard principal.
- Listado de tareas.
- Detalle de tarea.
- Formulario de creación y edición de tareas.
- Listado de materias.
- Formulario de creación y edición de materias.
- Eliminación de tareas y materias.
- Clasificación de tareas por estado, prioridad y tipo.
- Persistencia local con SQLite.
- Respaldo remoto con Firebase Firestore.
- Indicador de integración con calendario mediante `calendarSyncStatus`.
- Generación controlada de un `microsoftEventId` simulado para el flujo de calendario.

Funciones fuera del MVP:

- Autenticación de usuarios.
- Sincronización multiusuario.
- Lectura completa del calendario Microsoft.
- Sincronización bidireccional con Microsoft Calendar.
- Edición o eliminación avanzada de eventos en Outlook.
- Google Calendar.
- Clima, frases motivacionales o feriados.
- Notificaciones avanzadas.
- Recurrencias.
- Roles de usuario.

## 4. Arquitectura general del proyecto

AcadPlanner sigue una arquitectura por capas. La intención principal es evitar que las vistas contengan lógica de negocio o lógica de persistencia. Cada capa tiene una responsabilidad específica.

Flujo general:

```text
SwiftUI Views
↓
ViewModels
↓
Repositories
├── SQLite DataSources
└── Firebase DataSources
```

Descripción de capas:

- **Models:** definen las entidades principales de la aplicación.
- **Views:** presentan la información al usuario y capturan interacciones.
- **ViewModels:** administran el estado de pantalla y coordinan acciones.
- **Repositories:** centralizan el acceso a datos y deciden cómo guardar o consultar información.
- **DataSources:** implementan la persistencia local o remota.
- **Services:** reservados para integraciones externas como Microsoft Graph.
- **Utils:** agrupan utilidades de fecha, red y errores.

La regla arquitectónica principal es que una vista no debe comunicarse directamente con SQLite, Firebase ni Microsoft Graph. La vista se comunica con su ViewModel, y el ViewModel trabaja con repositorios. Esto permite mantener el proyecto más ordenado y defendible técnicamente.

## 5. Diseño de modelos de datos

Los modelos principales de AcadPlanner son `Subject` y `AcademicTask`.

### 5.1 Modelo Subject

`Subject` representa una materia académica. Sus campos principales son:

- `id`
- `name`
- `professor`
- `colorHex`
- `createdAt`
- `updatedAt`
- `isSynced`

El campo `isSynced` permite identificar si la materia ya fue respaldada correctamente en Firebase. Esto separa el estado local del estado remoto.

### 5.2 Modelo AcademicTask

`AcademicTask` representa una actividad académica. Sus campos principales son:

- `id`
- `subjectId`
- `title`
- `description`
- `dueDate`
- `priority`
- `status`
- `type`
- `microsoftEventId`
- `isAddedToCalendar`
- `calendarSyncStatus`
- `createdAt`
- `updatedAt`
- `isSynced`

Este modelo está diseñado para cubrir tanto el CRUD académico como la futura integración con Microsoft Calendar.

La semántica de sincronización se separó de forma clara:

- `isSynced`: indica respaldo en Firebase.
- `isAddedToCalendar`: bandera rápida para la interfaz.
- `calendarSyncStatus`: estado detallado de integración con calendario.
- `microsoftEventId`: referencia al evento de Microsoft Calendar.

### 5.3 Enumeraciones

El proyecto utiliza enumeraciones para mantener datos consistentes:

- `TaskStatus`: pending, inProgress, completed.
- `TaskPriority`: low, medium, high, urgent.
- `TaskType`: task, project, exam, practice, reading, presentation.
- `CalendarSyncStatus`: notAdded, pending, added, failed.

Estas enumeraciones se guardan como `rawValue` al persistir en SQLite y Firebase. Esto facilita reconstruir los modelos al leer la información.

## 6. Subsistema de persistencia local con SQLite

SQLite es la base de la estrategia offline-first del proyecto. La aplicación utiliza un archivo local llamado `acadplanner.sqlite`, creado dentro del sandbox de documentos del dispositivo.

El archivo `DatabaseManager.swift` centraliza la apertura de la base de datos y la creación de tablas. Al iniciar la aplicación, se verifican y crean las tablas necesarias:

- `subjects`
- `academic_tasks`

### 6.1 Tabla subjects

La tabla `subjects` almacena las materias con los siguientes campos:

| Campo | Tipo | Descripción |
|---|---|---|
| id | TEXT | Identificador UUID |
| name | TEXT | Nombre de la materia |
| professor | TEXT | Profesor asignado |
| color_hex | TEXT | Color de referencia |
| created_at | TEXT | Fecha de creación |
| updated_at | TEXT | Fecha de actualización |
| is_synced | INTEGER | Estado de respaldo Firebase |

### 6.2 Tabla academic_tasks

La tabla `academic_tasks` almacena las tareas académicas:

| Campo | Tipo | Descripción |
|---|---|---|
| id | TEXT | Identificador UUID |
| subject_id | TEXT | Relación con la materia |
| title | TEXT | Título de la tarea |
| description | TEXT | Descripción |
| due_date | TEXT | Fecha de entrega |
| priority | TEXT | Prioridad |
| status | TEXT | Estado |
| type | TEXT | Tipo de actividad |
| microsoft_event_id | TEXT | Referencia futura a Microsoft Calendar |
| is_added_to_calendar | INTEGER | Bandera de calendario |
| calendar_sync_status | TEXT | Estado de integración con calendario |
| created_at | TEXT | Fecha de creación |
| updated_at | TEXT | Fecha de actualización |
| is_synced | INTEGER | Estado de respaldo Firebase |

### 6.3 Operaciones CRUD

Las clases `SQLiteSubjectDataSource` y `SQLiteTaskDataSource` implementan operaciones de consulta, inserción, actualización y eliminación.

El patrón utilizado es:

```text
Repository
↓
SQLiteDataSource
↓
DatabaseManager
↓
SQLite
```

Las consultas utilizan sentencias preparadas mediante `sqlite3_prepare_v2` y enlazado de parámetros con `sqlite3_bind_text` o `sqlite3_bind_int`. Esto evita construir SQL mediante interpolación directa de cadenas y reduce riesgos de inyección.

También se llama `sqlite3_finalize` al terminar cada operación para liberar recursos asociados a las sentencias preparadas.

## 7. Respaldo remoto con Firebase Firestore

Firebase Firestore se utiliza como capa de respaldo remoto. La aplicación guarda primero en SQLite y después intenta respaldar en Firebase. Esta decisión mantiene la app funcional aunque exista una falla de red.

Colecciones utilizadas:

- `subjects`
- `academic_tasks`

### 7.1 Respaldo de materias

`FirebaseSubjectDataSource` guarda materias en la colección `subjects`. Cada documento usa como ID el UUID de la materia:

```text
subjects/{subject.id}
```

Campos enviados:

- `id`
- `name`
- `professor`
- `colorHex`
- `createdAt`
- `updatedAt`
- `isSynced`

### 7.2 Respaldo de tareas académicas

`FirebaseTaskDataSource` guarda tareas en la colección `academic_tasks`. Cada documento usa como ID el UUID de la tarea:

```text
academic_tasks/{task.id}
```

Los enums se guardan como texto usando su `rawValue`. Las fechas se envían como `Timestamp`.

### 7.3 Estrategia offline-first

El flujo implementado en los repositorios es:

```text
Guardar en SQLite con isSynced = false
↓
Intentar respaldo en Firebase
↓
Si Firebase responde correctamente:
    actualizar localmente con isSynced = true
Si Firebase falla:
    conservar datos locales sin romper la app
```

Este flujo es importante porque Firebase no reemplaza a SQLite. SQLite sigue siendo la fuente local principal, mientras Firebase actúa como respaldo remoto.

## 8. Control de estado con MVVM y repositorios

El proyecto utiliza MVVM para separar la interfaz de la lógica de estado.

ViewModels principales:

- `DashboardViewModel`
- `TaskListViewModel`
- `TaskDetailViewModel`
- `TaskFormViewModel`
- `SubjectViewModel`

### 8.1 DashboardViewModel

`DashboardViewModel` obtiene tareas desde `TaskRepository` y calcula:

- Tareas próximas.
- Cantidad de tareas pendientes o en progreso.
- Cantidad de tareas completadas.
- Cantidad de tareas agregadas al calendario.

Esto evita que `DashboardView` tenga que filtrar directamente los datos.

### 8.2 TaskDetailViewModel

`TaskDetailViewModel` administra el detalle de una tarea. También consulta la materia relacionada mediante `SubjectRepository`, lo que permite mostrar nombre de materia y profesor en la pantalla de detalle.

Además coordina el flujo de calendario:

```text
TaskDetailViewModel
↓
CalendarRepository
↓
TaskRepository
↓
SQLite + Firebase
```

Actualmente el calendario usa un flujo simulado, pero conserva la estructura necesaria para conectar Microsoft Graph después.

### 8.3 TaskFormViewModel y SubjectViewModel

`TaskFormViewModel` administra los campos del formulario de tareas y prepara los objetos `AcademicTask`.  
`SubjectViewModel` administra materias, validación básica y operaciones de creación, edición o eliminación.

## 9. Interfaz de usuario con SwiftUI

AcadPlanner utiliza SwiftUI para construir una interfaz simple y académica. La navegación principal usa `TabView` con secciones principales:

- Dashboard.
- Tasks.
- Subjects.

Pantallas implementadas:

- `DashboardView`
- `TaskListView`
- `TaskDetailView`
- `TaskFormView`
- `SubjectListView`
- `SubjectFormView`

### 9.1 Dashboard

El dashboard resume información relevante del estudiante:

- Próximas tareas.
- Tareas pendientes.
- Tareas completadas.
- Tareas agregadas al calendario.

### 9.2 Lista y detalle de tareas

La lista de tareas permite consultar actividades académicas guardadas. Desde el detalle se muestra información de la tarea, materia, profesor, prioridad, estado, tipo y fecha de entrega.

### 9.3 Formularios

Los formularios permiten crear o editar tareas y materias. Las vistas capturan datos, pero la lógica de guardado se mantiene en ViewModels y repositorios.

## 10. Integración preparada con Microsoft Calendar

El proyecto está diseñado para integrarse con Microsoft Calendar mediante Microsoft Graph. La arquitectura definida es:

```text
TaskDetailView
↓
TaskDetailViewModel
↓
CalendarRepository
↓
MicrosoftAuthService
↓
MicrosoftCalendarService
↓
microsoftEventId
↓
TaskRepository
↓
SQLite + Firebase
```

En el MVP actual, `CalendarRepository` genera un identificador simulado con el formato:

```text
mock-microsoft-event-{task.id}
```

Después se actualizan:

- `microsoftEventId`
- `isAddedToCalendar`
- `calendarSyncStatus`

La integración real requiere:

- App Registration en Microsoft Entra ID.
- Client ID.
- Redirect URI para iOS.
- Permiso delegado `Calendars.ReadWrite`.
- Autenticación con MSAL.

Durante el desarrollo se intentó crear el registro en Microsoft Entra ID, pero la cuenta disponible no tenía acceso a un tenant válido ni calificaba para un sandbox de Microsoft 365 Developer Program. Por esa razón, la integración se documenta como preparada y no como funcional en producción.

## 11. Seguridad y manejo de configuración sensible

El archivo `GoogleService-Info.plist` es necesario localmente para configurar Firebase, pero se encuentra ignorado por Git mediante `.gitignore`.

No deben subirse al repositorio:

- `GoogleService-Info.plist`
- Client secrets.
- Access tokens.
- Refresh tokens.
- Llaves privadas.
- Archivos `.env`.
- `Secrets.plist`.

Para iOS, una integración real con Microsoft Graph no debe usar client secret embebido. La autenticación debe realizarse mediante flujo delegado de usuario con MSAL.

## 12. Plan de pruebas y resultados

Se realizaron pruebas manuales para validar el comportamiento principal del MVP.

### 12.1 Prueba de persistencia local de materias

**Objetivo:** confirmar que una materia creada permanece guardada después de cerrar y abrir la app.  
**Procedimiento:** crear una materia desde `SubjectFormView`, cerrar el simulador y abrir nuevamente la app.  
**Resultado:** la materia permanece visible, confirmando persistencia local con SQLite.

### 12.2 Prueba de persistencia local de tareas

**Objetivo:** confirmar que una tarea creada permanece guardada en SQLite.  
**Procedimiento:** crear una tarea vinculada a una materia, cerrar la app y abrirla nuevamente.  
**Resultado:** la tarea permanece disponible en la lista y en el dashboard.

### 12.3 Prueba de respaldo Firebase para materias

**Objetivo:** validar que las materias se respaldan en Firestore.  
**Procedimiento:** crear una materia y revisar Firebase Console.  
**Resultado:** la colección `subjects` recibe un documento con el UUID de la materia.

### 12.4 Prueba de respaldo Firebase para tareas

**Objetivo:** validar que las tareas se respaldan en Firestore.  
**Procedimiento:** crear una tarea y revisar Firebase Console.  
**Resultado:** la colección `academic_tasks` recibe un documento con el UUID de la tarea.

### 12.5 Prueba de edición y eliminación

**Objetivo:** confirmar que la app soporta edición y borrado sin fallos.  
**Procedimiento:** editar una tarea, editar una materia, borrar una tarea de prueba y observar que la app no se cierre inesperadamente.  
**Resultado:** las operaciones se ejecutan correctamente y la app no presenta fallos durante la prueba manual.

### 12.6 Prueba de flujo de calendario simulado

**Objetivo:** confirmar que el flujo de calendario actualiza el estado de una tarea.  
**Procedimiento:** abrir una tarea y seleccionar la opción de agregar a Microsoft Calendar.  
**Resultado:** la tarea actualiza su estado a `Added`, se guarda un `microsoftEventId` simulado y los datos se persisten mediante `TaskRepository`.

## 13. Limitaciones actuales

Limitaciones del MVP:

- No existe autenticación de usuarios.
- Firebase funciona como respaldo, no como sincronización bidireccional completa.
- Microsoft Graph no está activo por falta de App Registration en Entra ID.
- No hay manejo avanzado de conflictos entre datos locales y remotos.
- No hay notificaciones locales o push.
- No hay colaboración entre usuarios.

Estas limitaciones son aceptables para el alcance académico actual y pueden convertirse en puntos de crecimiento para una versión profesional.

## 14. Conclusiones

AcadPlanner cumple con el objetivo de construir una aplicación iOS académica basada en SwiftUI, MVVM, SQLite y Firebase. El proyecto demuestra una separación clara de responsabilidades entre interfaz, ViewModels, repositorios y fuentes de datos.

La decisión de implementar SQLite como primera capa de persistencia permite que la aplicación funcione bajo un enfoque offline-first. Esto es especialmente útil para un gestor académico, ya que el estudiante puede consultar tareas y materias sin depender completamente de internet.

Firebase Firestore agrega una segunda capa de valor al permitir respaldo remoto de materias y tareas. El flujo implementado evita que Firebase sea un punto único de falla, ya que primero se guarda localmente y después se intenta respaldar en la nube.

La integración con Microsoft Calendar quedó diseñada de forma correcta para una evolución posterior. Aunque no se activó Microsoft Graph por restricciones externas de Microsoft Entra ID, la estructura actual conserva `CalendarRepository`, `MicrosoftAuthService`, `MicrosoftCalendarService`, `microsoftEventId` y `calendarSyncStatus`, lo que facilita completar la integración cuando exista el client ID y redirect URI necesarios.

En conclusión, AcadPlanner presenta una base técnica sólida para una entrega académica y también un camino claro para escalar hacia una aplicación más profesional.

## 15. Bibliografía

- Apple Inc. SwiftUI Documentation. Apple Developer Documentation. https://developer.apple.com/documentation/swiftui/
- Deniz, E. iOS Swift SQLite3 Integration. Medium. https://medium.com/@emre.deniz/ios-swift-sqlite3-integration-1b3dece47b46
- Firebase Documentation. Leer y escribir datos en Firebase para iOS. https://firebase.google.com/docs/database/ios/read-and-write?hl=es-419
- Firebase Documentation. Cloud Firestore. https://firebase.google.com/docs/firestore
- Microsoft Learn. Microsoft Graph Calendar API. https://learn.microsoft.com/graph/api/resources/calendar
- Microsoft Learn. Microsoft identity platform for mobile applications. https://learn.microsoft.com/entra/identity-platform/scenario-mobile-overview
