import { useEffect, useState } from 'react'
import { Button, Col, Form, Modal, Row, Table } from 'react-bootstrap'
import Alerta from '../componentes/Alerta'
import Cargando from '../componentes/Cargando'
import Tabla from '../componentes/Tabla'
import { listarCitas, obtenerCita, registrarCita, reprogramarCita, eliminarCita } from '../api/citas'
import { listarMascotas } from '../api/mascotas'
import { listarMedicamentos, listarProcedimientos, listarVeterinarios } from '../api/catalogos'
import { validarCita } from '../validaciones/citas'

const moneda = (valor) =>
  new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(Number(valor))

const FORM_VACIO = {
  id_mascota: '', fecha_cita: '', hora: '', id_veterinario: '', motivo: '',
  procedimientos: [], recetas: [],
}
const FILA_PROCEDIMIENTO = { id_procedimiento: '', costo: '' }
const FILA_RECETA = { id_medicamento: '', dosis: '' }

const COLUMNAS = [
  { titulo: 'Mascota', campo: 'nombre_mascota' },
  { titulo: 'N.º', campo: 'numero_cita' },
  { titulo: 'Fecha', campo: 'fecha_cita' },
  { titulo: 'Hora', campo: 'hora_corta' },
  { titulo: 'Veterinario', campo: 'nombre_veterinario' },
  { titulo: 'Motivo', campo: 'motivo' },
  { titulo: 'Procedimientos', campo: 'total_texto' },
]

