import { Table } from 'react-bootstrap'

export default function Tabla({ columnas, filas, acciones }) {
  if (!filas || filas.length === 0) {
    return <p className="text-muted my-3">No hay registros para mostrar.</p>
  }

  return (
    <Table striped hover responsive>
      <thead>
        <tr>
          {columnas.map((c) => (
            <th key={c.campo}>{c.titulo}</th>
          ))}
          {acciones && <th>Acciones</th>}
        </tr>
      </thead>
      <tbody>
        {filas.map((fila, i) => (
          <tr key={i}>
            {columnas.map((c) => (
              <td key={c.campo}>{fila[c.campo]}</td>
            ))}
            {acciones && <td>{acciones(fila)}</td>}
          </tr>
        ))}
      </tbody>
    </Table>
  )
}