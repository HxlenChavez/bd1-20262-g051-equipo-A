-- ==============================================================================
-- Experiencia de Aprendizaje 4 (EA4) - Equipo A
-- Scripts de Modificación de la Base de Datos - SGBD PostgreSQL (JSONB)
-- Archivo: 20262-bd1-ea4-equipo-A-scripts-01-postgre-mod-02.sql
-- ==============================================================================

-- 1. INSERTAR REGISTROS BASE EN LAS TABLAS PADRE
INSERT INTO rol (nombre_rol, descripcion_rol) 
VALUES ('Estudiante', 'Usuario estudiante') 
ON CONFLICT (nombre_rol) DO NOTHING;

INSERT INTO tipo_usuario (nombre_tipo_usuario, descripcion_tipo_usuario) 
VALUES ('Estudiante', 'Tipo de usuario estudiante') 
ON CONFLICT (nombre_tipo_usuario) DO NOTHING;

-- Insertar usuarios de prueba (usando los nombres reales de las columnas)
INSERT INTO usuario (id_tipo_usuario, id_rol, numero_documento, nombres_usuario, apellidos_usuario, correo_electronico)
VALUES 
(1, 1, '1000000001', 'Helen', 'Chavez', 'helen.chavez@pascualbravo.edu.co'),
(1, 1, '1000000002', 'Emanuel', 'Perez', 'emanuel.perez@pascualbravo.edu.co')
ON CONFLICT (numero_documento) DO NOTHING;

-- Insertar tipo de evento y evento de prueba
INSERT INTO tipo_evento (id_usuario_registra, nombre_tipo_evento, descripcion_tipo_evento)
VALUES (1, 'Académico', 'Eventos académicos')
ON CONFLICT (nombre_tipo_evento) DO NOTHING;

INSERT INTO evento (id_usuario_organizador, id_tipo_evento, nombre_evento, descripcion_evento, fecha_inicio, fecha_fin, lugar_evento)
VALUES (1, 1, 'Feria de Tecnología Pascualina', 'Exposición de proyectos de software e IoT', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '4 hours', 'Auditorio Bloque 25');

-- 2. AGREGAR COLUMNAS JSONB
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS perfil_extendido JSONB;
ALTER TABLE evento ADD COLUMN IF NOT EXISTS metricas_iot JSONB;

-- 3. ACTUALIZAR CON DATOS SEMI-ESTRUCTURADOS (JSONB)
UPDATE usuario 
SET perfil_extendido = '{
    "intereses": ["Programación Web", "Inteligencia Artificial", "Bases de Datos"],
    "habilidades": [
        {"nombre": "Python", "nivel": "Avanzado"},
        {"nombre": "SQL", "nivel": "Intermedio"}
    ]
}'::jsonb
WHERE id_usuario = 1;

UPDATE evento 
SET metricas_iot = '{
    "geolocalizacion": {
        "latitud": 6.2758,
        "longitud": -75.5889,
        "lugar": "Auditorio Bloque 25 - Pascual Bravo"
    },
    "sensores_ambientales": {
        "temperatura_celsius": 22.5,
        "humedad_porcentaje": 60,
        "nivel_ruido_db": 68.4
    }
}'::jsonb
WHERE id_evento = 1;

-- 4. CONSULTA DE VERIFICACIÓN CON DATOS REALES (Muestra los resultados)
SELECT id_evento, nombre_evento, 
       metricas_iot -> 'geolocalizacion' ->> 'lugar' AS ubicacion,
       (metricas_iot -> 'sensores_ambientales' ->> 'temperatura_celsius')::numeric AS temp_celsius
FROM evento
WHERE metricas_iot IS NOT NULL;