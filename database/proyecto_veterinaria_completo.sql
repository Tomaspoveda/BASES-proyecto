-- =====================================================
-- SCRIPT ÚNICO: tablas -> catálogos -> dueños/mascotas -> citas -> banco de consultas
-- Se ejecuta de principio a fin sobre cualquier servidor MySQL (borra y recrea la base).
-- Las pruebas de error usan procedimientos con HANDLER para que el script no se detenga.
-- =====================================================

-- =====================================================
-- RECONSTRUIR LA BASE DE PRUEBAS DESDE CERO
-- Orden: tablas -> catálogos -> dueños/mascotas -> citas
-- Se puede ejecutar cuantas veces quieras: borra y recrea toda la base.
-- (Un INSERT que falla gasta un id de AUTO_INCREMENT; por eso, si algo
--  sale mal a mitad de la carga, se reconstruye todo con este archivo.)
-- =====================================================
DROP DATABASE IF EXISTS proyecto_veterinaria_test;
CREATE DATABASE IF NOT EXISTS proyecto_veterinaria_test;
USE proyecto_veterinaria_test;


-- CREACIÓN DE TABLAS --
CREATE TABLE dueno (
id_dueno INT AUTO_INCREMENT PRIMARY KEY,
nombre_dueno VARCHAR(50) NOT NULL, 
calle VARCHAR(100) NOT NULL, 
ciudad VARCHAR(60) NOT NULL
);

CREATE TABLE telefono_dueno (
telefono VARCHAR(50) NOT NULL,
FK_id_dueno INT NOT NULL,
PRIMARY KEY (FK_id_dueno, telefono),
FOREIGN KEY (FK_id_dueno)
REFERENCES dueno (id_dueno));

CREATE TABLE especie (
 id_especie INT AUTO_INCREMENT PRIMARY KEY,
 nombre_especie VARCHAR(50) NOT NULL
 );
 
 CREATE TABLE raza (
 id_raza INT AUTO_INCREMENT PRIMARY KEY,
 nombre_raza VARCHAR(50) NOT NULL,
 FK_id_especie INT NOT NULL,
 FOREIGN KEY (FK_id_especie)
 REFERENCES especie (id_especie)
 );
 

CREATE TABLE mascota (
id_mascota INT AUTO_INCREMENT PRIMARY KEY,
nombre_mascota VARCHAR(50) NOT NULL,
fecha_nacimiento DATE NOT NULL,
FK_id_dueno INT NOT NULL,
FK_id_raza INT NOT NULL,
FOREIGN KEY (FK_id_dueno)
REFERENCES dueno(id_dueno),
-- Llaves foraneas independientes-- 
FOREIGN KEY (FK_id_raza)
REFERENCES raza(id_raza)
);

CREATE TABLE veterinario (  -- Relacion de recursividad explicita, un veterinario puede ser supervisado por otro veterinario
 id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
 nombre_veterinario VARCHAR(50) NOT NULL,
 especialidad VARCHAR(50) NOT NULL DEFAULT 'Medicina general', -- Si no se indica especialidad, se asume medicina general --
 FK_id_veterinario_supervisor INT,
 FOREIGN KEY (FK_id_veterinario_supervisor)
 REFERENCES veterinario (id_veterinario)
 );
 
 CREATE TABLE cita (
 FK_id_mascota INT NOT NULL, 
 numero_cita INT NOT NULL,
 fecha_cita DATE NOT NULL,
 hora TIME NOT NULL,
 motivo VARCHAR(150) NOT NULL DEFAULT 'Control general de rutina', -- Motivo más frecuente de las citas --
 FK_id_veterinario INT NOT NULL,
 PRIMARY KEY (FK_id_mascota, numero_cita),
 FOREIGN KEY (FK_id_mascota)
 REFERENCES mascota (id_mascota),
 
 FOREIGN KEY (FK_id_veterinario)
 REFERENCES veterinario (id_veterinario),
 
 UNIQUE (FK_id_veterinario, fecha_cita, hora), -- Un veterinario no puede atender dos citas al mismo tiempo --

 CHECK (numero_cita > 0) -- El número de cita nunca puede ser cero ni negativo --
 );
 
 CREATE TABLE procedimiento (
 id_procedimiento INT AUTO_INCREMENT PRIMARY KEY,
 nombre_procedimiento VARCHAR(50) NOT NULL,
 costo_referencia DECIMAL(10,2) NOT NULL, -- Almacena valores decimales grandes
 CHECK (costo_referencia >= 0) -- Condicion que evita precios negativos
 );
 
CREATE TABLE cita_procedimiento (
FK_id_mascota INT NOT NULL,
FK_numero_cita INT NOT NULL,
FK_id_procedimiento INT NOT NULL,
costo DECIMAL(10,2) NOT NULL,

PRIMARY KEY (FK_id_mascota, FK_numero_cita, FK_id_procedimiento),

FOREIGN KEY (FK_id_mascota, FK_numero_cita)
REFERENCES cita (FK_id_mascota, numero_cita),

FOREIGN KEY (FK_id_procedimiento)
REFERENCES procedimiento (id_procedimiento),

CHECK (costo > 0) -- Evita que se registre un procedimniento con costo 0 o negativo --
);
 
 CREATE TABLE medicamento (
 id_medicamento INT AUTO_INCREMENT PRIMARY KEY,
 nombre_medicamento VARCHAR(50) NOT NULL,
 presentacion VARCHAR(50) NOT NULL
 );
 
 CREATE TABLE receta (
 FK_id_mascota INT NOT NULL,
 FK_numero_cita INT NOT NULL,
 FK_id_medicamento INT NOT NULL,
 dosis VARCHAR(50) NOT NULL,
 
 PRIMARY KEY (FK_id_mascota, FK_numero_cita, FK_id_medicamento),
 
 FOREIGN KEY (FK_id_mascota, FK_numero_cita)
 REFERENCES cita (FK_id_mascota, numero_cita),
 
 FOREIGN KEY (FK_id_medicamento)
 REFERENCES medicamento (id_medicamento)
 );
 

-- =====================================================
-- DATOS DE CATÁLOGOS (escritos por el grupo)
-- Los ids quedan fijos por el orden de inserción (AUTO_INCREMENT desde 1).
-- Ojo: id_procedimiento 16 = 'Consulta diurna', id_medicamento 4 = 'Carprofeno',
-- id_veterinario 7 = 'Mateo Wilson'. El banco de consultas depende de eso.
-- Los ids 50 (procedimiento, medicamento, veterinario) NO se usarán en citas:
-- sirven para las demostraciones de DELETE + ROLLBACK.
-- =====================================================

INSERT INTO especie (nombre_especie) VALUES
('Perro'),
('Gato'),
('Conejo'),
('Ave'),
('Roedor'),
('Reptil');

INSERT INTO raza (nombre_raza, FK_id_especie) VALUES
('Labrador Retriever', 1),
('Golden Retriever', 1),
('Pastor Alemán', 1),
('Bulldog Francés', 1),
('Beagle', 1),
('Poodle', 1),
('Chihuahua', 1),
('Schnauzer', 1),
('Rottweiler', 1),
('Boxer', 1),
('Husky Siberiano', 1),
('Dálmata', 1),
('Cocker Spaniel', 1),
('Yorkshire Terrier', 1),
('Pug', 1),
('Shih Tzu', 1),
('Criollo', 1),
('Pitbull', 1),
('Border Collie', 1),
('Dachshund', 1),
('Maltés', 1),
('Gran Danés', 1),
('Siamés', 2),
('Persa', 2),
('Maine Coon', 2),
('Angora', 2),
('Bengalí', 2),
('Ragdoll', 2),
('Británico de pelo corto', 2),
('Criollo felino', 2),
('Esfinge', 2),
('Azul ruso', 2),
('Abisinio', 2),
('Birmano', 2),
('Cabeza de León', 3),
('Holandés enano', 3),
('Rex', 3),
('Gigante de Flandes', 3),
('Canario', 4),
('Periquito australiano', 4),
('Cacatúa', 4),
('Agaporni', 4),
('Ninfa', 4),
('Hámster sirio', 5),
('Cobayo', 5),
('Chinchilla', 5),
('Jerbo', 5),
('Iguana verde', 6),
('Tortuga de orejas rojas', 6),
('Gecko leopardo', 6);

INSERT INTO veterinario (nombre_veterinario, especialidad, FK_id_veterinario_supervisor) VALUES
('Laura Martínez', 'Medicina general', NULL),
('Andrés Gómez', 'Cirugía', NULL),
('Carolina Ríos', 'Medicina interna', NULL),
('Felipe Herrera', 'Dermatología', 1),
('Valentina Cruz', 'Cardiología', 2),
('Sebastián Ortiz', 'Oftalmología', 3),
('Mateo Wilson', 'Medicina general', 1),
('Daniela Vargas', 'Cirugía', 2),
('Camilo Rojas', 'Medicina general', 3),
('Isabella Mejía', 'Odontología', 1),
('Julián Castro', 'Oncología', 2),
('Natalia Peña', 'Medicina general', 3),
('Santiago Duarte', 'Neurología', 1),
('María Fernanda López', 'Dermatología', 2),
('Esteban Salazar', 'Cirugía', 3),
('Paula Jiménez', 'Medicina general', 1),
('Nicolás Aguirre', 'Animales exóticos', 2),
('Sofía Restrepo', 'Cardiología', 3),
('David Quintero', 'Ortopedia', 1),
('Juliana Cardona', 'Medicina general', 2),
('Tomás Bedoya', 'Medicina interna', 3),
('Alejandra Roldán', 'Oftalmología', 1),
('Mauricio Arango', 'Cirugía', 2),
('Catalina Zapata', 'Medicina general', 3),
('Ricardo Montoya', 'Odontología', 1),
('Manuela Ospina', 'Dermatología', 2),
('Diego Palacios', 'Medicina general', 3),
('Karen Londoño', 'Oncología', 1),
('Jorge Cárdenas', 'Ortopedia', 2),
('Luisa Giraldo', 'Medicina general', 3),
('Samuel Hoyos', 'Animales exóticos', 5),
('Gabriela Marín', 'Medicina interna', 6),
('Óscar Builes', 'Cirugía', 4),
('Diana Echeverri', 'Medicina general', 5),
('Pablo Correa', 'Neurología', 6),
('Mariana Tobón', 'Dermatología', 4),
('Hernán Uribe', 'Medicina general', 5),
('Lina Naranjo', 'Cardiología', 6),
('Iván Franco', 'Cirugía', 4),
('Verónica Salgado', 'Medicina general', 5),
('Álvaro Patiño', 'Oftalmología', 6),
('Claudia Mesa', 'Medicina interna', 4),
('Cristian Lozano', 'Ortopedia', 5),
('Tatiana Bernal', 'Medicina general', 6),
('Emilio Gaviria', 'Odontología', 4),
('Angélica Ruiz', 'Dermatología', 5),
('Rodrigo Suárez', 'Medicina general', 6),
('Silvia Pineda', 'Animales exóticos', 4),
('Fabián Ramírez', 'Cirugía', 5),
('Elena Vélez', 'Medicina general', 6);

INSERT INTO procedimiento (nombre_procedimiento, costo_referencia) VALUES
('Vacuna antirrábica', 35000),
('Vacuna triple felina', 55000),
('Vacuna polivalente canina', 60000),
('Desparasitación interna', 25000),
('Desparasitación externa', 30000),
('Baño medicado', 45000),
('Corte de uñas', 15000),
('Limpieza de oídos', 20000),
('Limpieza dental', 120000),
('Extracción dental', 90000),
('Esterilización canina hembra', 280000),
('Esterilización felina hembra', 200000),
('Castración canina macho', 220000),
('Castración felino macho', 130000),
('Implantación de microchip', 70000),
('Consulta diurna', 80000),
('Consulta nocturna', 140000),
('Consulta de urgencias', 180000),
('Consulta de control', 50000),
('Radiografía simple', 110000),
('Ecografía abdominal', 150000),
('Electrocardiograma', 130000),
('Hemograma completo', 60000),
('Perfil bioquímico', 95000),
('Examen de orina', 40000),
('Citología de piel', 55000),
('Raspado cutáneo', 50000),
('Prueba de parvovirus', 65000),
('Prueba de leucemia felina', 75000),
('Sutura de heridas', 100000),
('Drenaje de absceso', 85000),
('Curación de heridas', 40000),
('Hospitalización por día', 120000),
('Fluidoterapia', 90000),
('Transfusión sanguínea', 350000),
('Cirugía de tumor cutáneo', 450000),
('Cirugía de cesárea', 520000),
('Cirugía de fractura', 900000),
('Cirugía de hernia', 380000),
('Cirugía de cataratas', 800000),
('Tratamiento de otitis', 70000),
('Terapia láser', 85000),
('Fisioterapia', 60000),
('Eutanasia', 150000),
('Certificado de salud', 30000),
('Certificado de viaje', 60000),
('Control de peso', 35000),
('Consulta de nutrición', 70000),
('Endoscopia', 480000),
('Resonancia magnética', 1200000);

INSERT INTO medicamento (nombre_medicamento, presentacion) VALUES
('Amoxicilina', 'Suspensión oral'),
('Amoxicilina con ácido clavulánico', 'Tableta'),
('Cefalexina', 'Cápsula'),
('Carprofeno', 'Tableta'),
('Meloxicam', 'Suspensión oral'),
('Tramadol', 'Tableta'),
('Metronidazol', 'Tableta'),
('Doxiciclina', 'Tableta'),
('Enrofloxacina', 'Tableta'),
('Prednisolona', 'Tableta'),
('Dexametasona', 'Inyectable'),
('Ivermectina', 'Solución inyectable'),
('Praziquantel', 'Tableta'),
('Fenbendazol', 'Suspensión oral'),
('Furosemida', 'Tableta'),
('Enalapril', 'Tableta'),
('Pimobendán', 'Cápsula'),
('Omeprazol', 'Cápsula'),
('Ranitidina', 'Jarabe'),
('Metoclopramida', 'Inyectable'),
('Maropitant', 'Tableta'),
('Ondansetrón', 'Inyectable'),
('Loperamida', 'Tableta'),
('Sucralfato', 'Suspensión oral'),
('Gabapentina', 'Cápsula'),
('Fenobarbital', 'Tableta'),
('Diazepam', 'Inyectable'),
('Acepromazina', 'Inyectable'),
('Ketamina', 'Inyectable'),
('Propofol', 'Inyectable'),
('Atropina', 'Inyectable'),
('Cetirizina', 'Tableta'),
('Clorfeniramina', 'Jarabe'),
('Ciclosporina', 'Cápsula'),
('Oclacitinib', 'Tableta'),
('Ketoconazol', 'Tableta'),
('Itraconazol', 'Cápsula'),
('Terbinafina', 'Tableta'),
('Gentamicina oftálmica', 'Gotas oftálmicas'),
('Tobramicina oftálmica', 'Gotas oftálmicas'),
('Ciprofloxacina ótica', 'Gotas óticas'),
('Otomax', 'Gotas óticas'),
('Fipronil', 'Pipeta tópica'),
('Selamectina', 'Pipeta tópica'),
('Afoxolaner', 'Tableta masticable'),
('Fluralaner', 'Tableta masticable'),
('Vitamina B12', 'Inyectable'),
('Hierro dextrán', 'Inyectable'),
('Suero de rehidratación', 'Solución oral'),
('Probiótico veterinario', 'Sobre en polvo');

