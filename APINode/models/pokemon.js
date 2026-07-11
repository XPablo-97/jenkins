const { Schema, model } = require('mongoose');

const PokemonSchema = Schema({
    name: {
        type: String,
        required: true
    },
    weight: {
        type: Number
    },
    height: {
        type: Number
    },
    spriteUrl: {
        type: String
    },
    type: {
        type: String
    }
}, { collection: 'pokemones'});

PokemonSchema.method('toJSON', function(){
    const {__v, ...object} = this.toObject();
    return object;
})

module.exports = model('Pokemon', PokemonSchema);