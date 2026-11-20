# Resultado del benchmark de índices

Tabla de prueba `cita_bench`: 247 citas reales + 20000 sintéticas = **20247 filas**. Cada tiempo es la mediana de 20 ejecuciones.

| Consulta | Índice | Sin índice (ms) | Con índice (ms) | Mejora | Plan sin índice | Plan con índice |
|---|---|---|---|---|---|---|
| Citas de un trimestre (rango de fechas) | `idx_bench_fecha` (fecha_cita) | 32.03 | 3.51 | 9.1x | ALL, 20407 filas | range, 1705 filas |
| Agenda de un veterinario en un semestre (veterinario 1) | `idx_bench_vet_fecha` (FK_id_veterinario, fecha_cita) | 21.14 | 0.83 | 25.4x | ALL, 20407 filas | range, 54 filas |
| Últimas 5 citas de una mascota (mascota 1) | `idx_bench_mascota_numero` (FK_id_mascota, numero_cita) | 22.35 | 0.76 | 29.5x | ALL, 20407 filas | ref, 254 filas |
