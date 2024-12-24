# PROYECTO LIQUIDACIÓN SUELDOS - ESCOLAR # 
## SEGUNDA ENTREGA ##
**MENDIETA, MAURO GERMÁN**
:white_check_mark: *COMISIÓN 59430*

-****Anderson Michel TORRES*** *(Profesor)*
-****Hugo Gonzalez*** *(Tutor Regular CoderAsk)*
-****Nicolás Maugeri*** *(Tutor Adjunto CoderAsk)*

## TRABAJO REALIZADO

En la presente entrega se presenta el desarrollo de inserción de datos en las tablas creadas la primer entrega de la base de datos LIQUI_ESCUELA.
Además se explica el desarrollo de los objetos que comienzan a conformar el Proyecto.

La entrega está organizada en Carpetas, para poder organizar el trabajo realizado. 
Por un lado se encuentra la carpeta `Inserts` que contiene los Script de inserción y los archivos `.CSV` que se utilizaron para la carga.
Por otro lado se presenta la carpeta `Objetos`, la cual contiene los scripts de creación de Triggers, Procedimientos, Vistas y Funciones.

## 📂OBJETOS

### :clipboard: VISTAS
Este repositorio contiene definiciones de vistas SQL diseñadas para facilitar la gestión de empleados, cargos y su relación con otras entidades dentro de un sistema escolar. 
Para la combinación de tablas se utilizaron JOINS.

### 1. EMPLEADO POR BANCO: `vw_empleadoxbanco`

**Descripción:**  
Lista a los empleados agrupados por el banco en el que tienen su cuenta. Incluye información detallada como sucursal y número de cuenta.  

**Campos:**  
- `nombre_completo`: Nombre completo del empleado (`Apellido, Nombre`).  
- `dni`: Documento Nacional de Identidad del empleado.  
- `nombre_banco`: Nombre del banco asociado.  
- `sucursal_banco`: Sucursal del banco.  
- `cuenta_banco`: Número de cuenta bancaria.  


### 2. CANTIDAD DE HORAS POR EMPLEADO: `vw_horasxemp`  

**Descripción:**  
Calcula el total de horas asignadas a cada empleado en sus cargos. 

**Campos:**
- `id_empleado`: Identificador único del empleado.
- `dni`: Documento del empleado.
- `nombre_completo`: Nombre completo del empleado.
- `total_hs`: Total de horas asignadas.


### 3. ESTADO ACTUAL DEL CARGO: `vw_estado_cargo`    

**Descripción:**    
Muestra el estado de cada cargo (OCUPADO o VACANTE) y su relación con empleados, junto con detalles adicionales sobre las horas y la denominación del cargo.

**Campos:**
- `id_empleado`: Identificador único del empleado.
- `nombre_completo`: Nombre del empleado.
- `dni`: Documento del empleado.
- `id_cargo`: Identificador único del cargo.
- `denominacion`: Denominación del cargo.
- `horas`: Cantidad de horas asociadas al cargo.
- `estado_cargo`: Estado del cargo (OCUPADO o VACANTE).


### 4. EMPLEADOS POR AREA: `vw_empleadoxarea`

**Descripción:**    
Lista empleados según el área en la que trabajan, agrupados por las escuelas a las que pertenecen.

**Campos:**    
- `nombre_completo`: Nombre completo del empleado.
- `area_escuela`: Nombre del área de trabajo.
- `escuela`: Nombre de la escuela asociada al área.

---
  
### :clipboard: TRIGGERS
### 1. VERIFICADOR DE INCOMPATIBILIDAD: `tg_incomp_emp`  

**Descripción:**  
Este trigger controla la incompatibilidad horaria al supervisar la cantidad de horas activas de un empleado antes de asignar un nuevo cargo.
Si el total de horas (actuales + nuevas) supera el límite permitido (50 horas), se bloquea la inserción y se lanza un mensaje de error.

**Eventos:**  
`Tabla: emp_cargo`
Momento: `BEFORE INSERT`  

**Lógica:**  
Calcula las horas actuales del empleado desde la vista vw_horasxemp.
Obtiene las horas asociadas al nuevo cargo (NEW.id_cargo).
Verifica si el total de horas supera las 50.
Si el límite es excedido, genera un error con el mensaje: `"El agente, con esta designación, supera el límite de Horas Permitidas".`

**Uso:**    
Este trigger garantiza que un empleado no exceda las horas máximas asignadas al momento de ser designado en un nuevo cargo.

### 2. INSPECCIONA LA DESIGNACION DE UN REEMPLAZANTE: `tg_des_reemp`

**Descripción:**  
Este trigger impide la designación de un reemplazante en un cargo si no hay un titular previamente asignado.

**Eventos:**  
`Tabla: emp_cargo`  
Momento: `BEFORE INSERT`  

