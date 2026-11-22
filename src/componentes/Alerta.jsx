import { Alert } from 'react-bootstrap'

export default function Alerta({ tipo = 'danger', mensaje, onCerrar }) {
  if (!mensaje) return null

  return (
    <Alert variant={tipo} dismissible onClose={onCerrar}>
      {mensaje === 'Ocurrió un error inesperado'
        ? 'No pudimos cargar la información de la clínica. Comprueba la conexión con el servidor e inténtalo de nuevo.'
        : mensaje}
    </Alert>
  )
}
