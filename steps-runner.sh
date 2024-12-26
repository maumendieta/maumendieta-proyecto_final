# PARA LEVANTAR EL CONTENEDOR CONECTADO AL SERVIDOR DE MYSQL:

docker-compose up --build -d

# ACCEDER AL CONTENEDOR PARA VER LOS DATOS
docker exec -it mysql-server bash

# CREAR LA BASE DE DATOS DESDE EL CODIGO CREADO
docker exec -it mysql-server mysql --verbose -u root -p -e "source /proyecto_sql/estructura.sql;"

# GENERAR UNA QUERY POR CODIGO - DOCKER
docker exec -it mysql-server mysql -u root -p -e "SHOW TABLES FROM liqui_escuela;"

# LEVANTAR PRIMERA PARTE DEL PROYECTO
docker exec -it -e MYSQL_PWD="liquimgm" mysql-server \
mysql \
--verbose \
-u root \
-e "\
DROP DATABASE IF EXISTS liqui_escuela;
source proyecto_sql/estructura.sql; "

# INTENTO DE REALIZAR LA CARGA DEL ARCHIVO .CSV MEDIANTE DOCKER.
# CON ESTE COMANDO SE HABILITA EL local_infile en MYSQL, que habilitaría la carga del ARCHIVO CSV
docker exec -it -e MYSQL_PWD="liquimgm" mysql-server \
mysql \
--verbose \
-u root \
-e "SET GLOBAL local_infile = 1;"

# CON ESTE COMANDO SE EJECUTARÍA LA IMPORTACIÓN DEL ARCHIVO CSV (GUARDADO EN EL CONTENEDOR) A LA TABLA EXISTENTE EN LA BASE DE DATOS
docker exec -it -e MYSQL_PWD="liquimgm" mysql-server \
mysql \
--verbose \
-u root \
-e " \
SET GLOBAL local_infile = 1; \
LOAD DATA LOCAL INFILE '/CSV/empleado.csv' \
INTO TABLE liqui_escuela.empleado \
FIELDS TERMINATED BY ',' \
IGNORE 1 LINES;"
# ERROR 2068 (HY000) at line 1: LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.


# 1- SE IMPORTA EMPLEADO.CSV DESDE MYSQL WORKBENCH, LUEGO SE CONTINÚA CON LA CARGA DEL PROYECTO

# SEGUNDA PARTE DE CARGA DE PROYECTO
docker exec -it -e MYSQL_PWD="liquimgm" mysql-server \
mysql \
--verbose \
-u root \
-e "\
source proyecto_sql/CSV/inserts.sql; "\

# 2- SE IMPORTA CARGO.CSV DESDE MYSQL WORKBENCH, LUEGO SE CONTINÚA CON LA CARGA DEL PROYECTO
# 3- SE IMPORTA EMP_CARGO.CSV DESDE MYSQL WORKBENCH, LUEGO SE CONTINÚA CON LA CARGA DEL PROYECTO


# TERCERA PARTE DE CARGA DE PROYECTO
docker exec -it -e MYSQL_PWD="liquimgm" mysql-server \
mysql \
--verbose \
-u root \
-e "\
source proyecto_sql/OBJETOS/funciones.sql; \
source proyecto_sql/OBJETOS/procedimientos.sql; \
source proyecto_sql/OBJETOS/triggers.sql; "\

# CUARTA PARTE DE CARGA DE PROYECTO
docker exec -it -e MYSQL_PWD="liquimgm" mysql-server \
mysql \
--verbose \
-u root \
-e "\
source proyecto_sql/OBJETOS/vistas.sql; \
source proyecto_sql/OBJETOS/eventos.sql; "


#   QUINTA PARTE DE CARGA DE PROYECTO
docker exec -it -e MYSQL_PWD="liquimgm" mysql-server \
mysql \
--verbose \
-u root \
-e "\
source proyecto_sql/OBJETOS/procedimientos_tcl.sql; \
source proyecto_sql/OBJETOS/usuarios.sql; "

# CARGA COMPLETA VERIFICADA OK - SIN ERRORES - :)

# PARA DAR DE BAJA LA BASE DE DATOS
docker compose  down

