// Los límites (150 para el motivo, 50 para la dosis) son los de las columnas de la base de datos

const hayRepetidos = (ids) => new Set(ids).size !== ids.length

function validarProcedimientos(filas) {
  if (filas.some((f) => !f.id_procedimiento)) {
    return 'Seleccione un procedimiento en cada fila o quite la fila vacía'
  }
  if (hayRepetidos(filas.map((f) => f.id_procedimiento))) {
    return 'No puede repetir un procedimiento en la misma cita'
  }
  if (filas.some((f) => f.costo !== '' && !(Number(f.costo) > 0 && Number(f.costo) < 100000000))) {
    return 'El costo debe ser mayor que cero y menor que 100.000.000'
  }
  return ''
}

function validarRecetas(filas) {
  if (filas.some((f) => !f.id_medicamento)) {
    return 'Seleccione un medicamento en cada fila o quite la fila vacía'
  }
  if (filas.some((f) => !f.dosis.trim())) {
    return 'Cada medicamento necesita su dosis'
  }
  if (filas.some((f) => f.dosis.trim().length > 50)) {
    return 'La dosis no puede superar 50 caracteres'
  }
  if (hayRepetidos(filas.map((f) => f.id_medicamento))) {
    return 'No puede repetir un medicamento en la misma cita'
  }
  return ''
}

// reprogramando = true: solo se validan fecha, hora, veterinario y motivo
export function validarCita(form, { reprogramando = false } = {}) {
  const errores = {}

  if (!reprogramando && !form.id_mascota) errores.id_mascota = 'Debe seleccionar una mascota'
  if (!form.fecha_cita) errores.fecha_cita = 'La fecha de la cita es obligatoria'
  if (!form.hora) errores.hora = 'La hora de la cita es obligatoria'
  if (!form.id_veterinario) errores.id_veterinario = 'Debe seleccionar un veterinario'
  if (form.motivo.trim().length > 150) errores.motivo = 'El motivo no puede superar 150 caracteres'

  if (!reprogramando) {
    const errorProcedimientos = validarProcedimientos(form.procedimientos)
    if (errorProcedimientos) errores.procedimientos = errorProcedimientos
    const errorRecetas = validarRecetas(form.recetas)
    if (errorRecetas) errores.recetas = errorRecetas
  }

  return errores
}