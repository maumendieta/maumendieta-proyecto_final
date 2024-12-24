-- funcion que calcula la cantidad de horas que tiene un docente
DROP FUNCTION IF EXISTS liqui_escuela.fx_empleado_horas
DELIMITER //
CREATE FUNCTION liqui_escuela.fx_empleado_horas (_dni INT)
	RETURNS INT
    READS SQL DATA
BEGIN
		DECLARE total_horas INT DEFAULT 0;
			SELECT 
			SUM(c.horas) INTO total_horas
			FROM liqui_escuela.emp_cargo AS ec
			LEFT JOIN liqui_escuela.empleado AS e USING (id_empleado)
			LEFT JOIN liqui_escuela.cargo AS c USING (id_cargo)
			WHERE e.dni = _dni
            GROUP BY e.id_empleado;
            RETURN total_horas;
END //
DELIMITER ;


-- MISMA FUNCIÓN QUE ANTES, CON CONTROL DE EXISTENCIA DEL DOCENTE
-- EN CASO DE NO EXISTIR, ARROJA ERROR CON MENSAJE "DOCENTE INEXISTENTE"

DROP FUNCTION IF EXISTS liqui_escuela.fx_empleado_horas
DELIMITER //
CREATE FUNCTION liqui_escuela.fx_empleado_horas (_dni INT)
	RETURNS INT
    READS SQL DATA
BEGIN
-- DECLARACIÓN DE VARIABLES
        DECLARE existencia INT;
        DECLARE total_horas INT;
 -- EXISTENCIA DEL DOCENTE
 SELECT COUNT(e.id_empleado) INTO existencia
	    FROM liqui_escuela.empleado as e
        WHERE e.dni = _dni
        GROUP BY e.id_empleado;
        IF existencia > 0 THEN 
                    SELECT 
                    SUM(c.horas) INTO total_horas
                    FROM liqui_escuela.emp_cargo AS ec
                    LEFT JOIN liqui_escuela.empleado AS e USING (id_empleado)
                    LEFT JOIN liqui_escuela.cargo AS c USING (id_cargo)
                    WHERE e.dni = _dni
                    GROUP BY e.id_empleado;
                    RETURN total_horas;
        ELSE        
                    SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'DOCENTE INEXISTENTE', MYSQL_ERRNO = 1001;
		END IF;             
END //
DELIMITER ;


-- FUNCIÓN para calcular la Antigüedad de cada docente
-- este calculo va a servir para el cálculo del COMPLEMENTO DE ANTIGUEDAD DE LOS SUELDOS
DROP FUNCTION IF EXISTS liqui_escuela.fx_calc_ant;
DELIMITER //
CREATE FUNCTION liqui_escuela.fx_calc_ant (_dni INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE antiguedad INT;
    DECLARE _ingreso DATE;
    SELECT 
		e.fecha_ingreso INTO _ingreso
        FROM liqui_escuela.empleado as e
        WHERE e.dni = _dni;
    IF _ingreso IS NULL THEN
        RETURN NULL;
    END IF;
    SET antiguedad = TIMESTAMPDIFF(YEAR, _ingreso, CURDATE());
    RETURN antiguedad;
END//
DELIMITER ;

-- FUNCIÓN QUE CALCULA EL % DE ANTIGUEDAD USANDO LA FUNCIÓN CREADA ANTERIORMENTE
DROP FUNCTION IF EXISTS liqui_escuela.fx_porc_ant;
DELIMITER //
CREATE FUNCTION liqui_escuela.fx_porc_ant (_dni INT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE antiguedad INT;
    DECLARE porc_ant FLOAT;
    SELECT
		fx_calc_ant(_dni) INTO antiguedad
        FROM liqui_escuela.empleado as e
        WHERE e.dni = _dni;
    CASE 
    WHEN antiguedad =  0 OR antiguedad > 0 AND antiguedad < 5 THEN SET porc_ant = 0.5;
    WHEN antiguedad = 5 OR antiguedad > 5 AND antiguedad < 10 THEN SET porc_ant = 0.75;
    WHEN antiguedad = 10 OR antiguedad > 10 AND antiguedad < 15 THEN SET porc_ant = 1.00;
	WHEN antiguedad = 15 OR antiguedad > 15 AND antiguedad < 20 THEN SET porc_ant = 1.25;
    WHEN antiguedad = 20 OR antiguedad > 20 THEN SET porc_ant = 1.50;
    END CASE;
    RETURN porc_ant;
END//
DELIMITER ;



-- FUNCIÓN QUE DEFINE MOTIVO DE BAJA DE UN EMPLEADO


DELIMITER //
DROP FUNCTION IF EXISTS liqui_escuela.fx_mot_baja//
CREATE FUNCTION liqui_escuela.fx_mot_baja(_mot INT)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE _mot INT;
    DECLARE mot_baja VARCHAR(200);
    CASE 
    WHEN _mot = 1 THEN SET mot_baja = 'renuncia por causas particulares';
    WHEN _mot = 5 THEN SET mot_baja = 'jubilacion art 74 - provincia';
    WHEN _mot = 7 THEN SET mot_baja = 'jubilacion anses';
    WHEN _mot = 99  THEN SET mot_baja = 'fallecimiento';
    END CASE;
    RETURN mot_baja;
END//
DELIMITER ;