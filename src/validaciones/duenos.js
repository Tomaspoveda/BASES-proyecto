const REGEX_TELEFONO = /^[0-9]{10}$/

// Los límites (50, 100, 60) son los mismos de las columnas de la base de datos
export function validarDueno({ nombre_dueno, calle, ciudad, telefonos }) {
  const errores = {}

  const nombre = nombre_dueno.trim()
  if (!nombre) {
    errores.nombre_dueno = 'El nombre del dueño es obligatorio'
  } else if (nombre.length < 3) {
    errores.nombre_dueno = 'El nombre del dueño debe tener al menos 3 caracteres'
  } else if (nombre.length > 50) {
    errores.nombre_dueno = 'El nombre del dueño no puede tener más de 50 caracteres'
  }

  if (!calle.trim()) {
    errores.calle = 'La calle es obligatoria'
  } else if (calle.trim().length > 100) {
    errores.calle = 'La calle no puede tener más de 100 caracteres'
  }

  if (!ciudad.trim()) {
    errores.ciudad = 'La ciudad es obligatoria'
  } else if (ciudad.trim().length > 60) {
    errores.ciudad = 'La ciudad no puede tener más de 60 caracteres'
  }

  const lista = telefonos.map((telefono) => telefono.trim()).filter((telefono) => telefono !== '')

  if (lista.length === 0) {
    errores.telefonos = 'Debe ingresar al menos un teléfono'
  } else if (lista.some((telefono) => !REGEX_TELEFONO.test(telefono))) {
    errores.telefonos = 'Los teléfonos deben tener 10 dígitos y solo contener números'
  } else if (new Set(lista).size !== lista.length) {
    errores.telefonos = 'No puede ingresar teléfonos duplicados'
  }

  return errores
}