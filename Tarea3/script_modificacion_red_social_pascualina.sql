-- =============================================================================
-- INSTITUCIÓN UNIVERSITARIA PASCUAL BRAVO
-- SCRIPT DE MODIFICACIÓN DE BASE DE DATOS (DDL - ALTER / DROP / TRUNCATE)
-- =============================================================================

-- 1.1 Agregar columna de programa académico a la tabla usuario
ALTER TABLE usuario 
ADD COLUMN programa_academico VARCHAR(80) NULL;

-- 1.2 Modificar el tamaño del teléfono para admitir prefijos internacionales
ALTER TABLE usuario 
ALTER COLUMN telefono_usuario TYPE VARCHAR(20);

-- 1.3.1 Crear tabla propuesta de convocatorias (inicialmente vacía)
CREATE TABLE convocatoria ();

-- 1.3.2 Agregar clave primaria y campos iniciales
ALTER TABLE convocatoria 
ADD COLUMN id_convocatoria INT GENERATED ALWAYS AS IDENTITY,
ADD COLUMN titulo_convocatoria VARCHAR(100) NOT NULL,
ADD COLUMN descripcion_convocatoria TEXT NULL,
ADD COLUMN numero_plazas INT NOT NULL,
ADD CONSTRAINT pk_convocatoria PRIMARY KEY (id_convocatoria);

-- 1.3.3 Eliminar columna redundante de descripción
ALTER TABLE convocatoria 
DROP COLUMN descripcion_convocatoria;

-- 1.3.4 Renombrar la tabla a convocatoria_grupo y su clave primaria
ALTER TABLE convocatoria 
RENAME TO convocatoria_grupo;

ALTER TABLE convocatoria_grupo 
RENAME CONSTRAINT pk_convocatoria TO pk_convocatoria_grupo;

-- 1.3.5 Agregar código único de convocatoria
ALTER TABLE convocatoria_grupo 
ADD COLUMN codigo_convocatoria VARCHAR(20) NOT NULL,
ADD CONSTRAINT uk_convocatoria_grupo_codigo UNIQUE (codigo_convocatoria);

-- 1.3.6 Agregar fechas de inicio y fin con restricción CHECK
ALTER TABLE convocatoria_grupo 
ADD COLUMN fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
ADD COLUMN fecha_fin DATE NOT NULL,
ADD CONSTRAINT ck_convocatoria_grupo_fechas CHECK (fecha_fin >= fecha_inicio);

-- 1.3.7 Agregar número de postulados y ajustar restricciones en plazas
ALTER TABLE convocatoria_grupo 
ADD COLUMN numero_postulados INT NOT NULL DEFAULT 0,
ADD CONSTRAINT ck_convocatoria_grupo_postulados CHECK (numero_postulados >= 0);

ALTER TABLE convocatoria_grupo 
ALTER COLUMN numero_plazas TYPE SMALLINT,
ADD CONSTRAINT ck_convocatoria_grupo_plazas CHECK (numero_plazas BETWEEN 1 AND 100);

-- 1.3.8 Ampliar el tamaño del título y crear un índice de consulta
ALTER TABLE convocatoria_grupo 
ALTER COLUMN titulo_convocatoria TYPE VARCHAR(150);

CREATE INDEX ix_convocatoria_grupo_fecha_inicio 
ON convocatoria_grupo (fecha_inicio);

-- 1.3.9 Eliminar la restricción de fechas y la columna fecha_fin
ALTER TABLE convocatoria_grupo 
DROP CONSTRAINT ck_convocatoria_grupo_fechas;

ALTER TABLE convocatoria_grupo 
DROP COLUMN fecha_fin;

-- 1.3.10 Reiniciar datos de la tabla con TRUNCATE
TRUNCATE TABLE convocatoria_grupo RESTART IDENTITY;