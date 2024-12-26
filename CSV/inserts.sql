USE liqui_escuela;

-- INSERTS PARA TABLAS

-- inserción en TABLA ESCUELA
INSERT INTO liqui_escuela.escuela
(nombre, numero, categoria, ciudad, nivel) VALUES
('san justo',2698,1,'rosario',1),
('obraje',6589,2,'galvez',2),
('tecnica',4986,1,'rosario',2),
('patricios',5846,3,'rosario',3),
('superior',1236,2,'rosario',1),
('contable',7789,1,'perez',2);

-- inserción en TABLA TIPO_CARGO
INSERT INTO liqui_escuela.tipo_cargo
(id_tipo_cargo, tipo_cargo) VALUES
(1,'cat'),
(2,'cgo');

-- inserción en TABLA AREA
INSERT INTO liqui_escuela.area
(id_area, area_escuela) VALUES
(1,'docentes'),
(2,'asistentes'),
(3,'maestranza');

-- inserción en TABLA SIT_REVISTA
INSERT INTO liqui_escuela.sit_revista 
(id_sit_revista, situacion_revista) VALUES
(1,'titular'),
(3, 'reemplazante'),
(9, 'titular a termino'),
(99, 'tareas diferentes');

-- inserción en TABLA BANCO
INSERT INTO liqui_escuela.banco
(id_banco, nombre_banco) VALUES
(1, 'industrial'),
(2, 'forestal');

-- inserción en TABLA EMPLEADO (modificación de tabla por mejora de datos - se agrega columna apellido y se ordena)
-- ALTER TABLE liqui_escuela.empleado
-- ADD COLUMN apellido VARCHAR (200); 
-- ALTER TABLE liqui_escuela.empleado
-- MODIFY apellido VARCHAR(200) AFTER  nombre,
-- MODIFY COLUMN agremiado BOOLEAN;

-- INSERT REALIZADO VIA IMPORTACIÓN DE CSV (empleado.csv) 1000 empleados

-- *********************************
-- TABLAS CON FORENGN KEY
-- *********************************

-- inserción TABLA CARGO
-- INSERT REALIZADO VIA IMPORTACIÓN DE CSV (cargos.csv) 112 registros generado con Excel > CSV


-- insert TABLA ASISTENCIA
-- PARA CARGAR DATOS EN LA TABLA ASISTENCIA SE UTILIZAN DOS PROCEDIMIENTOS CREADOS PARA TAL FIN
-- ADEMÁS DE ESTO, SE CREÓ UN EVENTO PARA AUTOMATIZAR LA CARGA DIARIA DE ASISTENCIA DÍA POR DÍA


-- inserción en TABLA EMP_CARGO (modificación de tabla por repetición de datos - horas cargo)
ALTER TABLE liqui_escuela.emp_cargo
DROP COLUMN horas_cargo;
-- UNA VEZ BORRADA LA COLUMNA se genera dataset con Mockaroo 100 registros y se importa CSV en Workbench


-- inserción en TABLA COD_EMPLEADO 
-- se insertará en avance del curso. Depende de la liquidación


-- inserción en TABLA INDICE 
INSERT INTO liqui_escuela.indice
(mes,anio,basico,compl_basico) VALUES
(10,2024,274.233,374.566),
(11,2024,295.544,415.852);



-- PARA LA NUEVA TABLA GENERADA, ANTE LA NECESIDAD DE REGISTRO DE INASISTENCIAS, SE CREA LA TABLA AUSENTISMO
-- PARA PODER INGESTAR DATOS, SE GENERA EL SIGUIENTE BLOQUE DE DATOS UTILIZANDO EXCEL > CONCATENACIÓN DE DATOS 
INSERT INTO liqui_escuela.ausentismo
(fecha, empleado_id, motivo, afecta_sueldo) VALUES
('2024-12-1', '588', "enfermedad personal",0),
('2024-12-1', '172', "enfermedad personal",1),
('2024-12-1', '248', "imprevisto",1),
('2024-12-1', '475', "enfermedad personal",1),
('2024-12-1', '617', "imprevisto",1),
('2024-12-2', '155', "imprevisto",1),
('2024-12-2', '661', "imprevisto",1),
('2024-12-2', '936', "imprevisto",1),
('2024-12-2', '655', "imprevisto",1),
('2024-12-2', '859', "imprevisto",1),
('2024-12-3', '282', "imprevisto",1),
('2024-12-4', '633', "imprevisto",1),
('2024-12-4', '291', "imprevisto",1),
('2024-12-4', '714', "imprevisto",1),
('2024-12-4', '458', "imprevisto",1),
('2024-12-4', '827', "imprevisto",1),
('2024-12-4', '304', "imprevisto",1),
('2024-12-4', '407', "imprevisto",1),
('2024-12-4', '989', "imprevisto",1),
('2024-12-5', '818', "accidente de trabajo",0),
('2024-12-5', '605', "accidente de trabajo",0),
('2024-12-5', '1', "accidente de trabajo",0),
('2024-12-5', '853', "accidente de trabajo",0),
('2024-12-5', '855', "accidente de trabajo",0),
('2024-12-6', '484', "accidente de trabajo",0),
('2024-12-6', '888', "accidente de trabajo",0),
('2024-12-6', '951', "enfermedad personal",0),
('2024-12-6', '69', "enfermedad personal",0),
('2024-12-7', '596', "enfermedad personal",0),
('2024-12-7', '957', "enfermedad personal",0),
('2024-12-7', '372', "enfermedad personal",0),
('2024-12-7', '348', "enfermedad personal",0),
('2024-12-8', '837', "enfermedad personal",0),
('2024-12-8', '969', "enfermedad personal",0),
('2024-12-8', '260', "enfermedad personal",0),
('2024-12-8', '418', "enfermedad personal",0),
('2024-12-10', '473', "enfermedad personal",0),
('2024-12-10', '490', "enfermedad personal",0),
('2024-12-10', '419', "enfermedad personal",0),
('2024-12-10', '126', "atencion familiar enfermo",0),
('2024-12-10', '9', "imprevisto",1),
('2024-12-12', '538', "imprevisto",1),
('2024-12-12', '933', "imprevisto",1),
('2024-12-12', '354', "imprevisto",1),
('2024-12-12', '751', "imprevisto",1),
('2024-12-12', '739', "imprevisto",1),
('2024-12-12', '426', "imprevisto",1),
('2024-12-12', '716', "imprevisto",1),
('2024-12-15', '280', "imprevisto",1),
('2024-12-19', '446', "imprevisto",1),
('2024-12-21', '868', "imprevisto",1),
('2024-12-21', '837', "imprevisto",1),
('2024-12-21', '117', "imprevisto",1),
('2024-12-21', '481', "imprevisto",1),
('2024-12-21', '122', "imprevisto",1),
('2024-12-21', '200', "imprevisto",1),
('2024-12-21', '800', "imprevisto",1);


INSERT INTO liqui_escuela.periodos_sueldo(mes_p,anio_p,concepto) VALUES
(10,2024, "SUELDO OCTUBRE 2024"),
(11,2024, "SUELDO NOVIEMBRE 2024"),
(14,2024, "2° CUOTA - S.A.C. 2024");