const Pool = require('pg').Pool
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Biblioteca',
  password: '1234',
  port: 5432,
})

//------------------------------ Personas --------------------------------------
const getPersonas = (request,response) => {    
    pool.query('select * from personas',(error, results) => {
        if (error) {
            throw error
        }
        response.status(200).json(results.rows)
    })
}
const postPersonas = (request,response) => {
    const {nombre, apellido1, apellido2, telefono, correo} = request.body
    pool.query('insert into Personas (Nombre, Apellido1, Apellido2, Telefono, Correo) values($1,$2,$3,$4,$5)',
    [nombre, apellido1, apellido2, telefono, correo],
     (error, results) =>{
        if (error) {
            throw error
          }
          response.status(201).send(console.log(request.body))
    })
}

//------------------------------ Empleados --------------------------------------
const VerEmpleadosID = (request,response) => {
    const id = parseInt(request.params.id)
    pool.query('select * from verempleadosid($1)',[id], (error, results) => {
        if (error){
            throw error
        }
        response.status(200).json(results.rows)
    })

}
const InsertEmpleado = (request,response) =>{
    const {nombre, apellido1, apellido2, telefono, correo, idpuesto, salario} = request.body
    pool.query('call insertempleado ($1,$2,$3,$4,$5,$6,$7)',[nombre, apellido1, apellido2, telefono, correo, idpuesto, salario], 
    (error, results)=>{
        if (error){
            throw error
        }
        response.status(201).send('Empleado insertado')
    })
}
const FijarSalarioEmpleado =  (request,response) =>{
    const id = parseInt (request.params.id)
    const {salario} = request.body
    pool.query('call fijarsalarioempleado ($1,$2)',[id,salario],
    (error,results) =>{
        if(error){
            throw error
        }
        response.status(200).send(`Salario fijado a: ${salario}`)
    })
}
const EliminarEmpleado =  (request,response) =>{
    const id = parseInt (request.params.id)
    pool.query('call eliminarempleado ($1)',[id],
    (error,results) =>{
        if(error){
            throw error
        }
        response.status(200).send(`Empleado ${id} eliminado `)
    })
}
//------------------------------ Libros --------------------------------------

const VerLibrosPorTitulo = (request,response) => {
    const titulo = request.params.titulo
    pool.query('select * from verlibrosportitulo($1)',[titulo], (error, results) => {
        if (error){
            throw error
        }
        response.status(200).json(results.rows)
    })

}
const InsertLibro = (request,response) =>{
    const {titulo, año, edicion, editorial, idioma, idautor} = request.body
    pool.query('call insertlibro ($1,$2,$3,$4,$5,$6)',[titulo, año, edicion, editorial, idioma, idautor], 
    (error, results)=>{
        if (error){
            throw error
        }
        response.status(201).send(`libro ${titulo} insertado`)
    })
}
const ModificarTituloLibro = (request,response) =>{
    const isbn = parseInt (request.params.isbn)
    const {titulo} = request.body
    pool.query('call modificartitulolibro ($1,$2)',[isbn,titulo],
    (error,results) =>{
        if(error){
            throw error
        }
        response.status(200).send(`Titulo de libro modificado a: ${titulo}`)
    })
}
const EliminarLibro =  (request,response) =>{
    const id = parseInt (request.params.id)
    pool.query('call eliminarlibro ($1)',[id],
    (error,results) =>{
        if(error){
            throw error
        }
        response.status(200).send(`Libro con el isbn: ${id} eliminado `)
    })
}
//------------------------------ Libros --------------------------------------
const VerPrestamosPorUsuario = (request,response) => {
    const id = request.params.id
    pool.query('select * from verprestamoporusuario($1)',[id], (error, results) => {
        if (error){
            throw error
        }
        response.status(200).json(results.rows)
    })

}
const NuevoPrestamo = (request,response) =>{
    const {idusuario, idempleado, fechadev, idlibro} = request.body
    pool.query('call nuevoprestamo ($1,$2,$3,$4)',[idusuario, idempleado, fechadev, idlibro], 
    (error, results)=>{
        if (error){
            throw error
        }
        response.status(201).send(`Prestamo a ${idusuario} creado`)
    })
}
const ModificarEstadoPrestamo = (request,response) =>{
    const idprestamo = parseInt (request.params.idprestamo)
    pool.query('call modifestadoprestamo($1)',[idprestamo],
    (error,results) =>{
        if(error){
            throw error
        }
        response.status(200).send(`Estado modificado `)
    })
}
const EliminarPrestamo =  (request,response) =>{
    const id = parseInt (request.params.id)
    pool.query('call eliminarprestamo ($1)',[id],
    (error,results) =>{
        if(error){
            throw error
        }
        response.status(200).send(`Prestamo con el id: ${id} eliminado `)
    })
}
module.exports = {
    getPersonas,
    postPersonas,
    //  Empleados
    VerEmpleadosID,
    InsertEmpleado,
    FijarSalarioEmpleado,
    EliminarEmpleado,
    //  Libros
    VerLibrosPorTitulo,
    InsertLibro,
    ModificarTituloLibro,
    EliminarLibro,
    //  Prestamos
    VerPrestamosPorUsuario,
    NuevoPrestamo,
    ModificarEstadoPrestamo,
    EliminarPrestamo
}


