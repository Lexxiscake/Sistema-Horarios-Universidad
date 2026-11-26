/* ============================================================================
   Sistema de Gestión de Horarios Universitarios
   Script de instalación de la base de datos (SQL Server)

   Crea la base de datos PruebaDB, sus tablas, los datos de prueba y los
   grupos/horarios del periodo activo.

   Formas de ejecutarlo:
     1. Recomendado:  python scripts/init_db.py
     2. SSMS: abrir este archivo y ejecutarlo (F5)
     3. sqlcmd: sqlcmd -S localhost\SQLEXPRESS -E -i BD\init_db.sql

   Es seguro ejecutarlo varias veces: solo crea lo que falta y no duplica
   los datos de prueba.
   ============================================================================ */

IF DB_ID('PruebaDB') IS NULL
BEGIN
    CREATE DATABASE [PruebaDB];
END
GO

USE [PruebaDB];
GO

SET NOCOUNT ON;
GO

/* ============================================================================
   TABLAS
   ============================================================================ */

IF OBJECT_ID('dbo.Alumnos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Alumnos (
        Num_control      CHAR(8)        NOT NULL PRIMARY KEY,
        Nombre           NVARCHAR(100)  NOT NULL,
        Semestre         INT            NULL,
        Carrera          NVARCHAR(50)   NULL
                         CONSTRAINT DF_Alumnos_Carrera
                         DEFAULT N'Ing. en Sistemas Computaciones',
        Contraseña_hash  NVARCHAR(255)  NOT NULL,
        Foto             NVARCHAR(255)  NULL
    );
END
GO

