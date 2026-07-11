const { response } = require("express");
const Pokemon = require('../models/pokemon');

const guardarPokemon = async (req, res = response) => {
    const uid = req.uid;
    const pokemon = new Pokemon(
        {
            pokeid: uid,
            ...req.body
        });
    try {
        const pokemonDb = await pokemon.save();
        res.status(200)
        .json({
            ok: true,
            result: pokemonDb
        });
    } catch (error) {
        res.status(500)
        .json({
            ok:false,
            mgs: `Error: ${error}`
        })
    }
}

const listaPokemon = async (req, res = response) => {
    const pokemones = await Pokemon.find();
    res.status(200)
    .json({
        ok: true,
        result: pokemones
    });
}

const eliminarPokemon = async (req, res = response) => {
    const uid = req.params.id;
    try {
        const pokemonDb = await Pokemon.findById({_id: uid});
        if(!pokemonDb){
            return res.status(404)
            .json({
                ok: true,
                msg: 'El pokemon no exite en la BD'
            });
        }
        await Pokemon.findByIdAndDelete(uid);
        res.status(200)
        .json({
            ok: true,
            result: `Pokemon ${uid} eliminado`
        });
    } catch (error) {
        res.status(500).json({
            ok: false,
            msg: 'Error al eliminar el pokemon'
        })
    }
}

module.exports = {
    guardarPokemon,
    listaPokemon,
    eliminarPokemon
}