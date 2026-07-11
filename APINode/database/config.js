const mongoose = require('mongoose');

const MONGO_URI = process.env.MONGO_URI || '';

const dbConnection = async () => {
    mongoose
    .connect(MONGO_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    })
    .then(() => console.log('🚀 Conexión exitosa a MongoDB'))
    .catch((error) => console.error('Error conectando a MongoDB:', error));
}

module.exports = {
    dbConnection
}