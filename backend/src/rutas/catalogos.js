import { Router } from 'express'
import { llamar } from '../db.js'
import { envolver } from '../envolver.js'
import { enteroOpcional } from '../utilidades.js'

// Los catálogos son las listas que se usan en los desplegables del frontend.
// Aquí solo se leen (GET), no se cambian.
const router = Router()

// GET /api/especies -> perro, gato, ave...
router.get('/especies', envolver(async (req, res) => {
  res.json(await llamar('sp_listar_especies'))
}))

// GET /api/razas?id_especie=3 -> las razas de esa especie
// Si no mandan id_especie, devuelve todas las razas.
router.get('/razas', envolver(async (req, res) => {
  const idEspecie = enteroOpcional(req.query.id_especie, 'id_especie')
  res.json(await llamar('sp_listar_razas', [idEspecie]))
}))

// GET /api/procedimientos -> lista de procedimientos con su costo
router.get('/procedimientos', envolver(async (req, res) => {
  res.json(await llamar('sp_listar_procedimientos'))
}))

// GET /api/medicamentos -> lista de medicamentos
router.get('/medicamentos', envolver(async (req, res) => {
  res.json(await llamar('sp_listar_medicamentos'))
}))
// GET /api/veterinarios -> lista de veterinarios
router.get('/veterinarios', envolver(async (req, res) => {
  res.json(await llamar('sp_listar_veterinarios'))
}))
export default router
