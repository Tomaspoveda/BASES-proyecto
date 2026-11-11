import { BrowserRouter, Routes, Route, Navigate, NavLink } from 'react-router-dom'
import { Container, Nav, Navbar } from 'react-bootstrap'
import Duenos from './paginas/Duenos'
import Mascotas from './paginas/Mascotas'

export default function App() {
  return (
    <BrowserRouter>
      <Navbar bg="dark" data-bs-theme="dark" expand="md">
        <Container>
          <Navbar.Brand>Clínica Veterinaria</Navbar.Brand>
          <Nav className="me-auto">
            <Nav.Link as={NavLink} to="/duenos">Dueños</Nav.Link>
            <Nav.Link as={NavLink} to="/mascotas">Mascotas</Nav.Link>
          </Nav>
        </Container>
      </Navbar>

      <Container className="my-4">
        <Routes>
          <Route path="/" element={<Navigate to="/duenos" replace />} />
          <Route path="/duenos" element={<Duenos />} />
          <Route path="/mascotas" element={<Mascotas />} />
        </Routes>
      </Container>
    </BrowserRouter>
  )
}