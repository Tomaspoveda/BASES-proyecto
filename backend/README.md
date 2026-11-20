# Backend de la clínica veterinaria

API en Express que conecta el frontend (React + Vite) con MySQL.
**Regla del proyecto:** la API no escribe SQL suelto; solo llama procedimientos almacenados (`CALL sp_...`).

## Requisitos
- Node.js 22.13 o superior
- MySQL 8 con la base `proyecto_veterinaria_test` creada (ejecuta `database/proyecto_veterinaria_completo.sql`, que ya incluye todos los procedimientos)

## Instalación
1. Entra a esta carpeta: `cd backend`
2. Instala dependencias: `npm ci`
3. Copia `.env.example` como `.env` y escribe la clave de `veterinaria_api` según los [pasos de instalación](../README.md#2-crear-la-base-de-datos)
4. Arranca el servidor: `npm start` (queda en http://localhost:3000)
5. Comprueba que responde: abre http://localhost:3000/api/salud y debe mostrar `{"ok":true}`

## Frontend
En otra terminal, en la carpeta raíz del proyecto: `npm ci` y `npm run dev`.
Vite reenvía todo lo que empieza por `/api` a este servidor (ver `vite.config.js`).

## Pruebas y benchmark
- `npm test` ejecuta las pruebas unitarias. `npm run test:integracion` ejecuta también las pruebas HTTP con MySQL y falla si la base no está disponible.
- `npm run benchmark` mide el efecto de los índices sobre una copia temporal de `cita` con unas 20.000 filas. Utiliza `BENCH_DB_USER` y `BENCH_DB_PASSWORD`.

## Endpoints
| Método | Ruta | Procedimiento |
|---|---|---|
| GET | /api/salud | (solo comprueba que MySQL responde) |
| GET | /api/especies | sp_listar_especies |
| GET | /api/razas?id_especie= | sp_listar_razas |
| GET | /api/procedimientos | sp_listar_procedimientos |
| GET | /api/medicamentos | sp_listar_medicamentos |
| GET | /api/veterinarios | sp_listar_veterinarios |
| GET, POST | /api/duenos | sp_listar_duenos, sp_crear_dueno |
| GET, PUT, DELETE | /api/duenos/:id | sp_obtener_dueno, sp_actualizar_dueno, sp_eliminar_dueno |
| GET, POST | /api/mascotas (?id_dueno=) | sp_listar_mascotas, sp_crear_mascota |
| GET, PUT, DELETE | /api/mascotas/:id | sp_obtener_mascota, sp_actualizar_mascota, sp_eliminar_mascota |
| GET | /api/citas (?id_mascota=) | sp_listar_citas |
| POST | /api/citas | sp_registrar_cita_completa |
| GET | /api/citas/:idMascota/:numero | sp_obtener_cita, sp_listar_procedimientos_cita, sp_listar_recetas_cita |
| PUT | /api/citas/:idMascota/:numero | sp_reprogramar_cita |
| DELETE | /api/citas/:idMascota/:numero | sp_eliminar_cita |

## Errores
Siempre se responde `{ "error": "mensaje" }`: 400 validación, 404 no existe, 409 conflicto (por ejemplo, dueño con mascotas o veterinario con otra cita a esa hora), 503 sin conexión a MySQL, 500 error inesperado.