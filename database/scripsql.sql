-- Database: Biblioteca

--DROP DATABASE "Biblioteca";

CREATE DATABASE "Biblioteca"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_CR.UTF-8'
    LC_CTYPE = 'es_CR.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

CREATE TABLE Autores (
	IDAutor SERIAL PRIMARY KEY,
	Nombre VARCHAR(15),
	Apellido VARCHAR(15)
);

CREATE TABLE Libros (
	ISBN SERIAL PRIMARY KEY,
	Titulo VARCHAR(30),
	Annio DATE,
	Edicion INT,
	Editorial VARCHAR(20),
	Idioma VARCHAR(15),
	IDAutor INT,
	CONSTRAINT FK_LIB_AUTOR FOREIGN KEY(IDAutor) REFERENCES Autores(IDAutor)
);

CREATE TABLE Personas(
	Cedula SERIAL PRIMARY KEY,
	Nombre VARCHAR(15),
	Apellido1 VARCHAR(15),
	Apellido2 VARCHAR(15),
	Telefono INT,
	Correo VARCHAR(35)
);

CREATE TABLE Puestos(
	ID SERIAL PRIMARY KEY,
	NombrePuesto VARCHAR(30),
	Descripcion VARCHAR(200)
);

CREATE TABLE Usuarios (
	ID SERIAL PRIMARY KEY,
	Morosidad BOOLEAN,
	Cedula INT,
	CONSTRAINT FK_USU_PERSONA FOREIGN KEY (Cedula) REFERENCES Personas(Cedula)
);

CREATE TABLE Empleados(
	ID SERIAL PRIMARY KEY,
	FechaContratacion DATE,
	Salario INT,
	Cedula INT,
	IDPuesto INT,
	CONSTRAINT FK_EMP_PERSONA FOREIGN KEY (Cedula) REFERENCES Personas(Cedula),
	CONSTRAINT FK_USU_PUESTO FOREIGN KEY (IDPuesto) REFERENCES Puestos(ID)
);

CREATE TABLE Prestamos(
	ID SERIAL PRIMARY KEY,
	FechaPrestamo DATE,
	FechaDevolucion DATE,
	Estado BOOLEAN,
	IDUsuario INT,
	IDEmpleado INT,
	ISBN INT,
	CONSTRAINT FK_PRE_USUARIO FOREIGN KEY (IDUsuario) REFERENCES Usuarios(ID),
	CONSTRAINT FK_PRE_EMPLEADO FOREIGN KEY (IDEmpleado) REFERENCES Empleados(ID),
	CONSTRAINT FK_PRE_LIBRO FOREIGN KEY (ISBN) REFERENCES Libros(ISBN)
);

-----------------------------------------------Procedures-----------------------------------------------------
CREATE OR REPLACE PROCEDURE InsertUsuario(PNombre VARCHAR(15),	PApellido1 VARCHAR(15),	PApellido2 VARCHAR(15),	PTelefono INT,	PCorreo VARCHAR(35)) 
 LANGUAGE plpgsql AS 
$$
DECLARE 
	RES INT;
BEGIN 
	INSERT INTO Personas (Nombre, Apellido1, Apellido2, Telefono, Correo) 
	VALUES (PNombre, PApellido1, PApellido2, PTelefono, PCorreo) RETURNING Cedula INTO RES;
	INSERT INTO Usuarios (Cedula,Morosidad) values (RES,FALSE);
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE InsertEmpleado(PNombre VARCHAR(15),PApellido1 VARCHAR(15),PApellido2 VARCHAR(15),PTelefono INT,PCorreo VARCHAR(35),PIDPuesto INT,PSalario INT) 
 LANGUAGE plpgsql AS 
$$
DECLARE 
	RES INT;
BEGIN 
	INSERT INTO Personas (Nombre, Apellido1, Apellido2, Telefono, Correo) 
	VALUES (PNombre, PApellido1, PApellido2, PTelefono, PCorreo) RETURNING Cedula INTO RES;
	INSERT INTO Empleados (FechaContratacion,Salario,Cedula,IDPuesto) values (now(),PSalario,RES,PIDPuesto);
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE FijarSalarioEmpleado(PIDEmpleado INT,PNUEVOSalario INT) 
 LANGUAGE plpgsql AS 
$$
BEGIN 
	UPDATE Empleados SET Salario = PNUEVOSalario WHERE Empleados.ID = PIDEmpleado;
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE EliminarEmpleado(PIDEmpleado INT)
 LANGUAGE plpgsql AS
$$
BEGIN 
  IF (NOT EXISTS(select ID from Prestamos WHERE PIDEmpleado = IDEmpleado)) THEN
   DELETE FROM Empleados WHERE ID = PIDEmpleado;
  END IF;
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE InsertLibro
(PTitulo VARCHAR(30),PAnnio Date,PEdicion int,PEditorial VARCHAR(20),PIdioma VARCHAR(15),PIDAutor INT) 
 LANGUAGE plpgsql AS 
