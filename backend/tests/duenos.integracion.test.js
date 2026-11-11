// Pruebas de INTEGRACIÓN de dueños: levantan la API de verdad y hablan con MySQL.
// Necesitan la base proyecto_veterinaria_test cargada y el .env configurado.
// Si MySQL no responde, las pruebas se saltan (no fallan).
import test, { before, after } from 'node:test'
import assert from 'node:assert/strict'
import { crearApp } from '../src/app.js'
import { pool } from '../src/db.js'

let servidor
let base
let hayBase = true

before(async () => {
  try {
    await pool.query('SELECT 1')
  } catch {
    hayBase = false
  }
  servidor = crearApp().listen(0) // puerto libre al azar
  await new Promise((listo) => servidor.once('listening', listo))
  base = `http://localhost:${servidor.address().port}`
})

after(async () => {
  servidor.closeAllConnections?.()
  servidor.close()
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
  const [[fila]] = await pool.query('SELECT COUNT(*) AS n FROM dueno')
  return fila.n
}

const nuevoDueno = (extra = {}) => ({
  nombre_dueno: 'Prueba Automatizada',
  calle: 'Calle 1 # 2-3',
  ciudad: 'Bogotá',
  telefonos: ['3001112233', '3104445566'],
  ...extra,
})

test('crear, actualizar y eliminar un dueño con sus teléfonos deja la base como estaba', async (t) => {
  if (!hayBase) return t.skip('MySQL no disponible')
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

test('teléfonos repetidos se rechazan con 400 y no se guarda ningún dueño', async (t) => {
  if (!hayBase) return t.skip('MySQL no disponible')
  const antes = await contarDuenos()
  const respuesta = await pedir('POST', '/api/duenos', nuevoDueno({ telefonos: ['3001112233', '3001112233'] }))
  assert.equal(respuesta.estado, 400)
  assert.match(respuesta.datos.error, /duplicados/)
  assert.equal(await contarDuenos(), antes)
})

test('un teléfono con letras o de largo incorrecto se rechaza con 400', async (t) => {
  if (!hayBase) return t.skip('MySQL no disponible')
  const antes = await contarDuenos()
  const respuesta = await pedir('POST', '/api/duenos', nuevoDueno({ telefonos: ['30011abc33'] }))
  assert.equal(respuesta.estado, 400)
  assert.match(respuesta.datos.error, /10 dígitos/)
  assert.equal(await contarDuenos(), antes)
})

test('no deja eliminar un dueño que tiene mascotas (409) y el dueño sigue existiendo', async (t) => {
  if (!hayBase) return t.skip('MySQL no disponible')
  const [[fila]] = await pool.query('SELECT FK_id_dueno AS id FROM mascota LIMIT 1')
  const respuesta = await pedir('DELETE', `/api/duenos/${fila.id}`)
  assert.equal(respuesta.estado, 409)
  assert.match(respuesta.datos.error, /mascotas/)
  assert.equal((await pedir('GET', `/api/duenos/${fila.id}`)).estado, 200)
})

test('un dueño que no existe responde 404 con el mensaje de la base', async (t) => {
  if (!hayBase) return t.skip('MySQL no disponible')
  const respuesta = await pedir('GET', '/api/duenos/999999')
  assert.equal(respuesta.estado, 404)
  assert.equal(respuesta.datos.error, 'El dueño indicado no existe')
})

test('ROLLBACK: sp_demo_rollback falla a la mitad y deja los datos EXACTAMENTE como estaban', async (t) => {
  if (!hayBase) return t.skip('MySQL no disponible')
  const leer = async () => {
    const [[proc]] = await pool.query('SELECT costo_referencia FROM procedimiento WHERE id_procedimiento = 1')
    const [[vet]] = await pool.query('SELECT especialidad FROM veterinario WHERE id_veterinario = 7')
    return { costo: proc.costo_referencia, especialidad: vet.especialidad }
  }
  const antes = await leer()

  // El procedimiento (del script principal) modifica 2 tablas y falla en la 3ª por una llave foránea
  const [resultado] = await pool.query('CALL sp_demo_rollback()')
  assert.match(resultado[0][0].resultado, /ROLLBACK/)

  assert.deepEqual(await leer(), antes)
})