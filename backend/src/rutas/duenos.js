import { Router } from 'express'
import { llamar } from '../db.js'
import { envolver } from '../envolver.js'
import { ErrorSolicitud } from '../errores.js'
import { leerId, telefonosALista } from '../utilidades.js'

// Todo lo de los dueños: ver, crear, cambiar y borrar (el famoso CRUD).
const router = Router()

// Convierte los teléfonos de texto ("300,310") a lista (['300', '310']) para el frontend
const conTelefonos = (dueno) => ({ ...dueno, telefonos: telefonosALista(dueno.telefonos) })

// Saca los datos del cuerpo de la petición y los deja listos para el procedimiento.
// El frontend manda: { nombre_dueno, calle, ciudad, telefonos: ['3001234567', ...] }
// Lo único que revisamos aquí es que los teléfonos sean una lista.
// Lo demás (largos, 10 dígitos, repetidos) lo revisa sp_validar_dueno en la base.
function leerCuerpo(cuerpo) {
  const { nombre_dueno = null, calle = null, ciudad = null, telefonos } = cuerpo ?? {}
  if (!Array.isArray(telefonos)) {
    throw new ErrorSolicitud('Los teléfonos deben enviarse como una lista')
  }
  // Los teléfonos viajan a la base como texto JSON: '["300...","310..."]'
  return [nombre_dueno, calle, ciudad, JSON.stringify(telefonos)]
}

// GET /api/duenos -> todos los dueños
router.get('/', envolver(async (req, res) => {
  const filas = await llamar('sp_listar_duenos')
  res.json(filas.map(conTelefonos))
}))

// GET /api/duenos/5 -> un dueño (si no existe, la base avisa y sale 404)
router.get('/:id', envolver(async (req, res) => {
  const [dueno] = await llamar('sp_obtener_dueno', [leerId(req.params.id)])
  res.json(conTelefonos(dueno))
}))

// POST /api/duenos -> crear un dueño nuevo (responde 201 = "creado") con su id
router.post('/', envolver(async (req, res) => {
  const [creado] = await llamar('sp_crear_dueno', leerCuerpo(req.body))
  res.status(201).json(creado)
}))

// PUT /api/duenos/5 -> cambiar los datos y teléfonos de un dueño
router.put('/:id', envolver(async (req, res) => {
  const id = leerId(req.params.id)
  const [actualizado] = await llamar('sp_actualizar_dueno', [id, ...leerCuerpo(req.body)])
  res.json(actualizado)
}))

// DELETE /api/duenos/5 -> borrar un dueño (si tiene mascotas, la base no deja: sale 409)
router.delete('/:id', envolver(async (req, res) => {
  const [eliminado] = await llamar('sp_eliminar_dueno', [leerId(req.params.id)])
  res.json(eliminado)
}))

export default router
