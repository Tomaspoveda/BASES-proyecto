import test from 'node:test'
import assert from 'node:assert/strict'
import { ErrorSolicitud, traducirError } from '../src/errores.js'
import { fechaOpcional } from '../src/utilidades.js'

test('fechaOpcional rechaza días que no existen aunque el formato sea correcto', () => {
  assert.throws(() => fechaOpcional('2026-02-31', 'fecha'), ErrorSolicitud)
  assert.throws(() => fechaOpcional('2026-13-01', 'fecha'), ErrorSolicitud)
  assert.equal(fechaOpcional('2024-02-29', 'fecha'), '2024-02-29') // 2024 sí fue bisiesto
  assert.equal(fechaOpcional('', 'fecha'), null)
})

test('CHECK, NOT NULL, texto largo y formato inválido responden 400', () => {
  for (const errno of [3819, 1048, 1406, 1292, 1525]) {
    assert.equal(traducirError({ errno }).estado, 400, `errno ${errno}`)
  }
})

test('deadlock y timeout de bloqueo responden 409', () => {
  assert.equal(traducirError({ errno: 1213 }).estado, 409)
  assert.equal(traducirError({ errno: 1205 }).estado, 409)
})