const REGEX_TELEFONO = /^[0-9]{10}$/;

export function validarDueno({ nombre_dueno, calle, ciudad, telefonos }) {
  const errores = {};

  if (!nombre_dueno.trim()) {
    errores.nombre_dueno = 'El nombre del dueño es obligatorio';
  }else if (nombre_dueno.trim().length < 3) {
    errores.nombre_dueno = 'El nombre del dueño debe tener al menos 3 caracteres y no mas de 100 caracteres';
  } else if (nombre_dueno.trim().length > 100) {
    errores.nombre_dueno = 'El nombre del dueño no puede tener mas de 100 caracteres';
  }

  if (!calle.trim()) {
    errores.calle = 'La calle es obligatoria';
  }

  if (!ciudad.trim()) {
    errores.ciudad = 'La ciudad es obligatoria';
  }

  const lista = telefonos.map((telefono) => telefono.trim()).filter((telefono) => telefono !== '');

  if (lista.length === 0) {
    errores.telefonos = 'Debe ingresar al menos un teléfono';
  }else if (lista.some((telefono) => !REGEX_TELEFONO.test(telefono))) {
    errores.telefonos = 'Los teléfonos deben tener 10 dígitos y solo contener números';
  }else if (new Set(lista).size !== lista.length) {
    errores.telefonos = 'No puede ingresar teléfonos duplicados';
  }

  return errores;
}