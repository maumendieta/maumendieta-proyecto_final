-- PROCEDIMIENTO DESTINADO A BUSCAR EMPLEADOS DENTRO DE UNA TABLA
-- USA DOS VARIABLES DNI(ENTRADA) Y EMP_ID (SALIDA) 
DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.pd_busca_empleado;
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
-- PRUEBA FUNCIONAMIENTO 
-- SET @salida = 0;
-- call liqui_escuela.pd_busca_empleado (22052810,@salida);
-- select @salida from DUAL; 
-- CORRECTO


-- PROCEDIMIENTO DESTINADO A REGISTAR BAJAS DE EMPLEADOS
-- SE BASA EN TRES VARIABLES: DNI, FECHA Y MOTIVO (ENTRADAS)
DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.pd_baja_empleado_sinfx;
CREATE PROCEDURE liqui_escuela.pd_baja_empleado_sinfx( 
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
-- PRUEBA FUNCIONAMIENTO
-- call liqui_escuela.pd_baja_empleado_sinfx (22052810,'2024-06-22',1); 
-- CORRECTO


-- MISMA FUNCIÓN QUE LA ANTERIOR + USO DE FUNCIÓN INTERNAMENTE PARA DETERMINAR MOTIVO DE BAJA
DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.pd_baja_empleado;
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
-- PRUEBA FUNCIONAMIENTO
-- CALL liqui_escuela.pd_baja_empleado(34646462,'2024-09-14',1);
-- SELECT * FROM liqui_escuela.empleado
-- WHERE dni=34646462;
-- OK



--  PROCEDIMIENTO DE INGESTA DE PRESENTISMO
DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.sp_ingesta_presentismo ;
CREATE PROCEDURE liqui_escuela.sp_ingesta_presentismo (IN dia_asistencia DATE)
BEGIN
-- BORRA UN REGISTRO DE DÍA ANTERIOR - PARA QUE NO HAYAN DUPLICADOS EN LA TABLA ASISTENCIA
-- LA CONFIGURACIÓN PREDETERMINADA DE MY SQL NO PERMITE BORRAR DATOS DE UNA TABLA RELACIONADA, POR ESTE MOTIVO
-- SE MODIFICA EL SETEO DEL SQL_SAFE_UPDATES. LUEGO DEL DELETE SE VUELVE A ACTIVAR, POR SEGURIDAD.
	SET SQL_SAFE_UPDATES = 0;
    DELETE FROM liqui_escuela.asistencia
        WHERE fecha = dia_asistencia;
	SET SQL_SAFE_UPDATES = 1;
-- INSERCIÓN EN TABLA ASISTENCIA
    INSERT INTO liqui_escuela.asistencia(
        fecha, id_empleado, asistencia
    ) SELECT
        dia_asistencia,
        e.id_empleado,
        -- SE UTILIZA LA FUNCIÓN COALESCE PARA EVITAR TENER NULOS - DEVUELVE "PRESENTE" COMO VALOR PREDETERMINADO
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
-- -- LLAMADO DEL PROCEDIMIENTO PARA LA INGESTA DEL DÍA ACTUAL 
-- CALL liqui_escuela.sp_ingesta_presentismo (CURRENT_DATE());
-- --  LLAMADO DEL PROCEDIMIENTO PARA UNA FECHA ESPECÍFICA
-- CALL liqui_escuela.sp_ingesta_presentismo ('2024-12-02');



-- ANTE LA NECESIDAD DE CARGA DE ASISTENCIA DE UN PERÍODO COMPRENDIDO ENTRE DOS FECHAS, PARA NO HACERLO DE MANERA MANUAL DÍA POR DÍA
-- SE CREA EL SIGUIENTE PROCEDIMIENTO
-- DENTRO DE ESTE PROCEDIMIENTO SE LLAMA AL PROCEDIMIENTO sp_ingesta_presentismo
DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.sp_pasa_revista_periodo ;
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
-- -- LLAMADO DEL PROCEDIMIENTO PARA CARGAR ASISTENCIA EN EL PERÍODO COMPRENDIDO ENTRE EL 01/11/2024 Y EL 30/11/2024
-- CALL liqui_escuela.sp_pasa_revista_periodo ('2024-11-01', '2024-11-30');




-- PROCEDIMIENTO PARA GENERAR SUELDOS EN BASE A LA TABLA emp_cargo

DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.sp_generar_sueldos;
CREATE PROCEDURE liqui_escuela.sp_generar_sueldos(
    IN sp_mes INT
,   IN sp_anio INT)

BEGIN
-- DECLARACIÓN DE VARIABLES
    DECLARE done INT DEFAULT 0;
    DECLARE _puntaje INT;
    DECLARE _id_emp_cargo INT;
    DECLARE _basico DECIMAL(10,2);
    DECLARE _basico_ref DECIMAL(10,4);
    DECLARE _antig DECIMAL(10,2);
    DECLARE _antig_ref DECIMAL(10,2);
    DECLARE _comp_bas DECIMAL (10,2);
    DECLARE _comp_bas_ref DECIMAL (10,4);
    DECLARE _sueldo DECIMAL (10,4);
    DECLARE _id_indice INT;

-- COMIENZA A BARRER CADA REGISTRO DE LA TAMBLA emp_cargo
-- SE UTILIZA CURSOR PARA PODER BARRER TODOS LOS DATOS DE LA TABLA emp_cargo Y GENERAR UN SUELDO POR CADA REGISTRO DE ESA TABLA.
DECLARE emp_cursor CURSOR FOR
        SELECT ec.id_emp_cargo, c.puntaje
        FROM liqui_escuela.emp_cargo as ec
        LEFT JOIN liqui_escuela.cargo as c
        USING (id_cargo);     
-- LA SIGUIENTE DECLARACIÓN INSPECCIONA SI QUEDAN DATOS PARA BARRER EN LA TABLA emp_cargo
-- LUEGO DEL ÚLTIMO REGISTRO, SETEA LA variable done en 1 y cierra el BUCLE.
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

-- SETEO DE VARIABLES COMUNES A TODOS LOS REGISTROS
-- SETEO DEL VALOR REFERENCIA DEL id_indice SEGÚN PERÍODO (ESTO ES IGUAL PARA TODOS LOS REGISTROS)
SET _id_indice = (SELECT id_indice FROM indice WHERE mes = sp_mes AND anio = sp_anio);
-- SETEO DEL VALOR REFERENCIA DEL BASICO SEGÚN PERÍODO (ESTO ES IGUAL PARA TODOS LOS REGISTROS)
SET _basico_ref = (SELECT basico FROM indice WHERE mes = sp_mes AND anio = sp_anio);
-- SETEO DEL VALOR REFERENCIA DEL COMPLEMENTO AL BASICO SEGÚN PERÍODO (ESTO ES IGUAL PARA TODOS LOS REGISTROS)
SET _comp_bas_ref = (SELECT compl_basico FROM indice WHERE mes = sp_mes AND anio = sp_anio);

-- ABRE EL CURSOR
    OPEN emp_cursor;
-- BUCLE QUE RELEVA LOS DATOS DE CADA emp_cargo
    read_loop: LOOP
        FETCH emp_cursor INTO _id_emp_cargo, _puntaje;
        IF done THEN
            LEAVE read_loop;
        END IF;
-- SETEADO DE LA REFERENCIA POR ANTIGUEDAD SEGÚN CADA EMPLEADO
    SET _antig_ref = (SELECT liqui_escuela.fx_porc_ant(
                    (SELECT dni 
                    FROM emp_cargo
                    LEFT JOIN empleado USING (id_empleado)
                    WHERE id_emp_cargo = _id_emp_cargo))
            );        
        -- CALCULO DEL BÁSICO
        SET _basico = _puntaje * _basico_ref;
        -- CALCULO DE ANTIGUEDAD
        SET _antig = _basico * _antig_ref;        
        -- CALCULO DE COMPLEMENTO AL BÁSICO:
        IF _puntaje > 50 THEN
        SET  _comp_bas = _comp_bas_ref;
        ELSE SET _comp_bas = 0;
        END IF;
        -- CALCULO SUELDO FINAL
        SET _sueldo = (_basico + _antig + _comp_bas);
-- INSERCIÓN FINAL EN LA TABLA cod_empleado
        INSERT INTO liqui_escuela.cod_empleado (id_emp_cargo, id_indice, calculo)
        VALUES (_id_emp_cargo, _id_indice, _sueldo);        
    END LOOP;
-- CIERRA EL CURSOR
    CLOSE emp_cursor;
END//
DELIMITER ;

-- PRUEBA DE FUNCIONAMIENTO OK



-- CARGA LOS DATOS DE SUELDOS POR PERÍODOS EN LA TABLA SUELDOS - AGRUPADO POR PERSONA Y PERIODO
DELIMITER //
DROP PROCEDURE IF EXISTS liqui_escuela.carga_sueldos_periodo ;
CREATE PROCEDURE liqui_escuela.carga_sueldos_periodo 
    (	IN s_mes INT
    , 	IN s_anio INT)
BEGIN
	-- DECLARACION DE VARIABLE
    DECLARE ind_ref INT;
    -- SE SETEA LA FECHA A PROCESAR EN EL PROCEDIMIENTO - FECHA INICIAL  
    SET ind_ref = 
		(SELECT id_indice FROM liqui_escuela.indice 
			WHERE mes = s_mes AND anio = s_anio LIMIT 1);
    INSERT INTO liqui_escuela.sueldo (id_banco, monto, id_indice, id_empleado)
		SELECT banco, monto, indice, empleado
		FROM liqui_escuela.vw_sueldo_periodo_x_empleado
		WHERE indice = ind_ref;
END //
DELIMITER ;