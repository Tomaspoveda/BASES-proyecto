import 'dotenv/config' // lee el archivo .env (usuario, clave, etc.)
import mysql from 'mysql2/promise'

// El "pool" es un grupito de conexiones a MySQL que se reutilizan (más rápido que abrir una cada vez).
// El usuario de la aplicación solo tiene EXECUTE sobre las rutinas de sus rutas.
const usuario = process.env.DB_USER ?? 'veterinaria_api'
const clave = process.env.DB_PASSWORD
if (usuario !== 'veterinaria_api') {
  throw new Error('Configura DB_USER=veterinaria_api para la conexión de la API')
}

export function validarConfiguracion() {
  if (!clave?.trim()) throw new Error('Configura DB_PASSWORD con la clave de veterinaria_api')
}
export const pool = mysql.createPool({
  host: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? 3306),
  user: usuario,
  password: clave,
  database: process.env.DB_NAME ?? 'proyecto_veterinaria_test',
  charset: 'utf8mb4', // para que las tildes y la ñ salgan bien
  dateStrings: true, // las fechas llegan como texto '2024-05-10' (si no, JavaScript les cambia el día por la zona horaria)
  connectionLimit: 10,
})

// ESTA es la única forma de hablar con la base: llamar procedimientos almacenados.
// Ejemplo: llamar('sp_crear_dueno', ['Ana', 'Calle 1', 'Cali', '["3001234567"]'])
// Devuelve las filas del SELECT del procedimiento (o una lista vacía si no devuelve nada).
export async function llamar(procedimiento, parametros = []) {
  // Seguro anti-travesuras: solo dejamos nombres que empiecen por sp_
  if (!/^sp_[a-z_]+$/.test(procedimiento)) {
    throw new Error(`Nombre de procedimiento no permitido: ${procedimiento}`)
  }
  // Arma "CALL sp_algo(?, ?, ?)": un ? por cada parámetro (así no se cuela SQL malicioso)
  const marcas = parametros.map(() => '?').join(', ')
  const [resultado] = await pool.query(`CALL ${procedimiento}(${marcas})`, parametros)
  // MySQL devuelve [filas, info]; nos quedamos con las filas
  if (Array.isArray(resultado) && Array.isArray(resultado[0])) return resultado[0]
  return []
}
