# PARA LEVANTAR ESTE CONTENEDOR CON EL SERVIDOR DE MYSQL:

docker-compose up --build -d

# ACCEDER AL CONTENEDOR PARA VER LOS DATOS
docker exec -it mysql-server bash

# CREAR LA BASE DE DATOS DESDE EL CODIGO CREADO
docker exec -it mysql-server mysql --verbose -u root -p -e "source /proyecto_sql/estructura.sql;"