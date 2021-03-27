const query = require ('./queries.js');
const express = require('express');

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const port = 3000;



app.get('/', (request, response) => {
    response.json({ info: request.body })
  })


app.get('/Personas',query.getPersonas);
app.post('/AgregarPersona',query.postPersonas);


//------------- EMPLEADOS --------------------
app.get('/VerEmpleadosID/:id',query.VerEmpleadosID);
app.post('/InsertEmpleado',query.InsertEmpleado);
app.put('/FijarSalarioEmpleado/:id', query.FijarSalarioEmpleado)
app.delete('/EliminarEmpleado/:id', query.EliminarEmpleado)

//------------- Libros --------------------
app.get('/VerLibrosPorTitulo/:titulo',query.VerLibrosPorTitulo);
app.post('/InsertLibro',query.InsertLibro);
app.put('/ModificarTituloLibro/:isbn', query.ModificarTituloLibro);
app.delete('/EliminarLibro/:id', query.EliminarLibro);

//------------- Préstamos ------------------
app.get('/VerPrestamosPorUsuario/:id',query.VerPrestamosPorUsuario);
app.post('/NuevoPrestamo',query.NuevoPrestamo);
app.put('/ModificarEstadoPrestamo/:idprestamo', query.ModificarEstadoPrestamo);
app.delete('/EliminarPrestamo/:id', query.EliminarPrestamo);


app.listen(port, () => {
  console.log(`Servidor alojado en el puerto: ${port}.`)
})
