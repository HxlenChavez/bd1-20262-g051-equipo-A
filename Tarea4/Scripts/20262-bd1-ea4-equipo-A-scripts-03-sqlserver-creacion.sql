-- =============================================================================
-- INSTITUCIÓN UNIVERSITARIA PASCUAL BRAVO
-- BASE DE DATOS I - RED SOCIAL PASCUALINA
-- SCRIPT DE CREACIÓN DE BASE DE DATOS (DDL) - MS SQL SERVER / SSMS
-- Archivo: 20262-bd1-ea4-equipo-A-scripts-03-sqlserver-crea.sql
-- =============================================================================

-- USAR BASE DE DATOS MASTER PARA CONTROL DE INICIALIZACIÓN
USE master;
GO

-- LIMPIEZA PREVIA SI LA BASE DE DATOS YA EXISTE
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'red_social_pascualina')
BEGIN
    ALTER DATABASE red_social_pascualina SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE red_social_pascualina;
END
GO

-- CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE red_social_pascualina;
GO

-- CAMBIO AL CONTEXTO DE LA BASE DE DATOS RECIÉN CREADA
USE red_social_pascualina;
GO


-- =============================================================================
-- BLOQUE 1: CATÁLOGOS INDEPENDIENTES (Sin Claves Foráneas)
-- =============================================================================

-- 1. TABLA: rol
CREATE TABLE rol (
    id_rol SMALLINT IDENTITY(1,1),
    nombre_rol NVARCHAR(30) NOT NULL,
    descripcion_rol NVARCHAR(255) NULL,
    estado_rol BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT pk_rol PRIMARY KEY (id_rol),
    CONSTRAINT uk_rol_nombre UNIQUE (nombre_rol)
);
GO

-- 2. TABLA: tipo_usuario
CREATE TABLE tipo_usuario (
    id_tipo_usuario SMALLINT IDENTITY(1,1),
    nombre_tipo_usuario NVARCHAR(40) NOT NULL,
    descripcion_tipo_usuario NVARCHAR(255) NULL,
    estado_tipo_usuario BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT pk_tipo_usuario PRIMARY KEY (id_tipo_usuario),
    CONSTRAINT uk_tipo_usuario_nombre UNIQUE (nombre_tipo_usuario)
);
GO


-- =============================================================================
-- BLOQUE 2: ENTIDADES PRINCIPALES Y ACCESO
-- =============================================================================

-- 3. TABLA: usuario
CREATE TABLE usuario (
    id_usuario INT IDENTITY(1,1),
    uuid_usuario UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    id_tipo_usuario SMALLINT NOT NULL,
    id_rol SMALLINT NOT NULL,
    numero_documento NVARCHAR(20) NOT NULL,
    nombres_usuario NVARCHAR(60) NOT NULL,
    apellidos_usuario NVARCHAR(60) NOT NULL,
    correo_electronico NVARCHAR(120) NOT NULL,
    telefono_usuario NVARCHAR(15) NULL,
    fecha_nacimiento DATE NULL,
    fecha_registro DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado_usuario NVARCHAR(12) NOT NULL DEFAULT 'activo',
    
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_uuid UNIQUE (uuid_usuario),
    CONSTRAINT uk_usuario_documento UNIQUE (numero_documento),
    CONSTRAINT uk_usuario_correo UNIQUE (correo_electronico),
    CONSTRAINT fk_usuario_tipo_usuario FOREIGN KEY (id_tipo_usuario) 
        REFERENCES tipo_usuario (id_tipo_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) 
        REFERENCES rol (id_rol) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT ck_usuario_estado CHECK (estado_usuario IN ('activo', 'inactivo', 'suspendido'))
);
GO

