USE liqui_escuela;

-- CREACION DE ROL DE ADMINISTRADOR CON ACCESO Y PERMISOS TOTALES
CREATE ROLE admin_liqui;
GRANT ALL PRIVILEGES ON liqui_escuela.* TO admin_liqui;

-- CREACION DE ROL DE CONSULTA CON ACCESO LIMITADO A SELECT
CREATE ROLE consulta_liqui;
GRANT SELECT ON liqui_escuela.* TO consulta_liqui;

-- CREACION DE USUARIO DE GESTION DE BASE CON PERSMISOS DE UPDATE (NO TIENE PERMITIDO BORRAR)
CREATE ROLE gestion_liqui;
GRANT SELECT, UPDATE ON liqui_escuela.* TO gestion_liqui;
GRANT INSERT ON liqui_escuela.* TO gestion_liqui;

-- CREACION DE USUARIO CON PERMISOS PARA CREAR OTROS USUARIOS
CREATE USER 'director'
-- DEFINICION DE PASSWORD DE ACCESO DEL USUARIO
IDENTIFIED BY 'escuela87';
-- DESIGNACION DE ROL
GRANT 'admin_liqui' TO 'director';
-- SE LE DA ACCESO TOTAL COMO ADMINISTRADOR A TODAS LAS BASES PORQUE ES LA ÚNICA MANERA DE GENEREAR PERMISOS DE CREACIÓN DE USUARIO (GLOBAL)
GRANT ALL ON *.* to 'director' WITH GRANT OPTION;
FLUSH PRIVILEGES;



-- CREACION DE USUARIO DESDE LA TERMINAL DESDE EL USUARIO 'director'

-- PS C:\****> mysql -u director -p
-- Enter password: *********
-- Welcome to the MySQL monitor.  Commands end with ; or \g.
-- Your MySQL connection id is 48
-- Server version: 8.0.39 MySQL Community Server - GPL

-- Copyright (c) 2000, 2024, Oracle and/or its affiliates.

-- Oracle is a registered trademark of Oracle Corporation and/or its
-- affiliates. Other names may be trademarks of their respective
-- owners.

-- Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

-- mysql> use liqui_escuela;
-- Database changed
-- mysql> create user 'secretario' identified by 'secre2234';
-- Query OK, 0 rows affected (0.01 sec)

-- mysql> grant 'gestion_liqui' to 'secretario';
-- Query OK, 0 rows affected (0.00 sec)
