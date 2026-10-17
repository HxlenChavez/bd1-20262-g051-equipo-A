-- =============================================================================
-- INSTITUCIÓN UNIVERSITARIA PASCUAL BRAVO
-- SCRIPT DE MODIFICACIÓN DE LA BASE DE DATOS (DDL)
-- =============================================================================

--
-- Modificación de Tablas
-- 

--
-- 1.1.- Agregar un campo a la tabla de usuarios de la red social
--
ALTER TABLE usuario 
ADD COLUMN programa_academico VARCHAR(80) NULL;


--
-- 1.2.- Modificar un campo de la tabla de usuarios
--
ALTER TABLE usuario 
ALTER COLUMN telefono_usuario TYPE VARCHAR(20);


--
-- Gestionar una tabla "nueva"
-- 

-- 1.3.1
-- Crear una tabla "nueva" de su iniciativa (una tabla coherente con el sistema con su nombre, no coloque "nueva" como nombre)
--
CREATE TABLE convocatoria ();


-- 1.3.2
-- Agregar una clave primaria y otros 3 campos cualquiera a la tabla "nueva"
-- Mínimo un campo tipo texto y uno numérico
--
ALTER TABLE convocatoria 
ADD COLUMN id_convocatoria INT GENERATED ALWAYS AS IDENTITY,
ADD COLUMN titulo_convocatoria VARCHAR(100) NOT NULL,
ADD COLUMN descripcion_convocatoria TEXT NULL,
ADD COLUMN numero_plazas INT NOT NULL,
ADD CONSTRAINT pk_convocatoria PRIMARY KEY (id_convocatoria);


-- 1.3.3
-- Quitar uno de los campos de la tabla "nueva"
--
ALTER TABLE convocatoria 
DROP COLUMN descripcion_convocatoria;


-- 1.3.4
-- Cambiar el nombre de la tabla "nueva" a otro nombre "otro_nombre"
-- Todas las operaciones siguientes se realizan sobre la tabla renombrada
--
ALTER TABLE convocatoria 
RENAME TO convocatoria_grupo;

ALTER TABLE convocatoria_grupo 
RENAME CONSTRAINT pk_convocatoria TO pk_convocatoria_grupo;


-- 1.3.5 
-- Agregar un campo único a la tabla 
--
ALTER TABLE convocatoria_grupo 
ADD COLUMN codigo_convocatoria VARCHAR(20) NOT NULL,
ADD CONSTRAINT uk_convocatoria_grupo_codigo UNIQUE (codigo_convocatoria);


-- 1.3.6
-- Agregar 2 fechas de inicio y fin; y colocar un control de orden de fechas
--
ALTER TABLE convocatoria_grupo 
ADD COLUMN fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
ADD COLUMN fecha_fin DATE NOT NULL,
ADD CONSTRAINT ck_convocatoria_grupo_fechas CHECK (fecha_fin >= fecha_inicio);


-- 1.3.7
-- Agregar 1 campo entero y colocar un control para que no sea negativo
--
ALTER TABLE convocatoria_grupo 
ADD COLUMN numero_postulados INT NOT NULL DEFAULT 0,
ADD CONSTRAINT ck_convocatoria_grupo_postulados CHECK (numero_postulados >= 0);


-- 1.3.8
-- Modificar el tamaño de un campo texto de la tabla renombra
--
ALTER TABLE convocatoria_grupo 
ALTER COLUMN titulo_convocatoria TYPE VARCHAR(150);


-- 1.3.7 (reiteración en plantilla)
-- Modificar el campo numeríco y colocar un control de rango 
--
ALTER TABLE convocatoria_grupo 
ALTER COLUMN numero_plazas TYPE SMALLINT,
ADD CONSTRAINT ck_convocatoria_grupo_plazas CHECK (numero_plazas BETWEEN 1 AND 100);


-- 1.3.8 (reiteración en plantilla)
-- Agregar un índice a la tabla (cualquier campo)
--
CREATE INDEX ix_convocatoria_grupo_fecha_inicio 
ON convocatoria_grupo (fecha_inicio);


--
-- 1.3.9 
-- Eliminar una de las fechas
--
ALTER TABLE convocatoria_grupo 
DROP CONSTRAINT ck_convocatoria_grupo_fechas;

ALTER TABLE convocatoria_grupo 
DROP COLUMN fecha_fin;


-- 1.3.10
-- Borrar todos los datos de una tabla sin dejar traza
--
TRUNCATE TABLE convocatoria_grupo RESTART IDENTITY;