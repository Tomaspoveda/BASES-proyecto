# Clínica Veterinaria · Proyecto final de Bases de Datos

Caso 1 (clínica veterinaria) · Pista Ingeniería Informática

**Integrantes:** Tomás Poveda, Juan Esteban Rubio, Isabela Benitez, Cristian Cifuentes y Nicolás Ayala

Sistema web para gestionar dueños, mascotas y citas de una clínica veterinaria. Las operaciones de negocio de la API pasan por procedimientos almacenados de MySQL.

[Arquitectura y diagramas de flujo](docs/arquitectura.md) · [Modelo relacional y cardinalidades](docs/modelo-relacional.md)

```
Navegador (React + Vite)  →  API (Node + Express)  →  CALL sp_...  →  MySQL
     puerto 5173                  puerto 3000
```

## Requisitos

| Programa | Versión | Cómo comprobarlo |
|---|---|---|
| Node.js | 22.13 o superior | `node -v` |
| MySQL Server | 8.0.21 o superior | `mysql --version` |
| Git | cualquiera | `git --version` |

## 1. Descargar el proyecto

```
git clone --branch correciones-nico https://github.com/nicoayala07/BASES-proyecto.git
cd BASES-proyecto
```

## 2. Crear la base de datos

Abre una terminal **en la carpeta raíz del proyecto** y entra a MySQL:

```
mysql -u root -p
```

Dentro de `mysql>` ejecuta estas dos líneas, **una por una y en este orden**:

```
charset utf8mb4
source database/proyecto_veterinaria_completo.sql
```

- `charset utf8mb4` es **obligatorio**: sin él, las tildes y la ñ se guardan dañadas (por ejemplo `due├▒o`).
- El script principal borra y recrea la base `proyecto_veterinaria_test` con todo lo necesario: tablas, datos, banco de consultas, índices, transacciones, funciones y los procedimientos `sp_...` que usa la API.
- No debe aparecer ninguna línea que empiece por `ERROR`. Los mensajes `Query OK` (con o sin `warning`) son normales.
- Durante la carga el script muestra a propósito dos mensajes de error controlado: «ERROR: el dueño 999999 no existe. Se hizo ROLLBACK de los 3 pasos.» y dos filas en `error_capturado` («El veterinario indicado no existe» y «La especialidad no puede estar vacia»). Forman parte de las demostraciones de ROLLBACK y de `SIGNAL`, no son fallos.
- Si tu terminal no encuentra el archivo (por ejemplo, en el _MySQL Command Line Client_), usa la ruta completa con barras `/`: `source C:/ruta/al/proyecto/database/proyecto_veterinaria_completo.sql`

Comprueba que quedó bien:

```sql
USE proyecto_veterinaria_test;
SELECT COUNT(*) FROM dueno;
SHOW PROCEDURE STATUS WHERE Db = 'proyecto_veterinaria_test' AND Name LIKE 'sp_%dueno';
```

El primer resultado debe ser `60` y la segunda consulta debe mostrar 5 procedimientos.
En una instalación nueva, todavía en la sesión administrativa, ejecuta:

```sql
source database/usuario_api.sql
```

Copia la contraseña aleatoria que MySQL devuelve para `veterinaria_api@localhost`. El script otorga `EXECUTE` únicamente sobre los procedimientos que invocan las rutas. Si recreas las rutinas en una instalación existente, vuelve a ejecutar los `GRANT` de ese archivo y conserva la cuenta y su contraseña omitiendo `CREATE USER`. Si el usuario ya existía con permisos de otra instalación, verifica con `SHOW GRANTS` que solo tenga los permisos de este archivo.

El esquema permite un supervisor distinto o `NULL`. MySQL requiere IDs explícitos en el catálogo de veterinarios porque un `CHECK` no admite columnas `AUTO_INCREMENT`. La carga conserva los IDs originales.

Para actualizar una base existente, haz un respaldo y detén la API durante la migración. Busca autosupervisiones con `SELECT id_veterinario FROM veterinario WHERE FK_id_veterinario_supervisor = id_veterinario` y corrige las que aparezcan. La sesión administrativa omite temporalmente la comprobación de llaves foráneas para quitar `AUTO_INCREMENT` de la columna referenciada, sin modificar IDs ni eliminar restricciones:

```sql
USE proyecto_veterinaria_test;
SET @validacion_fk_anterior = @@SESSION.FOREIGN_KEY_CHECKS;
SET SESSION FOREIGN_KEY_CHECKS = 0;
ALTER TABLE veterinario
  MODIFY id_veterinario INT NOT NULL,
  ADD CONSTRAINT chk_veterinario_no_autosupervision
    CHECK (FK_id_veterinario_supervisor IS NULL OR FK_id_veterinario_supervisor <> id_veterinario);
SET SESSION FOREIGN_KEY_CHECKS = @validacion_fk_anterior;
```

