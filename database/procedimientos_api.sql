-- =====================================================
-- PROCEDIMIENTOS QUE USA LA API (backend)
-- Ejecutar DESPUÉS de proyecto_veterinaria_completo.sql
-- Se puede ejecutar varias veces (cada uno hace DROP IF EXISTS).
--
-- Convención de errores (el backend los traduce en errores.js):
--   MYSQL_ERRNO 5404 -> "no existe"            -> HTTP 404
--   MYSQL_ERRNO 5409 -> "conflicto"            -> HTTP 409
--   SIGNAL sin errno (queda 1644) -> validación -> HTTP 400
-- =====================================================
USE proyecto_veterinaria_test;

-- =====================================================
-- CATÁLOGOS (solo lectura)
-- =====================================================
DROP PROCEDURE IF EXISTS sp_listar_especies;
DROP PROCEDURE IF EXISTS sp_listar_razas;
DROP PROCEDURE IF EXISTS sp_listar_procedimientos;
DROP PROCEDURE IF EXISTS sp_listar_medicamentos;

DELIMITER //

CREATE PROCEDURE sp_listar_especies()
BEGIN
    SELECT id_especie, nombre_especie
    FROM especie
    ORDER BY nombre_especie;
END //

-- Si p_id_especie es NULL devuelve todas las razas
CREATE PROCEDURE sp_listar_razas(IN p_id_especie INT)
BEGIN
    SELECT r.id_raza, r.nombre_raza, e.id_especie, e.nombre_especie
    FROM raza r
    INNER JOIN especie e ON e.id_especie = r.FK_id_especie
    WHERE p_id_especie IS NULL OR r.FK_id_especie = p_id_especie
    ORDER BY r.nombre_raza;
END //

CREATE PROCEDURE sp_listar_procedimientos()
BEGIN
    SELECT id_procedimiento, nombre_procedimiento, costo_referencia
    FROM procedimiento
    ORDER BY nombre_procedimiento;
END //

CREATE PROCEDURE sp_listar_medicamentos()
BEGIN
    SELECT id_medicamento, nombre_medicamento, presentacion
    FROM medicamento
    ORDER BY nombre_medicamento;
END //

DELIMITER ;


-- =====================================================
-- DUEÑOS
-- Los teléfonos llegan como texto JSON: '["3001234567","3109876543"]'
-- y salen como texto separado por comas: '3001234567,3109876543'
-- =====================================================
DROP PROCEDURE IF EXISTS sp_validar_dueno;
DROP PROCEDURE IF EXISTS sp_listar_duenos;
DROP PROCEDURE IF EXISTS sp_obtener_dueno;
DROP PROCEDURE IF EXISTS sp_crear_dueno;
DROP PROCEDURE IF EXISTS sp_actualizar_dueno;
DROP PROCEDURE IF EXISTS sp_eliminar_dueno;

DELIMITER //