-- 4. TABLA: cuenta (Entidad Débil 1:1 con usuario)
CREATE TABLE cuenta (
    id_usuario INT NOT NULL,
    nombre_cuenta NVARCHAR(30) NOT NULL,
    clave_cifrada NVARCHAR(255) NOT NULL,
    estado_cuenta NVARCHAR(12) NOT NULL DEFAULT 'activa',
    fecha_ultimo_acceso DATETIME2 NULL,
    intentos_fallidos SMALLINT NOT NULL DEFAULT 0,
    
    CONSTRAINT pk_cuenta PRIMARY KEY (id_usuario),
    CONSTRAINT uk_cuenta_nombre UNIQUE (nombre_cuenta),
    CONSTRAINT fk_cuenta_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_cuenta_estado CHECK (estado_cuenta IN ('activa', 'bloqueada', 'pendiente')),
    CONSTRAINT ck_cuenta_intentos CHECK (intentos_fallidos >= 0)
);
GO


-- =============================================================================
-- BLOQUE 3: COMUNIDADES, PERFILES Y SEGUIMIENTO
-- =============================================================================

-- 5. TABLA: grupo
CREATE TABLE grupo (
    id_grupo INT IDENTITY(1,1),
    nombre_grupo NVARCHAR(80) NOT NULL,
    descripcion_grupo NVARCHAR(500) NULL,
    fecha_creacion DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    es_privado BIT NOT NULL DEFAULT 0,
    estado_grupo NVARCHAR(10) NOT NULL DEFAULT 'activo',
    
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT uk_grupo_nombre UNIQUE (nombre_grupo),
    CONSTRAINT ck_grupo_estado CHECK (estado_grupo IN ('activo', 'inactivo', 'cerrado'))
);
GO

-- 6. TABLA: perfil
CREATE TABLE perfil (
    id_perfil INT IDENTITY(1,1),
    id_usuario INT NULL,
    id_grupo INT NULL,
    titular_perfil NVARCHAR(100) NOT NULL,
    area_estudio NVARCHAR(100) NULL,
    descripcion_perfil NVARCHAR(500) NULL,
    atributos_perfil NVARCHAR(MAX) NULL,
    url_fotografia NVARCHAR(255) NULL,
    fecha_actualizacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),
    CONSTRAINT uk_perfil_usuario UNIQUE (id_usuario),
    CONSTRAINT uk_perfil_grupo UNIQUE (id_grupo),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_perfil_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo (id_grupo) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_perfil_exclusividad CHECK (
        (id_usuario IS NOT NULL AND id_grupo IS NULL) OR 
        (id_usuario IS NULL AND id_grupo IS NOT NULL)
    ),
    CONSTRAINT ck_perfil_json CHECK (atributos_perfil IS NULL OR ISJSON(atributos_perfil) = 1)
);
GO

