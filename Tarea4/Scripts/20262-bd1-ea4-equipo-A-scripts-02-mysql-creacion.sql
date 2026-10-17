-- =============================================================================
-- INSTITUCIÓN UNIVERSITARIA PASCUAL BRAVO
-- BASE DE DATOS I - RED SOCIAL PASCUALINA
-- SCRIPT DE CREACIÓN DE BASE DE DATOS (DDL) - MYSQL 8.0 / MYSQL WORKBENCH
-- Archivo: 20262-bd1-ea4-equipo-A-scripts-02-mysql-crea.sql
-- =============================================================================

-- CREACIÓN Y USO DE LA BASE DE DATOS
DROP DATABASE IF EXISTS red_social_pascualina;
CREATE DATABASE red_social_pascualina CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE red_social_pascualina;

-- LIMPIEZA PREVIA DE TABLAS (En orden inverso de dependencias)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS participacion_evento;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS tipo_evento;
DROP TABLE IF EXISTS compra_producto;
DROP TABLE IF EXISTS producto;
DROP TABLE IF EXISTS tipo_producto;
DROP TABLE IF EXISTS calificacion;
DROP TABLE IF EXISTS solicitud_servicio;
DROP TABLE IF EXISTS servicio;
DROP TABLE IF EXISTS tipo_servicio;
DROP TABLE IF EXISTS notificacion;
DROP TABLE IF EXISTS mensaje;
DROP TABLE IF EXISTS reaccion;
DROP TABLE IF EXISTS comentario;
DROP TABLE IF EXISTS publicacion;
DROP TABLE IF EXISTS usuario_sigue_usuario;
DROP TABLE IF EXISTS grupo_usuario;
DROP TABLE IF EXISTS perfil;
DROP TABLE IF EXISTS grupo;
DROP TABLE IF EXISTS cuenta;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS tipo_usuario;
DROP TABLE IF EXISTS rol;
SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- BLOQUE 1: CATÁLOGOS INDEPENDIENTES (Sin Claves Foráneas)
-- =============================================================================

-- 1. TABLA: rol
CREATE TABLE rol (
    id_rol SMALLINT AUTO_INCREMENT,
    nombre_rol VARCHAR(30) NOT NULL,
    descripcion_rol VARCHAR(255) NULL,
    estado_rol BOOLEAN NOT NULL DEFAULT true,
    
    CONSTRAINT pk_rol PRIMARY KEY (id_rol),
    CONSTRAINT uk_rol_nombre UNIQUE (nombre_rol)
) ENGINE=InnoDB;

-- 2. TABLA: tipo_usuario
CREATE TABLE tipo_usuario (
    id_tipo_usuario SMALLINT AUTO_INCREMENT,
    nombre_tipo_usuario VARCHAR(40) NOT NULL,
    descripcion_tipo_usuario VARCHAR(255) NULL,
    estado_tipo_usuario BOOLEAN NOT NULL DEFAULT true,
    
    CONSTRAINT pk_tipo_usuario PRIMARY KEY (id_tipo_usuario),
    CONSTRAINT uk_tipo_usuario_nombre UNIQUE (nombre_tipo_usuario)
) ENGINE=InnoDB;


-- =============================================================================
-- BLOQUE 2: ENTIDADES PRINCIPALES Y ACCESO
-- =============================================================================

-- 3. TABLA: usuario
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT,
    uuid_usuario VARCHAR(36) NOT NULL DEFAULT (UUID()),
    id_tipo_usuario SMALLINT NOT NULL,
    id_rol SMALLINT NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    nombres_usuario VARCHAR(60) NOT NULL,
    apellidos_usuario VARCHAR(60) NOT NULL,
    correo_electronico VARCHAR(120) NOT NULL,
    telefono_usuario VARCHAR(15) NULL,
    fecha_nacimiento DATE NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_usuario VARCHAR(12) NOT NULL DEFAULT 'activo',
    
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_uuid UNIQUE (uuid_usuario),
    CONSTRAINT uk_usuario_documento UNIQUE (numero_documento),
    CONSTRAINT uk_usuario_correo UNIQUE (correo_electronico),
    CONSTRAINT fk_usuario_tipo_usuario FOREIGN KEY (id_tipo_usuario) 
        REFERENCES tipo_usuario (id_tipo_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) 
        REFERENCES rol (id_rol) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_usuario_estado CHECK (estado_usuario IN ('activo', 'inactivo', 'suspendido'))
) ENGINE=InnoDB;

