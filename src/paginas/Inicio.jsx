import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import Alerta from '../componentes/Alerta'
import { listarDuenos } from '../api/duenos'
import { listarMascotas } from '../api/mascotas'
import { listarCitas } from '../api/citas'

const PILA = [
  { clave: 'citas', ruta: '/citas', titulo: 'Citas registradas', emoji: '📅' },
  { clave: 'mascotas', ruta: '/mascotas', titulo: 'Mascotas registradas', emoji: '🐶' },
  { clave: 'duenos', ruta: '/duenos', titulo: 'Dueños registrados', emoji: '👤' },
]

export default function Inicio() {
  const [totales, setTotales] = useState(null)
  const [recientes, setRecientes] = useState([])
  const [error, setError] = useState('')

  useEffect(() => {
    let activo = true
    async function cargar() {
      try {
        const [d, m, c] = await Promise.all([listarDuenos(), listarMascotas(), listarCitas()])
        if (!activo) return
        setTotales({ duenos: d.length, mascotas: m.length, citas: c.length })
        setRecientes(c.slice(0, 5))
      } catch (e) {
        if (activo) setError(e.message)
      }
    }
    cargar()
    return () => { activo = false }
  }, [])

  return (
    <>
      <Alerta mensaje={error} onCerrar={() => setError('')} />

      <section className="hero">
        <div className="hero-texto">
          <h1>Cuidamos a cada mascota con atención y cariño</h1>
          <p>Gestiona dueños, mascotas y citas desde un solo lugar.</p>
          <div className="hero-botones">
            <Link to="/citas" className="boton boton-lleno">Registrar una cita</Link>
            <Link to="/mascotas" className="boton boton-suave">Ver mascotas</Link>
          </div>
        </div>

        <div className="pila">
          {PILA.map((t, i) => (
            <Link key={t.clave} to={t.ruta} className={`pila-tarjeta n${i + 1}`}>
              <span className="pila-emoji">{t.emoji}</span>
              <span className="pila-numero">{totales ? totales[t.clave] : '–'}</span>
              <span className="pila-titulo">{t.titulo}</span>
            </Link>
          ))}
        </div>
      </section>

      {recientes.length > 0 && (
        <section className="panel">
          <h2>Citas más recientes</h2>
          <ul className="lista-citas">
            {recientes.map((c) => (
              <li key={`${c.id_mascota}-${c.numero_cita}`}>
                <span className="lista-fecha">{c.fecha_cita} · {String(c.hora).slice(0, 5)}</span>
                <span className="lista-nombre">{c.nombre_mascota}</span>
                <span className="lista-vet">{c.nombre_veterinario}</span>
              </li>
            ))}
          </ul>
        </section>
      )}
    </>
  )
}