// Pruebas de INTEGRACIÓN de dueños: levantan la API de verdad y hablan con MySQL.
// Necesitan la base proyecto_veterinaria_test cargada y el .env configurado.
// Se activan con npm run test:integracion.
import test, { before, after } from 'node:test'
import assert from 'node:assert/strict'
import { crearApp } from '../src/app.js'
import { pool } from '../src/db.js'

let servidor
let base
const integrar = process.env.PROBAR_MYSQL === '1'
const prueba = (nombre, ejecutar) => test(nombre, { skip: !integrar }, ejecutar)

before(async () => {
  if (!integrar) return
  await pool.query('SELECT 1')
  servidor = crearApp().listen(0) // puerto libre al azar
  await new Promise((listo) => servidor.once('listening', listo))
  base = `http://localhost:${servidor.address().port}`
})

after(async () => {
  servidor?.closeAllConnections?.()
  await new Promise((listo) => servidor ? servidor.close(listo) : listo())
  await pool.end()
})

async function pedir(metodo, ruta, cuerpo) {
  const respuesta = await fetch(base + ruta, {
    method: metodo,
    headers: { 'Content-Type': 'application/json' },
    body: cuerpo ? JSON.stringify(cuerpo) : undefined,
  })
  let datos = null
  try { datos = await respuesta.json() } catch { /* sin cuerpo */ }
  return { estado: respuesta.status, datos }
}

async function contarDuenos() {
  const respuesta = await pedir('GET', '/api/duenos')
  assert.equal(respuesta.estado, 200)
  return respuesta.datos.length
}

const nuevoDueno = (extra = {}) => ({
  nombre_dueno: 'Prueba Automatizada',
  calle: 'Calle 1 # 2-3',
  ciudad: 'Bogotá',
  telefonos: ['3001112233', '3104445566'],
  ...extra,
})

prueba('crear, actualizar y eliminar un dueño con sus teléfonos deja la base como estaba', async () => {
  const antes = await contarDuenos()

  const creado = await pedir('POST', '/api/duenos', nuevoDueno())
  assert.equal(creado.estado, 201)
  assert.deepEqual(creado.datos.telefonos, ['3001112233', '3104445566'])
  const id = creado.datos.id_dueno

  const cambiado = await pedir('PUT', `/api/duenos/${id}`, nuevoDueno({
    nombre_dueno: 'Prueba Actualizada',
    telefonos: ['3207778899'],
  }))
  assert.equal(cambiado.estado, 200)
  assert.equal(cambiado.datos.nombre_dueno, 'Prueba Actualizada')
  assert.deepEqual(cambiado.datos.telefonos, ['3207778899']) // los teléfonos viejos se reemplazaron

  assert.equal((await pedir('DELETE', `/api/duenos/${id}`)).estado, 200)
  assert.equal((await pedir('GET', `/api/duenos/${id}`)).estado, 404)
  assert.equal(await contarDuenos(), antes)
})

prueba('teléfonos repetidos se rechazan con 400 y no se guarda ningún dueño', async () => {
  const antes = await contarDuenos()
  const respuesta = await pedir('POST', '/api/duenos', nuevoDueno({ telefonos: ['3001112233', '3001112233'] }))
  assert.equal(respuesta.estado, 400)
  assert.match(respuesta.datos.error, /duplicados/)
  assert.equal(await contarDuenos(), antes)
})

prueba('un teléfono con letras o de largo incorrecto se rechaza con 400', async () => {
  const antes = await contarDuenos()
  const respuesta = await pedir('POST', '/api/duenos', nuevoDueno({ telefonos: ['30011abc33'] }))
  assert.equal(respuesta.estado, 400)
  assert.match(respuesta.datos.error, /10 dígitos/)
  assert.equal(await contarDuenos(), antes)
})

prueba('no deja eliminar un dueño que tiene mascotas (409) y el dueño sigue existiendo', async () => {
  const mascotas = await pedir('GET', '/api/mascotas')
  assert.equal(mascotas.estado, 200)
  const id = mascotas.datos[0].id_dueno
  const respuesta = await pedir('DELETE', `/api/duenos/${id}`)
  assert.equal(respuesta.estado, 409)
  assert.match(respuesta.datos.error, /mascotas/)
  assert.equal((await pedir('GET', `/api/duenos/${id}`)).estado, 200)
})

prueba('un dueño que no existe responde 404 con el mensaje de la base', async () => {
  const respuesta = await pedir('GET', '/api/duenos/999999')
  assert.equal(respuesta.estado, 404)
  assert.equal(respuesta.datos.error, 'El dueño indicado no existe')
})
