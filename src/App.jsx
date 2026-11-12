import { BrowserRouter, Routes, Route, NavLink, Link } from 'react-router-dom'
import { Container, Nav, Navbar } from 'react-bootstrap'
import Duenos from './paginas/Duenos'
import Mascotas from './paginas/Mascotas'
import Citas from './paginas/Citas'
import Inicio from './paginas/Inicio'

function Huella() {
  return (
    <svg width="26" height="26" viewBox="0 0 52 52" aria-hidden="true" focusable="false">
      <g fill="currentColor">
        <ellipse cx="8" cy="19" rx="4.6" ry="6" transform="rotate(-20 8 19)" />
        <ellipse cx="19" cy="9.5" rx="4.6" ry="6.4" transform="rotate(-8 19 9.5)" />
        <ellipse cx="33" cy="9.5" rx="4.6" ry="6.4" transform="rotate(8 33 9.5)" />
        <ellipse cx="44" cy="19" rx="4.6" ry="6" transform="rotate(20 44 19)" />
        <path d="M26 21c-6.6 0-13 6.4-13 12.6 0 4.2 3.2 6.4 7 6.4 2.3 0 3.8-1 6-1s3.7 1 6 1c3.8 0 7-2.2 7-6.4C39 27.4 32.6 21 26 21z" />
      </g>
    </svg>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <Navbar className="navbar-vet" data-bs-theme="dark" expand="md">
        <Container>
          <Navbar.Brand as={Link} to="/">
            <Huella />
            Clínica Veterinaria
          </Navbar.Brand>
          <Navbar.Toggle aria-controls="menu-principal" />
          <Navbar.Collapse id="menu-principal">
            <Nav className="me-auto">
              <Nav.Link as={NavLink} to="/duenos">Dueños</Nav.Link>
              <Nav.Link as={NavLink} to="/mascotas">Mascotas</Nav.Link>
              <Nav.Link as={NavLink} to="/citas">Citas</Nav.Link>
            </Nav>
          </Navbar.Collapse>
        </Container>
      </Navbar>

      <Container className="contenido">
        <Routes>
          <Route path="/" element={<Inicio />} />          
          <Route path="/duenos" element={<Duenos />} />
          <Route path="/mascotas" element={<Mascotas />} />
          <Route path="/citas" element={<Citas />} />
        </Routes>
      </Container>
    </BrowserRouter>
  )
}