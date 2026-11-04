const BASE_URL = '/api'

async function solicitar(ruta, opciones = {}) {
  let respuesta
  try {
    respuesta = await fetch(BASE_URL + ruta, {
      headers: { 'Content-Type': 'application/json' },
      ...opciones,
    })
  } catch {
    throw new Error('No se pudo conectar con el servidor')
  }

  let datos = null
  try {
    datos = await respuesta.json()
  } catch {
    // la respuesta no trae JSON; se deja datos en null
  }

  if (!respuesta.ok) {
    throw new Error(datos?.error || 'Ocurrió un error inesperado')
  }
  return datos
}

export const obtener = (ruta) => solicitar(ruta)

export const crear = (ruta, cuerpo) =>
  solicitar(ruta, { method: 'POST', body: JSON.stringify(cuerpo) })

export const actualizar = (ruta, cuerpo) =>
  solicitar(ruta, { method: 'PUT', body: JSON.stringify(cuerpo) })

export const eliminar = (ruta) => solicitar(ruta, { method: 'DELETE' })