export default function Citas() {
  const [citas, setCitas] = useState([])
  const [mascotas, setMascotas] = useState([])
  const [veterinarios, setVeterinarios] = useState([])
  const [procedimientos, setProcedimientos] = useState([])
  const [medicamentos, setMedicamentos] = useState([])
  const [filtroMascota, setFiltroMascota] = useState('') // '' = todas las mascotas
  const [cargando, setCargando] = useState(true)
  const [alerta, setAlerta] = useState({ tipo: 'danger', mensaje: '' })
  const [mostrarForm, setMostrarForm] = useState(false)
  const [editando, setEditando] = useState(null) // null = cita nueva; si no, { id_mascota, numero }
  const [form, setForm] = useState(FORM_VACIO)
  const [errores, setErrores] = useState({})
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)
  const [detalle, setDetalle] = useState(null)
  const [version, setVersion] = useState(0)

  // Listas para los desplegables: se cargan una sola vez
  useEffect(() => {
    let activo = true

    async function cargarCatalogos() {
      try {
        const [m, v, p, med] = await Promise.all([
          listarMascotas(),
          listarVeterinarios(),
          listarProcedimientos(),
          listarMedicamentos(),
        ])
        if (!activo) return
        setMascotas(m)
        setVeterinarios(v)
        setProcedimientos(p)
        setMedicamentos(med)
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
        const datos = await listarCitas(filtroMascota)
        if (activo) setCitas(datos)
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
  }, [filtroMascota, version])

  function cambiarFiltro(e) {
    setCargando(true)
    setFiltroMascota(e.target.value)
  }

  function abrirNueva() {
    setEditando(null)
    setForm({ ...FORM_VACIO, id_mascota: filtroMascota })
    setErrores({})
    setErrorForm('')
    setMostrarForm(true)
  }

  function abrirReprogramar(cita) {
    setEditando({ id_mascota: cita.id_mascota, numero: cita.numero_cita })
    setForm({
      ...FORM_VACIO,
      id_mascota: String(cita.id_mascota),
      fecha_cita: cita.fecha_cita,
      hora: cita.hora.slice(0, 5),
      id_veterinario: String(cita.id_veterinario),
      motivo: cita.motivo,
    })
    setErrores({})
    setErrorForm('')
    setMostrarForm(true)
  }

  function cambiar(e) {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  // Manejo de las filas dinámicas (procedimientos y recetas)
  function agregarFila(lista, filaVacia) {
    setForm((f) => ({ ...f, [lista]: [...f[lista], filaVacia] }))
  }

  function quitarFila(lista, indice) {
    setForm((f) => ({ ...f, [lista]: f[lista].filter((_, i) => i !== indice) }))
  }

  function cambiarFila(lista, indice, campo, valor) {
    setForm((f) => ({
      ...f,
      [lista]: f[lista].map((fila, i) => (i === indice ? { ...fila, [campo]: valor } : fila)),
    }))
  }

  async function guardar(e) {
    e.preventDefault()
    const reprogramando = editando !== null

    const erroresNuevos = validarCita(form, { reprogramando })
    setErrores(erroresNuevos)
    if (Object.keys(erroresNuevos).length > 0) return

    setGuardando(true)
    setErrorForm('')
    try {
      if (reprogramando) {
        await reprogramarCita(editando.id_mascota, editando.numero, {
          fecha_cita: form.fecha_cita,
          hora: form.hora,
          id_veterinario: form.id_veterinario,
          motivo: form.motivo.trim(),
        })
        setAlerta({ tipo: 'success', mensaje: 'Cita reprogramada correctamente' })
      } else {
        const creada = await registrarCita({
          id_mascota: form.id_mascota,
          fecha_cita: form.fecha_cita,
          hora: form.hora,
          id_veterinario: form.id_veterinario,
          motivo: form.motivo.trim(),
          procedimientos: form.procedimientos.map((p) =>
            p.costo === ''
              ? { id_procedimiento: p.id_procedimiento }
              : { id_procedimiento: p.id_procedimiento, costo: p.costo },
          ),
          recetas: form.recetas.map((r) => ({ id_medicamento: r.id_medicamento, dosis: r.dosis.trim() })),
        })
        setAlerta({
          tipo: 'success',
          mensaje: `Cita n.º ${creada.numero_cita} registrada para ${creada.nombre_mascota}`,
        })
      }
      setMostrarForm(false)
      setVersion((v) => v + 1)
    } catch (err) {
      setErrorForm(err.message) // por ejemplo: el veterinario ya tiene una cita a esa hora (409)
    } finally {
      setGuardando(false)
    }
  }

  async function verDetalle(cita) {
    try {
      setDetalle(await obtenerCita(cita.id_mascota, cita.numero_cita))
    } catch (err) {
      setAlerta({ tipo: 'danger', mensaje: err.message })
    }
  }

  async function borrar(cita) {
    if (!window.confirm(`¿Eliminar la cita n.º ${cita.numero_cita} de ${cita.nombre_mascota}? Se borran también sus procedimientos y recetas.`)) return
    try {
      await eliminarCita(cita.id_mascota, cita.numero_cita)
      setAlerta({ tipo: 'success', mensaje: 'Cita eliminada' })
      setVersion((v) => v + 1)
    } catch (err) {
      setAlerta({ tipo: 'danger', mensaje: err.message })
    }
  }

  const filas = citas.map((c) => ({
    ...c,
    hora_corta: c.hora.slice(0, 5),
    total_texto: moneda(c.total_procedimientos),
  }))

  const totalDetalle = detalle
    ? detalle.procedimientos.reduce((suma, p) => suma + Number(p.costo), 0)
    : 0

  const reprogramando = editando !== null

  return (
    <>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h2>Citas</h2>
        <Button onClick={abrirNueva}>Nueva cita</Button>
      </div>

      <Alerta
        tipo={alerta.tipo}
        mensaje={alerta.mensaje}
        onCerrar={() => setAlerta({ ...alerta, mensaje: '' })}
      />

      <Row className="mb-3">
        <Col md={5}>
          <Form.Label>Filtrar por mascota</Form.Label>
          <Form.Select value={filtroMascota} onChange={cambiarFiltro}>
            <option value="">Todas las mascotas</option>
            {mascotas.map((m) => (
              <option key={m.id_mascota} value={m.id_mascota}>
                {m.nombre_mascota} ({m.nombre_dueno})
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
          filas={filas}
          acciones={(c) => (
            <>
              <Button size="sm" variant="outline-secondary" className="me-2" onClick={() => verDetalle(c)}>
                Ver
              </Button>
              <Button size="sm" variant="outline-primary" className="me-2" onClick={() => abrirReprogramar(c)}>
                Reprogramar
              </Button>
              <Button size="sm" variant="outline-danger" onClick={() => borrar(c)}>
                Eliminar
              </Button>
            </>
          )}
        />
      )}

      {/* ---------- Formulario: nueva cita o reprogramar ---------- */}
      <Modal show={mostrarForm} onHide={() => setMostrarForm(false)} size="lg" scrollable>
        <Form onSubmit={guardar} noValidate>
          <Modal.Header closeButton>
            <Modal.Title>{reprogramando ? 'Reprogramar cita' : 'Nueva cita'}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <Alerta mensaje={errorForm} onCerrar={() => setErrorForm('')} />

            <Form.Group className="mb-3">
              <Form.Label>Mascota</Form.Label>
              <Form.Select name="id_mascota" value={form.id_mascota} onChange={cambiar}
                disabled={reprogramando} isInvalid={!!errores.id_mascota}>
                <option value="">Seleccione una mascota</option>
                {mascotas.map((m) => (
                  <option key={m.id_mascota} value={m.id_mascota}>
                    {m.nombre_mascota} ({m.nombre_dueno})
                  </option>
                ))}
              </Form.Select>
              <Form.Control.Feedback type="invalid">{errores.id_mascota}</Form.Control.Feedback>
            </Form.Group>

            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Fecha</Form.Label>
                  <Form.Control type="date" name="fecha_cita" value={form.fecha_cita}
                    onChange={cambiar} isInvalid={!!errores.fecha_cita} />
                  <Form.Control.Feedback type="invalid">{errores.fecha_cita}</Form.Control.Feedback>
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Hora</Form.Label>
                  <Form.Control type="time" name="hora" value={form.hora}
                    onChange={cambiar} isInvalid={!!errores.hora} />
                  <Form.Control.Feedback type="invalid">{errores.hora}</Form.Control.Feedback>
                </Form.Group>
              </Col>
            </Row>

            <Form.Group className="mb-3">
              <Form.Label>Veterinario</Form.Label>
              <Form.Select name="id_veterinario" value={form.id_veterinario}
                onChange={cambiar} isInvalid={!!errores.id_veterinario}>
                <option value="">Seleccione un veterinario</option>
                {veterinarios.map((v) => (
                  <option key={v.id_veterinario} value={v.id_veterinario}>
                    {v.nombre_veterinario} · {v.especialidad}
                  </option>
                ))}
              </Form.Select>
              <Form.Control.Feedback type="invalid">{errores.id_veterinario}</Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Motivo (opcional)</Form.Label>
              <Form.Control name="motivo" value={form.motivo} maxLength={150}
                placeholder="Si lo deja vacío: Control general de rutina"
                onChange={cambiar} isInvalid={!!errores.motivo} />
              <Form.Control.Feedback type="invalid">{errores.motivo}</Form.Control.Feedback>
            </Form.Group>

            {!reprogramando && (
              <>
                <hr />
                <div className="d-flex justify-content-between align-items-center mb-2">
                  <h6 className="mb-0">Procedimientos realizados</h6>
                  <Button size="sm" variant="outline-primary"
                    onClick={() => agregarFila('procedimientos', FILA_PROCEDIMIENTO)}>
                    + Agregar procedimiento
                  </Button>
                </div>
                {form.procedimientos.map((fila, i) => (
                  <Row key={i} className="g-2 mb-2">
                    <Col md={6}>
                      <Form.Select value={fila.id_procedimiento}
                        onChange={(e) => cambiarFila('procedimientos', i, 'id_procedimiento', e.target.value)}>
                        <option value="">Procedimiento</option>
                        {procedimientos.map((p) => (
                          <option key={p.id_procedimiento} value={p.id_procedimiento}>
                            {p.nombre_procedimiento} ({moneda(p.costo_referencia)})
                          </option>
                        ))}
                      </Form.Select>
                    </Col>
                    <Col md={4}>
                      <Form.Control type="number" min="0" step="0.01" value={fila.costo}
                        placeholder="Costo (vacío = el de referencia)"
                        onChange={(e) => cambiarFila('procedimientos', i, 'costo', e.target.value)} />
                    </Col>
                    <Col md={2}>
                      <Button variant="outline-danger" className="w-100"
                        onClick={() => quitarFila('procedimientos', i)}>
                        Quitar
                      </Button>
                    </Col>
                  </Row>
                ))}
                {errores.procedimientos && <div className="text-danger small mb-2">{errores.procedimientos}</div>}

                <div className="d-flex justify-content-between align-items-center mt-4 mb-2">
                  <h6 className="mb-0">Medicamentos recetados</h6>
                  <Button size="sm" variant="outline-primary"
                    onClick={() => agregarFila('recetas', FILA_RECETA)}>
                    + Agregar medicamento
                  </Button>
                </div>
                {form.recetas.map((fila, i) => (
                  <Row key={i} className="g-2 mb-2">
                    <Col md={5}>
                      <Form.Select value={fila.id_medicamento}
                        onChange={(e) => cambiarFila('recetas', i, 'id_medicamento', e.target.value)}>
                        <option value="">Medicamento</option>
                        {medicamentos.map((m) => (
                          <option key={m.id_medicamento} value={m.id_medicamento}>
                            {m.nombre_medicamento} ({m.presentacion})
                          </option>
                        ))}
                      </Form.Select>
                    </Col>
                    <Col md={5}>
                      <Form.Control value={fila.dosis} maxLength={50} placeholder="Dosis (ej: 1 tableta cada 12 horas)"
                        onChange={(e) => cambiarFila('recetas', i, 'dosis', e.target.value)} />
                    </Col>
                    <Col md={2}>
                      <Button variant="outline-danger" className="w-100"
                        onClick={() => quitarFila('recetas', i)}>
                        Quitar
                      </Button>
                    </Col>
                  </Row>
                ))}
                {errores.recetas && <div className="text-danger small mb-2">{errores.recetas}</div>}
              </>
            )}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setMostrarForm(false)}>Cancelar</Button>
            <Button type="submit" disabled={guardando}>
              {guardando ? 'Guardando...' : 'Guardar'}
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>

      {/* ---------- Detalle de una cita ---------- */}
      <Modal show={detalle !== null} onHide={() => setDetalle(null)} size="lg" scrollable>
        <Modal.Header closeButton>
          <Modal.Title>Cita n.º {detalle?.numero_cita} de {detalle?.nombre_mascota}</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {detalle && (
            <>
              <p>
                <strong>Fecha:</strong> {detalle.fecha_cita} a las {detalle.hora.slice(0, 5)}
                <br />
                <strong>Veterinario:</strong> {detalle.nombre_veterinario}
                <br />
                <strong>Motivo:</strong> {detalle.motivo}
              </p>

              <h6>Procedimientos</h6>
              {detalle.procedimientos.length === 0 ? (
                <p className="text-muted">Sin procedimientos registrados.</p>
              ) : (
                <Table size="sm">
                  <thead>
                    <tr><th>Procedimiento</th><th className="text-end">Costo</th></tr>
                  </thead>
                  <tbody>
                    {detalle.procedimientos.map((p) => (
                      <tr key={p.id_procedimiento}>
                        <td>{p.nombre_procedimiento}</td>
                        <td className="text-end">{moneda(p.costo)}</td>
                      </tr>
                    ))}
                    <tr className="fw-bold">
                      <td>Total</td>
                      <td className="text-end">{moneda(totalDetalle)}</td>
                    </tr>
                  </tbody>
                </Table>
              )}

              <h6 className="mt-3">Medicamentos recetados</h6>
              {detalle.recetas.length === 0 ? (
                <p className="text-muted">Sin medicamentos recetados.</p>
              ) : (
                <Table size="sm">
                  <thead>
                    <tr><th>Medicamento</th><th>Presentación</th><th>Dosis</th></tr>
                  </thead>
                  <tbody>
                    {detalle.recetas.map((r) => (
                      <tr key={r.id_medicamento}>
                        <td>{r.nombre_medicamento}</td>
                        <td>{r.presentacion}</td>
                        <td>{r.dosis}</td>
                      </tr>
                    ))}
                  </tbody>
                </Table>
              )}
            </>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setDetalle(null)}>Cerrar</Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}