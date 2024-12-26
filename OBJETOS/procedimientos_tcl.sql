-- PROCEDIMIENTO PARA CONTROL DE EDAD EN INGESTA DE DATOS EN EMPLEADO
-- LA PERSONA QUE SE AGREGA AL SISTEMA DEBE SER MAYOR DE 18 Y MENOR DE 50
-- EN CASO DE NO CUMPLIR LOS REQUISITOS, APLICA ROLLBACK Y DEVUELVE UN MENSAJE DETERMINADO

DELIMITER //

DROP PROCEDURE IF EXISTS liqui_escuela.sptcl_control_edad;

CREATE PROCEDURE liqui_escuela.sptcl_control_edad (
        IN _id_banco INT,
        IN _nombre VARCHAR(200),
        IN _apellido VARCHAR(200),
        IN _dni INT,
        IN _fecha_nacimiento DATE,
        IN _fecha_ingreso DATE,
        IN _fecha_baja DATE,
        IN _sucursal_banco INT,
        IN _cuenta_banco INT,
        IN _agremiado ENUM('SI','NO')
)
BEGIN
    DECLARE max_edad INT DEFAULT 50;
    DECLARE min_edad INT DEFAULT 18;
    DECLARE edad_real INT;
    DECLARE mensaje VARCHAR(255);

    -- INICIA TRNSACCIÓN
    START TRANSACTION;

INSERT INTO liqui_escuela.empleado (id_banco,nombre,apellido,dni,fecha_nacimiento) VALUES (
    _id_banco
,   _nombre
,   _apellido
,   _dni
,   _fecha_nacimiento
,   _fecha_ingreso
,   _fecha_baja
,   _sucursal_banco
,   _cuenta_banco
,   _agremiado);

    -- CALCULO DE LA EDAD DE LA PERSONA
    SET edad_real = TIMESTAMPDIFF(YEAR, _fecha_nacimiento, CURDATE());

    -- Verificar condiciones y generar el mensaje de error
    IF edad_real < min_edad THEN
        SET mensaje = 'LA PERSONA ES MENOR DE EDAD. DEBE CUMPLIR ESE REQUISITO.';
        ROLLBACK;
    ELSEIF edad_real > max_edad THEN
        SET mensaje = 'POSIBLE SITUACIÓN DE SOBREEDAD, REVISAR.';
        ROLLBACK;
    ELSE
        SET mensaje = 'PERSONA INGRESADA.';
        COMMIT;
    END IF;

    -- Opcional: Devolver el mensaje de error
    SELECT mensaje AS mensaje;

END //
DELIMITER ;


-- PRUEBA EXITOSA
-- call liqui_escuela.sptcl_control_edad (1,'bruno','mars', 21568955,'1985-12-10','2024-02-02',NULL,NULL,NULL,'NO');

-- select * from liqui_escuela.empleado
-- where apellido = 'mars';