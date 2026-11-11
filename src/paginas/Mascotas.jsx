import { useEffect, useState } from 'react'
import { Button, Col, Form, Modal, Row } from 'react-bootstrap'
import Alerta from '../componentes/Alerta'
import Cargando from '../componentes/Cargando'
import Tabla from '../componentes/Tabla'
import { listarMascotas, crearMascota, actualizarMascota, eliminarMascota } from '../api/mascotas'
import { listarDuenos } from '../api/duenos'
import { listarEspecies, listarRazas } from '../api/catalogos'
import { validarMascota } from '../validaciones/mascotas'

const VACIO = { nombre_mascota: '', fecha_nacimiento: '', id_dueno: '', id_especie: '', id_raza: '' }

const COLUMNAS = [
  { titulo: 'Nombre', campo: 'nombre_mascota' },
  { titulo: 'Especie', campo: 'nombre_especie' },
  { titulo: 'Raza', campo: 'nombre_raza' },
  { titulo: 'Nacimiento', campo: 'fecha_nacimiento' },
  { titulo: 'Dueño', campo: 'nombre_dueno' },
]

export default function Mascotas() {
  const [mascotas, setMascotas] = useState([])
  const [duenos, setDuenos] = useState([])
  const [especies, setEspecies] = useState([])
  const [razas, setRazas] = useState([])
  const [filtroDueno, setFiltroDueno] = useState('') // '' = todos los dueños
  const [cargando, setCargando] = useState(true)
  const [alerta, setAlerta] = useState({ tipo: 'danger', mensaje: '' })
  const [mostrarForm, setMostrarForm] = useState(false)
  const [editandoId, setEditandoId] = useState(null)
  const [form, setForm] = useState(VACIO)
  const [errores, setErrores] = useState({})
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)
  const [version, setVersion] = useState(0)

  // Listas para los desplegables (dueños y especies): se cargan una sola vez
  useEffect(() => {
    let activo = true

    async function cargarCatalogos() {
      try {
        const [listaDuenos, listaEspecies] = await Promise.all([listarDuenos(), listarEspecies()])
        if (!activo) return
        setDuenos(listaDuenos)
        setEspecies(listaEspecies)
      } catch (e) {
        if (activo) setAlerta({ tipo: 'danger', mensaje: e.message })
      }
    }

    cargarCatalogos()
    return () => {
      activo = false
    }
  }, [])

  // La tabla se vuelve a cargar al cambiar el filtro o al guardar/eliminar (version)
  useEffect(() => {
    let activo = true

    async function cargar() {
      try {
        const datos = await listarMascotas(filtroDueno)
        if (activo) setMascotas(datos)
      } catch (e) {
        if (activo) setAlerta({ tipo: 'danger', mensaje: e.message })
      } finally {
        if (activo) setCargando(false)
      }
    }

    cargar()
    return () => {
      activo = false
    }
  }, [filtroDueno, version])

  function cambiarFiltro(e) {
    setCargando(true)
    setFiltroDueno(e.target.value)
  }

  // Las razas dependen de la especie elegida
  async function cargarRazas(idEspecie) {
    if (!idEspecie) {
      setRazas([])
      return
    }
    try {
      setRazas(await listarRazas(idEspecie))
    } catch (err) {
      setErrorForm(err.message)
    }
  }

  function abrirNuevo() {
    setEditandoId(null)
    setForm(VACIO)
    setRazas([])
    setErrores({})
    setErrorForm('')
    setMostrarForm(true)
  }

  async function abrirEditar(mascota) {
    setEditandoId(mascota.id_mascota)
    setForm({
      nombre_mascota: mascota.nombre_mascota,
      fecha_nacimiento: mascota.fecha_nacimiento,
      id_dueno: String(mascota.id_dueno),
      id_especie: String(mascota.id_especie),
      id_raza: String(mascota.id_raza),
    })
    setErrores({})
    setErrorForm('')
    setMostrarForm(true)
    await cargarRazas(mascota.id_especie)
  }

  function cambiar(e) {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  async function cambiarEspecie(e) {
    const idEspecie = e.target.value
    setForm({ ...form, id_especie: idEspecie, id_raza: '' }) // al cambiar de especie, la raza anterior ya no sirve
    await cargarRazas(idEspecie)
  }

  async function guardar(e) {
    e.preventDefault()
    const datos = {
      nombre_mascota: form.nombre_mascota.trim(),
      fecha_nacimiento: form.fecha_nacimiento,
      id_dueno: form.id_dueno,
      id_raza: form.id_raza,
    }

    const erroresNuevos = validarMascota(datos)
    setErrores(erroresNuevos)
    if (Object.keys(erroresNuevos).length > 0) return

    setGuardando(true)
    setErrorForm('')
    try {
      if (editandoId) await actualizarMascota(editandoId, datos)
      else await crearMascota(datos)
      setMostrarForm(false)
      setAlerta({ tipo: 'success', mensaje: 'Mascota guardada correctamente' })
      setVersion((v) => v + 1)
    } catch (err) {
      setErrorForm(err.message)
    } finally {
      setGuardando(false)
    }
  }

  async function borrar(mascota) {
    if (!window.confirm(`¿Eliminar a ${mascota.nombre_mascota}?`)) return
    try {
      await eliminarMascota(mascota.id_mascota)
      setAlerta({ tipo: 'success', mensaje: 'Mascota eliminada' })
      setVersion((v) => v + 1)
    } catch (err) {
      setAlerta({ tipo: 'danger', mensaje: err.message }) // por ejemplo: la mascota tiene citas (409)
    }
  }

  return (
    <>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h2>Mascotas</h2>
        <Button onClick={abrirNuevo}>Nueva mascota</Button>
      </div>

      <Alerta
        tipo={alerta.tipo}
        mensaje={alerta.mensaje}
        onCerrar={() => setAlerta({ ...alerta, mensaje: '' })}
      />

      <Row className="mb-3">
        <Col md={4}>
          <Form.Label>Filtrar por dueño</Form.Label>
          <Form.Select value={filtroDueno} onChange={cambiarFiltro}>
            <option value="">Todos los dueños</option>
            {duenos.map((d) => (
              <option key={d.id_dueno} value={d.id_dueno}>
                {d.nombre_dueno}
              </option>
            ))}
          </Form.Select>
        </Col>
      </Row>

      {cargando ? (
        <Cargando />
      ) : (
        <Tabla
          columnas={COLUMNAS}
          filas={mascotas}
          acciones={(m) => (
            <>
              <Button size="sm" variant="outline-primary" className="me-2" onClick={() => abrirEditar(m)}>
                Editar
              </Button>
              <Button size="sm" variant="outline-danger" onClick={() => borrar(m)}>
                Eliminar
              </Button>
            </>
          )}
        />
      )}

      <Modal show={mostrarForm} onHide={() => setMostrarForm(false)}>
        <Form onSubmit={guardar} noValidate>
          <Modal.Header closeButton>
            <Modal.Title>{editandoId ? 'Editar mascota' : 'Nueva mascota'}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <Alerta mensaje={errorForm} onCerrar={() => setErrorForm('')} />

            <Form.Group className="mb-3">
              <Form.Label>Nombre</Form.Label>
              <Form.Control name="nombre_mascota" value={form.nombre_mascota} maxLength={50}
                onChange={cambiar} isInvalid={!!errores.nombre_mascota} />
              <Form.Control.Feedback type="invalid">{errores.nombre_mascota}</Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Fecha de nacimiento</Form.Label>
              <Form.Control type="date" name="fecha_nacimiento" value={form.fecha_nacimiento}
                max={new Date().toLocaleDateString('en-CA')}
                onChange={cambiar} isInvalid={!!errores.fecha_nacimiento} />
              <Form.Control.Feedback type="invalid">{errores.fecha_nacimiento}</Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Dueño</Form.Label>
              <Form.Select name="id_dueno" value={form.id_dueno}
                onChange={cambiar} isInvalid={!!errores.id_dueno}>
                <option value="">Seleccione un dueño</option>
                {duenos.map((d) => (
                  <option key={d.id_dueno} value={d.id_dueno}>
                    {d.nombre_dueno}
                  </option>
                ))}
              </Form.Select>
              <Form.Control.Feedback type="invalid">{errores.id_dueno}</Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Especie</Form.Label>
              <Form.Select name="id_especie" value={form.id_especie} onChange={cambiarEspecie}>
                <option value="">Seleccione una especie</option>
                {especies.map((e) => (
                  <option key={e.id_especie} value={e.id_especie}>
                    {e.nombre_especie}
                  </option>
                ))}
              </Form.Select>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Raza</Form.Label>
              <Form.Select name="id_raza" value={form.id_raza} disabled={!form.id_especie}
                onChange={cambiar} isInvalid={!!errores.id_raza}>
                <option value="">
                  {form.id_especie ? 'Seleccione una raza' : 'Primero elija una especie'}
                </option>
                {razas.map((r) => (
                  <option key={r.id_raza} value={r.id_raza}>
                    {r.nombre_raza}
                  </option>
                ))}
              </Form.Select>
              <Form.Control.Feedback type="invalid">{errores.id_raza}</Form.Control.Feedback>
            </Form.Group>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setMostrarForm(false)}>Cancelar</Button>
            <Button type="submit" disabled={guardando}>
              {guardando ? 'Guardando...' : 'Guardar'}
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>
    </>
  )
}