**Lógica:**  
Obtiene el estado actual del cargo desde la vista vw_estado_cargo.
Los estados posibles son: `"vacante"` o `"ocupado"`.
Si el cargo está marcado como "vacante" y el tipo de designación (id_sit_revista) corresponde a un reemplazante (3):
Se bloquea la inserción.
Se lanza un mensaje de error: `"NO SE PUEDE DESIGNAR REEMPLAZANTE SIN TITULAR DESIGNADO"`.  

**Uso:**   
Este trigger asegura la consistencia en la gestión de cargos, garantizando que los reemplazantes solo puedan ser asignados a cargos ocupados por titulares.

---

### :clipboard: STORE PROCEDURES

## 📜 PROCEDIMIENTO - BUSCA EMPLEADO: `pd_busca_empleado`

### Descripción
Este procedimiento busca el ID de un empleado en la tabla `empleado` utilizando su DNI como referencia. Es útil como paso intermedio en otras operaciones que requieren el `id_empleado` para actualizar o consultar información relacionada.

### Parámetros
- **Entrada (`emp_dni`)**: DNI del empleado que se desea buscar. *(Tipo: `INT`)*  
- **Salida (`emp_id`)**: ID del empleado encontrado. *(Tipo: `INT`)*  

### Funcionamiento
1. Realiza una consulta en la tabla `empleado` para encontrar el registro que coincida con el DNI proporcionado.  
2. Si se encuentra un empleado con el DNI especificado, su `id_empleado` se asigna a la variable de salida `emp_id`.  
3. En caso de no encontrar un resultado, `emp_id` no será modificado (puede ser manejado por lógica externa).


## 📜 PROCEDIMIENTO - BAJA EMPLEADO: `pd_baja_empleado`

### Descripción
Este procedimiento actualiza la fecha de baja y agrega un motivo detallado en el registro de un empleado en la tabla `empleado`. Utiliza la función `fx_mot_baja` para determinar el texto descriptivo del motivo de baja y el procedimiento `pd_busca_empleado` para localizar al empleado por su DNI.

### Parámetros de Entrada
- `emp_dni` *(INT)*: El Documento Nacional de Identidad del empleado a dar de baja.  
- `baja` *(DATE)*: La fecha en que se dará de baja al empleado.  
- `motivo` *(INT)*: Código numérico que representa el motivo de la baja.  
 `pd_busca_empleado`**: Busca al empleado y devuelve su ID mediante una variable de salida.  

### Funcionamiento
1. Llama al procedimiento `pd_busca_empleado` para localizar el `id_empleado` asociado al DNI proporcionado.  
2. Usa la función `fx_mot_baja` para obtener el motivo textual basado en el código proporcionado.  
3. Actualiza el registro del empleado en la tabla `empleado`, estableciendo:
   - La fecha de baja (`fecha_baja`).
   - El motivo descriptivo en el campo `observaciones`.

--- 

### :clipboard: FUNCTIONS - Funciones Incluidas 

### 1. CALCULA LA CANTIDAD DE HORAS POR EMPLEADO: `fx_empleado_horas`      
**Descripción:**             
      - Calcula la cantidad total de horas asignadas a un docente según su número de documento (DNI).        

**Parámetros:**                  
      - `_dni` (`INT`): Número de documento del docente.        

**Devuelve:**                    
      - Total de horas (`INT`).        

**Control de errores:**                    
      - Si el docente no existe, lanza un error con el mensaje: `"DOCENTE INEXISTENTE"`.      


### 2. CALCULA ANTIGUEDAD DEL EMPLEADO: `fx_calc_ant`      
**Descripción:**          
    - Calcula la antigüedad en años de un docente a partir de su fecha de ingreso.      

**Parámetros:**          
    - _dni (`INT`): Número de documento del docente.      

**Devuelve:**          
    - Antigüedad en años (`INT`).      

**Notas:**          
    - Si no hay fecha de ingreso registrada, devuelve `NULL`.      


### 3. PORCENTAJE DE ANTIGUEDAD: `fx_porc_ant`      
**Descripción:**      
      - Calcula el porcentaje de antigüedad aplicable al sueldo de un docente, basado en su antigüedad.      

**Parámetros:**            
      _dni (INT): Número de documento del docente.            

**Devuelve:** Porcentaje de antigüedad (FLOAT).      
      Escala de porcentajes:      
                   / ***0 a 5 años: 0.5%***      
                   / ***5 a 10 años: 0.75%***      
                   / ***10 a 15 años: 1.0%***      
                   / ***15 a 20 años: 1.25%***      
                   / ***Más de 20 años: 1.5%***      

### 4. MOTIVO DE BAJA: `fx_mot_baja`
**Descripción:**      
      - Devuelve una descripción textual del motivo de baja de un docente según un código numérico.    

**Parámetros:**      
      - _mot (INT): Código del motivo de baja.      

**Devuelve:**      
Descripción del motivo (VARCHAR(200)).      