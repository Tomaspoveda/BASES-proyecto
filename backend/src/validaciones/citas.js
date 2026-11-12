import { ErrorSolicitud } from '../errores.js'
import { enteroRequerido, fechaRequerida, horaRequerida } from '../utilidades.js'

// Validaciones de la aplicación ANTES de llegar a la base.
// (La base vuelve a validar con SIGNAL/CHECK: aquí solo evitamos viajes inútiles y damos mensajes claros.)

function leerLista(valor, nombre) {
  if (valor === undefined || valor === null) return []
  if (!Array.isArray(valor)) throw new ErrorSolicitud(`El campo ${nombre} debe enviarse como una lista`)
  return valor
}

function leerObjeto(item, nombre) {
  if (typeof item !== 'object' || item === null || Array.isArray(item)) {
    throw new ErrorSolicitud(`Cada elemento de ${nombre} debe ser un objeto`)
  }
  return item
}

function sinRepetidos(ids, mensaje) {
  if (new Set(ids).size !== ids.length) throw new ErrorSolicitud(mensaje)
}

// [{ id_procedimiento: 16, costo: 50000 }]  (costo es opcional: si falta, la base usa el costo de referencia)
export function leerProcedimientos(valor) {
  const lista = leerLista(valor, 'procedimientos').map((crudo, i) => {
    const item = leerObjeto(crudo, 'procedimientos')
    const id_procedimiento = enteroRequerido(item.id_procedimiento, `procedimientos[${i}].id_procedimiento`)
    if (item.costo === undefined || item.costo === null || item.costo === '') return { id_procedimiento }
    const costo = Number(item.costo)
    if (!Number.isFinite(costo) || costo <= 0 || costo >= 100000000) {
      throw new ErrorSolicitud('El costo de cada procedimiento debe ser un número mayor que cero')
    }
    return { id_procedimiento, costo }
  })
  sinRepetidos(lista.map((p) => p.id_procedimiento), 'No puede repetir un procedimiento en la misma cita')
  return lista
}

// [{ id_medicamento: 4, dosis: '1 tableta cada 12 horas' }]
export function leerRecetas(valor) {
  const lista = leerLista(valor, 'recetas').map((crudo, i) => {
    const item = leerObjeto(crudo, 'recetas')
    const id_medicamento = enteroRequerido(item.id_medicamento, `recetas[${i}].id_medicamento`)
    const dosis = typeof item.dosis === 'string' ? item.dosis.trim() : ''
    if (!dosis) throw new ErrorSolicitud('Cada medicamento debe llevar su dosis')
    if (dosis.length > 50) throw new ErrorSolicitud('La dosis no puede tener más de 50 caracteres')
    return { id_medicamento, dosis }
  })
  sinRepetidos(lista.map((r) => r.id_medicamento), 'No puede repetir un medicamento en la misma cita')
  return lista
}

function leerMotivo(valor) {
  if (valor === undefined || valor === null) return null
  if (typeof valor !== 'string') throw new ErrorSolicitud('El motivo debe ser texto')
  const motivo = valor.trim()
  if (motivo.length > 150) throw new ErrorSolicitud('El motivo no puede tener más de 150 caracteres')
  return motivo === '' ? null : motivo // vacío = la base usa el DEFAULT 'Control general de rutina'
}

// Deja los datos en el orden de sp_registrar_cita_completa
export function leerCuerpoCita(cuerpo) {
  const c = cuerpo ?? {}
  return [
    enteroRequerido(c.id_mascota, 'id_mascota'),
    fechaRequerida(c.fecha_cita, 'fecha_cita'),
    horaRequerida(c.hora, 'hora'),
    leerMotivo(c.motivo),
    enteroRequerido(c.id_veterinario, 'id_veterinario'),
    JSON.stringify(leerProcedimientos(c.procedimientos)),
    JSON.stringify(leerRecetas(c.recetas)),
  ]
}

// Deja los datos (sin los ids de la ruta) en el orden de sp_reprogramar_cita
export function leerCuerpoReprogramar(cuerpo) {
  const c = cuerpo ?? {}
  return [
    fechaRequerida(c.fecha_cita, 'fecha_cita'),
    horaRequerida(c.hora, 'hora'),
    enteroRequerido(c.id_veterinario, 'id_veterinario'),
    leerMotivo(c.motivo),
  ]
}