-- Valida los datos de un dueño. No devuelve nada: si algo está mal, lanza SIGNAL (400).
-- Los parámetros son más anchos que las columnas a propósito: así un texto
-- demasiado largo se detecta aquí en vez de truncarse en silencio.
CREATE PROCEDURE sp_validar_dueno(
    IN p_nombre    VARCHAR(255),
    IN p_calle     VARCHAR(255),
    IN p_ciudad    VARCHAR(255),
    IN p_telefonos TEXT
)
BEGIN
    DECLARE v_total     INT DEFAULT 0;
    DECLARE v_distintos INT DEFAULT 0;
    DECLARE v_invalidos INT DEFAULT 0;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del dueño es obligatorio';
    ELSEIF CHAR_LENGTH(TRIM(p_nombre)) < 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del dueño debe tener al menos 3 caracteres';
    ELSEIF CHAR_LENGTH(TRIM(p_nombre)) > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del dueño no puede tener más de 50 caracteres';
    END IF;

    IF p_calle IS NULL OR TRIM(p_calle) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La calle es obligatoria';
    ELSEIF CHAR_LENGTH(TRIM(p_calle)) > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La calle no puede tener más de 100 caracteres';
    END IF;

    IF p_ciudad IS NULL OR TRIM(p_ciudad) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ciudad es obligatoria';
    ELSEIF CHAR_LENGTH(TRIM(p_ciudad)) > 60 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ciudad no puede tener más de 60 caracteres';
    END IF;

    -- Los IF van anidados con ELSEIF para que JSON_TYPE solo se evalúe si el JSON es válido
    IF p_telefonos IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los teléfonos deben enviarse como una lista';
    ELSEIF NOT JSON_VALID(p_telefonos) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los teléfonos deben enviarse como una lista';
    ELSEIF JSON_TYPE(p_telefonos) <> 'ARRAY' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los teléfonos deben enviarse como una lista';
    END IF;

    -- Convierte el arreglo JSON en filas y cuenta: total, distintos y los que no tienen 10 dígitos
    SELECT COUNT(*),
           COUNT(DISTINCT x.tel),
           COALESCE(SUM(x.tel NOT REGEXP '^[0-9]{10}$'), 0)
      INTO v_total, v_distintos, v_invalidos
    FROM (
        SELECT COALESCE(TRIM(j.tel), '') AS tel
        FROM JSON_TABLE(p_telefonos, '$[*]' COLUMNS (tel VARCHAR(100) PATH '$')) AS j
    ) AS x;

    IF v_total = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe ingresar al menos un teléfono';
    ELSEIF v_invalidos > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los teléfonos deben tener 10 dígitos y solo contener números';
    ELSEIF v_distintos <> v_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puede ingresar teléfonos duplicados';
    END IF;
END //

CREATE PROCEDURE sp_listar_duenos()
BEGIN
    SELECT d.id_dueno, d.nombre_dueno, d.calle, d.ciudad,
           GROUP_CONCAT(t.telefono ORDER BY t.telefono SEPARATOR ',') AS telefonos
    FROM dueno d
    LEFT JOIN telefono_dueno t ON t.FK_id_dueno = d.id_dueno
    GROUP BY d.id_dueno, d.nombre_dueno, d.calle, d.ciudad
    ORDER BY d.nombre_dueno;
END //

CREATE PROCEDURE sp_obtener_dueno(IN p_id_dueno INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dueno WHERE id_dueno = p_id_dueno) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El dueño indicado no existe', MYSQL_ERRNO = 5404;
    END IF;

    SELECT d.id_dueno, d.nombre_dueno, d.calle, d.ciudad,
           GROUP_CONCAT(t.telefono ORDER BY t.telefono SEPARATOR ',') AS telefonos
    FROM dueno d
    LEFT JOIN telefono_dueno t ON t.FK_id_dueno = d.id_dueno
    WHERE d.id_dueno = p_id_dueno
    GROUP BY d.id_dueno, d.nombre_dueno, d.calle, d.ciudad;
END //

-- TRANSACCIÓN: dueño + sus teléfonos se guardan juntos o no se guarda nada.
CREATE PROCEDURE sp_crear_dueno(
    IN p_nombre    VARCHAR(255),
    IN p_calle     VARCHAR(255),
    IN p_ciudad    VARCHAR(255),
    IN p_telefonos TEXT
)
BEGIN
    DECLARE v_id INT;

    -- Si CUALQUIER instrucción de abajo falla: deshace todo y reenvía el mismo error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    CALL sp_validar_dueno(p_nombre, p_calle, p_ciudad, p_telefonos);

    START TRANSACTION;

    INSERT INTO dueno (nombre_dueno, calle, ciudad)
    VALUES (TRIM(p_nombre), TRIM(p_calle), TRIM(p_ciudad));
    SET v_id = LAST_INSERT_ID();

    INSERT INTO telefono_dueno (telefono, FK_id_dueno)
    SELECT TRIM(j.tel), v_id
    FROM JSON_TABLE(p_telefonos, '$[*]' COLUMNS (tel VARCHAR(100) PATH '$')) AS j;

    COMMIT;

    CALL sp_obtener_dueno(v_id);
