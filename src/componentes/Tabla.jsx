import { Table } from 'react-bootstrap'

export default function Tabla({ columnas, filas, acciones }) {
  if (!filas || filas.length === 0) {
    return <div className="tabla-vacia">No hay registros para mostrar.</div>
  }

  return (
    <Table hover responsive className="tabla-clinica">
      <thead>
        <tr>
          {columnas.map((c) => (
            <th key={c.campo}>{c.titulo}</th>
          ))}
          {acciones && <th className="col-acciones">Acciones</th>}
        </tr>
      </thead>
      <tbody>
        {filas.map((fila, i) => (
          <tr key={i}>
            {columnas.map((c) => (
              <td key={c.campo}>{fila[c.campo]}</td>
            ))}
            {acciones && <td className="col-acciones">{acciones(fila)}</td>}
          </tr>
        ))}
      </tbody>
    </Table>
  )
}