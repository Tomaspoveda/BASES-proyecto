// Este archivo agarra los errores feos de MySQL y los vuelve respuestas bonitas para el frontend.
// El frontend (cliente.js) siempre busca el campo "error" en el JSON, por eso respondemos { error: "..." }.

// Error que lanzamos nosotros cuando algo viene mal armado (ej: los teléfonos no son una lista).
export class ErrorSolicitud extends Error {
  constructor(mensaje) {
    super(mensaje)
    this.name = 'ErrorSolicitud'
    this.estado = 400 // 400 = "mandaste algo mal"
  }
}

// Recibe el error y devuelve { estado, mensaje }:
// estado = el numerito HTTP (404, 409, etc.) y mensaje = lo que va a leer el usuario.
//
// Los numeritos 5404 y 5409 los inventamos en los procedimientos con SIGNAL:
//   5404 = "eso no existe"
//   5409 = "no se puede, tiene cosas relacionadas" (ej: dueño con mascotas)
// Y un SIGNAL normal (45000) sin numerito llega como 1644 (son las validaciones).
export function traducirError(err) {
  // Error nuestro: se devuelve tal cual
  if (err instanceof ErrorSolicitud) {
    return { estado: err.estado, mensaje: err.message }
  }
  // Mandaron un JSON dañado
  if (err?.type === 'entity.parse.failed') {
    return { estado: 400, mensaje: 'El cuerpo de la solicitud no es un JSON válido' }
  }

  // Miramos el numerito del error de MySQL
  switch (err?.errno) {
    case 5404: // no existe
      return { estado: 404, mensaje: err.sqlMessage }
    case 5409: // conflicto
      return { estado: 409, mensaje: err.sqlMessage }
    case 1644: // validación que falló
      return { estado: 400, mensaje: err.sqlMessage }
    case 1062: // dato repetido
      return { estado: 409, mensaje: 'Ya existe un registro con esos datos' }
    case 1451: // llave foránea (hay registros pegados a este)
    case 1452:
      return { estado: 409, mensaje: 'La operación entra en conflicto con registros relacionados' }
    case 3819: // un CHECK de la tabla no se cumplió
      return { estado: 400, mensaje: 'Algún valor no cumple las reglas de la base de datos' }
    case 1048: // una columna NOT NULL llegó vacía
      return { estado: 400, mensaje: 'Falta un dato obligatorio' }
    case 1406: // texto más largo que la columna
      return { estado: 400, mensaje: 'Un texto supera el largo permitido' }
    case 1292: // fecha u otro valor con formato inválido
    case 1525:
      return { estado: 400, mensaje: 'Un valor tiene un formato inválido' }
    case 1213: // deadlock
    case 1205: // tiempo de espera de bloqueo agotado
      return { estado: 409, mensaje: 'La operación chocó con otra en curso. Intenta de nuevo' }
    case 1045: // credenciales incorrectas
    case 1049:
      return { estado: 503, mensaje: 'No se pudo conectar con la base de datos' }
    default:
      break
  }

  // MySQL apagado o sin conexión
  if (['ECONNREFUSED', 'PROTOCOL_CONNECTION_LOST', 'ETIMEDOUT', 'ENOTFOUND'].includes(err?.code)) {
    return { estado: 503, mensaje: 'No se pudo conectar con la base de datos' }
  }

  // Cualquier otra cosa rara: error 500 y NO mostramos los detalles al usuario
  return { estado: 500, mensaje: 'Ocurrió un error inesperado en el servidor' }
}

// Esta es la "red de seguridad" de Express: todo error que se escape termina aquí.
// (Tiene 4 parámetros a propósito, así Express sabe que es de errores.)
// eslint-disable-next-line no-unused-vars
export function manejadorErrores(err, req, res, next) {
  const { estado, mensaje } = traducirError(err)
  if (estado >= 500) console.error(err) // los errores feos los vemos en la terminal
  res.status(estado).json({ error: mensaje })
}
