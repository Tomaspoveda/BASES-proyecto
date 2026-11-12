import { Router } from 'express'
import { llamar } from '../db.js'
import { envolver } from '../envolver.js'
import { enteroOpcional, leerId } from '../utilidades.js'
import { leerCuerpoCita, leerCuerpoReprogramar } from '../validaciones/citas.js'

// Una cita se identifica con DOS datos: la mascota y el número de cita de esa mascota
// (es una entidad débil), por eso las rutas llevan /:idMascota/:numero
const router = Router()

// Junta la cita con sus procedimientos y sus recetas en un solo objeto
async function detalleCita(idMascota, numero) {
  const [cita] = await llamar('sp_obtener_cita', [idMascota, numero])
  const procedimientos = await llamar('sp_listar_procedimientos_cita', [idMascota, numero])
  const recetas = await llamar('sp_listar_recetas_cita', [idMascota, numero])
  return { ...cita, procedimientos, recetas }
}

// GET /api/citas  o  GET /api/citas?id_mascota=5
router.get('/', envolver(async (req, res) => {
  const idMascota = enteroOpcional(req.query.id_mascota, 'id_mascota')
  res.json(await llamar('sp_listar_citas', [idMascota]))
}))

// GET /api/citas/5/2 -> la cita 2 de la mascota 5, con procedimientos y recetas
router.get('/:idMascota/:numero', envolver(async (req, res) => {
  const idMascota = leerId(req.params.idMascota, 'idMascota')
  const numero = leerId(req.params.numero, 'numero')
  res.json(await detalleCita(idMascota, numero))
}))

// POST /api/citas -> TRANSACCIÓN: cita + procedimientos + recetas, todo o nada
router.post('/', envolver(async (req, res) => {
  const [creada] = await llamar('sp_registrar_cita_completa', leerCuerpoCita(req.body))
  res.status(201).json(await detalleCita(creada.id_mascota, creada.numero_cita))
}))

// PUT /api/citas/5/2 -> reprogramar (fecha, hora, veterinario, motivo)
router.put('/:idMascota/:numero', envolver(async (req, res) => {
  const idMascota = leerId(req.params.idMascota, 'idMascota')
  const numero = leerId(req.params.numero, 'numero')
  await llamar('sp_reprogramar_cita', [idMascota, numero, ...leerCuerpoReprogramar(req.body)])
  res.json(await detalleCita(idMascota, numero))
}))

// DELETE /api/citas/5/2 -> TRANSACCIÓN: borra recetas, procedimientos y la cita
router.delete('/:idMascota/:numero', envolver(async (req, res) => {
  const idMascota = leerId(req.params.idMascota, 'idMascota')
  const numero = leerId(req.params.numero, 'numero')
  const [eliminada] = await llamar('sp_eliminar_cita', [idMascota, numero])
  res.json(eliminada)
}))

export default router