-- =====================================================
-- DUEÑOS, TELÉFONOS Y MASCOTAS (datos inventados por el grupo)
-- Dueños 56..60 no tienen mascotas a propósito (para demostrar LEFT JOIN).
-- Teléfonos de 10 dígitos, igual que la validación del frontend.
-- =====================================================

INSERT INTO dueno (nombre_dueno, calle, ciudad) VALUES
('Daniela Castro Silva', 'Diagonal 166 # 14-29', 'Manizales'),
('Fernando Acosta Pardo', 'Transversal 151 # 57-31', 'Bogotá'),
('Camila López Vargas', 'Calle 116 # 2-88', 'Bucaramanga'),
('Mauricio Ramírez Ortiz', 'Avenida 90 # 46-49', 'Bucaramanga'),
('Andrés Cano Castro', 'Calle 143 # 69-38', 'Medellín'),
('Viviana García Arias', 'Diagonal 80 # 4-91', 'Cali'),
('Gloria Cárdenas Rojas', 'Calle 103 # 75-71', 'Bucaramanga'),
('Daniela Rojas Silva', 'Diagonal 126 # 51-68', 'Medellín'),
('Fernando Acosta Mejía', 'Diagonal 133 # 4-74', 'Medellín'),
('Santiago Rodríguez Bedoya', 'Diagonal 27 # 92-80', 'Barranquilla'),
('Camilo García Mejía', 'Carrera 32 # 81-90', 'Barranquilla'),
('Camilo Bedoya Pardo', 'Avenida 144 # 52-86', 'Medellín'),
('Óscar Bedoya Mejía', 'Transversal 111 # 26-38', 'Medellín'),
('Carlos Rodríguez García', 'Diagonal 118 # 67-63', 'Cali'),
('Sebastián Díaz Bedoya', 'Transversal 120 # 66-99', 'Bucaramanga'),
('Marcela Pardo Londoño', 'Calle 75 # 41-59', 'Bogotá'),
('Esteban Bedoya Bedoya', 'Diagonal 67 # 58-24', 'Barranquilla'),
('Camilo Martínez Arias', 'Avenida 128 # 48-13', 'Medellín'),
('Fernando García Cárdenas', 'Calle 24 # 1-58', 'Pereira'),
('Nicolás Martínez Quintero', 'Carrera 64 # 16-80', 'Bogotá'),
('Nicolás Díaz Londoño', 'Avenida 40 # 1-41', 'Pereira'),
('Adriana Bedoya Cano', 'Carrera 140 # 29-61', 'Pereira'),
('Santiago Quintero Bedoya', 'Diagonal 75 # 11-54', 'Bogotá'),
('Santiago Acosta Vargas', 'Diagonal 106 # 50-20', 'Bucaramanga'),
('Sebastián Ortiz Gómez', 'Calle 100 # 10-7', 'Cali'),
('Ricardo Zuluaga Gómez', 'Calle 131 # 61-42', 'Medellín'),
('Esteban Castro López', 'Transversal 120 # 74-80', 'Bogotá'),
('Valentina Acosta Silva', 'Carrera 112 # 80-44', 'Barranquilla'),
('Jorge Londoño Bedoya', 'Calle 141 # 52-5', 'Medellín'),
('Laura Rodríguez Arias', 'Diagonal 13 # 58-97', 'Cúcuta'),
('Sebastián Mejía Bedoya', 'Calle 34 # 83-68', 'Medellín'),
('Patricia García Hernández', 'Carrera 100 # 35-55', 'Cartagena'),
('Fernando Martínez Ortiz', 'Avenida 48 # 45-23', 'Medellín'),
('Viviana Mejía Zuluaga', 'Transversal 74 # 60-23', 'Cali'),
('Patricia Mejía Cárdenas', 'Calle 135 # 68-36', 'Bogotá'),
('Paola Torres Gómez', 'Calle 117 # 83-43', 'Barranquilla'),
('Nicolás Londoño Hernández', 'Calle 91 # 21-46', 'Cartagena'),
('Nicolás Ramírez López', 'Diagonal 72 # 72-97', 'Pereira'),
('Paola Acosta Vargas', 'Diagonal 69 # 86-72', 'Bogotá'),
('Felipe Díaz López', 'Transversal 44 # 14-88', 'Bogotá'),
('Ricardo Cano Hernández', 'Calle 130 # 41-36', 'Pereira'),
('Andrés Vargas Castro', 'Carrera 67 # 33-9', 'Bogotá'),
('Fernando Zuluaga Díaz', 'Transversal 4 # 8-13', 'Medellín'),
('María Vargas López', 'Calle 144 # 74-45', 'Cali'),
('Viviana Quintero Arias', 'Diagonal 10 # 52-41', 'Manizales'),
('Paola Quintero Cárdenas', 'Transversal 31 # 88-48', 'Bucaramanga'),
('Diego Ortiz Vargas', 'Avenida 15 # 95-92', 'Barranquilla'),
('María Vargas Bedoya', 'Avenida 75 # 94-99', 'Bogotá'),
('Juliana Zuluaga Rojas', 'Avenida 150 # 3-70', 'Cali'),
('Sebastián Pardo Rodríguez', 'Calle 42 # 80-16', 'Bogotá'),
('Juan García Silva', 'Avenida 153 # 83-84', 'Medellín'),
('María Rojas Acosta', 'Carrera 92 # 54-50', 'Cali'),
('Natalia Zuluaga Rojas', 'Carrera 33 # 24-70', 'Bogotá'),
('Nicolás Londoño Pardo', 'Transversal 66 # 19-30', 'Bogotá'),
('María Díaz Pardo', 'Transversal 107 # 34-41', 'Bogotá'),
('Camila Hernández Pardo', 'Calle 167 # 66-34', 'Cali'),
('Patricia Zuluaga Cano', 'Avenida 15 # 85-2', 'Cúcuta'),
('Natalia Mejía Rodríguez', 'Carrera 131 # 20-96', 'Cali'),
('Gloria Torres Pardo', 'Avenida 88 # 26-48', 'Cali'),
('Viviana Arias Cárdenas', 'Diagonal 122 # 87-75', 'Medellín');

INSERT INTO telefono_dueno (telefono, FK_id_dueno) VALUES
('3627058602', 1),
('3584210839', 2),
('3066882811', 3),
('3658440932', 4),
('3484526309', 5),
('3765828025', 5),
('3201805154', 6),
('3299321571', 7),
('3164941577', 8),
('3188357951', 8),
('3174432568', 9),
('3576523735', 10),
('3569632792', 10),
('3515474284', 11),
('3281449766', 12),
('3565178836', 13),
('3506204842', 14),
('3967750031', 15),
('3450378495', 16),
('3183801253', 16),
('3392419689', 17),
('3821046028', 17),
('3837555597', 17),
('3540720754', 18),
('3735486439', 19),
('3061884791', 19),
('3895755521', 20),
('3824886193', 20),
('3336882834', 21),
('3728556898', 22),
('3329822290', 22),
('3044224852', 23),
('3722022697', 23),
('3043858176', 24),
('3252807001', 24),
('3594502831', 24),
('3632337352', 25),
('3667534789', 26),
('3331159212', 27),
('3636082445', 28),
('3787457212', 29),
('3576990854', 30),
('3177588814', 30),
('3190187916', 31),
('3979780252', 32),
('3016128400', 32),
('3198152473', 33),
('3573638560', 33),
('3927319796', 34),
('3073608724', 35),
('3854690598', 36),
('3819539182', 37),
('3116603304', 38),
('3284514203', 39),
('3817805780', 39),
('3370412143', 40),
('3049074182', 40),
('3889837085', 40),
('3671300668', 41),
('3922328385', 42),
('3271051298', 43),
('3725278120', 44),
('3617695851', 44),
('3904316349', 45),
('3992480052', 45),
('3913729871', 46),
('3120984264', 46),
('3942607911', 47),
('3571647744', 48),
('3967452198', 49),
('3346352136', 50),
('3586398488', 51),
('3457328409', 52),
('3342692767', 52),
('3094098584', 52),
('3388498556', 53),
('3830686695', 53),
('3389650133', 54),
('3279672683', 54),
('3811136179', 55),
('3816354011', 56),
('3276113875', 57),
('3921153277', 57),
('3186210761', 58),
('3770775106', 58),
('3261488361', 58),
('3202994461', 59),
('3516199456', 60),
('3994398286', 60);

INSERT INTO mascota (nombre_mascota, fecha_nacimiento, FK_id_dueno, FK_id_raza) VALUES
('Luna', '2016-12-11', 1, 34),
('Max', '2021-02-22', 2, 41),
('Toby', '2017-10-15', 3, 20),
('Mia', '2012-06-28', 4, 14),
('Rocky', '2018-10-11', 5, 32),
('Nala', '2011-06-13', 6, 12),
('Simba', '2023-08-01', 7, 28),
('Coco', '2011-10-01', 8, 10),
('Bella', '2019-01-04', 9, 28),
('Thor', '2017-05-28', 10, 9),
('Kira', '2014-01-03', 11, 8),
('Lola', '2022-06-28', 12, 20),
('Zeus', '2012-11-20', 13, 31),
('Mateo', '2020-01-10', 14, 5),
('Canela', '2017-04-04', 15, 3),
('Rufo', '2023-02-19', 16, 42),
('Chispa', '2018-09-24', 17, 1),
('Bruno', '2024-05-14', 18, 28),
('Maya', '2024-08-07', 19, 23),
('Nube', '2013-05-21', 20, 18),
('Oso', '2017-12-02', 21, 3),
('Pelusa', '2020-07-27', 22, 16),
('Sol', '2021-03-26', 23, 1),
('Rex', '2023-02-26', 24, 5),
('Frida', '2015-12-15', 25, 17),
('Tango', '2014-06-06', 26, 34),
('Pepa', '2025-02-07', 27, 15),
('Milo', '2016-07-03', 28, 1),
('Lucky', '2021-02-09', 29, 18),
('Greta', '2016-05-03', 30, 10),
('Duque', '2012-09-03', 31, 34),
('Perla', '2019-06-26', 32, 5),
('Gala', '2014-09-09', 33, 22),
('Rambo', '2015-10-21', 34, 16),
('Mora', '2014-03-12', 35, 16),
('Tigre', '2021-10-05', 36, 20),
('Copo', '2023-09-02', 37, 50),
('Alma', '2025-04-24', 38, 9),
('Bola', '2025-01-10', 39, 5),
('Ñoño', '2017-12-04', 40, 7),
('Kiwi', '2015-11-27', 41, 14),
('Trufa', '2016-05-10', 42, 5),
('Cleo', '2022-01-03', 43, 49),
('Boby', '2012-04-21', 44, 26),
('Sasha', '2011-01-11', 45, 45),
('Panda', '2024-06-04', 46, 9),
('Estrella', '2019-07-22', 47, 11),
('Gringo', '2020-04-02', 48, 28),
('Princesa', '2020-12-16', 49, 38),
('Moka', '2011-11-21', 50, 28),
('Chocolate', '2014-09-09', 51, 43),
('Manchas', '2016-07-18', 52, 24),
('Pipo', '2025-01-14', 53, 30),
('Lía', '2011-11-20', 54, 44),
('Ámbar', '2024-11-16', 55, 13),
('Fido', '2025-03-15', 17, 12),
('Mini', '2015-02-08', 3, 47),
('Capitán', '2014-05-07', 36, 15),
('Dulce', '2011-02-02', 40, 47),
('Nina', '2017-11-05', 17, 7),
('Luna', '2015-03-10', 34, 29),
('Max', '2024-07-18', 30, 14),
('Toby', '2017-07-28', 19, 12),
('Mia', '2020-09-24', 27, 43),
('Rocky', '2022-08-09', 48, 28),
('Nala', '2014-12-26', 55, 50),
('Simba', '2016-09-03', 17, 36),
('Coco', '2013-02-15', 14, 25),
('Bella', '2023-04-10', 46, 20),
('Thor', '2024-08-02', 50, 9),
('Kira', '2022-05-23', 47, 35),
('Lola', '2015-08-11', 38, 34),
('Zeus', '2023-07-17', 29, 31),
('Mateo', '2016-07-03', 11, 4),
('Canela', '2015-02-23', 23, 23),
('Rufo', '2013-04-11', 53, 32),
('Chispa', '2014-05-20', 34, 41),
('Bruno', '2015-03-19', 20, 9),
('Maya', '2015-08-17', 17, 34),
('Nube', '2012-09-05', 20, 49),
('Oso', '2017-01-06', 8, 29),
('Pelusa', '2020-06-13', 39, 44),
('Sol', '2011-02-02', 16, 23),
('Rex', '2011-11-11', 1, 50),
('Frida', '2011-08-02', 13, 1);

-- =====================================================
-- CITAS, PROCEDIMIENTOS POR CITA Y RECETAS (datos inventados por el grupo)
-- Reglas que se respetaron al generarlos:
--  * numero_cita crece con la fecha de cada mascota (1, 2, 3...)
--  * ninguna cita es anterior al nacimiento de la mascota
--  * un veterinario no tiene dos citas a la misma fecha y hora (UNIQUE)
--  * veterinarios 44..50, procedimiento 50 y medicamento 50 no se usan
--  * las mascotas 78..85 no tienen citas (para demostrar LEFT JOIN)
-- =====================================================

