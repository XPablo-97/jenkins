/**Path: /api/pokemon */

const { Router } = require('express');
const { guardarPokemon, listaPokemon, eliminarPokemon } = require('../controllers/pokemon');
const router = Router();

router.get("/", listaPokemon);

router.post("/", guardarPokemon);

router.delete("/:id", eliminarPokemon);

module.exports = router;