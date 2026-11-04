import { obtener, crear, actualizar, eliminar } from './cliente'

export const listarDuenos = () => obtener('/duenos')

export const obtenerDueno = (id) => obtener(`/duenos/${id}`)

// dueno = { nombre_dueno, calle, ciudad, telefonos: ['3001234567', ...] }
export const crearDueno = (dueno) => crear('/duenos', dueno)

export const actualizarDueno = (id, dueno) => actualizar(`/duenos/${id}`, dueno)

export const eliminarDueno = (id) => eliminar(`/duenos/${id}`)  