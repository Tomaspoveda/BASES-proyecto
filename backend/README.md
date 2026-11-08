# Backend de la clínica veterinaria

API en Express que conecta el frontend (React + Vite) con MySQL.
**Regla del proyecto:** la API no escribe SQL suelto; solo llama procedimientos almacenados (`CALL sp_...`).

## Requisitos
- Node.js 20 o superior
- MySQL 8 con la base `proyecto_veterinaria_test` creada (ejecuta `proyecto_veterinaria_completo.sql` y luego los procedimientos de dueños y mascotas)

## Instalación
1. Entra a esta carpeta: `cd backend`
2. Instala dependencias: `npm install`
3. Copia `.env.example` como `.env` y escribe tu usuario y clave de MySQL
4. Arranca el servidor: `npm start` (queda en http://localhost:3000)
5. Comprueba que responde: abre http://localhost:3000/api/salud y debe mostrar `{"ok":true}`

## Frontend
En otra terminal, en la carpeta raíz del proyecto: `npm install` y `npm run dev`.
Vite reenvía todo lo que empieza por `/api` a este servidor (ver `vite.config.js`).

## Pruebas
`npm test` ejecuta las pruebas de la traducción de errores y de las utilidades (no necesitan MySQL).

## Endpoints
| Método | Ruta | Procedimiento |
|---|---|---|
| GET | /api/especies | sp_listar_especies |
| GET | /api/razas?id_especie= | sp_listar_razas |
| GET | /api/procedimientos | sp_listar_procedimientos |
| GET | /api/medicamentos | sp_listar_medicamentos |
| GET, POST | /api/duenos | sp_listar_duenos, sp_crear_dueno |
| GET, PUT, DELETE | /api/duenos/:id | sp_obtener_dueno, sp_actualizar_dueno, sp_eliminar_dueno |
| GET, POST | /api/mascotas (?id_dueno=) | sp_listar_mascotas, sp_crear_mascota |
| GET, PUT, DELETE | /api/mascotas/:id | sp_obtener_mascota, sp_actualizar_mascota, sp_eliminar_mascota |

## Errores
Siempre se responde `{ "error": "mensaje" }`: 400 validación, 404 no existe, 409 conflicto (por ejemplo, dueño con mascotas), 503 sin conexión a MySQL, 500 error inesperado.
