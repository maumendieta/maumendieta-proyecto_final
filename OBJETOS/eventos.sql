

-- EVENTO QUE SE CORRE TODOS LOS DIAS PARA CARGA DE ASISTENCIA
-- SE LLAMA AL PROCEDIMIENTO liqui_escuela.sp_ingesta_presentismo
DROP EVENT IF EXISTS liqui_escuela.ev_carga_presentismo;
CREATE EVENT liqui_escuela.ev_carga_presentismo
    ON SCHEDULE
      EVERY 1 DAY
    COMMENT 'PASA REVISTA DIARIAMENTE'
    DO
		CALL liqui_escuela.sp_ingesta_presentismo( CURRENT_DATE());