import { useEffect, useState } from 'react'
import { Card, Col, Row } from 'react-bootstrap'
import { Link } from 'react-router-dom'
import Alerta from '../componentes/Alerta'
import Cargando from '../componentes/Cargando'
import { listarDuenos } from '../api/duenos'
import { listarMascotas } from '../api/mascotas'
import { listarEspecies } from '../api/catalogos'

export default function Inicio() {
  const [totales, setTotales] = useState(null)
  const [error, setError] = useState('')

  useEffect(() => {
    let activo = true

    async function cargar() {
      try {
        const [duenos, mascotas, especies] = await Promise.all([
          listarDuenos(),
          listarMascotas(),
          listarEspecies(),
        ])
        if (activo) {
          setTotales({ duenos: duenos.length, mascotas: mascotas.length, especies: especies.length })
        }
      } catch (e) {
        if (activo) setError(e.message)
      }
    }

    cargar()
    return () => {
      activo = false
    }
  }, [])

  const tarjetas = totales
    ? [
        { titulo: 'Dueños registrados', valor: totales.duenos, enlace: '/duenos' },
        { titulo: 'Mascotas registradas', valor: totales.mascotas, enlace: '/mascotas' },
        { titulo: 'Especies atendidas', valor: totales.especies, enlace: '/mascotas' },
      ]
    : []

  return (
    <>
      <div className="text-center my-4">
        <h1 className="display-5 fw-bold">Clínica Veterinaria</h1>
        <p className="lead text-muted">Gestión de dueños y mascotas</p>
      </div>

      <Alerta mensaje={error} onCerrar={() => setError('')} />
      {!totales && !error && <Cargando />}

      <Row xs={1} sm={3} className="g-3">
        {tarjetas.map((t) => (
          <Col key={t.titulo}>
            <Link to={t.enlace} className="text-decoration-none">
              <Card className="tarjeta-estadistica text-center h-100">
                <Card.Body className="py-4">
                  <div className="numero">{t.valor}</div>
                  <Card.Text className="text-muted mt-2 mb-0">{t.titulo}</Card.Text>
                </Card.Body>
              </Card>
            </Link>
          </Col>
        ))}
      </Row>
    </>
  )
}