-- 7. TABLA: grupo_usuario (Membresía N:M)
CREATE TABLE grupo_usuario (
    id_grupo INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_ingreso DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado_membresia NVARCHAR(12) NOT NULL DEFAULT 'activa',
    rol_en_grupo NVARCHAR(15) NOT NULL DEFAULT 'miembro',
    
    CONSTRAINT pk_grupo_usuario PRIMARY KEY (id_grupo, id_usuario),
    CONSTRAINT fk_grupo_usuario_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo (id_grupo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_grupo_usuario_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_grupo_usuario_estado CHECK (estado_membresia IN ('pendiente', 'activa', 'rechazada', 'retirada')),
    CONSTRAINT ck_grupo_usuario_rol CHECK (rol_en_grupo IN ('administrador', 'moderador', 'miembro'))
);
GO

-- 8. TABLA: usuario_sigue_usuario (Relación N:M Recursiva)
CREATE TABLE usuario_sigue_usuario (
    id_usuario_seguidor INT NOT NULL,
    id_usuario_seguido INT NOT NULL,
    fecha_seguimiento DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    
    CONSTRAINT pk_usuario_sigue_usuario PRIMARY KEY (id_usuario_seguidor, id_usuario_seguido),
    CONSTRAINT fk_sigue_seguidor FOREIGN KEY (id_usuario_seguidor) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sigue_seguido FOREIGN KEY (id_usuario_seguido) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_sigue_no_automismo CHECK (id_usuario_seguidor <> id_usuario_seguido)
);
GO


-- =============================================================================
-- BLOQUE 4: PUBLICACIONES, INTERACCIONES Y MENSAJERÍA
-- =============================================================================

-- 9. TABLA: publicacion
CREATE TABLE publicacion (
    id_publicacion BIGINT IDENTITY(1,1),
    id_usuario INT NOT NULL,
    id_grupo INT NULL,
    titulo_publicacion NVARCHAR(150) NULL,
    contenido_publicacion NVARCHAR(MAX) NOT NULL,
    url_multimedia NVARCHAR(255) NULL,
    fecha_publicacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado_publicacion NVARCHAR(10) NOT NULL DEFAULT 'visible',
    
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_publicacion_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo (id_grupo) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT ck_publicacion_estado CHECK (estado_publicacion IN ('visible', 'oculto', 'eliminado'))
);
GO

-- 10. TABLA: comentario
CREATE TABLE comentario (
    id_comentario BIGINT IDENTITY(1,1),
    id_publicacion BIGINT NOT NULL,
    id_usuario INT NOT NULL,
    texto_comentario NVARCHAR(1000) NOT NULL,
    fecha_comentario DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado_comentario NVARCHAR(10) NOT NULL DEFAULT 'visible',
    
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) 
        REFERENCES publicacion (id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_comentario_estado CHECK (estado_comentario IN ('visible', 'oculto', 'eliminado'))
);
GO

-- 11. TABLA: reaccion (Entidad Débil)
CREATE TABLE reaccion (
    id_publicacion BIGINT NOT NULL,
    id_usuario INT NOT NULL,
    tipo_reaccion NVARCHAR(12) NOT NULL,
    fecha_reaccion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    
    CONSTRAINT pk_reaccion PRIMARY KEY (id_publicacion, id_usuario),
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) 
        REFERENCES publicacion (id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reaccion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_reaccion_tipo CHECK (tipo_reaccion IN ('me_gusta', 'me_encanta', 'me_divierte', 'me_sorprende'))
);
GO

-- 12. TABLA: mensaje
CREATE TABLE mensaje (
    id_mensaje BIGINT IDENTITY(1,1),
    id_usuario_remitente INT NOT NULL,
    id_usuario_destinatario INT NOT NULL,
    asunto_mensaje NVARCHAR(150) NULL,
    cuerpo_mensaje NVARCHAR(MAX) NOT NULL,
    fecha_envio DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    fue_leido BIT NOT NULL DEFAULT 0,
    
    CONSTRAINT pk_mensaje PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_mensaje_remitente FOREIGN KEY (id_usuario_remitente) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_mensaje_destinatario FOREIGN KEY (id_usuario_destinatario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_mensaje_no_automensaje CHECK (id_usuario_remitente <> id_usuario_destinatario)
);
GO

-- 13. TABLA: notificacion
CREATE TABLE notificacion (
    id_notificacion BIGINT IDENTITY(1,1),
    id_usuario INT NOT NULL,
    tipo_notificacion NVARCHAR(15) NOT NULL,
    referencia_origen BIGINT NULL,
    texto_notificacion NVARCHAR(255) NOT NULL,
    fecha_generacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    fue_leida BIT NOT NULL DEFAULT 0,
    
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_notificacion_tipo CHECK (tipo_notificacion IN ('comentario', 'reaccion', 'mensaje', 'seguidor', 'grupo', 'evento', 'servicio', 'producto'))
);
GO


-- =============================================================================
-- BLOQUE 5: MÓDULO DE SERVICIOS
-- =============================================================================

-- 14. TABLA: tipo_servicio
CREATE TABLE tipo_servicio (
    id_tipo_servicio SMALLINT IDENTITY(1,1),
    id_usuario_registra INT NOT NULL,
    nombre_tipo_servicio NVARCHAR(60) NOT NULL,
    descripcion_tipo_servicio NVARCHAR(255) NULL,
    estado_tipo_servicio BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT pk_tipo_servicio PRIMARY KEY (id_tipo_servicio),
    CONSTRAINT uk_tipo_servicio_nombre UNIQUE (nombre_tipo_servicio),
    CONSTRAINT fk_tipo_servicio_usuario FOREIGN KEY (id_usuario_registra) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

-- 15. TABLA: servicio
CREATE TABLE servicio (
    id_servicio INT IDENTITY(1,1),
    id_usuario INT NOT NULL,
    id_tipo_servicio SMALLINT NOT NULL,
    nombre_servicio NVARCHAR(100) NOT NULL,
    descripcion_servicio NVARCHAR(1000) NULL,
    precio_servicio DECIMAL(12,2) NOT NULL,
    duracion_minutos INT NULL,
    ubicacion_servicio NVARCHAR(150) NULL,
    esta_disponible BIT NOT NULL DEFAULT 1,
    fecha_publicacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    
    CONSTRAINT pk_servicio PRIMARY KEY (id_servicio),
    CONSTRAINT fk_servicio_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_servicio_tipo FOREIGN KEY (id_tipo_servicio) 
        REFERENCES tipo_servicio (id_tipo_servicio) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_servicio_precio CHECK (precio_servicio >= 0),
    CONSTRAINT ck_servicio_duracion CHECK (duracion_minutos IS NULL OR duracion_minutos > 0)
);
GO

-- 16. TABLA: solicitud_servicio (Traza N:M / Entidad Asociativa)
CREATE TABLE solicitud_servicio (
    id_solicitud BIGINT IDENTITY(1,1),
    id_servicio INT NOT NULL,
    id_usuario_solicitante INT NOT NULL,
    fecha_solicitud DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado_solicitud NVARCHAR(12) NOT NULL DEFAULT 'pendiente',
    valor_acordado DECIMAL(12,2) NOT NULL,
    
    CONSTRAINT pk_solicitud_servicio PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_solicitud_servicio FOREIGN KEY (id_servicio) 
        REFERENCES servicio (id_servicio) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_usuario FOREIGN KEY (id_usuario_solicitante) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_solicitud_estado CHECK (estado_solicitud IN ('pendiente', 'aceptada', 'rechazada', 'finalizada', 'cancelada')),
    CONSTRAINT ck_solicitud_valor CHECK (valor_acordado >= 0)
);
GO

-- 17. TABLA: calificacion (Entidad Débil 1:1 con solicitud_servicio)
CREATE TABLE calificacion (
    id_solicitud BIGINT NOT NULL,
    puntuacion SMALLINT NOT NULL,
    texto_calificacion NVARCHAR(500) NULL,
    fecha_calificacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    
    CONSTRAINT pk_calificacion PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_calificacion_solicitud FOREIGN KEY (id_solicitud) 
        REFERENCES solicitud_servicio (id_solicitud) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_calificacion_puntuacion CHECK (puntuacion BETWEEN 1 AND 5)
);
GO


-- =============================================================================
-- BLOQUE 6: MÓDULO DE PRODUCTOS / MERCADO
-- =============================================================================

-- 18. TABLA: tipo_producto
CREATE TABLE tipo_producto (
    id_tipo_producto SMALLINT IDENTITY(1,1),
    id_usuario_registra INT NOT NULL,
    nombre_tipo_producto NVARCHAR(60) NOT NULL,
    descripcion_tipo_producto NVARCHAR(255) NULL,
    estado_tipo_producto BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT pk_tipo_producto PRIMARY KEY (id_tipo_producto),
    CONSTRAINT uk_tipo_producto_nombre UNIQUE (nombre_tipo_producto),
    CONSTRAINT fk_tipo_producto_usuario FOREIGN KEY (id_usuario_registra) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

-- 19. TABLA: producto
CREATE TABLE producto (
    id_producto INT IDENTITY(1,1),
    id_usuario INT NOT NULL,
    id_tipo_producto SMALLINT NOT NULL,
    nombre_producto NVARCHAR(100) NOT NULL,
    descripcion_producto NVARCHAR(1000) NULL,
    precio_producto DECIMAL(12,2) NOT NULL,
    cantidad_disponible INT NOT NULL,
    condicion_producto NVARCHAR(6) NOT NULL,
    fecha_publicacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado_producto NVARCHAR(12) NOT NULL DEFAULT 'disponible',
    
    CONSTRAINT pk_producto PRIMARY KEY (id_producto),
    CONSTRAINT fk_producto_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_producto_tipo FOREIGN KEY (id_tipo_producto) 
        REFERENCES tipo_producto (id_tipo_producto) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_producto_precio CHECK (precio_producto >= 0),
    CONSTRAINT ck_producto_cantidad CHECK (cantidad_disponible >= 0),
    CONSTRAINT ck_producto_condicion CHECK (condicion_producto IN ('nuevo', 'usado')),
    CONSTRAINT ck_producto_estado CHECK (estado_producto IN ('disponible', 'reservado', 'vendido', 'retirado'))
);
GO

-- 20. TABLA: compra_producto (Traza de Ventas N:M / Entidad Asociativa)
CREATE TABLE compra_producto (
    id_compra BIGINT IDENTITY(1,1),
    id_producto INT NOT NULL,
    id_usuario_comprador INT NOT NULL,
    fecha_compra DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    valor_total DECIMAL(14,2) NOT NULL,
    estado_compra NVARCHAR(12) NOT NULL DEFAULT 'pagada',
    
    CONSTRAINT pk_compra_producto PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_producto FOREIGN KEY (id_producto) 
        REFERENCES producto (id_producto) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_compra_usuario FOREIGN KEY (id_usuario_comprador) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_compra_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_compra_precio CHECK (precio_unitario >= 0),
    CONSTRAINT ck_compra_estado CHECK (estado_compra IN ('pagada', 'entregada', 'cancelada'))
);
GO


-- =============================================================================
-- BLOQUE 7: MÓDULO DE EVENTOS ACADÉMICOS Y SOCIALES
-- =============================================================================

-- 21. TABLA: tipo_evento
CREATE TABLE tipo_evento (
    id_tipo_evento SMALLINT IDENTITY(1,1),
    id_usuario_registra INT NOT NULL,
    nombre_tipo_evento NVARCHAR(60) NOT NULL,
    descripcion_tipo_evento NVARCHAR(255) NULL,
    estado_tipo_evento BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT pk_tipo_evento PRIMARY KEY (id_tipo_evento),
    CONSTRAINT uk_tipo_evento_nombre UNIQUE (nombre_tipo_evento),
    CONSTRAINT fk_tipo_evento_usuario FOREIGN KEY (id_usuario_registra) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

-- 22. TABLA: evento
CREATE TABLE evento (
    id_evento INT IDENTITY(1,1),
    id_usuario_organizador INT NOT NULL,
    id_tipo_evento SMALLINT NOT NULL,
    nombre_evento NVARCHAR(120) NOT NULL,
    descripcion_evento NVARCHAR(1000) NULL,
    fecha_inicio DATETIME2 NOT NULL,
    fecha_fin DATETIME2 NOT NULL,
    lugar_evento NVARCHAR(150) NOT NULL,
    cupo_maximo INT NULL,
    valor_entrada DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado_evento NVARCHAR(12) NOT NULL DEFAULT 'programado',
    
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_organizador FOREIGN KEY (id_usuario_organizador) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_evento_tipo FOREIGN KEY (id_tipo_evento) 
        REFERENCES tipo_evento (id_tipo_evento) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_evento_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT ck_evento_cupo CHECK (cupo_maximo IS NULL OR cupo_maximo > 0),
    CONSTRAINT ck_evento_valor CHECK (valor_entrada >= 0),
    CONSTRAINT ck_evento_estado CHECK (estado_evento IN ('programado', 'en_curso', 'finalizado', 'cancelado'))
);
GO

-- 23. TABLA: participacion_evento (Traza N:M con Atributos)
CREATE TABLE participacion_evento (
    id_evento INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_inscripcion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    valor_pagado DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    asistio BIT NOT NULL DEFAULT 0,
    me_gusta BIT NOT NULL DEFAULT 0,
    comentario_evento NVARCHAR(500) NULL,
    fecha_hora_comentario DATETIME2 NULL,
    
    CONSTRAINT pk_participacion_evento PRIMARY KEY (id_evento, id_usuario),
    CONSTRAINT fk_participacion_evento FOREIGN KEY (id_evento) 
        REFERENCES evento (id_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_participacion_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario (id_usuario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_participacion_valor CHECK (valor_pagado >= 0)
);
GO