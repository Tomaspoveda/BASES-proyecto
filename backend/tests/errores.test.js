// Pruebas chiquitas: revisan que los errores se conviertan en el número HTTP correcto
// y que las funciones de utilidades hagan lo que deben. No necesitan MySQL prendido.
import test from 'node:test'
import assert from 'node:assert/strict'
import { ErrorSolicitud, traducirError } from '../src/errores.js'
import { leerId, telefonosALista, enteroOpcional, fechaOpcional } from '../src/utilidades.js'

test('SIGNAL con MYSQL_ERRNO 5404 se traduce a 404 con el mensaje de la base', () => {
  const r = traducirError({ errno: 5404, sqlMessage: 'El dueño indicado no existe' })
  assert.deepEqual(r, { estado: 404, mensaje: 'El dueño indicado no existe' })
})

test('SIGNAL con MYSQL_ERRNO 5409 se traduce a 409', () => {
  const r = traducirError({ errno: 5409, sqlMessage: 'No se puede eliminar el dueño porque tiene mascotas registradas' })
  assert.equal(r.estado, 409)
})

test('validaciones de la base (1644) se traducen a 400 con su mensaje', () => {
  const r = traducirError({ errno: 1644, sqlMessage: 'Los teléfonos deben tener 10 dígitos y solo contener números' })
  assert.deepEqual(r, { estado: 400, mensaje: 'Los teléfonos deben tener 10 dígitos y solo contener números' })
})

test('un error desconocido responde 500 sin filtrar detalles internos', () => {
  const r = traducirError(new Error('detalle interno secreto'))
  assert.equal(r.estado, 500)
  assert.ok(!r.mensaje.includes('secreto'))
})

test('si MySQL no responde, la API contesta 503', () => {
  assert.equal(traducirError({ code: 'ECONNREFUSED' }).estado, 503)
})

test('ErrorSolicitud se traduce a 400', () => {
  assert.equal(traducirError(new ErrorSolicitud('x')).estado, 400)
})

test('telefonosALista convierte el texto de la base en arreglo', () => {
  assert.deepEqual(telefonosALista('3001234567,3109876543'), ['3001234567', '3109876543'])
  assert.deepEqual(telefonosALista(null), [])
})

test('leerId acepta enteros positivos y rechaza el resto', () => {
  assert.equal(leerId('12'), 12)
  for (const malo of ['0', '-3', 'abc', '1.5', '']) {
    assert.throws(() => leerId(malo), ErrorSolicitud)
  }
})

test('enteroOpcional y fechaOpcional tratan vacío como null y validan formato', () => {
  assert.equal(enteroOpcional('', 'id_raza'), null)
  assert.equal(enteroOpcional('7', 'id_raza'), 7)
  assert.throws(() => enteroOpcional('x', 'id_raza'), ErrorSolicitud)
  assert.equal(fechaOpcional(undefined, 'fecha'), null)
  assert.equal(fechaOpcional('2024-05-10', 'fecha'), '2024-05-10')
  assert.throws(() => fechaOpcional('10/05/2024', 'fecha'), ErrorSolicitud)
})
