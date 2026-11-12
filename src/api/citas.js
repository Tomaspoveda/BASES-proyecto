import { obtener, crear, actualizar, eliminar } from './cliente'

// idMascota es opcional: si se pasa, solo trae las citas de esa mascota
export const listarCitas = (idMascota) =>
  obtener(idMascota ? `/citas?id_mascota=${idMascota}` : '/citas')

// Una cita se identifica con la mascota y el número de cita de esa mascota
export const obtenerCita = (idMascota, numero) => obtener(`/citas/${idMascota}/${numero}`)

// cita = { id_mascota, fecha_cita, hora, motivo, id_veterinario, procedimientos: [...], recetas: [...] }
export const registrarCita = (cita) => crear('/citas', cita)

// datos = { fecha_cita, hora, id_veterinario, motivo }
export const reprogramarCita = (idMascota, numero, datos) =>
  actualizar(`/citas/${idMascota}/${numero}`, datos)

export const eliminarCita = (idMascota, numero) => eliminar(`/citas/${idMascota}/${numero}`)