Después de aprovisionar la cuenta, escribe `exit`.

## 3. Arrancar el backend

```
cd backend
npm ci
```

Crea el archivo de configuración y configura la clave de la cuenta de la API:

- Windows (cmd o PowerShell): `copy .env.example .env`
- Mac o Linux: `cp .env.example .env`

Abre `backend/.env`, conserva `DB_USER=veterinaria_api` y guarda en `DB_PASSWORD` la contraseña del paso 2. Ponla entre comillas dobles para conservar caracteres especiales. El archivo está excluido de Git. Arranca la API:

```
npm start
```

Debe mostrar `API escuchando en http://localhost:3000` y `Conexión con MySQL correcta`.
Para comprobarlo, abre http://localhost:3000/api/salud: debe responder `{"ok":true}`.

Deja esta terminal abierta.

## 4. Arrancar el frontend

Abre **otra terminal** en la carpeta raíz del proyecto:

```
npm ci
npm run dev
```

Abre http://localhost:5173 en el navegador. Se ve la pantalla de inicio, con los totales de dueños, mascotas y citas y accesos a cada sección.

## 5. Qué se puede hacer

- **Inicio:** muestra cuántos dueños, mascotas y citas hay registrados y las citas más recientes. Desde aquí se llega a cada sección.
- **Dueños:** crear, editar y eliminar. Cada dueño lleva uno o varios teléfonos (de 10 dígitos, separados por comas). Un dueño que tiene mascotas no se puede eliminar.
- **Mascotas:** crear, editar y eliminar, filtrar por dueño y elegir especie y raza (las razas dependen de la especie). Una mascota con citas no se puede eliminar.
- **Citas:** ver todas las citas o las de una mascota, consultar el detalle (procedimientos con su costo y medicamentos con su dosis), registrar una cita completa, reprogramarla y eliminarla. Un veterinario no puede tener dos citas a la misma fecha y hora. Registrar y eliminar una cita son operaciones de todo o nada.

Las listas de especies, razas, procedimientos, medicamentos y veterinarios solo se leen: sirven para llenar los formularios.

## 6. Pruebas automatizadas

```
cd backend
npm test
```

Este comando ejecuta las pruebas unitarias y omite la integración. Para verificar la aplicación completa, configura la cuenta y carga los datos de ejemplo en una instancia de pruebas. Ejecuta en `backend/`:

```sh
npm run test:integracion
```

Este comando falla si MySQL o sus rutinas no están disponibles. Las pruebas de citas verifican alta con detalles, consulta, reprogramación, eliminación, conflicto de agenda, validación y `ROLLBACK`. Para provocar el rollback, se envía un medicamento que no existe junto a una receta válida. MySQL detecta el faltante después de insertar la cita y sus procedimientos. La prueba compara el listado antes y después y repite la operación con datos válidos en el mismo horario.


## 7. Prueba de rendimiento de los índices

```
cd backend
npm run benchmark
```

Define `BENCH_DB_USER` y `BENCH_DB_PASSWORD` en la terminal con una cuenta administrativa de la base de prueba. El benchmark usa esas credenciales para crear y modificar índices. Crea una copia de la tabla `cita` (`cita_bench`) con unas 20.000 filas sintéticas, mide cada consulta con y sin índice y la borra al terminar. Los resultados están en `backend/scripts/resultado_benchmark.md`.

## Estructura

```
database/    script SQL único (tablas, datos, consultas, índices y procedimientos)
backend/     API Express (rutas, validaciones, pruebas, benchmark)
src/         frontend React (páginas, componentes, validaciones)
docs/        documento de arquitectura
```

## Problemas frecuentes

| Síntoma | Causa y solución |
|---|---|
| `Access denied for user 'veterinaria_api'` | Comprueba `DB_HOST` y la clave de `backend/.env`. Si falta permiso sobre algún procedimiento, vuelve a aplicar sus `GRANT` del paso 2. |
| `PROCEDURE ... does not exist` | La base no se cargó completa. Repite el paso 2 completo y revisa que no haya líneas `ERROR`. |
| Tildes raras (`├®`, `├▒`) | Se ejecutó el script sin `charset utf8mb4`. Repite el paso 2 completo. |
| La página dice «No se pudo conectar con el servidor» | El backend no está corriendo. Revisa el paso 3. |
| `mysql` no se reconoce como comando | Abre el _MySQL Command Line Client_ desde el menú de inicio, o usa la ruta completa de `mysql.exe`. |
| El puerto 3000 está ocupado | Cambia `PORT` en `backend/.env` y el destino del proxy en `vite.config.js`. |

> Cada vez que se ejecuta `proyecto_veterinaria_completo.sql` se pierde lo que se haya creado desde la página, porque el script borra y recrea la base.