END //

-- TRANSACCIÓN: actualiza el dueño y reemplaza todos sus teléfonos.
CREATE PROCEDURE sp_actualizar_dueno(
    IN p_id_dueno  INT,
    IN p_nombre    VARCHAR(255),
    IN p_calle     VARCHAR(255),
    IN p_ciudad    VARCHAR(255),
    IN p_telefonos TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM dueno WHERE id_dueno = p_id_dueno) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El dueño indicado no existe', MYSQL_ERRNO = 5404;
    END IF;

    CALL sp_validar_dueno(p_nombre, p_calle, p_ciudad, p_telefonos);

    START TRANSACTION;

    UPDATE dueno
    SET nombre_dueno = TRIM(p_nombre),
        calle        = TRIM(p_calle),
        ciudad       = TRIM(p_ciudad)
    WHERE id_dueno = p_id_dueno;

    DELETE FROM telefono_dueno WHERE FK_id_dueno = p_id_dueno;

    INSERT INTO telefono_dueno (telefono, FK_id_dueno)
    SELECT TRIM(j.tel), p_id_dueno
    FROM JSON_TABLE(p_telefonos, '$[*]' COLUMNS (tel VARCHAR(100) PATH '$')) AS j;

    COMMIT;

    CALL sp_obtener_dueno(p_id_dueno);
END //

-- No deja borrar un dueño que tenga mascotas (409). Si no, borra teléfonos y dueño juntos.
CREATE PROCEDURE sp_eliminar_dueno(IN p_id_dueno INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM dueno WHERE id_dueno = p_id_dueno) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El dueño indicado no existe', MYSQL_ERRNO = 5404;
    END IF;

    IF EXISTS (SELECT 1 FROM mascota WHERE FK_id_dueno = p_id_dueno) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar el dueño porque tiene mascotas registradas',
                MYSQL_ERRNO = 5409;
    END IF;

    START TRANSACTION;
    DELETE FROM telefono_dueno WHERE FK_id_dueno = p_id_dueno;
    DELETE FROM dueno WHERE id_dueno = p_id_dueno;
    COMMIT;

    SELECT p_id_dueno AS id_dueno, 'Dueño eliminado' AS mensaje;
END //

DELIMITER ;


-- =====================================================
-- MASCOTAS
-- =====================================================
DROP PROCEDURE IF EXISTS sp_validar_mascota;
DROP PROCEDURE IF EXISTS sp_listar_mascotas;
DROP PROCEDURE IF EXISTS sp_obtener_mascota;
DROP PROCEDURE IF EXISTS sp_crear_mascota;
DROP PROCEDURE IF EXISTS sp_actualizar_mascota;
DROP PROCEDURE IF EXISTS sp_eliminar_mascota;

DELIMITER //

CREATE PROCEDURE sp_validar_mascota(
    IN p_nombre           VARCHAR(255),
    IN p_fecha_nacimiento DATE,
    IN p_id_dueno         INT,
    IN p_id_raza          INT
)
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la mascota es obligatorio';
    ELSEIF CHAR_LENGTH(TRIM(p_nombre)) > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la mascota no puede tener más de 50 caracteres';
    END IF;

    IF p_fecha_nacimiento IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento es obligatoria';
    ELSEIF p_fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento no puede ser futura';
    END IF;

    IF p_id_dueno IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe seleccionar un dueño';
    ELSEIF NOT EXISTS (SELECT 1 FROM dueno WHERE id_dueno = p_id_dueno) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El dueño indicado no existe', MYSQL_ERRNO = 5404;
    END IF;

    IF p_id_raza IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe seleccionar una raza';
    ELSEIF NOT EXISTS (SELECT 1 FROM raza WHERE id_raza = p_id_raza) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La raza indicada no existe', MYSQL_ERRNO = 5404;
    END IF;