INSERT INTO cita (FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario) VALUES
(1, 1, '2024-06-25', '10:30:00', 'Vacunación anual y desparasitación', 24),
(1, 2, '2026-08-22', '12:30:00', 'Vómito y diarrea de varios días', 32),
(2, 1, '2025-12-06', '10:30:00', 'Implantación de microchip', 24),
(2, 2, '2025-12-23', '09:30:00', 'Dolor abdominal, ecografía', 40),
(3, 1, '2026-05-12', '12:00:00', 'Infección de oído, sacude la cabeza', 12),
(4, 1, '2024-07-17', '17:30:00', 'Cojera y dolor al caminar', 19),
(4, 2, '2025-09-26', '15:00:00', 'Control general de rutina', 27),
(5, 1, '2025-05-21', '17:00:00', 'Limpieza dental por mal aliento', 17),
(5, 2, '2025-07-18', '15:00:00', 'Cojera y dolor al caminar', 29),
(5, 3, '2026-09-18', '11:00:00', 'Dolor abdominal, ecografía', 3),
(6, 1, '2025-03-10', '17:30:00', 'Control general de rutina', 13),
(6, 2, '2025-09-27', '09:30:00', 'Certificado de salud para viaje', 7),
(7, 1, '2024-10-26', '12:30:00', 'Vacunación anual y desparasitación', 12),
(8, 1, '2025-02-24', '10:30:00', 'Limpieza dental por mal aliento', 40),
(8, 2, '2025-06-12', '10:30:00', 'Infección de oído, sacude la cabeza', 4),
(8, 3, '2025-10-16', '09:00:00', 'Control general de rutina', 12),
(8, 4, '2026-05-18', '10:00:00', 'Lesiones y picazón en la piel', 34),
(9, 1, '2024-07-24', '11:00:00', 'Dolor abdominal, ecografía', 15),
(9, 2, '2025-02-03', '17:00:00', 'Control general de rutina', 9),
(9, 3, '2025-09-11', '12:00:00', 'Control general de rutina', 34),
(10, 1, '2024-11-13', '08:30:00', 'Urgencia nocturna, decaimiento', 3),
(10, 2, '2024-12-14', '13:30:00', 'Control general de rutina', 27),
(11, 1, '2024-05-06', '08:30:00', 'Vómito y diarrea de varios días', 42),
(11, 2, '2024-06-04', '17:00:00', 'Lesiones y picazón en la piel', 22),
(11, 3, '2025-01-24', '08:00:00', 'Cojera y dolor al caminar', 29),
(11, 4, '2026-02-05', '16:30:00', 'Vómito y diarrea de varios días', 32),
(12, 1, '2024-04-18', '17:00:00', 'Limpieza dental por mal aliento', 24),
(12, 2, '2024-10-09', '10:30:00', 'Esterilización programada', 9),
(12, 3, '2025-06-23', '15:30:00', 'Herida por pelea o accidente', 1),
(12, 4, '2026-01-09', '11:00:00', 'Urgencia nocturna, decaimiento', 33),
(12, 5, '2026-10-30', '16:00:00', 'Lesiones y picazón en la piel', 43),
(13, 1, '2026-03-26', '13:00:00', 'Cojera y dolor al caminar', 21),
(13, 2, '2026-04-23', '17:00:00', 'Limpieza dental por mal aliento', 43),
(14, 1, '2024-01-26', '16:30:00', 'Dolor abdominal, ecografía', 5),
(14, 2, '2024-03-16', '09:00:00', 'Control general de rutina', 30),
(15, 1, '2025-08-18', '13:30:00', 'Pulgas y garrapatas', 26),
(16, 1, '2025-09-23', '15:00:00', 'Control general de rutina', 37),
(16, 2, '2025-12-09', '17:00:00', 'Control general de rutina', 9),
(16, 3, '2026-03-02', '10:00:00', 'Infección de oído, sacude la cabeza', 3),
(16, 4, '2026-06-08', '10:00:00', 'Control general de rutina', 30),
(17, 1, '2026-01-22', '13:30:00', 'Infección de oído, sacude la cabeza', 6),
(17, 2, '2026-10-12', '17:00:00', 'Lagrimeo y ojo rojo', 26),
(18, 1, '2025-12-08', '08:00:00', 'Cojera y dolor al caminar', 43),
(18, 2, '2026-03-11', '08:30:00', 'Herida por pelea o accidente', 5),
(18, 3, '2026-04-15', '15:30:00', 'Control cardiológico', 23),
(19, 1, '2025-06-24', '08:30:00', 'Vacunación anual y desparasitación', 34),
(19, 2, '2025-09-05', '16:00:00', 'Urgencia nocturna, decaimiento', 15),
(19, 3, '2025-11-28', '10:00:00', 'Control general de rutina', 7),
(19, 4, '2026-01-07', '12:30:00', 'Control general de rutina', 37),
(19, 5, '2026-08-03', '13:00:00', 'Infección de oído, sacude la cabeza', 40),
(20, 1, '2025-05-13', '09:00:00', 'Cojera y dolor al caminar', 43),
(20, 2, '2025-07-10', '13:00:00', 'Infección de oído, sacude la cabeza', 14),
(20, 3, '2026-09-22', '12:30:00', 'Lesiones y picazón en la piel', 31),
(20, 4, '2026-10-22', '14:30:00', 'Cojera y dolor al caminar', 43),
(21, 1, '2026-01-10', '17:30:00', 'Control general de rutina', 12),
(21, 2, '2026-04-29', '09:00:00', 'Infección de oído, sacude la cabeza', 9),
(22, 1, '2024-05-16', '08:00:00', 'Control general de rutina', 27),
(22, 2, '2024-10-18', '15:00:00', 'Exámenes de laboratorio de control', 32),
(22, 3, '2025-05-21', '12:30:00', 'Exámenes de laboratorio de control', 21),
(22, 4, '2026-01-26', '08:00:00', 'Vacunación anual y desparasitación', 30),
(23, 1, '2025-02-19', '11:30:00', 'Cojera y dolor al caminar', 1),
(23, 2, '2025-06-30', '08:00:00', 'Vómito y diarrea de varios días', 21),
(23, 3, '2025-07-18', '16:00:00', 'Urgencia nocturna, decaimiento', 3),
(24, 1, '2025-07-07', '13:30:00', 'Vacunación anual y desparasitación', 34),
(24, 2, '2025-11-05', '12:00:00', 'Infección de oído, sacude la cabeza', 11),
(24, 3, '2026-01-22', '12:00:00', 'Masa en la piel, extirpación', 23),
(24, 4, '2026-01-29', '08:00:00', 'Exámenes de laboratorio de control', 21),
(24, 5, '2026-07-21', '13:00:00', 'Vacunación anual y desparasitación', 24),
(25, 1, '2025-02-01', '13:30:00', 'Lesiones y picazón en la piel', 43),
(25, 2, '2026-06-27', '14:30:00', 'Control general de rutina', 20),
(25, 3, '2026-07-11', '10:30:00', 'Infección de oído, sacude la cabeza', 3),
(25, 4, '2026-08-17', '12:00:00', 'Control general de rutina', 27),
(26, 1, '2024-11-09', '09:00:00', 'Esterilización programada', 20),
(26, 2, '2025-02-14', '08:00:00', 'Lesiones y picazón en la piel', 34),
(26, 3, '2026-02-28', '10:30:00', 'Cojera y dolor al caminar', 43),
(26, 4, '2026-05-18', '17:30:00', 'Herida por pelea o accidente', 20),
(27, 1, '2025-09-02', '13:00:00', 'Urgencia nocturna, decaimiento', 42),
(27, 2, '2025-09-20', '16:00:00', 'Vacunación anual y desparasitación', 20),
(27, 3, '2026-01-27', '14:30:00', 'Herida por pelea o accidente', 16),
(27, 4, '2026-03-16', '16:00:00', 'Certificado de salud para viaje', 9),
(28, 1, '2024-01-18', '15:00:00', 'Infección de oído, sacude la cabeza', 3),
(28, 2, '2024-12-26', '16:00:00', 'Lesiones y picazón en la piel', 17),
(28, 3, '2025-12-31', '14:30:00', 'Infección de oído, sacude la cabeza', 41),
(28, 4, '2026-04-11', '11:00:00', 'Exámenes de laboratorio de control', 32),
(29, 1, '2025-01-22', '10:00:00', 'Control general de rutina', 30),
(30, 1, '2024-01-16', '12:30:00', 'Control de peso y nutrición', 5),
(30, 2, '2024-03-11', '17:30:00', 'Cojera y dolor al caminar', 19),
(30, 3, '2024-08-06', '10:00:00', 'Control cardiológico', 22),
(30, 4, '2024-11-01', '16:00:00', 'Control general de rutina', 34),
(30, 5, '2024-12-18', '14:30:00', 'Vacunación anual y desparasitación', 27),
(30, 6, '2025-12-08', '16:30:00', 'Limpieza dental por mal aliento', 33),
(31, 1, '2024-01-25', '11:30:00', 'Lesiones y picazón en la piel', 23),
(31, 2, '2024-11-21', '10:00:00', 'Control de peso y nutrición', 18),
(32, 1, '2024-09-06', '11:00:00', 'Dolor abdominal, ecografía', 26),
(32, 2, '2025-06-07', '14:00:00', 'Cojera y dolor al caminar', 19),
(32, 3, '2026-05-15', '17:30:00', 'Control general de rutina', 7),
(32, 4, '2026-09-08', '08:00:00', 'Esterilización programada', 34),
(33, 1, '2024-02-24', '17:00:00', 'Vacunación anual y desparasitación', 20),
(33, 2, '2024-06-27', '08:00:00', 'Urgencia nocturna, decaimiento', 21),
(33, 3, '2024-09-09', '12:00:00', 'Control general de rutina', 16),
(33, 4, '2026-03-11', '11:00:00', 'Herida por pelea o accidente', 14),
(33, 5, '2026-06-08', '08:30:00', 'Herida por pelea o accidente', 39),
(33, 6, '2026-08-18', '09:00:00', 'Herida por pelea o accidente', 19),
(34, 1, '2024-06-13', '13:00:00', 'Control de peso y nutrición', 9),
(34, 2, '2024-06-20', '08:30:00', 'Control cardiológico', 38),
(34, 3, '2024-09-05', '17:30:00', 'Vacunación anual y desparasitación', 37),
(34, 4, '2024-09-09', '10:30:00', 'Cojera y dolor al caminar', 43),
(34, 5, '2025-05-01', '16:00:00', 'Vacunación anual y desparasitación', 40),
(34, 6, '2026-05-23', '16:30:00', 'Control cardiológico', 17),
(35, 1, '2024-05-17', '12:00:00', 'Vacunación anual y desparasitación', 7),
(35, 2, '2026-10-24', '09:30:00', 'Control general de rutina', 7),
(35, 3, '2026-11-02', '14:00:00', 'Masa en la piel, extirpación', 19),
(36, 1, '2025-02-05', '16:00:00', 'Lesiones y picazón en la piel', 18),
(36, 2, '2026-07-09', '15:30:00', 'Vómito y diarrea de varios días', 3),
(36, 3, '2026-10-01', '09:30:00', 'Control general de rutina', 5),
(37, 1, '2026-07-14', '14:30:00', 'Control cardiológico', 8),
(37, 2, '2026-09-04', '16:00:00', 'Control general de rutina', 40),
(38, 1, '2026-06-25', '09:30:00', 'Control general de rutina', 7),
(38, 2, '2026-08-12', '14:30:00', 'Pulgas y garrapatas', 12),
(38, 3, '2026-10-20', '14:00:00', 'Control cardiológico', 8),
(39, 1, '2025-08-28', '15:30:00', 'Certificado de salud para viaje', 14),
(39, 2, '2025-11-06', '17:00:00', 'Pulgas y garrapatas', 7),
(39, 3, '2025-12-13', '08:00:00', 'Dolor abdominal, ecografía', 3),
(39, 4, '2026-04-11', '16:30:00', 'Infección de oído, sacude la cabeza', 6),
(39, 5, '2026-07-29', '11:30:00', 'Dolor abdominal, ecografía', 3),
(39, 6, '2026-08-05', '13:30:00', 'Control general de rutina', 13),
(40, 1, '2024-08-23', '17:30:00', 'Herida por pelea o accidente', 27),
(40, 2, '2025-02-07', '15:00:00', 'Control general de rutina', 30),
(40, 3, '2025-03-20', '11:00:00', 'Vómito y diarrea de varios días', 32),
(40, 4, '2025-06-23', '12:00:00', 'Urgencia nocturna, decaimiento', 21),
(41, 1, '2024-02-03', '17:30:00', 'Infección de oído, sacude la cabeza', 4),
(41, 2, '2024-06-29', '11:00:00', 'Herida por pelea o accidente', 29),
(42, 1, '2024-08-15', '10:00:00', 'Vacunación anual y desparasitación', 30),
(42, 2, '2024-10-03', '09:00:00', 'Infección de oído, sacude la cabeza', 43),
(42, 3, '2024-10-04', '08:30:00', 'Control general de rutina', 6),
(42, 4, '2025-11-26', '11:00:00', 'Control de peso y nutrición', 30),
(42, 5, '2026-01-14', '14:30:00', 'Control general de rutina', 12),
(43, 1, '2024-10-15', '12:30:00', 'Vómito y diarrea de varios días', 21),
(43, 2, '2026-08-17', '16:30:00', 'Control general de rutina', 7),
(44, 1, '2024-02-27', '13:00:00', 'Limpieza dental por mal aliento', 33),
(44, 2, '2024-03-05', '10:00:00', 'Certificado de salud para viaje', 27),
(44, 3, '2024-11-07', '12:00:00', 'Cojera y dolor al caminar', 19),
(44, 4, '2025-04-05', '16:30:00', 'Cojera y dolor al caminar', 43),
(44, 5, '2025-04-25', '10:00:00', 'Implantación de microchip', 24),
(44, 6, '2025-11-12', '09:00:00', 'Certificado de salud para viaje', 7),
(45, 1, '2024-03-23', '10:30:00', 'Vómito y diarrea de varios días', 40),
(45, 2, '2024-11-11', '12:30:00', 'Lesiones y picazón en la piel', 2),
(45, 3, '2025-06-06', '14:00:00', 'Control cardiológico', 16),
(46, 1, '2024-10-23', '15:00:00', 'Certificado de salud para viaje', 7),
(46, 2, '2024-11-07', '09:30:00', 'Control de peso y nutrición', 11),
(46, 3, '2025-01-20', '09:00:00', 'Vómito y diarrea de varios días', 21),
(46, 4, '2025-01-21', '17:30:00', 'Dolor abdominal, ecografía', 18),
(46, 5, '2025-05-23', '09:00:00', 'Vacunación anual y desparasitación', 30),
(46, 6, '2025-12-22', '12:30:00', 'Infección de oído, sacude la cabeza', 36),
(47, 1, '2024-07-18', '17:30:00', 'Certificado de salud para viaje', 20),
(47, 2, '2024-10-09', '09:30:00', 'Herida por pelea o accidente', 15),
(47, 3, '2025-02-04', '10:30:00', 'Herida por pelea o accidente', 12),
(47, 4, '2025-02-14', '08:00:00', 'Urgencia nocturna, decaimiento', 3),
(47, 5, '2025-09-29', '14:00:00', 'Lesiones y picazón en la piel', 3),
(47, 6, '2026-09-08', '12:00:00', 'Herida por pelea o accidente', 19),
(48, 1, '2024-04-04', '13:30:00', 'Dolor abdominal, ecografía', 21),
(48, 2, '2024-09-26', '09:30:00', 'Infección de oído, sacude la cabeza', 40),
(48, 3, '2025-07-21', '08:30:00', 'Control general de rutina', 24),
(48, 4, '2026-02-20', '09:30:00', 'Esterilización programada', 20),
(48, 5, '2026-08-06', '14:30:00', 'Vómito y diarrea de varios días', 25),
(49, 1, '2024-01-25', '10:30:00', 'Certificado de salud para viaje', 35),
(49, 2, '2024-04-03', '11:00:00', 'Cojera y dolor al caminar', 29),
(50, 1, '2024-01-30', '10:00:00', 'Vómito y diarrea de varios días', 23),
(50, 2, '2025-03-01', '17:00:00', 'Exámenes de laboratorio de control', 3),
(50, 3, '2026-07-01', '16:00:00', 'Limpieza dental por mal aliento', 26),
(51, 1, '2025-05-24', '10:30:00', 'Vómito y diarrea de varios días', 25),
(51, 2, '2025-12-09', '17:30:00', 'Control general de rutina', 9),
(52, 1, '2024-08-03', '11:30:00', 'Control general de rutina', 10),
(52, 2, '2025-07-01', '09:00:00', 'Vacunación anual y desparasitación', 12),
(52, 3, '2025-07-15', '08:00:00', 'Vacunación anual y desparasitación', 7),
(52, 4, '2026-07-30', '13:00:00', 'Limpieza dental por mal aliento', 5),
(53, 1, '2025-06-18', '16:30:00', 'Control general de rutina', 37),
(53, 2, '2026-09-05', '17:30:00', 'Vacunación anual y desparasitación', 30),
(53, 3, '2026-11-06', '09:30:00', 'Lesiones y picazón en la piel', 33),
(54, 1, '2024-09-23', '13:00:00', 'Lesiones y picazón en la piel', 28),
(54, 2, '2025-06-12', '14:30:00', 'Cojera y dolor al caminar', 20),
(55, 1, '2025-02-26', '14:30:00', 'Herida por pelea o accidente', 32),
(55, 2, '2025-07-08', '11:30:00', 'Control general de rutina', 20),
(56, 1, '2025-06-23', '12:30:00', 'Vacunación anual y desparasitación', 30),
(56, 2, '2025-12-08', '08:30:00', 'Lesiones y picazón en la piel', 26),
(57, 1, '2024-02-19', '09:00:00', 'Cojera y dolor al caminar', 43),
(57, 2, '2024-05-16', '13:30:00', 'Urgencia nocturna, decaimiento', 3),
(58, 1, '2024-02-02', '09:00:00', 'Herida por pelea o accidente', 28),
(59, 1, '2024-05-20', '09:00:00', 'Infección de oído, sacude la cabeza', 19),
(59, 2, '2024-11-06', '15:00:00', 'Limpieza dental por mal aliento', 7),
(59, 3, '2024-11-19', '14:30:00', 'Certificado de salud para viaje', 30),
(59, 4, '2026-05-22', '15:30:00', 'Lesiones y picazón en la piel', 37),
(60, 1, '2024-04-18', '14:30:00', 'Certificado de salud para viaje', 9),
(60, 2, '2024-12-07', '10:30:00', 'Vómito y diarrea de varios días', 9),
(61, 1, '2025-02-15', '12:30:00', 'Herida por pelea o accidente', 34),
(61, 2, '2026-02-16', '10:00:00', 'Vómito y diarrea de varios días', 42),
(61, 3, '2026-06-17', '10:00:00', 'Limpieza dental por mal aliento', 21),
(62, 1, '2026-04-03', '13:30:00', 'Urgencia nocturna, decaimiento', 23),
(62, 2, '2026-07-22', '09:00:00', 'Vómito y diarrea de varios días', 32),
(63, 1, '2024-11-22', '10:30:00', 'Cojera y dolor al caminar', 19),
(64, 1, '2025-06-05', '15:30:00', 'Herida por pelea o accidente', 5),
(64, 2, '2025-06-27', '08:00:00', 'Urgencia nocturna, decaimiento', 41),
(64, 3, '2025-11-05', '10:00:00', 'Control general de rutina', 12),
(65, 1, '2024-09-21', '16:30:00', 'Infección de oído, sacude la cabeza', 17),
(65, 2, '2024-11-29', '09:30:00', 'Exámenes de laboratorio de control', 21),
(65, 3, '2025-12-31', '15:00:00', 'Control general de rutina', 7),
(65, 4, '2026-07-10', '08:30:00', 'Lesiones y picazón en la piel', 33),
(66, 1, '2024-02-27', '10:00:00', 'Infección de oído, sacude la cabeza', 39),
(66, 2, '2024-04-29', '14:30:00', 'Control de peso y nutrición', 2),
(66, 3, '2024-09-03', '12:00:00', 'Control general de rutina', 12),
(66, 4, '2025-03-24', '08:30:00', 'Herida por pelea o accidente', 31),
(66, 5, '2025-11-22', '14:30:00', 'Pulgas y garrapatas', 1),
(67, 1, '2024-07-03', '17:30:00', 'Control general de rutina', 30),
(67, 2, '2026-10-20', '08:30:00', 'Vómito y diarrea de varios días', 2),
(68, 1, '2026-03-06', '10:00:00', 'Cojera y dolor al caminar', 11),
(68, 2, '2026-08-31', '09:30:00', 'Vómito y diarrea de varios días', 32),
(68, 3, '2026-10-19', '09:30:00', 'Control de peso y nutrición', 1),
(69, 1, '2024-03-27', '13:00:00', 'Lesiones y picazón en la piel', 18),
(69, 2, '2024-04-06', '15:00:00', 'Control de peso y nutrición', 9),
(69, 3, '2026-05-09', '16:00:00', 'Lesiones y picazón en la piel', 35),
(70, 1, '2024-10-26', '08:00:00', 'Vacunación anual y desparasitación', 34),
(70, 2, '2025-11-20', '16:30:00', 'Pulgas y garrapatas', 12),
(70, 3, '2026-10-13', '08:30:00', 'Control general de rutina', 18),
(71, 1, '2024-08-03', '09:00:00', 'Control de peso y nutrición', 24),
(71, 2, '2026-01-09', '08:00:00', 'Dolor abdominal, ecografía', 32),
(72, 1, '2024-03-07', '11:30:00', 'Herida por pelea o accidente', 13),
(72, 2, '2024-05-16', '09:30:00', 'Control general de rutina', 16),
(72, 3, '2024-05-21', '15:30:00', 'Lesiones y picazón en la piel', 28),
(72, 4, '2025-09-15', '08:30:00', 'Vómito y diarrea de varios días', 37),
(72, 5, '2026-06-03', '16:00:00', 'Vacunación anual y desparasitación', 1),
(73, 1, '2025-05-27', '11:30:00', 'Vómito y diarrea de varios días', 3),
(73, 2, '2025-07-28', '08:00:00', 'Control general de rutina', 8),
(74, 1, '2024-10-16', '15:00:00', 'Control general de rutina', 30),
(74, 2, '2025-01-23', '16:00:00', 'Vacunación anual y desparasitación', 30),
(74, 3, '2026-03-25', '12:00:00', 'Herida por pelea o accidente', 3),
(74, 4, '2026-08-14', '10:00:00', 'Control general de rutina', 9),
(75, 1, '2025-06-10', '13:30:00', 'Pulgas y garrapatas', 16),
(76, 1, '2024-05-27', '12:30:00', 'Infección de oído, sacude la cabeza', 41),
(76, 2, '2024-10-28', '17:30:00', 'Vacunación anual y desparasitación', 12),
(76, 3, '2024-11-08', '17:00:00', 'Esterilización programada', 2),
(76, 4, '2025-01-18', '15:00:00', 'Cojera y dolor al caminar', 19),
(76, 5, '2026-09-10', '08:30:00', 'Control general de rutina', 40),
(77, 1, '2024-06-20', '13:30:00', 'Pulgas y garrapatas', 1),
(77, 2, '2024-10-10', '08:00:00', 'Control de peso y nutrición', 1),
(77, 3, '2024-11-26', '17:30:00', 'Herida por pelea o accidente', 25),
(77, 4, '2025-10-13', '17:30:00', 'Control general de rutina', 7);