$$
BEGIN
	INSERT INTO Libros (Titulo,Annio,Edicion,Editorial,Idioma,IDAutor) 
	VALUES (PTitulo,PAnnio,PEdicion,PEditorial,PIdioma,PIDAutor);
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ModificarTituloLibro(PISBN INT,PNuevoTitulo VARCHAR(30)) 
 LANGUAGE plpgsql AS 
$$
BEGIN 
	UPDATE Libros SET Titulo = PNuevoTitulo WHERE Libros.ISBN = PISBN;
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE EliminarLibro(PIDLibro INT) 
 LANGUAGE plpgsql AS 
$$
BEGIN 
  IF (NOT EXISTS(select ID from Prestamos WHERE PIDLibro = isbn and Estado = False)) THEN
   DELETE FROM Libros WHERE Libros.ISBN = PIDLibro;
  END IF;
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE NuevoPrestamo(PIDUsuario INT, PIDEmpleado INT, PFechaDev DATE, PIDLibro INT)
 LANGUAGE plpgsql AS 
$$
BEGIN
	INSERT INTO Prestamos (IDUsuario,IDEmpleado,FechaPrestamo,FechaDevolucion,Estado,ISBN) 
	VALUES (PIDUsuario,PIDEmpleado,CURRENT_DATE,PFechaDev,False,PIDLibro);
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ModifEstadoPrestamo	(PIDPrestamo INT) 
 LANGUAGE plpgsql AS 
$$
BEGIN 
	UPDATE Prestamos SET Estado = True WHERE Prestamos.ID = PIDPrestamo;
END
$$;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE EliminarPrestamo(pIDPrestamo INT)
 LANGUAGE plpgsql AS
 $$
 BEGIN 
  IF (NOT EXISTS(select ID from Prestamos WHERE ID = PIDPrestamo and Estado = False)) THEN
   DELETE FROM Prestamos WHERE Prestamos.ID = PIDPrestamo;
  END IF;
END
 $$;
---------------------------------------------------Function-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION VerEmpleadosID (PCedula int) RETURNS TABLE (Cedula INT,NombreCompleto VARCHAR (47), Telefono INT, Correo VARCHAR(35),FechaContratacion DATE,Puesto VARCHAR (15),Salario INT)
AS $$
DECLARE
 REG RECORD;
BEGIN
 FOR REG IN select PERSONAS.Cedula, (NOMBRE || ' ' || APELLIDO1 || ' ' || APELLIDO2) AS NombreCompleto, Personas.Telefono, Personas.Correo,Empleados.FechaContratacion,(NombrePuesto) AS Puesto,Empleados.Salario from Empleados
  INNER JOIN PERSONAS ON PERSONAS.Cedula = Empleados.Cedula
  INNER JOIN Puestos ON Puestos.ID = Empleados.IDPuesto
  where Personas.Cedula = PCedula LOOP
  Cedula:= reg.CEDULA;
  NombreCompleto:= reg.NombreCompleto;
  Telefono:= reg.Telefono;
  Correo:= reg.Correo;
  FechaContratacion:= reg.FechaContratacion;
  Puesto:= reg.Puesto;
  Salario:= reg.Salario;
  RETURN NEXT;
 END LOOP;
 RETURN;
END
$$
LANGUAGE plpgsql;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION VerLibrosPorTitulo (pTitulo VARCHAR(30)) RETURNS TABLE (ISBN INT,Titulo VARCHAR(30),Annio DOUBLE PRECISION,Edicion INT,Editorial VARCHAR(20),Idioma VARCHAR(15),Autor VARCHAR (32))
AS $$
DECLARE
 REG RECORD;
BEGIN
 FOR REG IN SELECT Libros.ISBN,Libros.Titulo,(EXTRACT(YEAR FROM Libros.Annio)) as Annio,Libros.Edicion,Libros.Editorial,Libros.Idioma,(Autores.Nombre || ', ' || Autores.Apellido) AS Autor FROM Libros
  INNER JOIN Autores ON Libros.IDAutor = Autores.IDAutor
  WHERE UPPER(Libros.Titulo) LIKE UPPER ('%' || PTitulo || '%') LOOP
  ISBN:= reg.ISBN;
  Titulo:= reg.Titulo;
  Annio:= reg.Annio;
  Edicion:= reg.Edicion;
  Editorial:= reg.Editorial;
  Idioma:= reg.Idioma;
  Autor:= reg.Autor;
  RETURN NEXT;
 END LOOP;
 RETURN;
END
$$
LANGUAGE plpgsql;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION VerPrestamoPorUsuario(PIDUsuario int) RETURNS TABLE(ID INT,FechaPrestamo DATE,FechaDevolucion DATE,Estado BOOLEAN,NombreUsuario VARCHAR (47),NombreEmpleados VARCHAR (47),Titulo VARCHAR (30))
AS $$
DECLARE
 REG RECORD;
