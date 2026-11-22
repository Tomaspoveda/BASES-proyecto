import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import Alerta from '../componentes/Alerta'
import { listarDuenos } from '../api/duenos'
import { listarMascotas } from '../api/mascotas'
import { listarCitas } from '../api/citas'
import { Gatito, GatoDormido, Ramita, IconoCuidado } from '../componentes/Ilustraciones'

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
          <span className="sobrelinea"><span aria-hidden="true">✳</span> BIENVENIDOS A NUESTRA CLÍNICA</span>
          <h1>El cuidado que necesitan.<br /><em>El cariño que merecen.</em></h1>
          <p>Un espacio para cuidar de sus patitas y de todo lo que las hace especiales. Gestiona dueños, mascotas y citas, con calma y en un solo lugar.</p>
          <div className="hero-botones">
            <Link to="/citas" className="boton boton-lleno">Registrar una cita <span aria-hidden="true">↗</span></Link>
            <Link to="/mascotas" className="boton boton-suave">Conocer a las mascotas <span aria-hidden="true">→</span></Link>
          </div>
          <div className="hero-nota"><IconoCuidado tipo="cariño" width="20" height="20" /> Cada mascota, parte de nuestra familia.</div>
        </div>
        <div className="hero-arte">
          <span className="arte-sol" aria-hidden="true">✳</span>
          <Ramita className="arte-ramita" />
          <span className="arte-saludo">¡Hola, qué bueno verte!</span>
          <div className="arte-marco"><Gatito className="hero-gatito" /></div>
          <div className="arte-etiqueta"><IconoCuidado tipo="mascotas" width="27" height="27" /><span>En buenas manos.<small>Y con mucho, mucho cariño.</small></span></div>
          <span className="arte-pie">TU COMPAÑERO DE CUIDADOS</span>
          <svg className="arte-colinas" viewBox="0 0 600 130" preserveAspectRatio="none" aria-hidden="true"><path d="M0 70Q130 0 280 75T600 30V130H0Z" fill="#c9cdb6" /><path d="M0 100Q150 135 340 62T600 100V130H0Z" fill="#a7b59c" /></svg>
        </div>
      </section>

      <section className="valores" aria-label="Nuestra forma de cuidar">
        <div><IconoCuidado tipo="cariño" /><span>Con todo el cariño<small>En cada pequeño detalle</small></span></div>
        <div><IconoCuidado tipo="mascotas" /><span>Cada patita cuenta<small>Un cuidado para cada mascota</small></span></div>
        <div><IconoCuidado tipo="citas" /><span>Todo en su lugar<small>Más sencillo, más tranquilo</small></span></div>
      </section>

      <section className="resumen" aria-labelledby="resumen-titulo">
        <div className="resumen-texto"><span className="sobrelinea">NUESTRO DÍA A DÍA</span><h2 id="resumen-titulo">Una pequeña <br />gran familia.</h2><p>Cada número es una historia <br />que acompañamos.</p><GatoDormido className="gato-resumen" /></div>
        <div className="pila" aria-label="Resumen de la clínica">
          {PILA.map((t, i) => (
            <Link key={t.clave} to={t.ruta} className={`pila-tarjeta n${i + 1}`}>
              <span className="pila-icono"><IconoCuidado tipo={t.clave} width="29" height="29" /></span>
              <span className="pila-numero">{totales ? totales[t.clave] : '–'}</span>
              <span className="pila-titulo">{t.titulo}</span>
              <span className="pila-ver">Ver {t.clave === 'duenos' ? 'dueños' : t.clave} <span aria-hidden="true">↗</span></span>
            </Link>
          ))}
        </div>
      </section>

      <section className="pausa">
        <div className="ilustracion-calma">
          <img src="/perrito-calma.png" alt="Perrito descansando con una flor y dos mariposas, en tonos crema, salvia y terracota" width="1851" height="850" loading="lazy" />
          <span>Un pequeño momento de calma.</span>
        </div>
        <div className="pausa-texto"><span className="sobrelinea">SU BIENESTAR, NUESTRA RAZÓN</span><h2>Las cosas bonitas<br />empiezan con<br /><em>un buen cuidado.</em></h2><p>Detrás de cada cita hay una familia y una historia. Aquí, tienes un lugar para acompañarlas.</p><Link to="/duenos" className="enlace-editorial">Ver nuestra comunidad <span aria-hidden="true">↗</span></Link><GatoDormido className="gato-pausa" /></div>
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
