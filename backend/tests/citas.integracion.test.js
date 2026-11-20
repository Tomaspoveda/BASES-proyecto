import test, { before, after } from 'node:test'
import assert from 'node:assert/strict'
import { once } from 'node:events'
import { crearApp } from '../src/app.js'
import { pool, validarConfiguracion } from '../src/db.js'

const integrar = process.env.PROBAR_MYSQL === '1'
const prueba = (nombre, ejecutar) => test(nombre, { skip: !integrar }, ejecutar)
const citas = '/api/citas'
let servidor
let origen
let cita

async function pedir(metodo, ruta, cuerpo, estado) {
  const respuesta = await fetch(origen + ruta, {
    method: metodo,
    headers: { 'Content-Type': 'application/json' },
    body: cuerpo === undefined ? undefined : JSON.stringify(cuerpo),
  })
  const datos = await respuesta.json()
  assert.equal(respuesta.status, estado, JSON.stringify(datos))
  return datos
}

before(async () => {
  if (!integrar) return
  validarConfiguracion()
  servidor = crearApp().listen(0, '127.0.0.1')
  await once(servidor, 'listening')
  origen = 'http://127.0.0.1:' + servidor.address().port
  await pedir('GET', '/api/salud', undefined, 200)
  const [mascotas, veterinarios, procedimientos, medicamentos] = await Promise.all(
    ['mascotas', 'veterinarios', 'procedimientos', 'medicamentos']
      .map((catalogo) => pedir('GET', '/api/' + catalogo, undefined, 200)),
  )
  cita = {
    id_mascota: mascotas[0].id_mascota,
    id_veterinario: veterinarios[0].id_veterinario,
    fecha_cita: '2099-09-16',
    hora: '13:00',
    motivo: 'Integración de citas',
    procedimientos: [{ id_procedimiento: procedimientos[0].id_procedimiento, costo: 21000 }],
    recetas: [{ id_medicamento: medicamentos[0].id_medicamento, dosis: '1 tableta' }],
  }
})

after(async () => {
  if (servidor) await new Promise((listo) => servidor.close(listo))
  await pool.end()
})

const listar = () => pedir('GET', citas + '?id_mascota=' + cita.id_mascota, undefined, 200)

async function registrar(t, hora) {
  const creada = await pedir('POST', citas, { ...cita, hora }, 201)
  const ruta = citas + '/' + creada.id_mascota + '/' + creada.numero_cita
  t.after(async () => {
    const respuesta = await fetch(origen + ruta, { method: 'DELETE' })
    assert.ok([200, 404].includes(respuesta.status), await respuesta.text())
  })
  return ruta
}

prueba('registra y consulta la cita con su procedimiento y receta', async (t) => {
  const ruta = await registrar(t, '13:00')
  const detalle = await pedir('GET', ruta, undefined, 200)
  assert.equal(detalle.motivo, cita.motivo)
  assert.equal(detalle.procedimientos[0].id_procedimiento, cita.procedimientos[0].id_procedimiento)
  assert.equal(Number(detalle.procedimientos[0].costo), 21000)
  assert.equal(detalle.recetas[0].id_medicamento, cita.recetas[0].id_medicamento)
  assert.equal(detalle.recetas[0].dosis, '1 tableta')
})

prueba('reprograma y conserva los procedimientos y las recetas', async (t) => {
  const ruta = await registrar(t, '14:00')
  const antes = await pedir('GET', ruta, undefined, 200)
  const editada = await pedir('PUT', ruta, { ...cita, hora: '14:30', motivo: 'Reprogramada' }, 200)
  assert.equal(editada.hora, '14:30:00')
  assert.equal(editada.motivo, 'Reprogramada')
  assert.deepEqual(editada.procedimientos, antes.procedimientos)
  assert.deepEqual(editada.recetas, antes.recetas)
})

prueba('elimina la cita completa y recupera el listado original', async (t) => {
  const antes = await listar()
  const ruta = await registrar(t, '15:00')
  await pedir('DELETE', ruta, undefined, 200)
  await pedir('GET', ruta, undefined, 404)
  assert.deepEqual(await listar(), antes)
})

prueba('rechaza una segunda cita para el mismo veterinario y horario', async (t) => {
  await registrar(t, '16:00')
  const antes = await listar()
  const fallo = await pedir('POST', citas, { ...cita, hora: '16:00' }, 409)
  assert.match(fallo.error, /ya tiene una cita/i)
  assert.deepEqual(await listar(), antes)
})

prueba('rechaza una dosis vacía sin guardar una cita', async () => {
  const antes = await listar()
  const recetas = [{ ...cita.recetas[0], dosis: '' }]
  const fallo = await pedir('POST', citas, { ...cita, recetas }, 400)
  assert.match(fallo.error, /dosis/i)
  assert.deepEqual(await listar(), antes)
})

prueba('revierte la cita, el procedimiento y la receta parcial si falta un medicamento', async (t) => {
  const antes = await listar()
  const recetas = [...cita.recetas, { id_medicamento: 2147483647, dosis: '1 tableta' }]
  // El procedimiento inserta cita y procedimientos antes de detectar el medicamento faltante.
  // El mismo horario y las mismas claves de detalle pueden reutilizarse inmediatamente.
  const fallo = await pedir('POST', citas, { ...cita, hora: '17:00', recetas }, 404)
  assert.match(fallo.error, /medicamentos indicados no existen/i)
  assert.deepEqual(await listar(), antes)
  const ruta = await registrar(t, '17:00')
  const detalle = await pedir('GET', ruta, undefined, 200)
  assert.equal(detalle.numero_cita, Math.max(0, ...antes.map((fila) => fila.numero_cita)) + 1)
  assert.equal(detalle.procedimientos.length, 1)
  assert.equal(detalle.recetas.length, 1)
})

prueba('la cuenta de la API no puede leer tablas directamente ni llamar rutinas de demostración', async () => {
  await assert.rejects(pool.query('SELECT id_veterinario FROM veterinario LIMIT 1'), { errno: 1142 })
  await assert.rejects(pool.query('CALL sp_demo_rollback()'), { errno: 1370 })
})
