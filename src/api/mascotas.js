import { obtener, crear, actualizar, eliminar } from './cliente'

// idDueno es opcional: si se pasa, solo trae las mascotas de ese dueño
export const listarMascotas = (idDueno) =>
  obtener(idDueno ? `/mascotas?id_dueno=${idDueno}` : '/mascotas')

export const obtenerMascota = (id) => obtener(`/mascotas/${id}`)

// mascota = { nombre_mascota, fecha_nacimiento, id_dueno, id_raza }
export const crearMascota = (mascota) => crear('/mascotas', mascota)

export const actualizarMascota = (id, mascota) => actualizar(`/mascotas/${id}`, mascota)

export const eliminarMascota = (id) => eliminar(`/mascotas/${id}`)