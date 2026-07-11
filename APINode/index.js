require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { dbConnection } = require('./database/config');

const PORT = process.env.PORT || 3001;

//Crear servidor
const app = express();

//Congiguracion CORS
app.use(cors());

//Lectura y parse del body
app.use(express.json());

//Conexion a base de datos
dbConnection();

// Ruta principal
app.get('/healthcheck', (req, res) => {
  res.json({ ok: true, message: 'API funcionando correctamente 🚀' });
});

//Rutas
app.use("/api/pokemon", require('./routes/pokemon'));

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
