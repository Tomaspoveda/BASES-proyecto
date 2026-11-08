import { ErrorSolicitud } from './errores.js'

// Funciones chiquitas para revisar y arreglar datos antes de mandarlos a la base.

// La base nos da los teléfonos pegados: "3001234567,3109876543".
// El frontend los quiere en una lista: ['3001234567', '3109876543'].
export function telefonosALista(texto) {
  return texto ? texto.split(',') : []
}

// Revisa el id que viene en la ruta (/duenos/5). Tiene que ser un número entero positivo.
// Si es "abc", "0", "-3" o "1.5", se rechaza.
export function leerId(valor, nombre = 'id') {
  const numero = Number(valor)
  if (!/^\d+$/.test(String(valor)) || !Number.isSafeInteger(numero) || numero < 1) {
    throw new ErrorSolicitud(`El ${nombre} debe ser un número entero positivo`)
  }
  return numero
}

// Id que puede venir o no (en el cuerpo o en la URL).
// Vacío = null (la base después decide si lo acepta). Si viene, tiene que ser entero.
export function enteroOpcional(valor, nombre) {
  if (valor === undefined || valor === null || valor === '') return null
  const numero = Number(valor)
  if (!Number.isSafeInteger(numero)) {
    throw new ErrorSolicitud(`El campo ${nombre} debe ser un número entero`)
  }
  return numero
}

// Fecha que puede venir o no. Si viene, tiene que ser tipo 2024-05-10.
// Vacía = null.
export function fechaOpcional(valor, nombre) {
  if (valor === undefined || valor === null || valor === '') return null
  if (typeof valor !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(valor)) {
    throw new ErrorSolicitud(`El campo ${nombre} debe tener el formato AAAA-MM-DD`)
  }
  return valor
}
