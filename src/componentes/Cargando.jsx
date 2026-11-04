import { Spinner } from 'react-bootstrap'

export default function Cargando({ texto = 'Cargando...' }) {
  return (
    <div className="d-flex align-items-center gap-2 my-3">
      <Spinner animation="border" size="sm" />
      <span>{texto}</span>
    </div>
  )
}