IF OBJECT_ID('dbo.Materias', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Materias (
        Serie      VARCHAR(20)   NOT NULL PRIMARY KEY,
        Nombre     NVARCHAR(100) NULL,
        Semestre   INT           NULL,
        Creditos   INT           NULL,
        Seriada    VARCHAR(20)   NULL,
        CONSTRAINT FK_Materias_Seriada
            FOREIGN KEY (Seriada) REFERENCES dbo.Materias(Serie)
    );
END
GO

IF OBJECT_ID('dbo.Kardex', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Kardex (
        Id_kardex     INT            IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Num_control   CHAR(8)        NOT NULL,
        Serie         VARCHAR(20)    NOT NULL,
        Calificacion  DECIMAL(4,2)   NOT NULL,
        Estatus       NVARCHAR(20)   NOT NULL
                      CONSTRAINT CK_Kardex_Estatus
                      CHECK (Estatus IN (N'APROBADA', N'REPROBADA', N'CURSANDO')),
        CONSTRAINT FK_Kardex_Alumnos
            FOREIGN KEY (Num_control) REFERENCES dbo.Alumnos(Num_control),
        CONSTRAINT FK_Kardex_Materias
            FOREIGN KEY (Serie) REFERENCES dbo.Materias(Serie)
    );
END
GO

IF OBJECT_ID('dbo.Periodos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Periodos (
        Id_periodo      INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Periodo_texto   VARCHAR(10)  NOT NULL UNIQUE,
        Nombre_periodo  NVARCHAR(50) NULL,
        Activo          BIT          NULL CONSTRAINT DF_Periodos_Activo DEFAULT 0
    );
END
GO

IF OBJECT_ID('dbo.Grupos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Grupos (
        Id_grupo       INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Id_periodo     INT           NOT NULL,
        Serie_materia  VARCHAR(20)   NOT NULL,
        Grupo_letra    CHAR(1)       NOT NULL
                       CONSTRAINT CK_Grupos_Letra
                       CHECK (Grupo_letra IN ('A', 'B', 'C', 'D')),
        Cupo_maximo    INT           NULL CONSTRAINT DF_Grupos_CupoMax DEFAULT 40,
        Cupo_actual    INT           NULL CONSTRAINT DF_Grupos_CupoAct DEFAULT 0,
        Aula           NVARCHAR(20)  NULL,
        CONSTRAINT FK_Grupos_Periodos
            FOREIGN KEY (Id_periodo) REFERENCES dbo.Periodos(Id_periodo),
        CONSTRAINT FK_Grupos_Materias
            FOREIGN KEY (Serie_materia) REFERENCES dbo.Materias(Serie),
        CONSTRAINT UQ_Grupos_PeriodoMateriaLetra
            UNIQUE (Id_periodo, Serie_materia, Grupo_letra)
    );
END
GO

IF OBJECT_ID('dbo.Horario_Grupo', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Horario_Grupo (
        Id_horario  INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Id_grupo    INT          NOT NULL,
        Dia_semana  VARCHAR(10)  NOT NULL
                    CONSTRAINT CK_Horario_Dia
                    CHECK (Dia_semana IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes')),
        Hora_inicio TIME(0)      NOT NULL,
        Hora_fin    TIME(0)      NOT NULL,
        CONSTRAINT FK_Horario_Grupo
            FOREIGN KEY (Id_grupo) REFERENCES dbo.Grupos(Id_grupo)
    );
END
GO

IF OBJECT_ID('dbo.Inscripciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Inscripciones (
        Id_inscripcion     INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Num_control        CHAR(8)      NOT NULL,
        Id_grupo           INT          NOT NULL,
        Fecha_inscripcion  DATETIME     NULL
                           CONSTRAINT DF_Inscripciones_Fecha DEFAULT GETDATE(),
        Estado             NVARCHAR(20) NULL
                           CONSTRAINT DF_Inscripciones_Estado DEFAULT N'INSCRITO',
        CONSTRAINT FK_Inscripciones_Alumnos
            FOREIGN KEY (Num_control) REFERENCES dbo.Alumnos(Num_control),
        CONSTRAINT FK_Inscripciones_Grupos
            FOREIGN KEY (Id_grupo) REFERENCES dbo.Grupos(Id_grupo),
        CONSTRAINT UQ_Inscripciones_AlumnoGrupo
            UNIQUE (Num_control, Id_grupo)
    );
END
GO

/* ============================================================================
   DATOS DE PRUEBA
   ============================================================================ */

IF NOT EXISTS (SELECT 1 FROM dbo.Alumnos)
BEGIN
    INSERT INTO dbo.Alumnos (Num_control, Nombre, Semestre, Carrera, Contraseña_hash, Foto)
    VALUES
        ('23211907', N'Samuel "Galleta"', 5, N'Ing. en Sistemas Computaciones', N'galleta',  N'img/galleta.jpeg'),
        ('23212002', N'Urabe Mikoto',     2, N'Ing. en Sistemas Computaciones', N'panfilo',  N'img/urabe.jpg'),
        ('23212005', N'Ryuko',            3, N'Ing. en Sistemas Computaciones', N'kill',     N'img/Ryukio.jpg'),
        ('23212006', N'Miku',             2, N'Ing. en Sistemas Computaciones', N'miku',     N'img/miku.jpg'),
        ('23212007', N'Doro',             3, N'Ing. en Sistemas Computaciones', N'doro123',  N'img/doro.jpg'),
        ('23212008', N'Ryou',             4, N'Ing. en Sistemas Computaciones', N'dinero',   N'img/Ryou.jpg'),
        ('23212009', N'Anko',             5, N'Ing. en Sistemas Computaciones', N'vampiro',  N'img/Anko.jpg'),
        ('23212010', N'Kobeni',           6, N'Ing. en Sistemas Computaciones', N'miedo',    N'img/kobeni.jpg');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Materias)
BEGIN
    INSERT INTO dbo.Materias (Serie, Nombre, Semestre, Creditos, Seriada) VALUES
    -- Semestre 1
    ('ACF-0901', N'Cálculo Diferencial',                         1, 5, NULL),
    ('AED-1285', N'Fundamentos de Programación',                 1, 5, NULL),
    ('ACC-0906', N'Fundamentos de Investigación',                1, 4, NULL),
    ('SCH-1024', N'Taller de Administración',                    1, 4, NULL),
    ('ACA-0907', N'Taller de Ética',                             1, 4, NULL),
    ('AEF-1041', N'Matemáticas Discretas',                       1, 5, NULL),

    -- Semestre 2
    ('ACF-0902', N'Cálculo Integral',                            2, 5, 'ACF-0901'),
    ('AED-1286', N'Programación Orientada a Objetos',            2, 5, 'AED-1285'),
    ('ACF-0903', N'Álgebra Lineal',                              2, 5, NULL),
    ('SCC-1005', N'Cultura Empresarial',                         2, 4, NULL),
    ('AEF-1052', N'Probabilidad y Estadística',                  2, 5, NULL),
    ('SCF-1006', N'Física General',                              2, 5, NULL),

    -- Semestre 3
    ('ACF-0904', N'Cálculo Vectorial',                           3, 5, 'ACF-0902'),
    ('AED-1026', N'Estructura de Datos',                         3, 5, NULL),
    ('AEC-1058', N'Química',                                     3, 4, NULL),
    ('AEC-1008', N'Contabilidad Financiera',                     3, 4, NULL),
    ('SCC-1013', N'Investigación de Operaciones',                3, 4, 'AEF-1052'),
    ('SCD-1018', N'Principios Eléctricos y Aplicaciones Digitales', 3, 5, 'SCF-1006'),

    -- Semestre 4
    ('ACF-0905', N'Ecuaciones Diferenciales',                    4, 5, 'ACF-0904'),
    ('SCD-1027', N'Tópicos Avanzados de Programación',           4, 5, 'AED-1026'),
    ('SCC-1017', N'Métodos Numéricos',                           4, 4, NULL),
    ('AEF-1031', N'Fundamentos de Bases de Datos',               4, 5, NULL),
    ('SCD-1022', N'Simulación',                                  4, 5, 'SCC-1013'),
    ('SCD-1003', N'Arquitectura de Computadoras',                4, 5, 'SCD-1018'),

    -- Semestre 5
    ('SCC-1010', N'Graficación',                                 5, 4, NULL),
    ('AEC-1034', N'Fundamentos de Telecomunicaciones',           5, 4, NULL),
    ('AEC-1061', N'Sistemas Operativos I',                       5, 4, NULL),
    ('SCA-1025', N'Taller de Bases de Datos',                    5, 4, 'AEF-1031'),
    ('SCC-1007', N'Fundamentos de Ingeniería de Software',       5, 4, NULL),
    ('ACD-0908', N'Desarrollo Sustentable',                      5, 5, NULL),

    -- Semestre 6
    ('SCD-1015', N'Lenguajes y Autómatas I',                     6, 5, NULL),
    ('SCD-1021', N'Redes de Computadoras',                       6, 5, 'AEC-1034'),
    ('SCA-1026', N'Taller de Sistemas Operativos',               6, 4, 'AEC-1061'),
    ('SCB-1001', N'Administración de Bases de Datos',            6, 5, 'SCA-1025'),
    ('SCD-1011', N'Ingeniería de Software',                      6, 5, 'SCC-1007'),
    ('SCC-1014', N'Lenguajes de Interfaz',                       6, 4, NULL),
    ('4SC9',     N'Servicio Social',                             6, 10, NULL),

    -- Semestre 7
    ('SCD-1016', N'Lenguajes y Autómatas II',                    7, 5, 'SCD-1015'),
    ('SCD-1004', N'Conmutación y Enrutamiento en Redes',         7, 5, NULL),
    ('ACA-0909', N'Taller de Investigación I',                   7, 4, NULL),
    ('SCC-1019', N'Programación Lógica y Funcional',             7, 4, NULL),
    ('SCG-1009', N'Gestión de Proyectos de Software',            7, 6, 'SCD-1011'),
    ('SCG-1023', N'Sistemas Programables',                       7, 4, 'SCC-1014'),

    -- Semestre 8
    ('AEB-1055', N'Programación Web',                            8, 5, NULL),
    ('SCA-1002', N'Administración de Redes',                     8, 4, 'SCD-1004'),
    ('ACA-0910', N'Taller de Investigación II',                  8, 4, 'ACA-0909'),
    ('SCC-1002', N'Inteligencia Artificial',                     8, 4, 'SCC-1019');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Kardex)
BEGIN
    INSERT INTO dbo.Kardex (Num_control, Serie, Calificacion, Estatus) VALUES
    -- Urabe Mikoto
    ('23212002', 'ACF-0901', 67, 'REPROBADA'),
    ('23212002', 'AED-1285', 50, 'REPROBADA'),
    ('23212002', 'ACC-0906', 69, 'REPROBADA'),
    ('23212002', 'SCH-1024', 99, 'APROBADA'),
    ('23212002', 'ACA-0907', 89, 'APROBADA'),
    ('23212002', 'AEF-1041', 93, 'APROBADA'),

    -- Ryuko
    ('23212005', 'ACF-0901', 97, 'APROBADA'),
    ('23212005', 'AED-1285', 91, 'APROBADA'),
    ('23212005', 'ACC-0906', 79, 'APROBADA'),
    ('23212005', 'SCH-1024', 78, 'APROBADA'),
    ('23212005', 'ACA-0907', 98, 'APROBADA'),
    ('23212005', 'AEF-1041', 93, 'APROBADA'),
    ('23212005', 'ACF-0902', 97, 'APROBADA'),
    ('23212005', 'AED-1286', 99, 'APROBADA'),
    ('23212005', 'ACF-0903', 79, 'APROBADA'),
    ('23212005', 'SCC-1005', 80, 'APROBADA'),
    ('23212005', 'AEF-1052', 89, 'APROBADA'),
    ('23212005', 'SCF-1006', 93, 'APROBADA'),

    -- Miku
    ('23212006', 'ACF-0901', 67, 'REPROBADA'),
    ('23212006', 'AED-1285', 90, 'APROBADA'),
    ('23212006', 'ACC-0906', 70, 'APROBADA'),
    ('23212006', 'SCH-1024', 99, 'APROBADA'),
    ('23212006', 'ACA-0907', 89, 'APROBADA'),
    ('23212006', 'AEF-1041', 93, 'APROBADA'),

    -- Doro
    ('23212007', 'ACF-0901', 85, 'APROBADA'),
    ('23212007', 'AED-1285', 90, 'APROBADA'),
    ('23212007', 'ACC-0906', 80, 'APROBADA'),
    ('23212007', 'SCH-1024', 88, 'APROBADA'),
    ('23212007', 'ACA-0907', 92, 'APROBADA'),
    ('23212007', 'AEF-1041', 87, 'APROBADA'),
    ('23212007', 'ACF-0902', 89, 'APROBADA'),
    ('23212007', 'AED-1286', 91, 'APROBADA'),
    ('23212007', 'ACF-0903', 85, 'APROBADA'),
    ('23212007', 'SCC-1005', 90, 'APROBADA'),
    ('23212007', 'AEF-1052', 88, 'APROBADA'),
    ('23212007', 'SCF-1006', 86, 'APROBADA'),
    ('23212007', 'ACF-0904', 55, 'REPROBADA'),
    ('23212007', 'AED-1026', 80, 'APROBADA'),
    ('23212007', 'AEC-1058', 75, 'APROBADA'),
    ('23212007', 'AEC-1008', 82, 'APROBADA'),
    ('23212007', 'SCC-1013', 70, 'APROBADA'),
    ('23212007', 'SCD-1018', 85, 'APROBADA'),

    -- Ryou
    ('23212008', 'ACF-0901', 85, 'APROBADA'),
    ('23212008', 'AED-1285', 90, 'APROBADA'),
    ('23212008', 'ACC-0906', 55, 'REPROBADA'),
    ('23212008', 'SCH-1024', 60, 'REPROBADA'),
    ('23212008', 'ACA-0907', 88, 'APROBADA'),
    ('23212008', 'AEF-1041', 87, 'APROBADA'),
    ('23212008', 'ACF-0902', 82, 'APROBADA'),
    ('23212008', 'AED-1286', 85, 'APROBADA'),
    ('23212008', 'ACF-0903', 80, 'APROBADA'),
    ('23212008', 'SCC-1005', 78, 'APROBADA'),
    ('23212008', 'AEF-1052', 81, 'APROBADA'),
    ('23212008', 'SCF-1006', 79, 'APROBADA'),
    ('23212008', 'ACF-0904', 80, 'APROBADA'),
    ('23212008', 'AED-1026', 84, 'APROBADA'),
    ('23212008', 'AEC-1058', 76, 'APROBADA'),
    ('23212008', 'AEC-1008', 73, 'APROBADA'),
    ('23212008', 'SCC-1013', 75, 'APROBADA'),
    ('23212008', 'SCD-1018', 72, 'APROBADA'),

    -- Anko
    ('23212009', 'ACF-0901', 86, 'APROBADA'),
    ('23212009', 'AED-1285', 89, 'APROBADA'),
    ('23212009', 'ACC-0906', 58, 'REPROBADA'),
    ('23212009', 'SCH-1024', 83, 'APROBADA'),
    ('23212009', 'ACA-0907', 55, 'REPROBADA'),
    ('23212009', 'AEF-1041', 88, 'APROBADA'),
    ('23212009', 'ACF-0902', 85, 'APROBADA'),
    ('23212009', 'AED-1286', 90, 'APROBADA'),
    ('23212009', 'ACF-0903', 82, 'APROBADA'),
    ('23212009', 'SCC-1005', 80, 'APROBADA'),
    ('23212009', 'AEF-1052', 84, 'APROBADA'),
    ('23212009', 'SCF-1006', 79, 'APROBADA'),
    ('23212009', 'ACF-0904', 81, 'APROBADA'),
    ('23212009', 'AED-1026', 86, 'APROBADA'),
    ('23212009', 'AEC-1058', 58, 'REPROBADA'),
    ('23212009', 'AEC-1008', 60, 'REPROBADA'),
    ('23212009', 'SCC-1013', 76, 'APROBADA'),
    ('23212009', 'SCD-1018', 74, 'APROBADA'),
    ('23212009', 'ACF-0905', 80, 'APROBADA'),
    ('23212009', 'SCD-1027', 85, 'APROBADA'),
    ('23212009', 'SCC-1017', 78, 'APROBADA'),
    ('23212009', 'AEF-1031', 82, 'APROBADA'),
    ('23212009', 'SCD-1022', 79, 'APROBADA'),
    ('23212009', 'SCD-1003', 81, 'APROBADA'),

    -- Kobeni
    ('23212010', 'ACF-0901', 87, 'APROBADA'),
    ('23212010', 'AED-1285', 91, 'APROBADA'),
    ('23212010', 'ACC-0906', 52, 'REPROBADA'),
    ('23212010', 'SCH-1024', 58, 'REPROBADA'),
    ('23212010', 'ACA-0907', 86, 'APROBADA'),
    ('23212010', 'AEF-1041', 88, 'APROBADA'),
    ('23212010', 'ACF-0902', 86, 'APROBADA'),
    ('23212010', 'AED-1286', 88, 'APROBADA'),
    ('23212010', 'ACF-0903', 83, 'APROBADA'),
    ('23212010', 'SCC-1005', 80, 'APROBADA'),
    ('23212010', 'AEF-1052', 82, 'APROBADA'),
    ('23212010', 'SCF-1006', 81, 'APROBADA'),
    ('23212010', 'ACF-0904', 82, 'APROBADA'),
    ('23212010', 'AED-1026', 85, 'APROBADA'),
    ('23212010', 'AEC-1058', 54, 'REPROBADA'),
    ('23212010', 'AEC-1008', 79, 'APROBADA'),
    ('23212010', 'SCC-1013', 77, 'APROBADA'),
    ('23212010', 'SCD-1018', 76, 'APROBADA'),
    ('23212010', 'ACF-0905', 80, 'APROBADA'),
    ('23212010', 'SCD-1027', 84, 'APROBADA'),
    ('23212010', 'SCC-1017', 75, 'APROBADA'),
    ('23212010', 'AEF-1031', 81, 'APROBADA'),
    ('23212010', 'SCD-1022', 78, 'APROBADA'),
    ('23212010', 'SCD-1003', 79, 'APROBADA'),
    ('23212010', 'SCC-1010', 50, 'REPROBADA'),
    ('23212010', 'AEC-1034', 84, 'APROBADA'),
    ('23212010', 'AEC-1061', 83, 'APROBADA'),
    ('23212010', 'SCA-1025', 80, 'APROBADA'),
    ('23212010', 'SCC-1007', 82, 'APROBADA'),
    ('23212010', 'ACD-0908', 55, 'REPROBADA');
END
GO

/* ============================================================================
   PERIODO ACTIVO Y GRUPOS
   ============================================================================ */

IF NOT EXISTS (SELECT 1 FROM dbo.Periodos)
BEGIN
    INSERT INTO dbo.Periodos (Periodo_texto, Nombre_periodo, Activo)
    VALUES ('2025-2', N'Agosto-Diciembre 2025', 1);
END
GO

DECLARE @id_periodo INT;

SELECT TOP (1) @id_periodo = Id_periodo
FROM dbo.Periodos
WHERE Activo = 1
ORDER BY Id_periodo;

IF @id_periodo IS NULL
    SELECT TOP (1) @id_periodo = Id_periodo FROM dbo.Periodos ORDER BY Id_periodo;

IF @id_periodo IS NULL
BEGIN
    INSERT INTO dbo.Periodos (Periodo_texto, Nombre_periodo, Activo)
    VALUES ('2025-2', N'Agosto-Diciembre 2025', 1);
    SET @id_periodo = SCOPE_IDENTITY();
END

IF NOT EXISTS (SELECT 1 FROM dbo.Grupos)
BEGIN
    DECLARE @serie VARCHAR(20);
    DECLARE @creditos INT;
    DECLARE @posicion INT;
    DECLARE @hora_base INT;
    DECLARE @letra CHAR(1);
    DECLARE @indice_letra INT;
    DECLARE @id_grupo INT;
    DECLARE @hora TIME(0);
    DECLARE @hora_fin TIME(0);
    DECLARE @dia VARCHAR(10);
    DECLARE @indice_dia INT;
    DECLARE @total_dias INT;

    DECLARE cur_materias CURSOR LOCAL FAST_FORWARD FOR
        SELECT Serie,
               Creditos,
               ROW_NUMBER() OVER (PARTITION BY Semestre ORDER BY Serie) AS Posicion
        FROM dbo.Materias
        ORDER BY Semestre, Serie;

    OPEN cur_materias;
    FETCH NEXT FROM cur_materias INTO @serie, @creditos, @posicion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Horario escalonado: cada materia del semestre empieza una hora
        -- después que la anterior (máximo 12:00). Los grupos A-D se
        -- desplazan una hora entre sí. Así los paquetes A-D pueden
        -- combinarse sin choques en la tabla de horario de la interfaz.
        SET @hora_base = 7 + CASE WHEN @posicion - 1 > 5 THEN 5 ELSE @posicion - 1 END;
        SET @total_dias = CASE WHEN @creditos >= 5 THEN 5 ELSE 4 END;
        SET @indice_letra = 0;

        WHILE @indice_letra < 4
        BEGIN
            SET @letra = CHAR(ASCII('A') + @indice_letra);
            SET @hora = CAST(CONCAT(@hora_base + @indice_letra, ':00:00') AS TIME(0));
            SET @hora_fin = DATEADD(MINUTE, 50, @hora);

            INSERT INTO dbo.Grupos (Id_periodo, Serie_materia, Grupo_letra, Cupo_maximo, Aula)
            VALUES (
                @id_periodo,
                @serie,
                @letra,
                40,
                N'B-10' + CAST(@indice_letra + 1 AS NVARCHAR(1))
            );
            SET @id_grupo = SCOPE_IDENTITY();

            SET @indice_dia = 0;
            WHILE @indice_dia < @total_dias
            BEGIN
                SET @dia = CASE @indice_dia
                    WHEN 0 THEN 'Lunes'
                    WHEN 1 THEN 'Martes'
                    WHEN 2 THEN 'Miércoles'
                    WHEN 3 THEN 'Jueves'
                    ELSE 'Viernes'
                END;

                INSERT INTO dbo.Horario_Grupo (Id_grupo, Dia_semana, Hora_inicio, Hora_fin)
                VALUES (@id_grupo, @dia, @hora, @hora_fin);

                SET @indice_dia = @indice_dia + 1;
            END

            SET @indice_letra = @indice_letra + 1;
        END

        FETCH NEXT FROM cur_materias INTO @serie, @creditos, @posicion;
    END

    CLOSE cur_materias;
    DEALLOCATE cur_materias;
END
GO

-- El Servicio Social se imparte en el laboratorio.
UPDATE dbo.Grupos
SET Aula = N'Lab-Red'
WHERE Serie_materia = '4SC9';
GO

/* ============================================================================
   TRIGGER: al inscribirse, la materia aparece como CURSANDO en el kardex
   ============================================================================ */

IF OBJECT_ID('dbo.TR_Inscribir_Auto_Cursando', 'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Inscribir_Auto_Cursando;
GO

CREATE TRIGGER dbo.TR_Inscribir_Auto_Cursando
ON dbo.Inscripciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Kardex (Num_control, Serie, Calificacion, Estatus)
    SELECT i.Num_control, g.Serie_materia, 0.00, N'CURSANDO'
    FROM inserted i
    JOIN dbo.Grupos g ON i.Id_grupo = g.Id_grupo
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Kardex k
        WHERE k.Num_control = i.Num_control
          AND k.Serie = g.Serie_materia
          AND k.Estatus = N'CURSANDO'
    );
END
GO

/* ============================================================================
   RESUMEN
   ============================================================================ */

SELECT
    (SELECT COUNT(*) FROM dbo.Alumnos)       AS Alumnos,
    (SELECT COUNT(*) FROM dbo.Materias)      AS Materias,
    (SELECT COUNT(*) FROM dbo.Kardex)        AS Kardex,
    (SELECT COUNT(*) FROM dbo.Periodos)      AS Periodos,
    (SELECT COUNT(*) FROM dbo.Grupos)        AS Grupos,
    (SELECT COUNT(*) FROM dbo.Horario_Grupo) AS Horarios;
GO
