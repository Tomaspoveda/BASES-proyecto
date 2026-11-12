import { useEffect, useState } from 'react'
import { Button, Form, Modal } from 'react-bootstrap'
import Alerta from '../componentes/Alerta'
import Cargando from '../componentes/Cargando'
import Tabla from '../componentes/Tabla'
import { listarDuenos, crearDueno, actualizarDueno, eliminarDueno } from '../api/duenos'
import { validarDueno } from '../validaciones/duenos'

const VACIO = { nombre_dueno: '', calle: '', ciudad: '', telefonos: '' }

const COLUMNAS = [
  { titulo: 'Nombre', campo: 'nombre_dueno' },
  { titulo: 'Calle', campo: 'calle' },
  { titulo: 'Ciudad', campo: 'ciudad' },
  { titulo: 'Teléfonos', campo: 'telefonos_texto' },
]

export default function Duenos() {
  const [duenos, setDuenos] = useState([])
  const [cargando, setCargando] = useState(true)
  const [alerta, setAlerta] = useState({ tipo: 'danger', mensaje: '' })
  const [mostrarForm, setMostrarForm] = useState(false)
  const [editandoId, setEditandoId] = useState(null)
  const [form, setForm] = useState(VACIO)
  const [errores, setErrores] = useState({})
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)
  const [version, setVersion] = useState(0)


useEffect(() => {
  let activo = true

  async function cargar() {
    try {
      const datos = await listarDuenos()
      if (!activo) return
      setDuenos(
        datos.map((d) => ({ ...d, telefonos_texto: (d.telefonos ?? []).join(', ') }))
      )
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
}, [version])

  function abrirNuevo() {
    setEditandoId(null)
    setForm(VACIO)
    setErrores({})
    setErrorForm('')
    setMostrarForm(true)
  }

  function abrirEditar(dueno) {
    setEditandoId(dueno.id_dueno)
    setForm({
      nombre_dueno: dueno.nombre_dueno,
      calle: dueno.calle,
      ciudad: dueno.ciudad,
      telefonos: (dueno.telefonos ?? []).join(', '),
    })
    setErrores({})
    setErrorForm('')
    setMostrarForm(true)
  }

  function cambiar(e) {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  async function guardar(e) {
    e.preventDefault()
    const datos = {
      nombre_dueno: form.nombre_dueno.trim(),
      calle: form.calle.trim(),
      ciudad: form.ciudad.trim(),
      telefonos: form.telefonos.split(',').map((t) => t.trim()).filter(Boolean),
    }

    const erroresNuevos = validarDueno(datos)
    setErrores(erroresNuevos)
    if (Object.keys(erroresNuevos).length > 0) return

    setGuardando(true)
    setErrorForm('')
    try {
      if (editandoId) await actualizarDueno(editandoId, datos)
      else await crearDueno(datos)
      setMostrarForm(false)
      setAlerta({ tipo: 'success', mensaje: 'Dueño guardado correctamente' })
      setVersion((v) => v + 1)
    } catch (err) {
      setErrorForm(err.message)
    } finally {
      setGuardando(false)
    }
  }

  async function borrar(dueno) {
    if (!window.confirm(`¿Eliminar a ${dueno.nombre_dueno}?`)) return
    try {
      await eliminarDueno(dueno.id_dueno)
      setAlerta({ tipo: 'success', mensaje: 'Dueño eliminado' })
      setVersion((v) => v + 1)
    } catch (err) {
      setAlerta({ tipo: 'danger', mensaje: err.message })
    }
  }

  return (
    <>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h2>Dueños</h2>
        <Button onClick={abrirNuevo}>Nuevo dueño</Button>
      </div>

      <Alerta
        tipo={alerta.tipo}
        mensaje={alerta.mensaje}
        onCerrar={() => setAlerta({ ...alerta, mensaje: '' })}
      />

      {cargando ? (
        <Cargando />
      ) : (
        <Tabla
          columnas={COLUMNAS}
          filas={duenos}
          acciones={(d) => (
            <>
              <Button size="sm" variant="outline-primary" className="me-2" onClick={() => abrirEditar(d)}>
                Editar
              </Button>
              <Button size="sm" variant="outline-danger" onClick={() => borrar(d)}>
                Eliminar
              </Button>
            </>
          )}
        />
      )}

      <Modal show={mostrarForm} onHide={() => setMostrarForm(false)}>
        <Form onSubmit={guardar} noValidate>
          <Modal.Header closeButton>
            <Modal.Title>{editandoId ? 'Editar dueño' : 'Nuevo dueño'}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <Alerta mensaje={errorForm} onCerrar={() => setErrorForm('')} />

            <Form.Group className="mb-3">
              <Form.Label>Nombre</Form.Label>
              <Form.Control name="nombre_dueno" value={form.nombre_dueno}
                onChange={cambiar} isInvalid={!!errores.nombre_dueno} />
              <Form.Control.Feedback type="invalid">{errores.nombre_dueno}</Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Calle</Form.Label>
              <Form.Control name="calle" value={form.calle}
                onChange={cambiar} isInvalid={!!errores.calle} />
              <Form.Control.Feedback type="invalid">{errores.calle}</Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Ciudad</Form.Label>
              <Form.Control name="ciudad" value={form.ciudad}
                onChange={cambiar} isInvalid={!!errores.ciudad} />
              <Form.Control.Feedback type="invalid">{errores.ciudad}</Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Teléfonos</Form.Label>
              <Form.Control name="telefonos" value={form.telefonos}
                onChange={cambiar} isInvalid={!!errores.telefonos} />
              <Form.Text muted>Separe varios teléfonos con comas.</Form.Text>
              <Form.Control.Feedback type="invalid">{errores.telefonos}</Form.Control.Feedback>
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