INSERT INTO cita_procedimiento (FK_id_mascota, FK_numero_cita, FK_id_procedimiento, costo) VALUES
(1, 1, 2, 54000),
(1, 1, 1, 34000),
(1, 1, 4, 23000),
(1, 2, 16, 73000),
(1, 2, 23, 65000),
(1, 2, 34, 96000),
(2, 1, 15, 75000),
(2, 1, 16, 79000),
(2, 2, 16, 84000),
(2, 2, 21, 161000),
(2, 2, 20, 118000),
(3, 1, 16, 81000),
(3, 1, 8, 18000),
(3, 1, 41, 72000),
(4, 1, 16, 74000),
(4, 1, 20, 109000),
(4, 1, 43, 56000),
(4, 2, 16, 75000),
(4, 2, 47, 37000),
(5, 1, 16, 81000),
(5, 1, 9, 113000),
(5, 2, 16, 84000),
(5, 2, 20, 102000),
(5, 2, 43, 57000),
(5, 3, 16, 79000),
(5, 3, 21, 155000),
(5, 3, 20, 117000),
(6, 1, 16, 78000),
(6, 1, 47, 36000),
(6, 2, 16, 76000),
(6, 2, 46, 59000),
(6, 2, 45, 27000),
(7, 1, 2, 56000),
(7, 1, 1, 33000),
(7, 1, 4, 24000),
(8, 1, 16, 82000),
(8, 1, 9, 131000),
(8, 2, 16, 72000),
(8, 2, 8, 20000),
(8, 2, 41, 73000),
(8, 3, 16, 77000),
(8, 3, 47, 32000),
(8, 4, 16, 80000),
(8, 4, 26, 54000),
(8, 4, 27, 54000),
(9, 1, 16, 81000),
(9, 1, 21, 149000),
(9, 1, 20, 99000),
(9, 2, 16, 81000),
(9, 2, 47, 33000),
(9, 3, 16, 76000),
(9, 3, 47, 36000),
(10, 1, 17, 127000),
(10, 1, 34, 96000),
(10, 1, 33, 125000),
(10, 2, 16, 83000),
(10, 2, 47, 33000),
(11, 1, 16, 77000),
(11, 1, 23, 63000),
(11, 1, 34, 88000),
(11, 2, 16, 74000),
(11, 2, 26, 50000),
(11, 2, 27, 46000),
(11, 3, 16, 86000),
(11, 3, 20, 111000),
(11, 3, 43, 56000),
(11, 4, 16, 81000),
(11, 4, 23, 59000),
(11, 4, 34, 88000),
(12, 1, 16, 82000),
(12, 1, 9, 130000),
(12, 2, 16, 80000),
(12, 2, 11, 280000),
(12, 3, 18, 168000),
(12, 3, 30, 97000),
(12, 3, 32, 42000),
(12, 4, 17, 140000),
(12, 4, 34, 97000),
(12, 4, 33, 121000),
(12, 5, 16, 85000),
(12, 5, 26, 60000),
(12, 5, 27, 53000),
(13, 1, 16, 87000),
(13, 1, 20, 111000),
(13, 1, 43, 56000),
(13, 2, 16, 80000),
(13, 2, 9, 126000),
(14, 1, 16, 86000),
(14, 1, 21, 138000),
(14, 1, 20, 105000),
(14, 2, 16, 76000),
(14, 2, 47, 34000),
(15, 1, 16, 78000),
(15, 1, 5, 30000),
(15, 1, 6, 43000),
(16, 1, 16, 74000),
(16, 1, 47, 36000),
(16, 2, 16, 78000),
(16, 2, 47, 36000),
(16, 3, 16, 83000),
(16, 3, 8, 20000),
(16, 3, 41, 66000),
(16, 4, 16, 84000),
(16, 4, 47, 34000),
(17, 1, 16, 87000),
(17, 1, 8, 20000),
(17, 1, 41, 75000),
(17, 2, 16, 86000),
(18, 1, 16, 77000),
(18, 1, 20, 101000),
(18, 1, 43, 55000),
(18, 2, 18, 178000),
(18, 2, 30, 110000),
(18, 2, 32, 43000),
(18, 3, 16, 86000),
(18, 3, 22, 130000),
(18, 3, 21, 145000),
(19, 1, 2, 52000),
(19, 1, 1, 33000),
(19, 1, 4, 25000),
(19, 2, 17, 145000),
(19, 2, 34, 93000),
(19, 2, 33, 111000),
(19, 3, 16, 80000),
(19, 3, 47, 35000),
(19, 4, 16, 73000),
(19, 4, 47, 36000),
(19, 5, 16, 83000),
(19, 5, 8, 20000),
(19, 5, 41, 75000),
(20, 1, 16, 72000),
(20, 1, 20, 113000),
(20, 1, 43, 57000),
(20, 2, 16, 82000),
(20, 2, 8, 20000),
(20, 2, 41, 71000),
(20, 3, 16, 83000),
(20, 3, 26, 60000),
(20, 3, 27, 55000),
(20, 4, 16, 82000),
(20, 4, 20, 102000),
(20, 4, 43, 58000),
(21, 1, 16, 86000),
(21, 1, 47, 37000),
(21, 2, 16, 84000),
(21, 2, 8, 20000),
(21, 2, 41, 65000),
(22, 1, 16, 78000),
(22, 1, 47, 37000),
(22, 2, 16, 78000),
(22, 2, 23, 59000),
(22, 2, 24, 97000),
(22, 2, 25, 37000),
(22, 3, 16, 86000),
(22, 3, 23, 60000),
(22, 3, 24, 87000),
(22, 3, 25, 44000),
(22, 4, 3, 55000),
(22, 4, 1, 37000),
(22, 4, 4, 24000),
(23, 1, 16, 87000),
(23, 1, 20, 118000),
(23, 1, 43, 54000),
(23, 2, 16, 77000),
(23, 2, 23, 63000),
(23, 2, 34, 92000),
(23, 3, 17, 130000),
(23, 3, 34, 91000),
(23, 3, 33, 118000),
(24, 1, 3, 59000),
(24, 1, 1, 37000),
(24, 1, 4, 26000),
(24, 2, 16, 79000),
(24, 2, 8, 20000),
(24, 2, 41, 68000),
(24, 3, 16, 77000),
(24, 3, 23, 64000),
(24, 3, 36, 431000),
(24, 4, 16, 79000),
(24, 4, 23, 56000),
(24, 4, 24, 103000),
(24, 4, 25, 40000),
(24, 5, 3, 66000),
(24, 5, 1, 32000),
(24, 5, 4, 24000),
(25, 1, 16, 78000),
(25, 1, 26, 50000),
(25, 1, 27, 45000),
(25, 2, 16, 75000),
(25, 2, 47, 35000),
(25, 3, 16, 77000),
(25, 3, 8, 21000),
(25, 3, 41, 74000),
(25, 4, 16, 78000),
(25, 4, 47, 35000),
(26, 1, 16, 75000),
(26, 1, 12, 203000),
(26, 2, 16, 87000),
(26, 2, 26, 54000),
(26, 2, 27, 48000),
(26, 3, 16, 85000),
(26, 3, 20, 107000),
(26, 3, 43, 58000),
(26, 4, 18, 180000),
(26, 4, 30, 99000),
(26, 4, 32, 37000),
(27, 1, 17, 133000),
(27, 1, 34, 91000),
(27, 1, 33, 108000),
(27, 2, 3, 64000),
(27, 2, 1, 33000),
(27, 2, 4, 27000),
(27, 3, 18, 180000),
(27, 3, 30, 97000),
(27, 3, 32, 43000),
(27, 4, 16, 77000),
(27, 4, 46, 62000),
(27, 4, 45, 30000),
(28, 1, 16, 73000),
(28, 1, 8, 19000),
(28, 1, 41, 71000),
(28, 2, 16, 87000),
(28, 2, 26, 51000),
(28, 2, 27, 53000),
(28, 3, 16, 76000),
(28, 3, 8, 21000),
(28, 3, 41, 70000),
(28, 4, 16, 85000),
(28, 4, 23, 59000),
(28, 4, 24, 104000),
(28, 4, 25, 36000),
(29, 1, 16, 86000),
(29, 1, 47, 37000),
(30, 1, 16, 75000),
(30, 1, 47, 35000),
(30, 1, 48, 75000),
(30, 2, 16, 73000),
(30, 2, 20, 117000),
(30, 2, 43, 66000),
(30, 3, 16, 77000),
(30, 3, 22, 140000),
(30, 3, 21, 143000),
(30, 4, 16, 81000),
(30, 4, 47, 38000),
(30, 5, 3, 58000),
(30, 5, 1, 35000),
(30, 5, 4, 23000),
(30, 6, 16, 78000),
(30, 6, 9, 116000),
(31, 1, 16, 81000),
(31, 1, 26, 55000),
(31, 1, 27, 54000),
(31, 2, 16, 87000),
(31, 2, 47, 35000),
(31, 2, 48, 74000),
(32, 1, 16, 85000),
(32, 1, 21, 147000),
(32, 1, 20, 110000),
(32, 2, 16, 78000),
(32, 2, 20, 107000),
(32, 2, 43, 64000),
(32, 3, 16, 81000),
(32, 3, 47, 32000),
(32, 4, 16, 82000),
(32, 4, 11, 296000),
(33, 1, 3, 59000),
(33, 1, 1, 38000),
(33, 1, 4, 25000),
(33, 2, 17, 139000),
(33, 2, 34, 96000),
(33, 2, 33, 115000),
(33, 3, 16, 76000),
(33, 3, 47, 32000),
(33, 4, 18, 178000),
(33, 4, 30, 106000),
(33, 4, 32, 39000),
(33, 5, 18, 170000),
(33, 5, 30, 96000),
(33, 5, 32, 41000),
(33, 6, 18, 194000),
(33, 6, 30, 106000),
(33, 6, 32, 40000),
(34, 1, 16, 81000),
(34, 1, 47, 37000),
(34, 1, 48, 70000),
(34, 2, 16, 84000),
(34, 2, 22, 118000),
(34, 2, 21, 141000),
(34, 3, 3, 55000),
(34, 3, 1, 36000),
(34, 3, 4, 27000),
(34, 4, 16, 74000),
(34, 4, 20, 99000),
(34, 4, 43, 63000),
(34, 5, 3, 62000),
(34, 5, 1, 38000),
(34, 5, 4, 24000),
(34, 6, 16, 86000),
(34, 6, 22, 119000),
(34, 6, 21, 147000),
(35, 1, 3, 59000),
(35, 1, 1, 34000),
(35, 1, 4, 24000),
(35, 2, 16, 81000),
(35, 2, 47, 38000),
(35, 3, 16, 80000),
(35, 3, 23, 61000),
(35, 3, 36, 441000),
(36, 1, 16, 77000),
(36, 1, 26, 56000),
(36, 1, 27, 50000),
(36, 2, 16, 77000),
(36, 2, 23, 64000),
(36, 2, 34, 81000),
(36, 3, 16, 76000),
(36, 3, 47, 35000),
(37, 1, 16, 80000),
(37, 1, 22, 135000),
(37, 1, 21, 157000),
(37, 2, 16, 81000),
(37, 2, 47, 38000),
(38, 1, 16, 80000),
(38, 1, 47, 38000),
(38, 2, 16, 74000),
(38, 2, 5, 29000),
(38, 2, 6, 48000),
(38, 3, 16, 87000),
(38, 3, 22, 135000),
(38, 3, 21, 144000),
(39, 1, 16, 77000),
(39, 1, 46, 61000),
(39, 1, 45, 31000),
(39, 2, 16, 85000),
(39, 2, 5, 33000),
(39, 2, 6, 42000),
(39, 3, 16, 81000),
(39, 3, 21, 153000),
(39, 3, 20, 121000),
(39, 4, 16, 82000),
(39, 4, 8, 21000),
(39, 4, 41, 75000),
(39, 5, 16, 81000),
(39, 5, 21, 154000),
(39, 5, 20, 101000),
(39, 6, 16, 87000),
(39, 6, 47, 37000),
(40, 1, 18, 166000),
(40, 1, 30, 92000),
(40, 1, 32, 37000),
(40, 2, 16, 87000),
(40, 2, 47, 33000),
(40, 3, 16, 72000),
(40, 3, 23, 59000),
(40, 3, 34, 93000),
(40, 4, 17, 126000),
(40, 4, 34, 90000),
(40, 4, 33, 130000),
(41, 1, 16, 82000),
(41, 1, 8, 19000),
(41, 1, 41, 71000),
(41, 2, 18, 195000),
(41, 2, 30, 109000),
(41, 2, 32, 43000),
(42, 1, 3, 63000),
(42, 1, 1, 32000),
(42, 1, 4, 27000),
(42, 2, 16, 80000),
(42, 2, 8, 19000),
(42, 2, 41, 70000),
(42, 3, 16, 75000),
(42, 3, 47, 32000),
(42, 4, 16, 73000),
(42, 4, 47, 34000),
(42, 4, 48, 66000),
(42, 5, 16, 77000),
(42, 5, 47, 36000),
(43, 1, 16, 72000),
(43, 1, 23, 57000),
(43, 1, 34, 87000),
(43, 2, 16, 83000),
(43, 2, 47, 34000),
(44, 1, 16, 83000),
(44, 1, 9, 121000),
(44, 2, 16, 82000),
(44, 2, 46, 56000),
(44, 2, 45, 30000),
(44, 3, 16, 76000),
(44, 3, 20, 120000),
(44, 3, 43, 54000),
(44, 4, 16, 81000),
(44, 4, 20, 115000),
(44, 4, 43, 59000),
(44, 5, 15, 76000),
(44, 5, 16, 84000),
(44, 6, 16, 88000),
(44, 6, 46, 61000),
(44, 6, 45, 29000),
(45, 1, 16, 80000),
(45, 1, 23, 55000),
(45, 1, 34, 99000),
(45, 2, 16, 73000),
(45, 2, 26, 53000),
(45, 2, 27, 50000),
(45, 3, 16, 81000),
(45, 3, 22, 136000),
(45, 3, 21, 138000),
(46, 1, 16, 82000),
(46, 1, 46, 62000),
(46, 1, 45, 31000),
(46, 2, 16, 82000),
(46, 2, 47, 35000),
(46, 2, 48, 68000),
(46, 3, 16, 82000),
(46, 3, 23, 55000),
(46, 3, 34, 82000),
(46, 4, 16, 73000),
(46, 4, 21, 140000),
(46, 4, 20, 102000),
(46, 5, 3, 60000),
(46, 5, 1, 34000),
(46, 5, 4, 26000),
(46, 6, 16, 74000),
(46, 6, 8, 20000),
(46, 6, 41, 69000),
(47, 1, 16, 77000),
(47, 1, 46, 55000),
(47, 1, 45, 32000),
(47, 2, 18, 188000),
(47, 2, 30, 97000),
(47, 2, 32, 38000),
(47, 3, 18, 195000),
(47, 3, 30, 102000),
(47, 3, 32, 43000),
(47, 4, 17, 131000),
(47, 4, 34, 97000),
(47, 4, 33, 117000),
(47, 5, 16, 84000),
(47, 5, 26, 56000),
(47, 5, 27, 53000),
(47, 6, 18, 165000),
(47, 6, 30, 105000),
(47, 6, 32, 39000),
(48, 1, 16, 76000),
(48, 1, 21, 151000),
(48, 1, 20, 116000),
(48, 2, 16, 77000),
(48, 2, 8, 21000),
(48, 2, 41, 76000),
(48, 3, 16, 75000),
(48, 3, 47, 32000),
(48, 4, 16, 82000),
(48, 4, 12, 195000),
(48, 5, 16, 86000),
(48, 5, 23, 57000),
(48, 5, 34, 90000),
(49, 1, 16, 79000),
(49, 1, 46, 65000),
(49, 1, 45, 29000),
(49, 2, 16, 73000),
(49, 2, 20, 103000),
(49, 2, 43, 55000),
(50, 1, 16, 80000),
(50, 1, 23, 65000),
(50, 1, 34, 88000),
(50, 2, 16, 86000),
(50, 2, 23, 63000),
(50, 2, 24, 90000),
(50, 2, 25, 42000),
(50, 3, 16, 82000),
(50, 3, 9, 131000),
(51, 1, 16, 85000),
(51, 1, 23, 62000),
(51, 1, 34, 84000),
(51, 2, 16, 72000),
(51, 2, 47, 35000),
(52, 1, 16, 83000),
(52, 1, 47, 36000),
(52, 2, 2, 51000),
(52, 2, 1, 37000),
(52, 2, 4, 25000),
(52, 3, 2, 51000),
(52, 3, 1, 35000),
(52, 3, 4, 26000),
(52, 4, 16, 76000),
(52, 4, 9, 124000),
(53, 1, 16, 86000),
(53, 1, 47, 35000),
(53, 2, 2, 58000),
(53, 2, 1, 36000),
(53, 2, 4, 25000),
(53, 3, 16, 84000),
(53, 3, 26, 52000),
(53, 3, 27, 47000),
(54, 1, 16, 83000),
(54, 1, 26, 57000),
(54, 1, 27, 47000),
(54, 2, 16, 73000),
(54, 2, 20, 118000),
(54, 2, 43, 61000),
(55, 1, 18, 184000),
(55, 1, 30, 95000),
(55, 1, 32, 40000),
(55, 2, 16, 83000),
(55, 2, 47, 36000),
(56, 1, 3, 54000),
(56, 1, 1, 33000),
(56, 1, 4, 24000),
(56, 2, 16, 86000),
(56, 2, 26, 59000),
(56, 2, 27, 47000),
(57, 1, 16, 82000),
(57, 1, 20, 108000),
(57, 1, 43, 59000),
(57, 2, 17, 152000),
(57, 2, 34, 89000),
(57, 2, 33, 130000),
(58, 1, 18, 193000),
(58, 1, 30, 105000),
(58, 1, 32, 41000),
(59, 1, 16, 79000),
(59, 1, 8, 21000),
(59, 1, 41, 71000),
(59, 2, 16, 74000),
(59, 2, 9, 120000),
(59, 3, 16, 86000),
(59, 3, 46, 65000),
(59, 3, 45, 29000),
(59, 4, 16, 75000),
(59, 4, 26, 53000),
(59, 4, 27, 50000),
(60, 1, 16, 79000),
(60, 1, 46, 57000),
(60, 1, 45, 31000),
(60, 2, 16, 80000),
(60, 2, 23, 62000),
(60, 2, 34, 95000),
(61, 1, 18, 165000),
(61, 1, 30, 96000),
(61, 1, 32, 43000),
(61, 2, 16, 78000),
(61, 2, 23, 63000),
(61, 2, 34, 96000),
(61, 3, 16, 72000),
(61, 3, 9, 118000),
(62, 1, 17, 153000),
(62, 1, 34, 89000),
(62, 1, 33, 129000),
(62, 2, 16, 76000),
(62, 2, 23, 57000),
(62, 2, 34, 98000),
(63, 1, 16, 73000),
(63, 1, 20, 108000),
(63, 1, 43, 59000),
(64, 1, 18, 171000),
(64, 1, 30, 103000),
(64, 1, 32, 42000),
(64, 2, 17, 140000),
(64, 2, 34, 84000),
(64, 2, 33, 131000),
(64, 3, 16, 84000),
(64, 3, 47, 34000),
(65, 1, 16, 81000),
(65, 1, 8, 20000),
(65, 1, 41, 76000),
(65, 2, 16, 84000),
(65, 2, 23, 65000),
(65, 2, 24, 97000),
(65, 2, 25, 40000),
(65, 3, 16, 73000),
(65, 3, 47, 38000),
(65, 4, 16, 80000),
(65, 4, 26, 55000),
(65, 4, 27, 52000),
(66, 1, 16, 82000),
(66, 1, 8, 22000),
(66, 1, 41, 75000),
(66, 2, 16, 81000),
(66, 2, 47, 36000),
(66, 2, 48, 72000),
(66, 3, 16, 82000),
(66, 3, 47, 37000),
(66, 4, 18, 191000),
(66, 4, 30, 105000),
(66, 4, 32, 38000),
(66, 5, 16, 75000),
(66, 5, 5, 27000),
(66, 5, 6, 43000),
(67, 1, 16, 77000),
(67, 1, 47, 33000),
(67, 2, 16, 83000),
(67, 2, 23, 55000),
(67, 2, 34, 94000),
(68, 1, 16, 77000),
(68, 1, 20, 111000),
(68, 1, 43, 56000),
(68, 2, 16, 87000),
(68, 2, 23, 57000),
(68, 2, 34, 83000),
(68, 3, 16, 80000),
(68, 3, 47, 35000),
(68, 3, 48, 70000),
(69, 1, 16, 80000),
(69, 1, 26, 55000),
(69, 1, 27, 52000),
(69, 2, 16, 75000),
(69, 2, 47, 32000),
(69, 2, 48, 66000),
(69, 3, 16, 78000),
(69, 3, 26, 60000),
(69, 3, 27, 49000),
(70, 1, 3, 59000),
(70, 1, 1, 35000),
(70, 1, 4, 27000),
(70, 2, 16, 79000),
(70, 2, 5, 31000),
(70, 2, 6, 48000),
(70, 3, 16, 86000),
(70, 3, 47, 34000),
(71, 1, 16, 75000),
(71, 1, 47, 34000),
(71, 1, 48, 74000),
(71, 2, 16, 80000),
(71, 2, 21, 160000),
(71, 2, 20, 107000),
(72, 1, 18, 194000),
(72, 1, 30, 102000),
(72, 1, 32, 43000),
(72, 2, 16, 82000),
(72, 2, 47, 34000),
(72, 3, 16, 82000),
(72, 3, 26, 50000),
(72, 3, 27, 50000),
(72, 4, 16, 77000),
(72, 4, 23, 59000),
(72, 4, 34, 89000),
(72, 5, 2, 50000),
(72, 5, 1, 36000),
(72, 5, 4, 27000),
(73, 1, 16, 74000),
(73, 1, 23, 63000),
(73, 1, 34, 88000),
(73, 2, 16, 85000),
(73, 2, 47, 38000),
(74, 1, 16, 72000),
(74, 1, 47, 33000),
(74, 2, 3, 58000),
(74, 2, 1, 36000),
(74, 2, 4, 24000),
(74, 3, 18, 166000),
(74, 3, 30, 106000),
(74, 3, 32, 40000),
(74, 4, 16, 83000),
(74, 4, 47, 35000),
(75, 1, 16, 82000),
(75, 1, 5, 28000),
(75, 1, 6, 47000),
(76, 1, 16, 85000),
(76, 1, 8, 19000),
(76, 1, 41, 66000),
(76, 2, 2, 55000),
(76, 2, 1, 34000),
(76, 2, 4, 24000),
(76, 3, 16, 87000),
(76, 3, 12, 205000),
(76, 4, 16, 75000),
(76, 4, 20, 119000),
(76, 4, 43, 59000),
(76, 5, 16, 78000),
(76, 5, 47, 35000),
(77, 1, 16, 86000),
(77, 1, 5, 31000),
(77, 1, 6, 49000),
(77, 2, 16, 73000),
(77, 2, 47, 34000),
(77, 2, 48, 68000),
(77, 3, 18, 195000),
(77, 3, 30, 97000),
(77, 3, 32, 40000),
(77, 4, 16, 81000),
(77, 4, 47, 37000);