BEGIN
 FOR REG IN SELECT Prestamos.ID,Prestamos.FechaPrestamo,Prestamos.FechaDevolucion,Prestamos.Estado,TUsuarios.NombreUsuario,TEmpleados.NombreEmpleados,Libros.Titulo FROM Prestamos
  INNER JOIN Usuarios ON Usuarios.ID = Prestamos.IDUsuario
  INNER JOIN Empleados ON Empleados.ID = Prestamos.IDEmpleado
  INNER JOIN (Select Cedula,(NOMBRE || ' ' || APELLIDO1 || ' ' || APELLIDO2) AS NombreUsuario from Personas ) TUsuarios ON TUsuarios.Cedula = Usuarios.Cedula
  INNER JOIN (Select Cedula,(NOMBRE || ' ' || APELLIDO1 || ' ' || APELLIDO2) AS NombreEmpleados from Personas ) TEmpleados ON TEmpleados.Cedula = Empleados.Cedula
  INNER JOIN Libros ON Libros.ISBN = Prestamos.ISBN
  WHERE Usuarios.ID = PIDUsuario LOOP
  ID:= REG.ID;
  FechaPrestamo:= REG.FechaPrestamo;
  FechaDevolucion:= REG.FechaDevolucion;
  Estado:= REG.Estado;
  NombreUsuario:= REG.NombreUsuario;
  NombreEmpleados:= REG.NombreEmpleados;
  Titulo:= REG.Titulo;
  RETURN NEXT;
 END LOOP;
 RETURN;
END
$$
LANGUAGE plpgsql;
------------------------------------------Inserciones--------------------------------------------------------------
INSERT INTO Autores (Nombre,Apellido) Values  ('William', 'Faulkner'), ('Oscar', 'Wilde'), ('Carmen','Lyra'), ('Franz','Kafka'), ('James','Joyce'), ('Philip','K. Dick'), ('Gabriel','García Márquez'), ('Paulo','Coelho'), ('Fiódor','Dostoievski'), ('George','Orwell'),('Nicholas','Sparks');
INSERT INTO Puestos (NombrePuesto,Descripcion) Values ('Director de biblioteca','Maximo responsable de la biblioteca'), ('Jefe de area','Dirije y es responsable del area a su cargo'), ('Responsable de coleccion','Define y gestiona un plan de desarrollo de las colecciones o de los fondos de una biblioteca'), ('Responsable de los usuarios','Es el responsable de que los usuarios dispongan de forma eficiente y con la máxima calidad de todos los recursos y servicios de la biblioteca'), ('Analista documental','Cataloga, clasifica, indiza, realiza resúmenes o abstracts de los documentos pertenecientes a una colección. Controla y mantiene el registro de autoridades u otros vocabularios controlados.');
Call InsertLibro('Cien años de soledad','01-01-1967',1,'Sudamericana','Español',7);
Call InsertLibro('Cuentos de mi tia Panchita','01-01-1920',1,'Sudamericana','Español',3);
Call InsertLibro('Every Breath','01-01-2018',1,'Tirant Lo Blanch','Ingles',1);
Call InsertLibro('The Return','01-01-2020',1,'Tirant Lo Blanch','Ingles',1);
Call InsertLibro('Cada suspiro','01-01-2018',1,'Tirant Lo Blanch','Español',11);
Call InsertLibro('En nombre del amor','01-01-2007',1,'Tirant Lo Blanch','Español',3);
Call InsertLibro('La cucarachita mandinga','01-01-1976',1,'Sudamericana','Español',3);
Call InsertEmpleado('Eitan','Solis','Pereira',75984612,'EitanMeroMero@gmail.com',1,2000000);
Call InsertEmpleado('Felipe','Perez','Ortiz',84793165,'Fepeor45@hotmail.com',5,300000);
Call InsertEmpleado('Isabella','Salas','Artavia',69582354,'Isa250695@gmail.com',4,340000);
Call InsertUsuario('Emma','Alpiza','Barrantes',27564891,'Albarrantes@gmail.com');
Call InsertUsuario('Sophia','Garcia','MARTIN',22564961,'SofiGM@gmail.com');
Call InsertUsuario('Lucas','Ruiz','DiaZ',84596123,'RuizD1307@gmail.com');
Call InsertUsuario('Oliver','Hernandez','Calvo',79486132,'Oliver4568@gmail.com');
Call NuevoPrestamo(1,1,'03/23/2021',9);
Call NuevoPrestamo(4,2,'05/15/2021',10);
Call NuevoPrestamo(1,2,'10/01/2021',12);
Call NuevoPrestamo(3,3,'03/24/2021',11);
Call NuevoPrestamo(3,1,'05/28/2021',15);
Call NuevoPrestamo(1,2,'04/20/2021',9);

