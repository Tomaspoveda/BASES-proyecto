import { Link } from 'react-router-dom'

const ACCESOS = [
  {
    ruta: '/duenos',
    titulo: 'Dueños',
    texto: 'Registra y edita a los dueños y sus teléfonos.',
    icono: (
      <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor"
        strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <circle cx="9" cy="8" r="3.5" />
        <path d="M2.5 20c0-3.6 2.9-6 6.5-6s6.5 2.4 6.5 6" />
        <circle cx="17.5" cy="9" r="2.6" />
        <path d="M17 14.2c2.7.1 4.5 1.9 4.5 4.8" />
      </svg>
    ),
  },
  {
    ruta: '/mascotas',
    titulo: 'Mascotas',
    texto: 'Consulta las mascotas, su especie y su raza.',
    icono: (
      <svg viewBox="0 0 52 52" width="28" height="28" fill="currentColor" aria-hidden="true">
        <ellipse cx="8" cy="19" rx="4.6" ry="6" transform="rotate(-20 8 19)" />
        <ellipse cx="19" cy="9.5" rx="4.6" ry="6.4" transform="rotate(-8 19 9.5)" />
        <ellipse cx="33" cy="9.5" rx="4.6" ry="6.4" transform="rotate(8 33 9.5)" />
        <ellipse cx="44" cy="19" rx="4.6" ry="6" transform="rotate(20 44 19)" />
        <path d="M26 21c-6.6 0-13 6.4-13 12.6 0 4.2 3.2 6.4 7 6.4 2.3 0 3.8-1 6-1s3.7 1 6 1c3.8 0 7-2.2 7-6.4C39 27.4 32.6 21 26 21z" />
      </svg>
    ),
  },
  {
    ruta: '/citas',
    titulo: 'Citas',
    texto: 'Registra, reprograma y revisa las citas de cada mascota.',
    icono: (
      <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor"
        strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <rect x="3.5" y="5" width="17" height="15.5" rx="2.5" />
        <path d="M3.5 10h17M8 3v4M16 3v4" />
      </svg>
    ),
  },
]

export default function Inicio() {
  return (
    <>
      <div className="inicio-cabecera">
        <h1>Clínica Veterinaria</h1>
        <p>¿Qué quieres gestionar hoy?</p>
      </div>

      <div className="accesos">
        {ACCESOS.map((a) => (
          <Link key={a.ruta} to={a.ruta} className="acceso">
            <span className="acceso-icono">{a.icono}</span>
            <span className="acceso-titulo">{a.titulo}</span>
            <span className="acceso-texto">{a.texto}</span>
          </Link>
        ))}
      </div>
    </>
  )
}