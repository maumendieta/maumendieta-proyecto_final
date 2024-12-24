

-- Controla la Incompatibilidad, al supervisar la cantidad de horas activas de un empleado a designar.

DELIMITER //
DROP TRIGGER IF EXISTS liqui_escuela.tg_incomp_emp //

CREATE TRIGGER liqui_escuela.tg_incomp_emp
BEFORE INSERT 
        ON liqui_escuela.emp_cargo
        FOR EACH ROW
BEGIN
    -- Declaración de variables
    DECLARE hs_actuales INT DEFAULT 0;
    DECLARE hs_nuevas INT DEFAULT 0;
    DECLARE msg VARCHAR(255) DEFAULT "El agente, con esta designación, supera el límite de Horas Permitidas";

    -- Obtiene las horas actuales del empleado desde la vista
    SELECT vw.total_hs INTO hs_actuales
    FROM liqui_escuela.vw_horasxemp AS vw
    WHERE vw.id_empleado = NEW.id_empleado;

    -- Obtiene las horas del nuevo cargo al que se designará el empleado
    SELECT c.horas INTO hs_nuevas
    FROM cargo AS c
    WHERE c.id_cargo = NEW.id_cargo;

    -- Verifica si el total de horas supera el límite permitido
    -- si supera el límite, no frena la designación y lanza mensaje de error
    IF hs_actuales + hs_nuevas > 50 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = msg;
    END IF;
END //



-- Este Trigger controla si hay un empleado designado como titular en el cargo para poder designar un reemplazante en el mismo

DELIMITER //
DROP TRIGGER IF EXISTS liqui_escuela.tg_des_reemp //

CREATE TRIGGER liqui_escuela.tg_des_reemp
BEFORE INSERT 
        ON liqui_escuela.emp_cargo
        FOR EACH ROW
BEGIN
    -- Declaración de variables
    DECLARE msg VARCHAR(255) DEFAULT "NO SE PUEDE DESIGNAR REEMPLAZANTE SIN TITULAR DESIGNADO";
    DECLARE _estado_cgo VARCHAR(50);

    -- Obtiene el estado actual del cargo (OCUPADO O VACANTE)
    SELECT vista.estado_cargo INTO _estado_cgo
    FROM liqui_escuela.vw_estado_cargo AS vista
    WHERE vista.id_cargo = NEW.id_cargo;

    -- EN CASO DE QUE EL CARGO ESTE VACANTE, NO SE PODRÁ DESIGNAR REEMPLAZANTE DEVUELVE MENSAJE DE ERROR
    CASE WHEN _estado_cgo LIKE 'vacante' THEN
            IF NEW.id_sit_revista = 3 THEN
                            SIGNAL SQLSTATE '45000' 
                            SET MESSAGE_TEXT = msg;
            END IF;
    END CASE;            
END //            

