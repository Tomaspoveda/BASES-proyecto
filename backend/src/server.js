import { crearApp } from './app.js'
import { pool, validarConfiguracion } from './db.js'

// El puerto sale del .env (3000 por defecto; el frontend ya apunta a ese en vite.config.js)
const puerto = Number(process.env.PORT ?? 3000)

validarConfiguracion()

// Prende el servidor
crearApp().listen(puerto, async () => {
  console.log(`API escuchando en http://localhost:${puerto}`)
  // De una vez probamos si MySQL responde, para enterarnos rápido si algo está mal
  try {
    await pool.query('SELECT 1')
    console.log('Conexión con MySQL correcta')
  } catch (err) {
    console.warn(`No se pudo conectar con MySQL: ${err.message}`)
    console.warn('Revisa el archivo .env (usuario, clave y nombre de la base).')
  }
})
