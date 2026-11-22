import { BrowserRouter, Routes, Route, NavLink, Link } from 'react-router-dom'
import Inicio from './paginas/Inicio'
import Duenos from './paginas/Duenos'
import Mascotas from './paginas/Mascotas'
import Citas from './paginas/Citas'
import { Gatito, Ramita } from './componentes/Ilustraciones'

const ENLACES = [
  { ruta: '/', texto: 'Inicio', fin: true, d: 'M3 11l9-8 9 8v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z' },
  { ruta: '/duenos', texto: 'Dueños', d: 'M16 20v-1.5a4.5 4.5 0 0 0-4.5-4.5h-3A4.5 4.5 0 0 0 4 18.5V20M10 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7zM20 20v-1.4a4 4 0 0 0-3-3.8' },
  { ruta: '/mascotas', texto: 'Mascotas', d: 'M12 21c-3.5 0-6-1.8-6-4.2 0-2.7 3-5.8 6-5.8s6 3.1 6 5.8c0 2.4-2.5 4.2-6 4.2zM5 10a1.7 2.3 0 1 0 0-.1M19 10a1.7 2.3 0 1 0 0-.1M9 6.5a1.6 2.2 0 1 0 0-.1M15 6.5a1.6 2.2 0 1 0 0-.1' },
  { ruta: '/citas', texto: 'Citas', d: 'M4 6.5A2.5 2.5 0 0 1 6.5 4h11A2.5 2.5 0 0 1 20 6.5v11a2.5 2.5 0 0 1-2.5 2.5h-11A2.5 2.5 0 0 1 4 17.5zM4 10h16M8 2.5V6M16 2.5V6' },
]

export default function App() {
  return (
    <BrowserRouter>
      <div className="cinta-bienvenida">Un lugar tranquilo para cuidar a quienes más quieres <span aria-hidden="true">✳</span></div>
      <header className="barra">
        <Link to="/" className="marca">
          <span className="marca-icono"><Gatito /></span>
          <span className="marca-texto">Clínica Veterinaria<small>CUIDADO CON CARIÑO</small></span>
        </Link>

        <nav className="navegacion" aria-label="Principal">
          {ENLACES.map((e) => (
            <NavLink key={e.ruta} to={e.ruta} end={e.fin} className="nav-item">
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor"
                strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                <path d={e.d} />
              </svg>
              <span>{e.texto}</span>
            </NavLink>
          ))}
        </nav>
        <Link to="/citas" className="boton boton-lleno barra-cita">Ir a citas <span aria-hidden="true">↗</span></Link>
      </header>

      <main className="contenido">
        <Routes>
          <Route path="/" element={<Inicio />} />
          <Route path="/duenos" element={<Duenos />} />
          <Route path="/mascotas" element={<Mascotas />} />
          <Route path="/citas" element={<Citas />} />
        </Routes>
      </main>
      <footer className="pie">
        <div className="pie-interior">
          <Link to="/" className="marca"><span className="marca-icono"><Gatito /></span><span className="marca-texto">Clínica Veterinaria<small>PEQUEÑAS PATITAS. GRANDES AFECTOS.</small></span></Link>
          <p>El cariño también es una forma de cuidar.</p>
          <Ramita className="pie-ramita" />
        </div>
      </footer>
    </BrowserRouter>
  )
}
