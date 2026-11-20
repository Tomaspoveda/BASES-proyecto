-- Ejecutar como administrador después del script principal.
-- Si la cuenta ya existe, omitir CREATE USER para conservar su contraseña.
CREATE USER 'veterinaria_api'@'localhost' IDENTIFIED BY RANDOM PASSWORD;

GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_actualizar_dueno TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_actualizar_mascota TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_crear_dueno TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_crear_mascota TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_eliminar_cita TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_eliminar_dueno TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_eliminar_mascota TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_citas TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_duenos TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_especies TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_mascotas TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_medicamentos TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_procedimientos TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_procedimientos_cita TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_razas TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_recetas_cita TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_listar_veterinarios TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_obtener_cita TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_obtener_dueno TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_obtener_mascota TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_registrar_cita_completa TO 'veterinaria_api'@'localhost';
GRANT EXECUTE ON PROCEDURE proyecto_veterinaria_test.sp_reprogramar_cita TO 'veterinaria_api'@'localhost';

SHOW GRANTS FOR 'veterinaria_api'@'localhost';