INSERT INTO receta (FK_id_mascota, FK_numero_cita, FK_id_medicamento, dosis) VALUES
(1, 2, 21, '1 tableta al día por 10 días'),
(2, 2, 18, '1 cápsula al día por 10 días'),
(3, 1, 41, '2 gotas cada 12 horas por 10 días'),
(3, 1, 42, '3 gotas cada 8 horas por 7 días'),
(4, 1, 6, '1 tableta al día por 10 días'),
(5, 1, 1, '2 ml cada 12 horas por 7 días'),
(5, 1, 5, '3 ml cada 8 horas por 5 días'),
(5, 2, 6, '1 tableta cada 12 horas por 7 días'),
(8, 2, 41, '3 gotas cada 8 horas por 7 días'),
(8, 4, 35, '1 tableta cada 12 horas por 7 días'),
(8, 4, 36, '1 tableta cada 12 horas por 7 días'),
(9, 1, 18, '1 cápsula cada 12 horas por 7 días'),
(9, 1, 5, '5 ml al día por 7 días'),
(10, 1, 11, '1 dosis aplicada en la clínica'),
(10, 1, 1, '2 ml cada 12 horas por 7 días'),
(11, 1, 21, '1 tableta cada 8 horas por 5 días'),
(11, 1, 24, '3 ml cada 8 horas por 5 días'),
(11, 2, 35, '1 tableta al día por 10 días'),
(11, 3, 25, '1 cápsula cada 8 horas por 5 días'),
(12, 1, 5, '2 ml cada 12 horas por 7 días'),
(12, 1, 1, '2 ml cada 12 horas por 7 días'),
(12, 2, 5, '3 ml cada 8 horas por 5 días'),
(12, 3, 5, '2 ml cada 12 horas por 7 días'),
(12, 4, 11, '1 dosis aplicada en la clínica'),
(13, 1, 25, '1 cápsula cada 12 horas por 7 días'),
(13, 1, 6, '1 tableta cada 12 horas por 7 días'),
(13, 2, 1, '5 ml al día por 7 días'),
(13, 2, 5, '5 ml al día por 7 días'),
(14, 1, 5, '3 ml cada 8 horas por 5 días'),
(15, 1, 44, '1 pipeta tópica, repetir en 30 días'),
(15, 1, 45, '1 tableta cada 3 meses'),
(16, 3, 41, '3 gotas cada 8 horas por 7 días'),
(17, 1, 41, '2 gotas cada 12 horas por 10 días'),
(17, 2, 40, '3 gotas cada 8 horas por 7 días'),
(18, 1, 25, '1 cápsula al día por 10 días'),
(18, 2, 5, '2 ml cada 12 horas por 7 días'),
(18, 3, 17, '1 cápsula cada 8 horas por 5 días'),
(19, 2, 6, '1 tableta cada 12 horas por 7 días'),
(19, 5, 9, '1 tableta al día por 10 días'),
(20, 1, 6, '1 tableta al día por 10 días'),
(20, 2, 9, '1 tableta cada 8 horas por 5 días'),
(20, 4, 6, '1 tableta cada 12 horas por 7 días'),
(20, 4, 5, '2 ml cada 12 horas por 7 días'),
(21, 2, 9, '1 tableta al día por 10 días'),
(23, 1, 5, '3 ml cada 8 horas por 5 días'),
(23, 2, 18, '1 cápsula cada 8 horas por 5 días'),
(23, 3, 1, '5 ml al día por 7 días'),
(23, 3, 11, '1 dosis aplicada en la clínica'),
(24, 2, 41, '2 gotas cada 12 horas por 10 días'),
(24, 3, 5, '5 ml al día por 7 días'),
(24, 3, 6, '1 tableta cada 8 horas por 5 días'),
(25, 1, 36, '1 tableta cada 12 horas por 7 días'),
(25, 1, 35, '1 tableta al día por 10 días'),
(25, 3, 9, '1 tableta cada 12 horas por 7 días'),
(26, 1, 6, '1 tableta cada 12 horas por 7 días'),
(26, 1, 5, '2 ml cada 12 horas por 7 días'),
(26, 2, 36, '1 tableta cada 8 horas por 5 días'),
(26, 2, 10, '1 tableta cada 8 horas por 5 días'),
(26, 3, 25, '1 cápsula al día por 10 días'),
(26, 4, 1, '2 ml cada 12 horas por 7 días'),
(27, 1, 1, '2 ml cada 12 horas por 7 días'),
(27, 3, 5, '5 ml al día por 7 días'),
(27, 3, 6, '1 tableta al día por 10 días'),
(28, 2, 10, '1 tableta cada 8 horas por 5 días'),
(28, 2, 36, '1 tableta cada 8 horas por 5 días'),
(28, 3, 42, '2 gotas cada 12 horas por 10 días'),
(30, 2, 5, '2 ml cada 12 horas por 7 días'),
(30, 3, 17, '1 cápsula cada 8 horas por 5 días'),
(31, 1, 36, '1 tableta cada 8 horas por 5 días'),
(32, 1, 5, '2 ml cada 12 horas por 7 días'),
(32, 1, 18, '1 cápsula cada 12 horas por 7 días'),
(32, 2, 4, '1 tableta al día por 10 días'),
(32, 4, 6, '1 tableta cada 12 horas por 7 días'),
(32, 4, 5, '2 ml cada 12 horas por 7 días'),
(33, 2, 6, '1 tableta al día por 10 días'),
(33, 4, 6, '1 tableta cada 12 horas por 7 días'),
(33, 4, 5, '3 ml cada 8 horas por 5 días'),
(33, 5, 5, '5 ml al día por 7 días'),
(33, 6, 1, '3 ml cada 8 horas por 5 días'),
(34, 2, 16, '1 tableta al día por 10 días'),
(34, 4, 6, '1 tableta al día por 10 días'),
(34, 4, 25, '1 cápsula cada 8 horas por 5 días'),
(34, 6, 17, '1 cápsula cada 12 horas por 7 días'),
(34, 6, 16, '1 tableta cada 8 horas por 5 días'),
(35, 3, 6, '1 tableta cada 8 horas por 5 días'),
(35, 3, 5, '2 ml cada 12 horas por 7 días'),
(36, 1, 36, '1 tableta cada 8 horas por 5 días'),
(36, 2, 7, '1 tableta al día por 10 días'),
(38, 2, 43, '1 pipeta tópica, repetir en 30 días'),
(38, 3, 17, '1 cápsula cada 8 horas por 5 días'),
(38, 3, 15, '1 tableta al día por 10 días'),
(39, 2, 45, '1 tableta cada 3 meses'),
(39, 2, 43, '1 pipeta tópica, repetir en 30 días'),
(39, 3, 18, '1 cápsula cada 12 horas por 7 días'),
(39, 3, 5, '3 ml cada 8 horas por 5 días'),
(39, 4, 9, '1 tableta cada 12 horas por 7 días'),
(39, 5, 5, '5 ml al día por 7 días'),
(40, 1, 1, '2 ml cada 12 horas por 7 días'),
(40, 1, 5, '3 ml cada 8 horas por 5 días'),
(40, 3, 7, '1 tableta cada 12 horas por 7 días'),
(40, 4, 6, '1 tableta al día por 10 días'),
(40, 4, 1, '5 ml al día por 7 días'),
(41, 1, 41, '2 gotas cada 12 horas por 10 días'),
(41, 1, 42, '2 gotas cada 12 horas por 10 días'),
(41, 2, 6, '1 tableta cada 8 horas por 5 días'),
(42, 2, 42, '2 gotas cada 12 horas por 10 días'),
(42, 2, 41, '2 gotas cada 12 horas por 10 días'),
(43, 1, 21, '1 tableta cada 12 horas por 7 días'),
(44, 1, 5, '2 ml cada 12 horas por 7 días'),
(44, 1, 1, '5 ml al día por 7 días'),
(44, 4, 6, '1 tableta cada 8 horas por 5 días'),
(44, 4, 25, '1 cápsula al día por 10 días'),
(45, 1, 7, '1 tableta cada 8 horas por 5 días'),
(45, 2, 36, '1 tableta cada 8 horas por 5 días'),
(45, 2, 10, '1 tableta al día por 10 días'),
(45, 3, 15, '1 tableta cada 12 horas por 7 días'),
(46, 3, 18, '1 cápsula al día por 10 días'),
(46, 6, 9, '1 tableta cada 8 horas por 5 días'),
(46, 6, 42, '3 gotas cada 8 horas por 7 días'),
(47, 2, 5, '5 ml al día por 7 días'),
(47, 2, 6, '1 tableta cada 12 horas por 7 días'),
(47, 3, 5, '3 ml cada 8 horas por 5 días'),
(47, 3, 1, '3 ml cada 8 horas por 5 días'),
(47, 4, 1, '3 ml cada 8 horas por 5 días'),
(47, 4, 27, '1 dosis aplicada en la clínica'),
(47, 5, 35, '1 tableta cada 8 horas por 5 días'),
(48, 1, 18, '1 cápsula cada 8 horas por 5 días'),
(48, 4, 5, '5 ml al día por 7 días'),
(48, 5, 24, '2 ml cada 12 horas por 7 días'),
(49, 2, 4, '1 tableta al día por 10 días'),
(50, 1, 23, '1 tableta cada 12 horas por 7 días'),
(50, 1, 21, '1 tableta al día por 10 días'),
(50, 3, 5, '3 ml cada 8 horas por 5 días'),
(51, 1, 21, '1 tableta cada 8 horas por 5 días'),
(53, 3, 10, '1 tableta cada 8 horas por 5 días'),
(54, 1, 36, '1 tableta cada 12 horas por 7 días'),
(54, 1, 35, '1 tableta al día por 10 días'),
(55, 1, 5, '2 ml cada 12 horas por 7 días'),
(56, 2, 35, '1 tableta al día por 10 días'),
(57, 2, 27, '1 dosis aplicada en la clínica'),
(58, 1, 1, '2 ml cada 12 horas por 7 días'),
(59, 1, 41, '3 gotas cada 8 horas por 7 días'),
(59, 1, 9, '1 tableta cada 8 horas por 5 días'),
(59, 2, 5, '3 ml cada 8 horas por 5 días'),
(59, 4, 10, '1 tableta cada 12 horas por 7 días'),
(61, 1, 1, '5 ml al día por 7 días'),
(61, 1, 6, '1 tableta al día por 10 días'),
(61, 2, 23, '1 tableta cada 8 horas por 5 días'),
(61, 2, 24, '5 ml al día por 7 días'),
(62, 1, 27, '1 dosis aplicada en la clínica'),
(62, 2, 24, '3 ml cada 8 horas por 5 días'),
(64, 1, 5, '3 ml cada 8 horas por 5 días'),
(64, 2, 6, '1 tableta cada 8 horas por 5 días'),
(64, 2, 1, '5 ml al día por 7 días'),
(65, 1, 42, '2 gotas cada 12 horas por 10 días'),
(65, 4, 36, '1 tableta cada 12 horas por 7 días'),
(66, 1, 9, '1 tableta cada 8 horas por 5 días'),
(66, 5, 44, '1 pipeta tópica, repetir en 30 días'),
(67, 2, 18, '1 cápsula al día por 10 días'),
(67, 2, 7, '1 tableta cada 8 horas por 5 días'),
(68, 1, 25, '1 cápsula cada 8 horas por 5 días'),
(68, 1, 6, '1 tableta cada 8 horas por 5 días'),
(68, 2, 20, '1 dosis aplicada en la clínica'),
(69, 1, 36, '1 tableta al día por 10 días'),
(69, 3, 35, '1 tableta cada 8 horas por 5 días'),
(70, 2, 44, '1 pipeta tópica, repetir en 30 días'),
(71, 2, 18, '1 cápsula cada 8 horas por 5 días'),
(72, 3, 10, '1 tableta cada 12 horas por 7 días'),
(73, 1, 7, '1 tableta cada 12 horas por 7 días'),
(74, 3, 5, '3 ml cada 8 horas por 5 días'),
(74, 3, 1, '5 ml al día por 7 días'),
(75, 1, 44, '1 pipeta tópica, repetir en 30 días'),
(75, 1, 43, '1 pipeta tópica, repetir en 30 días'),
(76, 4, 5, '2 ml cada 12 horas por 7 días'),
(76, 4, 25, '1 cápsula al día por 10 días'),
(77, 3, 6, '1 tableta cada 8 horas por 5 días');

