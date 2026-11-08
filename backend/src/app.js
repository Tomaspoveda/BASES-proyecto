import express from 'express'
import { pool } from './db.js'
import { envolver } from './envolver.js'
import { manejadorErrores } from './errores.js'
import catalogos from './rutas/catalogos.js'
import duenos from './rutas/duenos.js'
import mascotas from './rutas/mascotas.js'

// Aquí se arma la app: se conectan todas las rutas en un solo lugar.
export function crearApp() {
  const app = express()

  // Para que Express entienda los JSON que manda el frontend
  app.use(express.json())

  // GET /api/salud -> prueba rápida: si responde { ok: true }, el servidor y MySQL están vivos
  app.get('/api/salud', envolver(async (req, res) => {
    await pool.query('SELECT 1')
    res.json({ ok: true })
  }))

  // Cada grupo de rutas cuelga de su dirección
  app.use('/api', catalogos) // /api/especies, /api/razas, ...
  app.use('/api/duenos', duenos) // /api/duenos, /api/duenos/5
  app.use('/api/mascotas', mascotas) // /api/mascotas, /api/mascotas/5

  // Si piden una ruta que no existe, respondemos 404 en JSON
  app.use('/api', (req, res) => {
    res.status(404).json({ error: 'Ruta no encontrada' })
  })

  // SIEMPRE de último: atrapa cualquier error y lo convierte en respuesta
  app.use(manejadorErrores)
  return app
}
