import { obtener } from './cliente'

export const listarEspecies = () => obtener('/especies')

export const listarRazas = (idEspecie) => obtener(`/razas?id_especie=${idEspecie}`)

export const listarProcedimientos = () => obtener('/procedimientos')

export const listarMedicamentos = () => obtener('/medicamentos')


export const listarVeterinarios = () => obtener('/veterinarios')