-- BANCO DE CONSULTAS --
-- =====================================================
-- 1. WHERE / ORDER BY
-- =====================================================

-- CONSULTA 1
-- Pregunta de negocio:
-- ¿Qué procedimientos cuestan más de $100.000 y cuáles son los más costosos?
--
-- Se usa WHERE para filtrar por costo y ORDER BY para ordenar
-- los resultados de mayor a menor.

SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > 100000
ORDER BY costo_referencia DESC;

-- CONSULTA 2
-- Pregunta de negocio:
-- ¿Qué veterinarios de la clínica trabajan en medicina general?
--
-- WHERE permite seleccionar únicamente esa especialidad
-- y ORDER BY organiza los veterinarios por nombre.

SELECT id_veterinario, nombre_veterinario, especialidad
FROM veterinario
WHERE especialidad = 'Medicina general'
ORDER BY nombre_veterinario ASC;

-- CONSULTA 3
-- Pregunta de negocio:
-- ¿Qué citas se realizaron desde el 1 de junio de 2026 y cuáles son las más recientes?
--
-- WHERE permite limitar la consulta a un periodo determinado.
-- ORDER BY permite mostrar primero las citas más recientes.

SELECT FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario
FROM cita
WHERE fecha_cita >= '2026-06-01'
ORDER BY fecha_cita DESC, hora DESC;
-- =====================================================
-- 2. UPDATE
-- =====================================================
-- Se utilizaron transacciones y rollback con el objetivo de poder hacer update dentro de la base de datos y no afectar tampoco los datos orginales

-- CONSULTA 4
-- Pregunta de negocio:
-- ¿Cómo actualizar el costo de referencia de la consulta diurna
-- si la clínica decide aumentarlo un 5 %?
--
-- UPDATE es adecuado porque queremos modificar un dato
-- de un procedimiento que ya existe.
START TRANSACTION;

-- Ver valor antes
SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE nombre_procedimiento = 'Consulta diurna';

UPDATE procedimiento
SET costo_referencia = costo_referencia * 1.05
WHERE id_procedimiento = 16;

-- Ver valor después
SELECT nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE id_procedimiento = 16;

ROLLBACK;

-- CONSULTA 5
-- Pregunta de negocio:
-- ¿Cómo cambiar la especialidad de un veterinario
-- cuando recibe una nueva asignación dentro de la clínica?
--
-- UPDATE permite modificar la información del veterinario
-- sin eliminar ni volver a crear su registro.

START TRANSACTION;

SELECT id_veterinario, nombre_veterinario, especialidad
FROM veterinario
WHERE nombre_veterinario = 'Mateo Wilson';

UPDATE veterinario
SET especialidad = 'Medicina interna'
WHERE id_veterinario = 7;

SELECT id_veterinario, nombre_veterinario, especialidad
FROM veterinario
WHERE id_veterinario = 7;

ROLLBACK;

-- CONSULTA 6
-- Pregunta de negocio:
-- ¿Cómo actualizar la presentación de un medicamento
-- cuando cambia la presentación que maneja la clínica?
--
-- UPDATE es adecuado porque el medicamento sigue siendo el mismo;
-- solamente cambia uno de sus atributos.

START TRANSACTION;

SELECT id_medicamento, nombre_medicamento, presentacion
FROM medicamento
WHERE nombre_medicamento = 'Carprofeno';

UPDATE medicamento
SET presentacion = 'Tableta masticable'
WHERE id_medicamento = 4;

SELECT id_medicamento, nombre_medicamento, presentacion
FROM medicamento
WHERE id_medicamento = 4;