-- 4. TABLA: cuenta (Entidad Débil 1:1 con usuario)
CREATE TABLE cuenta (
    id_usuario INT NOT NULL,
    nombre_cuenta VARCHAR(30) NOT NULL,
    clave_cifrada VARCHAR(255) NOT NULL,
    estado_cuenta VARCHAR(12) NOT NULL DEFAULT 'activa',
    fecha_ultimo_acceso DATETIME NULL,
    intentos_fallidos SMALLINT NOT NULL DEFAULT 0,
    
    CONSTRAINT pk_cuenta PRIMARY KEY (id_usuario),
    CONSTRAINT uk_cuenta_nombre UNIQUE (nombre_cuenta),
    CONSTRAINT fk_cuenta_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_cuenta_estado CHECK (estado_cuenta IN ('activa', 'bloqueada', 'pendiente')),
    CONSTRAINT ck_cuenta_intentos CHECK (intentos_fallidos >= 0)
) ENGINE=InnoDB;


-- =============================================================================
-- BLOQUE 3: COMUNIDADES, PERFILES Y SEGUIMIENTO
-- =============================================================================

-- 5. TABLA: grupo
CREATE TABLE grupo (
    id_grupo INT AUTO_INCREMENT,
    nombre_grupo VARCHAR(80) NOT NULL,
    descripcion_grupo VARCHAR(500) NULL,
    fecha_creacion DATE NOT NULL DEFAULT (CURRENT_DATE),
    es_privado BOOLEAN NOT NULL DEFAULT false,
    estado_grupo VARCHAR(10) NOT NULL DEFAULT 'activo',
    
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT uk_grupo_nombre UNIQUE (nombre_grupo),
    CONSTRAINT ck_grupo_estado CHECK (estado_grupo IN ('activo', 'inactivo', 'cerrado'))
) ENGINE=InnoDB;

-- 6. TABLA: perfil
CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT,
    id_usuario INT NULL,
    id_grupo INT NULL,
    titular_perfil VARCHAR(100) NOT NULL,
    area_estudio VARCHAR(100) NULL,
    descripcion_perfil VARCHAR(500) NULL,
    atributos_perfil JSON NULL,
    url_fotografia VARCHAR(255) NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),
    CONSTRAINT uk_perfil_usuario UNIQUE (id_usuario),
    CONSTRAINT uk_perfil_grupo UNIQUE (id_grupo),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_perfil_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo (id_grupo) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. TABLA: grupo_usuario (Membresía N:M)