END //

-- Si p_id_dueno es NULL devuelve todas las mascotas; si no, solo las de ese dueño
CREATE PROCEDURE sp_listar_mascotas(IN p_id_dueno INT)
BEGIN
    SELECT m.id_mascota, m.nombre_mascota, m.fecha_nacimiento,
           d.id_dueno, d.nombre_dueno,
           r.id_raza, r.nombre_raza,
           e.id_especie, e.nombre_especie
    FROM mascota m
    INNER JOIN dueno d   ON d.id_dueno = m.FK_id_dueno
    INNER JOIN raza r    ON r.id_raza = m.FK_id_raza
    INNER JOIN especie e ON e.id_especie = r.FK_id_especie
    WHERE p_id_dueno IS NULL OR m.FK_id_dueno = p_id_dueno
    ORDER BY m.nombre_mascota;
END //

CREATE PROCEDURE sp_obtener_mascota(IN p_id_mascota INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE id_mascota = p_id_mascota) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La mascota indicada no existe', MYSQL_ERRNO = 5404;
    END IF;

    SELECT m.id_mascota, m.nombre_mascota, m.fecha_nacimiento,
           d.id_dueno, d.nombre_dueno,
           r.id_raza, r.nombre_raza,
           e.id_especie, e.nombre_especie
    FROM mascota m
    INNER JOIN dueno d   ON d.id_dueno = m.FK_id_dueno
    INNER JOIN raza r    ON r.id_raza = m.FK_id_raza
    INNER JOIN especie e ON e.id_especie = r.FK_id_especie
    WHERE m.id_mascota = p_id_mascota;
END //

CREATE PROCEDURE sp_crear_mascota(
    IN p_nombre           VARCHAR(255),
    IN p_fecha_nacimiento DATE,
    IN p_id_dueno         INT,
    IN p_id_raza          INT
)
BEGIN
    DECLARE v_id INT;

    CALL sp_validar_mascota(p_nombre, p_fecha_nacimiento, p_id_dueno, p_id_raza);

    INSERT INTO mascota (nombre_mascota, fecha_nacimiento, FK_id_dueno, FK_id_raza)
    VALUES (TRIM(p_nombre), p_fecha_nacimiento, p_id_dueno, p_id_raza);
    SET v_id = LAST_INSERT_ID();

    CALL sp_obtener_mascota(v_id);
END //

CREATE PROCEDURE sp_actualizar_mascota(
    IN p_id_mascota       INT,
    IN p_nombre           VARCHAR(255),
    IN p_fecha_nacimiento DATE,
    IN p_id_dueno         INT,
    IN p_id_raza          INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE id_mascota = p_id_mascota) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La mascota indicada no existe', MYSQL_ERRNO = 5404;
    END IF;

    CALL sp_validar_mascota(p_nombre, p_fecha_nacimiento, p_id_dueno, p_id_raza);

    UPDATE mascota
    SET nombre_mascota   = TRIM(p_nombre),
        fecha_nacimiento = p_fecha_nacimiento,
        FK_id_dueno      = p_id_dueno,
        FK_id_raza       = p_id_raza
    WHERE id_mascota = p_id_mascota;

    CALL sp_obtener_mascota(p_id_mascota);
END //

-- No deja borrar una mascota que tenga citas (409)
CREATE PROCEDURE sp_eliminar_mascota(IN p_id_mascota INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE id_mascota = p_id_mascota) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La mascota indicada no existe', MYSQL_ERRNO = 5404;
    END IF;

    IF EXISTS (SELECT 1 FROM cita WHERE FK_id_mascota = p_id_mascota) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar la mascota porque tiene citas registradas',
                MYSQL_ERRNO = 5409;
    END IF;

    DELETE FROM mascota WHERE id_mascota = p_id_mascota;

    SELECT p_id_mascota AS id_mascota, 'Mascota eliminada' AS mensaje;
END //

DELIMITER ;