ROLLBACK;

-- =====================================================
-- 3. DELETE
-- =====================================================

-- CONSULTA 7
-- Pregunta de negocio:
-- ¿Cómo eliminar un procedimiento que la clínica ya no ofrece?
--
-- DELETE es adecuado porque queremos retirar por completo
-- un registro existente del catálogo.

START TRANSACTION;

-- Ver registro antes
SELECT *
FROM procedimiento
WHERE id_procedimiento = 50;

DELETE FROM procedimiento
WHERE id_procedimiento = 50;

-- Comprobar que fue eliminado
SELECT *
FROM procedimiento
WHERE id_procedimiento = 50;

ROLLBACK;

-- Comprobar que volvió después del ROLLBACK
SELECT *
FROM procedimiento
WHERE id_procedimiento = 50;

-- CONSULTA 8
-- Pregunta de negocio:
-- ¿Cómo retirar del catálogo un medicamento
-- que la clínica dejó de manejar?
--
-- DELETE permite eliminar completamente el medicamento
-- existente del catálogo.

START TRANSACTION;

-- Ver registro antes
SELECT *
FROM medicamento
WHERE id_medicamento = 50;

DELETE FROM medicamento
WHERE id_medicamento = 50;

-- Comprobar eliminación
SELECT *
FROM medicamento
WHERE id_medicamento = 50;

ROLLBACK;

-- Comprobar restauración
SELECT *
FROM medicamento
WHERE id_medicamento = 50;

-- CONSULTA 9
-- Pregunta de negocio:
-- ¿Cómo eliminar del sistema un veterinario
-- que ya no pertenece a la clínica?
--
-- DELETE es adecuado porque queremos retirar completamente
-- el registro del veterinario.

START TRANSACTION;

-- Ver veterinario antes
SELECT *
FROM veterinario
WHERE id_veterinario = 50;

DELETE FROM veterinario
WHERE id_veterinario = 50;

-- Comprobar eliminación -- En un caso mas ral no se podria eliminar de manera tan facil un veterinario debdio a que puede estar asociandose con la tabla de CITAS si es que tiene alguna cita pendiente o asociada
SELECT *
FROM veterinario
WHERE id_veterinario = 50;

ROLLBACK;

-- Comprobar restauración
SELECT *
FROM veterinario
WHERE id_veterinario = 50;

-- =====================================================
-- 4. INNER JOINS
-- =====================================================

-- CONSULTA 10
-- Pregunta de negocio:
-- ¿Qué mascotas tiene registradas cada dueño?
--
-- INNER JOIN es adecuado porque necesitamos información
-- de DUEÑO y MASCOTA y solo nos interesan registros
-- que estén relacionados entre sí.

SELECT d.id_dueno, d.nombre_dueno, m.id_mascota, m.nombre_mascota
FROM dueno d
JOIN mascota m
ON d.id_dueno = m.FK_id_dueno
ORDER BY d.nombre_dueno;

-- CONSULTA 11
-- Pregunta de negocio:
-- ¿Qué veterinario atendió cada cita?
--
-- INNER JOIN permite relacionar cada cita con
-- el veterinario responsable de atenderla.

SELECT c.FK_id_mascota, c.numero_cita, c.fecha_cita, c.motivo, v.nombre_veterinario
FROM cita c
JOIN veterinario v
ON c.FK_id_veterinario = v.id_veterinario
ORDER BY c.fecha_cita DESC;

-- CONSULTA 12
-- Pregunta de negocio:
-- ¿Qué procedimiento se realizó y cuánto se cobró por él?
--
-- INNER JOIN permite relacionar CITA_PROCEDIMIENTO
-- con el catálogo PROCEDIMIENTO.

SELECT cp.FK_id_mascota, cp.FK_numero_cita, p.nombre_procedimiento, cp.costo
FROM cita_procedimiento cp
JOIN procedimiento p
ON cp.FK_id_procedimiento = p.id_procedimiento
ORDER BY cp.costo DESC;

-- =====================================================
-- 5. FUNCIONES DE AGREGACIÓN
-- =====================================================

-- CONSULTA 13
-- Pregunta de negocio:
-- ¿Cuántas citas tiene registradas actualmente la clínica?
--
-- COUNT es adecuado porque necesitamos contar
-- la cantidad total de registros de la tabla CITA.

SELECT COUNT(*) AS total_citas
FROM cita;

-- CONSULTA 14
-- Pregunta de negocio:
-- ¿Cuál es el valor total cobrado por todos
-- los procedimientos realizados en las citas?
--
-- SUM es adecuado porque necesitamos sumar
-- todos los valores almacenados en la columna costo.

SELECT SUM(costo) AS total_cobrado
FROM cita_procedimiento;

-- CONSULTA 15
-- Pregunta de negocio:
-- ¿Cuál es el costo de referencia promedio
-- de los procedimientos ofrecidos por la clínica?
--
-- AVG es adecuado porque necesitamos calcular
-- el promedio de todos los costos del catálogo.

SELECT AVG(costo_referencia) AS costo_promedio
FROM procedimiento;

-- =====================================================
-- 6. GROUP BY
-- =====================================================

-- CONSULTA 16
-- Pregunta de negocio:
-- ¿Cuántas citas ha atendido cada veterinario?
--
-- GROUP BY permite agrupar las citas según el veterinario
-- y COUNT permite contar cuántas citas hay en cada grupo.

SELECT FK_id_veterinario, COUNT(*) AS cantidad_citas
FROM cita
GROUP BY FK_id_veterinario
ORDER BY cantidad_citas DESC;

-- CONSULTA 17
-- Pregunta de negocio:
-- ¿Cuántas mascotas están registradas de cada raza?
--
-- GROUP BY agrupa las mascotas que tienen la misma raza
-- y COUNT calcula cuántas hay en cada grupo.

SELECT FK_id_raza, COUNT(*) AS cantidad_mascotas
FROM mascota
GROUP BY FK_id_raza
ORDER BY cantidad_mascotas DESC;

-- CONSULTA 18
-- Pregunta de negocio:
-- ¿Cuántas veces se ha realizado cada procedimiento?
--
-- GROUP BY permite agrupar los registros por procedimiento
-- y COUNT indica cuántas veces aparece cada uno.

SELECT FK_id_procedimiento, COUNT(*) AS veces_realizado
FROM cita_procedimiento
GROUP BY FK_id_procedimiento
ORDER BY veces_realizado DESC;

-- =====================================================
-- 7. HAVING
-- =====================================================
-- Usado para filtrar despues de agrupar, a diferencia de WHERE, que filtra filas antes del GROUP BY

-- CONSULTA 19
-- Pregunta de negocio:
-- ¿Qué veterinarios han atendido más de 10 citas?
--
-- GROUP BY agrupa las citas por veterinario.
-- HAVING permite filtrar únicamente los grupos
-- cuya cantidad de citas sea mayor a 10.

SELECT FK_id_veterinario, COUNT(*) AS cantidad_citas
FROM cita
GROUP BY FK_id_veterinario
HAVING COUNT(*) > 10
ORDER BY cantidad_citas DESC;

-- CONSULTA 20
-- Pregunta de negocio:
-- ¿Qué razas tienen más de 3 mascotas registradas?
--
-- GROUP BY agrupa las mascotas por raza
-- y HAVING filtra las razas con más de 3 mascotas.

SELECT FK_id_raza, COUNT(*) AS cantidad_mascotas
FROM mascota
GROUP BY FK_id_raza
HAVING COUNT(*) > 3
ORDER BY cantidad_mascotas DESC;

-- CONSULTA 21
-- Pregunta de negocio:
-- ¿Qué procedimientos tienen un costo promedio cobrado
-- superior a $100.000?
--
-- GROUP BY agrupa los registros por procedimiento.
-- AVG calcula el costo promedio de cada procedimiento.
-- HAVING conserva únicamente los promedios mayores a $100.000.

SELECT FK_id_procedimiento, AVG(costo) AS costo_promedio
FROM cita_procedimiento
GROUP BY FK_id_procedimiento
HAVING AVG(costo) > 100000
ORDER BY costo_promedio DESC;

-- =====================================================
-- 8. SUBCONSULTA WHERE
-- =====================================================
-- CONSULTA 22
-- Pregunta de negocio:
-- ¿Qué procedimientos tienen un costo de referencia
-- superior al promedio general?
--
-- La subconsulta calcula primero el costo promedio.
-- La consulta principal muestra los procedimientos
-- cuyo costo supera ese valor.

SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > (SELECT AVG(costo_referencia) FROM procedimiento)
ORDER BY costo_referencia DESC;

-- CONSULTA 23
-- Pregunta de negocio:
-- ¿Qué veterinarios han atendido al menos una cita?
--
-- La subconsulta obtiene los identificadores de los
-- veterinarios presentes en CITA.
-- IN permite comprobar si cada veterinario aparece
-- dentro de esa lista.

SELECT id_veterinario, nombre_veterinario, especialidad
FROM veterinario
WHERE id_veterinario IN (SELECT FK_id_veterinario FROM cita)
ORDER BY nombre_veterinario;

-- CONSULTA 24
-- Pregunta de negocio:
-- ¿Qué medicamentos del catálogo han sido recetados
-- al menos una vez?
--
-- La subconsulta obtiene los medicamentos presentes
-- en RECETA y la consulta principal muestra su información.

SELECT id_medicamento, nombre_medicamento, presentacion
FROM medicamento
WHERE id_medicamento IN (SELECT FK_id_medicamento FROM receta)
ORDER BY nombre_medicamento;

-- =====================================================
-- 9. SUBCONSULTA FROM
-- =====================================================
-- CONSULTA 25
-- Pregunta de negocio:
-- ¿Qué veterinarios han atendido más de 10 citas?
--
-- La subconsulta crea una tabla temporal con la cantidad
-- de citas de cada veterinario.
-- La consulta externa filtra los resultados mayores a 10.

SELECT *
FROM (SELECT FK_id_veterinario, COUNT(*) AS cantidad_citas FROM cita GROUP BY FK_id_veterinario) AS citas_por_veterinario
WHERE cantidad_citas > 10
ORDER BY cantidad_citas DESC;

-- CONSULTA 26
-- Pregunta de negocio:
-- ¿Qué procedimientos tienen un costo promedio
-- cobrado superior a $100.000?
--
-- La subconsulta calcula el costo promedio
-- de cada procedimiento.
-- La consulta externa filtra los promedios altos.

SELECT *
FROM (SELECT FK_id_procedimiento, ROUND(AVG(costo), 2) AS costo_promedio FROM cita_procedimiento GROUP BY FK_id_procedimiento) AS promedio_procedimientos
WHERE costo_promedio > 100000
ORDER BY costo_promedio DESC;

-- CONSULTA 27
-- Pregunta de negocio:
-- ¿Cuántas mascotas tiene en promedio cada dueño
-- que posee mascotas registradas?
--
-- La subconsulta cuenta las mascotas de cada dueño.
-- La consulta externa calcula el promedio de esos resultados.

SELECT ROUND(AVG(cantidad_mascotas), 2) AS promedio_mascotas_por_dueno
FROM (SELECT FK_id_dueno, COUNT(*) AS cantidad_mascotas FROM mascota GROUP BY FK_id_dueno) AS mascotas_por_dueno;

-- =====================================================
-- 10. VIEW
-- =====================================================

-- CONSULTA 28
-- Pregunta de negocio:
-- ¿Qué mascotas pertenecen a cada dueño?
--
-- Una VIEW es adecuada porque esta relación puede consultarse
-- frecuentemente y así no es necesario escribir el JOIN cada vez.

CREATE VIEW vista_duenos_mascotas AS
SELECT d.id_dueno, d.nombre_dueno, m.id_mascota, m.nombre_mascota
FROM dueno d
JOIN mascota m
ON d.id_dueno = m.FK_id_dueno;

-- Comprobacion de la Tabla
SELECT * FROM vista_duenos_mascotas;

-- CONSULTA 29
-- Pregunta de negocio:
-- ¿Qué veterinario atendió cada cita registrada?
--
-- Una VIEW permite guardar esta consulta para poder
-- reutilizarla cuando se necesite revisar las atenciones.

CREATE VIEW vista_citas_veterinarios AS
SELECT c.FK_id_mascota, c.numero_cita, c.fecha_cita, c.motivo, v.nombre_veterinario
FROM cita c
JOIN veterinario v
ON c.FK_id_veterinario = v.id_veterinario;

-- Comprobacion de la Tabla
SELECT * FROM vista_citas_veterinarios;

-- CONSULTA 30
-- Pregunta de negocio:
-- ¿Qué procedimientos tienen un costo de referencia
-- superior a $100.000?
--
-- Una VIEW es adecuada porque permite guardar este filtro
-- y consultarlo posteriormente sin repetir la condición.

CREATE VIEW vista_procedimientos_costosos AS
SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > 100000;

-- Comprobacion de la Tabla
SELECT * FROM vista_procedimientos_costosos;

-- =====================================================
-- 11. LEFT/RIGHT JOIN
-- =====================================================

-- CONSULTA 31
-- Pregunta de negocio:
-- ¿Qué veterinarios están registrados y qué citas han atendido,
-- incluyendo aquellos que todavía no tienen citas?
--
-- LEFT JOIN es adecuado porque queremos conservar todos los
-- veterinarios aunque no exista una cita relacionada.

SELECT v.id_veterinario, v.nombre_veterinario, c.numero_cita, c.fecha_cita
FROM veterinario v
LEFT JOIN cita c
ON v.id_veterinario = c.FK_id_veterinario
ORDER BY v.id_veterinario;

-- CONSULTA 32
-- Pregunta de negocio:
-- ¿Qué procedimientos existen en el catálogo y cuáles
-- han sido utilizados en alguna cita?
--
-- LEFT JOIN permite mostrar todos los procedimientos,
-- incluso aquellos que todavía no han sido realizados.

SELECT p.id_procedimiento, p.nombre_procedimiento, cp.FK_numero_cita, cp.costo
FROM procedimiento p
LEFT JOIN cita_procedimiento cp
ON p.id_procedimiento = cp.FK_id_procedimiento
ORDER BY p.id_procedimiento;

-- CONSULTA 33
-- Pregunta de negocio:
-- ¿Qué medicamentos existen en el catálogo,
-- incluyendo aquellos que nunca han sido recetados?
--
-- RIGHT JOIN es adecuado porque queremos conservar
-- todos los registros de la tabla MEDICAMENTO,
-- que está ubicada a la derecha del JOIN.

SELECT m.id_medicamento, m.nombre_medicamento, r.FK_id_mascota, r.dosis
FROM receta r
RIGHT JOIN medicamento m
ON r.FK_id_medicamento = m.id_medicamento
ORDER BY m.id_medicamento;

-- =====================================================
-- 12. SELF JOIN
-- =====================================================

-- CONSULTA 34
-- Pregunta de negocio:
-- ¿Quién es el supervisor de cada veterinario?
--
-- SELF JOIN es adecuado porque tanto el veterinario
-- como su supervisor se encuentran en la misma tabla.

SELECT v.id_veterinario, v.nombre_veterinario AS veterinario, s.nombre_veterinario AS supervisor
FROM veterinario v
JOIN veterinario s
ON v.FK_id_veterinario_supervisor = s.id_veterinario
ORDER BY v.id_veterinario;

