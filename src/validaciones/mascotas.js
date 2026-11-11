function hoyISO() {
  // formato AAAA-MM-DD en la hora local (toISOString usaría UTC y puede adelantar un día)
  return new Date().toLocaleDateString('en-CA')
}

// El límite de 50 es el de la columna nombre_mascota en la base de datos
export function validarMascota({ nombre_mascota, fecha_nacimiento, id_dueno, id_raza }) {
  const errores = {}

  if (!nombre_mascota?.trim()) {
    errores.nombre_mascota = 'El nombre es obligatorio'
  } else if (nombre_mascota.trim().length > 50) {
    errores.nombre_mascota = 'El nombre no puede superar 50 caracteres'
  }

  if (!fecha_nacimiento) {
    errores.fecha_nacimiento = 'La fecha de nacimiento es obligatoria'
  } else if (fecha_nacimiento > hoyISO()) {
    errores.fecha_nacimiento = 'La fecha de nacimiento no puede ser futura'
  }

  if (!id_dueno) errores.id_dueno = 'Debe seleccionar un dueño'
  if (!id_raza) errores.id_raza = 'Debe seleccionar una raza'

  return errores
}