-- PROCEDIMIENTO DESTINADO A REGISTAR BAJAS DE EMPLEADOS
-- SE BASA EN DOS VARIABLES: DNI Y MOTIVO

DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.pd_busca_empleado//
CREATE PROCEDURE liqui_escuela.pd_busca_empleado( 
	IN emp_dni INT,
    OUT emp_id INT)
BEGIN
	SELECT 
	e.id_empleado INTO emp_id
    FROM liqui_escuela.empleado as e
    WHERE e.dni = emp_dni;
END//

DELIMITER ;



DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.pd_baja_empleado//
CREATE PROCEDURE liqui_escuela.pd_baja_empleado( 
	IN emp_dni INT,
    IN baja DATE,
    IN motivo INT)
BEGIN
	CALL liqui_escuela.pd_busca_empleado(emp_dni, @salida);
    
    UPDATE liqui_escuela.empleado as e
    SET e.fecha_baja = baja,
		e.observaciones = motivo
	WHERE e.id_empleado = @salida;
END//

DELIMITER ;


-- llamado a los procedimientos
SET @salida = 0;
CALL liqui_escuela.pd_baja_empleado (22137830,'2023-02-03',5);

-- prueba inicial
SET @salida = 0;
CALL liqui_escuela.pd_busca_empleado (22137830,@salida)


-- MISMA FUNCIÓN QUE LA ANTERIOR + USO DE FUNCIÓN INTERNAMENTE PARA DETERMINAR MOTIVO DE BAJA
DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.pd_baja_empleado//
CREATE PROCEDURE liqui_escuela.pd_baja_empleado( 
	IN emp_dni INT,
    IN baja DATE,
    IN motivo INT)
BEGIN
	DECLARE _motivo VARCHAR (200);
	CALL liqui_escuela.pd_busca_empleado(emp_dni, @salida);
    
    SELECT liqui_escuela.fx_mot_baja (motivo) INTO _motivo
    FROM DUAL;
        
    UPDATE liqui_escuela.empleado as e
    SET e.fecha_baja = baja,
		e.observaciones = _motivo
	WHERE e.id_empleado = @salida;
END//

DELIMITER ;


        --  PROCEDIMIENTO DE INGESTA DE PRESENTISMO

DELIMITER //

DROP PROCEDURE IF EXISTS liqui_escuela.sp_ingesta_presentismo //
CREATE PROCEDURE liqui_escuela.sp_ingesta_presentismo (IN dia_asistencia DATE)
BEGIN
-- BORRA UN REGISTRO DE DÍA ANTERIOR - PARA QUE NO HAYAN DUPLICADOS EN LA TABLA ASISTENCIA
-- LA CONFIGURACIÓN PREDETERMINADA DE MY SQL NO PERMITE BORRAR DATOS DE UNA TABLA RELACIONADA, POR ESTE MOTIVO
-- SE MODIFICA EL SETEO DEL SQL_SAFE_UPDATES. LUEGO DEL DELETE SE VUELVE A ACTIVAR, POR SEGURIDAD.
	SET SQL_SAFE_UPDATES = 0;
    DELETE FROM liqui_escuela.asistencia
        WHERE fecha_asist = dia_asistencia;
	SET SQL_SAFE_UPDATES = 1;
    
-- INSERCIÓN EN TABLA ASISTENCIA
    INSERT INTO liqui_escuela.asistencia(
        fecha_asist, id_empleado, asistencia
    ) SELECT
        dia_asistencia,
        e.id_empleado,
        --
        COALESCE(au.asistencia, 'PRESENTE') AS asistencia
        FROM liqui_escuela.empleado AS e
		LEFT JOIN 
        (SELECT empleado_id
		,		asistencia
        FROM liqui_escuela.ausentismo 
			WHERE fecha = dia_asistencia) AS au
        ON e.id_empleado = au.empleado_id ;
		
END //

DELIMITER ;

-- LLAMADO DEL PROCEDIMIENTO PARA LA INGESTA DEL DÍA ACTUAL 
CALL liqui_escuela.sp_ingesta_presentismo (CURRENT_DATE());
--  LLAMADO DEL PROCEDIMIENTO PARA UNA FECHA ESPECÍFICA
CALL liqui_escuela.sp_ingesta_presentismo ('2024-12-02');

-- ANTE LA NECESIDAD DE CARGA DE ASISTENCIA DE UN PERÍODO COMPRENDIDO ENTRE DOS FECHAS, PARA NO HACERLO DE MANERA MANUAL DÍA POR DÍA
-- SE CREA EL SIGUIENTE PROCEDIMIENTO
-- DENTRO DE ESTE PROCEDIMIENTO SE LLAMA AL PROCEDIMIENTO sp_ingesta_presentismo

DELIMITER //


DROP PROCEDURE IF EXISTS liqui_escuela.sp_pasa_revista_periodo //

CREATE PROCEDURE liqui_escuela.sp_pasa_revista_periodo 
    (	IN inicio_carga DATE
    , 	IN fin_carga DATE)
BEGIN
	-- DECLARACION DE VARIABLE
    DECLARE fecha_carga DATE;
    -- SE SETEA LA FECHA A PROCESAR EN EL PROCEDIMIENTO - FECHA INICIAL  
    SET fecha_carga = inicio_carga;
    -- SE GENERA UN LOOP PARA REALIZAR LA CARGA DEL PERÍODO DECLARADO EN LOS PARÁMETROS 
    WHILE fecha_carga <= fin_carga DO
    CALL liqui_escuela.sp_ingesta_presentismo(fecha_carga);
    -- INCREMENTAMOS UN DIA A LA FECHA DE CARGA    
    SET fecha_carga = DATE_ADD(fecha_carga, INTERVAL 1 DAY);
    END WHILE;
END //

DELIMITER ;

-- LLAMADO DEL PROCEDIMIENTO PARA CARGAR ASISTENCIA EN EL PERÍODO COMPRENDIDO ENTRE EL 01/11/2024 Y EL 30/11/2024
CALL liqui_escuela.sp_pasa_revista_periodo ('2024-11-01', '2024-11-30');
