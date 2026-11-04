import { Alert } from 'react-bootstrap'

export default function Alerta({ tipo = 'danger', mensaje, onCerrar }) {
  if (!mensaje) return null

  return (
    <Alert variant={tipo} dismissible onClose={onCerrar}>
      {mensaje}
    </Alert>
  )
}