CREATE TABLE grupo_usuario (
    id_grupo INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_ingreso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_membresia VARCHAR(12) NOT NULL DEFAULT 'activa',
    rol_en_grupo VARCHAR(15) NOT NULL DEFAULT 'miembro',
    
    CONSTRAINT pk_grupo_usuario PRIMARY KEY (id_grupo, id_usuario),
    CONSTRAINT fk_grupo_usuario_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo (id_grupo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_grupo_usuario_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_grupo_usuario_estado CHECK (estado_membresia IN ('pendiente', 'activa', 'rechazada', 'retirada')),
    CONSTRAINT ck_grupo_usuario_rol CHECK (rol_en_grupo IN ('administrador', 'moderador', 'miembro'))
) ENGINE=InnoDB;

-- 8. TABLA: usuario_sigue_usuario (Relación N:M Recursiva)
CREATE TABLE usuario_sigue_usuario (
    id_usuario_seguidor INT NOT NULL,
    id_usuario_seguido INT NOT NULL,
    fecha_seguimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_usuario_sigue_usuario PRIMARY KEY (id_usuario_seguidor, id_usuario_seguido),
    CONSTRAINT fk_sigue_seguidor FOREIGN KEY (id_usuario_seguidor) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sigue_seguido FOREIGN KEY (id_usuario_seguido) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =============================================================================
-- BLOQUE 4: PUBLICACIONES, INTERACCIONES Y MENSAJERÍA
-- =============================================================================

-- 9. TABLA: publicacion
CREATE TABLE publicacion (
    id_publicacion BIGINT AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_grupo INT NULL,
    titulo_publicacion VARCHAR(150) NULL,
    contenido_publicacion TEXT NOT NULL,
    url_multimedia VARCHAR(255) NULL,
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_publicacion VARCHAR(10) NOT NULL DEFAULT 'visible',
    
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_publicacion_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo (id_grupo) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT ck_publicacion_estado CHECK (estado_publicacion IN ('visible', 'oculto', 'eliminado'))
) ENGINE=InnoDB;

-- 10. TABLA: comentario
CREATE TABLE comentario (
    id_comentario BIGINT AUTO_INCREMENT,
    id_publicacion BIGINT NOT NULL,
    id_usuario INT NOT NULL,
    texto_comentario VARCHAR(1000) NOT NULL,
    fecha_comentario DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_comentario VARCHAR(10) NOT NULL DEFAULT 'visible',
    
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) 
        REFERENCES publicacion (id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_comentario_estado CHECK (estado_comentario IN ('visible', 'oculto', 'eliminado'))
) ENGINE=InnoDB;

-- 11. TABLA: reaccion (Entidad Débil)
CREATE TABLE reaccion (
    id_publicacion BIGINT NOT NULL,
    id_usuario INT NOT NULL,
    tipo_reaccion VARCHAR(12) NOT NULL,
    fecha_reaccion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_reaccion PRIMARY KEY (id_publicacion, id_usuario),
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) 
        REFERENCES publicacion (id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reaccion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_reaccion_tipo CHECK (tipo_reaccion IN ('me_gusta', 'me_encanta', 'me_divierte', 'me_sorprende'))
) ENGINE=InnoDB;

-- 12. TABLA: mensaje
CREATE TABLE mensaje (
    id_mensaje BIGINT AUTO_INCREMENT,
    id_usuario_remitente INT NOT NULL,
    id_usuario_destinatario INT NOT NULL,
    asunto_mensaje VARCHAR(150) NULL,
    cuerpo_mensaje TEXT NOT NULL,
    fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fue_leido BOOLEAN NOT NULL DEFAULT false,
    
    CONSTRAINT pk_mensaje PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_mensaje_remitente FOREIGN KEY (id_usuario_remitente) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_mensaje_destinatario FOREIGN KEY (id_usuario_destinatario) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 13. TABLA: notificacion
CREATE TABLE notificacion (
    id_notificacion BIGINT AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    tipo_notificacion VARCHAR(15) NOT NULL,
    referencia_origen BIGINT NULL,
    texto_notificacion VARCHAR(255) NOT NULL,
    fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fue_leida BOOLEAN NOT NULL DEFAULT false,
    
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_notificacion_tipo CHECK (tipo_notificacion IN ('comentario', 'reaccion', 'mensaje', 'seguidor', 'grupo', 'evento', 'servicio', 'producto'))
) ENGINE=InnoDB;


-- =============================================================================
-- BLOQUE 5: MÓDULO DE SERVICIOS
-- =============================================================================

-- 14. TABLA: tipo_servicio
CREATE TABLE tipo_servicio (
    id_tipo_servicio SMALLINT AUTO_INCREMENT,
    id_usuario_registra INT NOT NULL,
    nombre_tipo_servicio VARCHAR(60) NOT NULL,
    descripcion_tipo_servicio VARCHAR(255) NULL,
    estado_tipo_servicio BOOLEAN NOT NULL DEFAULT true,
    
    CONSTRAINT pk_tipo_servicio PRIMARY KEY (id_tipo_servicio),
    CONSTRAINT uk_tipo_servicio_nombre UNIQUE (nombre_tipo_servicio),
    CONSTRAINT fk_tipo_servicio_usuario FOREIGN KEY (id_usuario_registra) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 15. TABLA: servicio
CREATE TABLE servicio (
    id_servicio INT AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_tipo_servicio SMALLINT NOT NULL,
    nombre_servicio VARCHAR(100) NOT NULL,
    descripcion_servicio VARCHAR(1000) NULL,
    precio_servicio DECIMAL(12,2) NOT NULL,
    duracion_minutos INT NULL,
    ubicacion_servicio VARCHAR(150) NULL,
    esta_disponible BOOLEAN NOT NULL DEFAULT true,
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_servicio PRIMARY KEY (id_servicio),
    CONSTRAINT fk_servicio_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_servicio_tipo FOREIGN KEY (id_tipo_servicio) 
        REFERENCES tipo_servicio (id_tipo_servicio) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_servicio_precio CHECK (precio_servicio >= 0),
    CONSTRAINT ck_servicio_duracion CHECK (duracion_minutos IS NULL OR duracion_minutos > 0)
) ENGINE=InnoDB;

-- 16. TABLA: solicitud_servicio (Traza N:M / Entidad Asociativa)
CREATE TABLE solicitud_servicio (
    id_solicitud BIGINT AUTO_INCREMENT,
    id_servicio INT NOT NULL,
    id_usuario_solicitante INT NOT NULL,
    fecha_solicitud DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_solicitud VARCHAR(12) NOT NULL DEFAULT 'pendiente',
    valor_acordado DECIMAL(12,2) NOT NULL,
    
    CONSTRAINT pk_solicitud_servicio PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_solicitud_servicio FOREIGN KEY (id_servicio) 
        REFERENCES servicio (id_servicio) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_usuario FOREIGN KEY (id_usuario_solicitante) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_solicitud_estado CHECK (estado_solicitud IN ('pendiente', 'aceptada', 'rechazada', 'finalizada', 'cancelada')),
    CONSTRAINT ck_solicitud_valor CHECK (valor_acordado >= 0)
) ENGINE=InnoDB;

-- 17. TABLA: calificacion (Entidad Débil 1:1 con solicitud_servicio)
CREATE TABLE calificacion (
    id_solicitud BIGINT NOT NULL,
    puntuacion SMALLINT NOT NULL,
    texto_calificacion VARCHAR(500) NULL,
    fecha_calificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_calificacion PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_calificacion_solicitud FOREIGN KEY (id_solicitud) 
        REFERENCES solicitud_servicio (id_solicitud) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_calificacion_puntuacion CHECK (puntuacion BETWEEN 1 AND 5)
) ENGINE=InnoDB;


-- =============================================================================
-- BLOQUE 6: MÓDULO DE PRODUCTOS / MERCADO
-- =============================================================================

-- 18. TABLA: tipo_producto
CREATE TABLE tipo_producto (
    id_tipo_producto SMALLINT AUTO_INCREMENT,
    id_usuario_registra INT NOT NULL,
    nombre_tipo_producto VARCHAR(60) NOT NULL,
    descripcion_tipo_producto VARCHAR(255) NULL,
    estado_tipo_producto BOOLEAN NOT NULL DEFAULT true,
    
    CONSTRAINT pk_tipo_producto PRIMARY KEY (id_tipo_producto),
    CONSTRAINT uk_tipo_producto_nombre UNIQUE (nombre_tipo_producto),
    CONSTRAINT fk_tipo_producto_usuario FOREIGN KEY (id_usuario_registra) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 19. TABLA: producto
CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_tipo_producto SMALLINT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion_producto VARCHAR(1000) NULL,
    precio_producto DECIMAL(12,2) NOT NULL,
    cantidad_disponible INT NOT NULL,
    condicion_producto VARCHAR(6) NOT NULL,
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_producto VARCHAR(12) NOT NULL DEFAULT 'disponible',
    
    CONSTRAINT pk_producto PRIMARY KEY (id_producto),
    CONSTRAINT fk_producto_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_producto_tipo FOREIGN KEY (id_tipo_producto) 
        REFERENCES tipo_producto (id_tipo_producto) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_producto_precio CHECK (precio_producto >= 0),
    CONSTRAINT ck_producto_cantidad CHECK (cantidad_disponible >= 0),
    CONSTRAINT ck_producto_condicion CHECK (condicion_producto IN ('nuevo', 'usado')),
    CONSTRAINT ck_producto_estado CHECK (estado_producto IN ('disponible', 'reservado', 'vendido', 'retirado'))
) ENGINE=InnoDB;

-- 20. TABLA: compra_producto (Traza de Ventas N:M / Entidad Asociativa)
CREATE TABLE compra_producto (
    id_compra BIGINT AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_usuario_comprador INT NOT NULL,
    fecha_compra DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    valor_total DECIMAL(14,2) NOT NULL,
    estado_compra VARCHAR(12) NOT NULL DEFAULT 'pagada',
    
    CONSTRAINT pk_compra_producto PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_producto FOREIGN KEY (id_producto) 
        REFERENCES producto (id_producto) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_compra_usuario FOREIGN KEY (id_usuario_comprador) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_compra_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_compra_precio CHECK (precio_unitario >= 0),
    CONSTRAINT ck_compra_estado CHECK (estado_compra IN ('pagada', 'entregada', 'cancelada'))
) ENGINE=InnoDB;


-- =============================================================================
-- BLOQUE 7: MÓDULO DE EVENTOS ACADÉMICOS Y SOCIALES
-- =============================================================================

-- 21. TABLA: tipo_evento
CREATE TABLE tipo_evento (
    id_tipo_evento SMALLINT AUTO_INCREMENT,
    id_usuario_registra INT NOT NULL,
    nombre_tipo_evento VARCHAR(60) NOT NULL,
    descripcion_tipo_evento VARCHAR(255) NULL,
    estado_tipo_evento BOOLEAN NOT NULL DEFAULT true,
    
    CONSTRAINT pk_tipo_evento PRIMARY KEY (id_tipo_evento),
    CONSTRAINT uk_tipo_evento_nombre UNIQUE (nombre_tipo_evento),
    CONSTRAINT fk_tipo_evento_usuario FOREIGN KEY (id_usuario_registra) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 22. TABLA: evento
CREATE TABLE evento (
    id_evento INT AUTO_INCREMENT,
    id_usuario_organizador INT NOT NULL,
    id_tipo_evento SMALLINT NOT NULL,
    nombre_evento VARCHAR(120) NOT NULL,
    descripcion_evento VARCHAR(1000) NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    lugar_evento VARCHAR(150) NOT NULL,
    cupo_maximo INT NULL,
    valor_entrada DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado_evento VARCHAR(12) NOT NULL DEFAULT 'programado',
    
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_organizador FOREIGN KEY (id_usuario_organizador) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evento_tipo FOREIGN KEY (id_tipo_evento) 
        REFERENCES tipo_evento (id_tipo_evento) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_evento_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT ck_evento_cupo CHECK (cupo_maximo IS NULL OR cupo_maximo > 0),
    CONSTRAINT ck_evento_valor CHECK (valor_entrada >= 0),
    CONSTRAINT ck_evento_estado CHECK (estado_evento IN ('programado', 'en_curso', 'finalizado', 'cancelado'))
) ENGINE=InnoDB;

-- 23. TABLA: participacion_evento (Traza N:M con Atributos)
CREATE TABLE participacion_evento (
    id_evento INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_inscripcion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_pagado DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    asistio BOOLEAN NOT NULL DEFAULT false,
    me_gusta BOOLEAN NOT NULL DEFAULT false,
    comentario_evento VARCHAR(500) NULL,
    fecha_hora_comentario DATETIME NULL,
    
    CONSTRAINT pk_participacion_evento PRIMARY KEY (id_evento, id_usuario),
    CONSTRAINT fk_participacion_evento FOREIGN KEY (id_evento) 
        REFERENCES evento (id_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_participacion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_participacion_valor CHECK (valor_pagado >= 0)
) ENGINE=InnoDB;