import { Router } from 'express'
import { llamar } from '../db.js'
import { envolver } from '../envolver.js'
import { enteroOpcional, fechaOpcional, leerId } from '../utilidades.js'

// Todo lo de las mascotas: ver, crear, cambiar y borrar.
const router = Router()

// Saca los datos del cuerpo y los deja en el orden que pide el procedimiento.
// El frontend manda: { nombre_mascota, fecha_nacimiento, id_dueno, id_raza }
// Aquí solo revisamos que los ids sean números y la fecha tenga forma de fecha.
// Lo importante (nombre, fecha no futura, que el dueño y la raza existan) lo revisa sp_validar_mascota.
function leerCuerpo(cuerpo) {
  const { nombre_mascota = null, fecha_nacimiento, id_dueno, id_raza } = cuerpo ?? {}
  return [
    nombre_mascota,
    fechaOpcional(fecha_nacimiento, 'fecha_nacimiento'),
    enteroOpcional(id_dueno, 'id_dueno'),
    enteroOpcional(id_raza, 'id_raza'),
  ]
}

// GET /api/mascotas -> todas las mascotas
// GET /api/mascotas?id_dueno=5 -> solo las de ese dueño
router.get('/', envolver(async (req, res) => {
  const idDueno = enteroOpcional(req.query.id_dueno, 'id_dueno')
  res.json(await llamar('sp_listar_mascotas', [idDueno]))
}))

// GET /api/mascotas/5 -> una mascota (si no existe, sale 404)
router.get('/:id', envolver(async (req, res) => {
  const [mascota] = await llamar('sp_obtener_mascota', [leerId(req.params.id)])
  res.json(mascota)
}))

// POST /api/mascotas -> crear una mascota nueva (responde 201 con su id)
router.post('/', envolver(async (req, res) => {
  const [creada] = await llamar('sp_crear_mascota', leerCuerpo(req.body))
  res.status(201).json(creada)
}))

// PUT /api/mascotas/5 -> cambiar los datos de una mascota
router.put('/:id', envolver(async (req, res) => {
  const id = leerId(req.params.id)
  const [actualizada] = await llamar('sp_actualizar_mascota', [id, ...leerCuerpo(req.body)])
  res.json(actualizada)
}))

// DELETE /api/mascotas/5 -> borrar una mascota (si tiene citas, la base no deja: sale 409)
router.delete('/:id', envolver(async (req, res) => {
  const [eliminada] = await llamar('sp_eliminar_mascota', [leerId(req.params.id)])
  res.json(eliminada)
}))

export default router