-- CONSULTA 35
-- Pregunta de negocio:
-- ¿Qué veterinarios están bajo la supervisión
-- del veterinario identificado con ID 1?
--
-- SELF JOIN permite relacionar cada veterinario
-- con otro registro de la misma tabla que actúa como supervisor.

SELECT v.nombre_veterinario AS veterinario, s.nombre_veterinario AS supervisor
FROM veterinario v
JOIN veterinario s
ON v.FK_id_veterinario_supervisor = s.id_veterinario
WHERE s.id_veterinario = 1;

-- CONSULTA 36
-- Pregunta de negocio:
-- ¿Qué veterinarios especializados en Cirugía tienen
-- supervisor y quién es ese supervisor?
--
-- SELF JOIN permite obtener los datos del veterinario
-- y de su supervisor desde la misma tabla.

SELECT v.nombre_veterinario AS veterinario, v.especialidad, s.nombre_veterinario AS supervisor
FROM veterinario v
INNER JOIN veterinario s
ON v.FK_id_veterinario_supervisor = s.id_veterinario
WHERE v.especialidad = 'Cirugía';

-- =====================================================
-- 13. UNION / UNION ALL
-- =====================================================
-- CONSULTA 37
-- Pregunta de negocio:
-- ¿Qué veterinarios pertenecen a Medicina general o Cirugía?
--
-- UNION permite combinar los resultados de dos consultas
-- en una sola lista y elimina posibles duplicados.

SELECT id_veterinario, nombre_veterinario, especialidad
FROM veterinario
WHERE especialidad = 'Medicina general'
UNION
SELECT id_veterinario, nombre_veterinario, especialidad
FROM veterinario
WHERE especialidad = 'Cirugía';

-- CONSULTA 38
-- Pregunta de negocio:
-- ¿Qué procedimientos tienen un costo menor a $80.000
-- o superior a $200.000?
--
-- UNION permite combinar ambos grupos en una sola lista.

SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia < 80000
UNION
SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > 200000
ORDER BY costo_referencia;

-- CONSULTA 39
-- Pregunta de negocio:
-- ¿Cómo combinar procedimientos costosos y muy costosos,
-- conservando aquellos que pertenecen a ambos grupos?
--
-- UNION ALL es adecuado porque conserva las filas repetidas,
-- permitiendo identificar procedimientos que cumplen ambas condiciones.

SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > 100000
UNION ALL
SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > 200000
ORDER BY costo_referencia;
 
 -- ====== Transacciones ====== --
 -- 1. Registrar una nueva mascota y cita --
START TRANSACTION;

-- Registrar una nueva mascota
INSERT INTO mascota
(nombre_mascota, fecha_nacimiento, FK_id_dueno, FK_id_raza)
VALUES
('Luna_Prueba', '2024-05-10', 1, 1);

-- Registrar la primera cita de la mascota usando LAST_INSERT_ID()
INSERT INTO cita
(FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario)
VALUES
(LAST_INSERT_ID(), 1, '2099-01-01', '09:00:00', 'Consulta general', 7);

-- Asociar el procedimiento a la cita buscando la mascota por sus datos recién creados
INSERT INTO cita_procedimiento
(FK_id_mascota, FK_numero_cita, FK_id_procedimiento, costo)
SELECT
    m.id_mascota,
    1,
    p.id_procedimiento,
    p.costo_referencia
FROM procedimiento p
JOIN mascota m ON m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1
WHERE p.nombre_procedimiento = 'Consulta diurna'
LIMIT 1;

-- Registrar el medicamento
INSERT INTO receta
(FK_id_mascota, FK_numero_cita, FK_id_medicamento, dosis)
SELECT
    m.id_mascota,
    1,
    med.id_medicamento,
    'Segun indicacion veterinaria'
FROM medicamento med
JOIN mascota m ON m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1
WHERE med.nombre_medicamento = 'Meloxicam'
LIMIT 1;

-- Comprobar los registros sin variables
SELECT * FROM mascota 
WHERE nombre_mascota = 'Luna_Prueba' AND FK_id_dueno = 1;

SELECT c.* FROM cita c
JOIN mascota m ON c.FK_id_mascota = m.id_mascota
WHERE m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1;

SELECT cp.* FROM cita_procedimiento cp
JOIN mascota m ON cp.FK_id_mascota = m.id_mascota
WHERE m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1;

SELECT r.* FROM receta r
JOIN mascota m ON r.FK_id_mascota = m.id_mascota
WHERE m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1;

-- Confirmar la transacción
COMMIT;

-- 2. Reprogramar una cita y actualizar su información --

SELECT *
FROM cita
LIMIT 10;

START TRANSACTION;

-- 1. Reprogramar la cita
UPDATE cita -- cambia fecha, hora y veterinario --
SET fecha_cita = '2099-01-02',
    hora = '10:00:00',
    FK_id_veterinario = 8
WHERE FK_id_mascota = (
    SELECT id_mascota 
    FROM mascota 
    WHERE nombre_mascota = 'Luna_Prueba' AND FK_id_dueno = 1
)
AND numero_cita = 1;

-- 2. Actualizar la dosis registrada
UPDATE receta  -- Actualiza la información del medicamento --
SET dosis = 'Segun nueva indicacion veterinaria'
WHERE FK_id_mascota = (
    SELECT id_mascota 
    FROM mascota 
    WHERE nombre_mascota = 'Luna_Prueba' AND FK_id_dueno = 1
)
AND FK_numero_cita = 1;

-- 3. Actualizar el costo del procedimiento (MODIFICA
UPDATE cita_procedimiento -- modifica el costo registrado --
SET costo = costo * 1.05
WHERE FK_id_mascota = (
    SELECT id_mascota 
    FROM mascota 
    WHERE nombre_mascota = 'Luna_Prueba' AND FK_id_dueno = 1
)
AND FK_numero_cita = 1;

-- Comprobar los cambios
SELECT c.FK_id_mascota, c.numero_cita, c.fecha_cita, c.hora, c.motivo, c.FK_id_veterinario FROM cita c
JOIN mascota m ON c.FK_id_mascota = m.id_mascota
WHERE m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1;

SELECT r.FK_id_mascota, r.FK_numero_cita, r.FK_id_medicamento, r.dosis FROM receta r
JOIN mascota m ON r.FK_id_mascota = m.id_mascota
WHERE m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1;

SELECT cp.FK_id_mascota, cp.FK_numero_cita, cp.FK_id_procedimiento, cp.costo FROM cita_procedimiento cp
JOIN mascota m ON cp.FK_id_mascota = m.id_mascota
WHERE m.nombre_mascota = 'Luna_Prueba' AND m.FK_id_dueno = 1;

COMMIT;

-- Rollback ante un error --
-- Transacción real: las 3 instrucciones modifican tablas distintas (procedimiento, veterinario, telefono_dueno).
-- El tercer INSERT falla por la llave foránea (el dueño 999999 no existe). El procedimiento captura el error
-- con un EXIT HANDLER, ejecuta ROLLBACK y devuelve un mensaje claro; así el script completo no se detiene.
DROP PROCEDURE IF EXISTS sp_demo_rollback;

DELIMITER //

CREATE PROCEDURE sp_demo_rollback()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: el dueño 999999 no existe. Se hizo ROLLBACK de los 3 pasos.' AS resultado;
    END;

    START TRANSACTION;

    -- 1. modifica el procedimiento
    UPDATE procedimiento
    SET costo_referencia = costo_referencia + 1000
    WHERE id_procedimiento = 1;

    -- 2. modifica el veterinario
    UPDATE veterinario
    SET especialidad = 'Medicina interna'
    WHERE id_veterinario = 7;

    -- 3. condición de error: el dueño no existe (viola la llave foránea)
    INSERT INTO telefono_dueno (telefono, FK_id_dueno)
    VALUES ('3999999999', 999999);

    COMMIT;
    SELECT 'Transacción confirmada' AS resultado;
END //

DELIMITER ;

-- Antes: valores originales
SELECT id_procedimiento, costo_referencia FROM procedimiento WHERE id_procedimiento = 1;
SELECT id_veterinario, especialidad FROM veterinario WHERE id_veterinario = 7;

CALL sp_demo_rollback();

-- Después: los valores volvieron a su estado original (el ROLLBACK deshizo los pasos 1 y 2)
SELECT id_procedimiento, costo_referencia FROM procedimiento WHERE id_procedimiento = 1;
SELECT id_veterinario, especialidad FROM veterinario WHERE id_veterinario = 7;

-- Versión manual para la sustentación (detiene el script al fallar; ejecutar línea por línea):
/*
START TRANSACTION;
UPDATE procedimiento SET costo_referencia = costo_referencia + 1000 WHERE id_procedimiento = 1;
UPDATE veterinario SET especialidad = 'Medicina interna' WHERE id_veterinario = 7;
INSERT INTO telefono_dueno (telefono, FK_id_dueno) VALUES ('3999999999', 999999);  -- falla por la FK
ROLLBACK;
*/


-- ===== indices ===== --
-- Se indexan fecha_cita y costo_referencia porque son las columnas que se usan con mayor
-- frecuencia en WHERE (filtros por rango) y ORDER BY (ordenar por fecha / por precio).
-- NO se indexan las llaves primarias ni foráneas porque MySQL ya crea índices automáticos para ellas.
-- Tampoco se indexan columnas de texto libre (motivo, dosis, nombres) ni de baja selectividad,
-- porque casi no se filtran por ellas y un índice extra solo haría más lentos los INSERT/UPDATE.

-- 1. Índice para la fecha de la cita --

-- EXPLAIN ANTES del índice --
EXPLAIN
SELECT FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario
FROM cita
WHERE fecha_cita >= '2026-06-01'
ORDER BY fecha_cita DESC, hora DESC;

-- Crear el índice --
CREATE INDEX idx_cita_fecha
ON cita(fecha_cita);

-- EXPLAIN DESPUÉS del índice (debe aparecer idx_cita_fecha en possible_keys / key) --
EXPLAIN
SELECT FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario
FROM cita
WHERE fecha_cita >= '2026-06-01'
ORDER BY fecha_cita DESC, hora DESC;

-- 2. Índice para el costo de los procedimientos: filtrar por precio --

-- EXPLAIN ANTES del índice --
EXPLAIN
SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > 100000
ORDER BY costo_referencia DESC;

-- Crear el índice --
CREATE INDEX idx_procedimiento_costo
ON procedimiento(costo_referencia);

-- EXPLAIN DESPUÉS del índice --
EXPLAIN
SELECT id_procedimiento, nombre_procedimiento, costo_referencia
FROM procedimiento
WHERE costo_referencia > 100000
ORDER BY costo_referencia DESC;


-- ====== Procedimientos almacenados con parametros ====== --
-- 1. Clasificar los procedimientos segun su precio (con IF / ELSEIF) --
DROP PROCEDURE IF EXISTS sp_clasificar_costo;

DELIMITER //

CREATE PROCEDURE sp_clasificar_costo(
    IN p_costo DECIMAL(10,2),
    OUT p_categoria VARCHAR(30)
)
BEGIN
    IF p_costo <= 50000 THEN
        SET p_categoria = 'Economico';
    ELSEIF p_costo <= 150000 THEN
        SET p_categoria = 'Intermedio';
    ELSE
        SET p_categoria = 'Especializado';
    END IF;
END //

DELIMITER ;

-- Probarlo --
CALL sp_clasificar_costo(40000, @categoria);
SELECT @categoria AS categoria;
CALL sp_clasificar_costo(100000, @categoria);
SELECT @categoria AS categoria;
CALL sp_clasificar_costo(300000, @categoria);
SELECT @categoria AS categoria;


-- ====== Funciones (usadas dentro de un SELECT) ====== --
-- 1. Calcular la edad de una mascota --
DROP FUNCTION IF EXISTS fn_edad_mascota;

DELIMITER //

CREATE FUNCTION fn_edad_mascota(p_fecha_nacimiento DATE)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
END //

DELIMITER ;

-- consulta todas las mascotas junto con su edad calculada
SELECT id_mascota, nombre_mascota, fecha_nacimiento,
       fn_edad_mascota(fecha_nacimiento) AS edad
FROM mascota;

-- 2. Clasificar el costo de un procedimiento --
DROP FUNCTION IF EXISTS fn_categoria_procedimiento;

DELIMITER //

CREATE FUNCTION fn_categoria_procedimiento(
    p_costo DECIMAL(10,2)
)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_costo <= 50000 THEN
        RETURN 'Economico';
    ELSEIF p_costo <= 150000 THEN
        RETURN 'Intermedio';
    ELSE
        RETURN 'Especializado';
    END IF;
END //

DELIMITER ;

SELECT id_procedimiento, nombre_procedimiento, costo_referencia,
       fn_categoria_procedimiento(costo_referencia) AS categoria
FROM procedimiento;


-- ====== Procedimiento con manejo de errores: SIGNAL SQLSTATE ====== --
-- Actualiza la especialidad de un veterinario validando la entrada.
-- Si el id no existe o la especialidad viene vacía, devuelve un mensaje claro
-- (SQLSTATE '45000') en vez de no hacer nada o dar un error genérico.
DROP PROCEDURE IF EXISTS sp_actualizar_especialidad;

DELIMITER //

CREATE PROCEDURE sp_actualizar_especialidad(
    IN p_id_veterinario INT,
    IN p_nueva_especialidad VARCHAR(50)
)
BEGIN
    -- Comprobar que el veterinario exista
    IF NOT EXISTS (
        SELECT 1
        FROM veterinario
        WHERE id_veterinario = p_id_veterinario
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El veterinario indicado no existe.';
    ELSEIF p_nueva_especialidad IS NULL
        OR TRIM(p_nueva_especialidad) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La especialidad no puede estar vacia.';
    ELSE
        UPDATE veterinario
        SET especialidad = p_nueva_especialidad
        WHERE id_veterinario = p_id_veterinario;
    END IF;
END //

DELIMITER ;

-- Prueba con entrada VÁLIDA (id 7 existe). Se hace dentro de una transacción y se deshace para no alterar los datos --
START TRANSACTION;
CALL sp_actualizar_especialidad(7, 'Cirugia');
SELECT id_veterinario, especialidad FROM veterinario WHERE id_veterinario = 7;
ROLLBACK;

-- Pruebas con entrada INVÁLIDA: este procedimiento llama al anterior con datos malos y muestra el mensaje de error
-- capturado, sin detener el script.
DROP PROCEDURE IF EXISTS sp_demo_entradas_invalidas;

DELIMITER //

CREATE PROCEDURE sp_demo_entradas_invalidas()
BEGIN
    DECLARE v_mensaje VARCHAR(255);

    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_mensaje = MESSAGE_TEXT;
        SELECT v_mensaje AS error_capturado;
    END;

    CALL sp_actualizar_especialidad(9999, 'Cirugia');  -- id inexistente
    CALL sp_actualizar_especialidad(7, '   ');          -- especialidad vacía
END //

DELIMITER ;

CALL sp_demo_entradas_invalidas();

-- Versión manual para la sustentación (cada línea muestra el error de SIGNAL y detiene el script; ejecutar una por una):
-- CALL sp_actualizar_especialidad(9999, 'Cirugia');   -- "Error: El veterinario indicado no existe."
-- CALL sp_actualizar_especialidad(7, '   ');          -- "Error: La especialidad no puede estar vacia."
