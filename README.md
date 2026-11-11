# Clínica Veterinaria · Proyecto final de Bases de Datos

Caso 1 (clínica veterinaria) · Pista Ingeniería Informática

**Integrantes:** _(escriban aquí los 4 nombres)_

Sistema web para gestionar dueños y mascotas de una clínica veterinaria. La aplicación **no escribe SQL**: todo pasa por procedimientos almacenados de MySQL.

```
Navegador (React + Vite)  →  API (Node + Express)  →  CALL sp_...  →  MySQL
     puerto 5173                  puerto 3000
```

## Requisitos

| Programa | Versión | Cómo comprobarlo |
|---|---|---|
| Node.js | 20 o superior | `node -v` |
| MySQL Server | 8.0.16 o superior | `mysql --version` |
| Git | cualquiera | `git --version` |

## 1. Descargar el proyecto

```
git clone <URL-del-repositorio>
cd <carpeta-del-proyecto>
```

## 2. Crear la base de datos

Abre una terminal **en la carpeta raíz del proyecto** y entra a MySQL:

```
mysql -u root -p
```

Dentro de `mysql>` ejecuta estas tres líneas, **una por una y en este orden**:

```
charset utf8mb4
source database/proyecto_veterinaria_completo.sql
source database/procedimientos_api.sql
```

- `charset utf8mb4` es **obligatorio**: sin él, las tildes y la ñ se guardan dañadas (por ejemplo `due├▒o`).
- El primer script **borra y recrea** la base `proyecto_veterinaria_test`, con tablas, datos, consultas e índices.
- El segundo crea los procedimientos que usa la API. **Siempre debe ir después del primero**, porque el primero borra todo lo que hubiera.
- No debe aparecer ninguna línea que empiece por `ERROR`. Los mensajes `Query OK` (con o sin `warning`) son normales.
- Si tu terminal no encuentra los archivos (por ejemplo, en el _MySQL Command Line Client_), usa la ruta completa con barras `/`: `source C:/ruta/al/proyecto/database/proyecto_veterinaria_completo.sql`

Comprueba que quedó bien:

```sql
USE proyecto_veterinaria_test;
SELECT COUNT(*) FROM dueno;
SHOW PROCEDURE STATUS WHERE Db = 'proyecto_veterinaria_test' AND Name LIKE 'sp_%dueno';
```

El primer resultado debe ser `60` y la segunda consulta debe mostrar 5 procedimientos. Luego escribe `exit`.

## 3. Arrancar el backend

```
cd backend
npm install
```

Crea el archivo de configuración y escribe tu clave de MySQL:

- Windows (cmd o PowerShell): `copy .env.example .env`
- Mac o Linux: `cp .env.example .env`

Abre `backend/.env` y cambia `DB_PASSWORD` por la clave de tu MySQL (sin comillas ni espacios). Guarda el archivo y arranca:

```
npm start
```

Debe mostrar `API escuchando en http://localhost:3000` y `Conexión con MySQL correcta`.
Para comprobarlo, abre http://localhost:3000/api/salud: debe responder `{"ok":true}`.

Deja esta terminal abierta.

## 4. Arrancar el frontend

Abre **otra terminal** en la carpeta raíz del proyecto:

```
npm install
npm run dev
```

Abre http://localhost:5173 en el navegador.

## 5. Qué se puede hacer

- **Dueños:** crear, editar y eliminar. Cada dueño lleva uno o varios teléfonos (de 10 dígitos, separados por comas). Un dueño que tiene mascotas no se puede eliminar.
- **Mascotas:** crear, editar y eliminar, filtrar por dueño y elegir especie y raza (las razas dependen de la especie). Una mascota con citas no se puede eliminar.

## 6. Pruebas automatizadas

```
cd backend
npm test
```

Incluye pruebas unitarias (no necesitan MySQL) y pruebas de integración que usan la API y la base. Estas últimas necesitan la base cargada y el `.env` configurado; si MySQL no responde, se saltan. Una de ellas comprueba que un `ROLLBACK` deja los datos exactamente como estaban.

## Estructura

```
database/    scripts SQL (tablas, datos, consultas, procedimientos)
backend/     API Express (rutas, validaciones, pruebas)
src/         frontend React (páginas, componentes, validaciones)
```

## Problemas frecuentes

| Síntoma | Causa y solución |
|---|---|
| `Access denied for user 'root'` | La clave de `backend/.env` no es la de MySQL. Corrígela, guarda y reinicia con `npm start`. |
| `PROCEDURE ... does not exist` | Falta ejecutar `database/procedimientos_api.sql` (siempre después del script principal). |
| Tildes raras (`├®`, `├▒`) | Se ejecutaron los scripts sin `charset utf8mb4`. Repite el paso 2 completo. |
| La página dice «No se pudo conectar con el servidor» | El backend no está corriendo. Revisa el paso 3. |
| `mysql` no se reconoce como comando | Abre el _MySQL Command Line Client_ desde el menú de inicio, o usa la ruta completa de `mysql.exe`. |
| El puerto 3000 está ocupado | Cambia `PORT` en `backend/.env` y el destino del proxy en `vite.config.js`. |

> Cada vez que se ejecuta `proyecto_veterinaria_completo.sql` se pierde lo que se haya creado desde la página, y hay que volver a ejecutar `procedimientos_api.sql`.