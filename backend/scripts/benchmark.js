// Prueba de rendimiento de índices (requisito de Ingeniería Informática).
//
// Qué hace:
//   1. Crea una COPIA de la tabla cita (cita_bench) SIN índices y le agrega filas sintéticas.
//      Se usa una copia para no ensuciar los datos reales de la clínica.
//   2. Para cada consulta: mide el tiempo y el EXPLAIN SIN índice, crea el índice,
//      mide otra vez CON índice y lo borra.
//   3. Imprime el resultado y lo guarda en scripts/resultado_benchmark.md
//   4. Borra la tabla de prueba.
//
// Uso (desde la carpeta backend, con MySQL prendido y el .env listo):
//   npm run benchmark            -> agrega 20.000 filas
//   node scripts/benchmark.js 50000   -> agrega 50.000 filas (el mínimo del proyecto es 5.000)
//
// Nota: esto es una herramienta de medición, no parte de la aplicación; por eso usa SQL directo.
// Necesita un usuario con permisos sobre las tablas (el root del .env sirve).
import { writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { pool } from '../src/db.js'

const TABLA = 'cita_bench'
const MINIMO = 5000
const FILAS_EXTRA = Number(process.argv[2] ?? 20000)
const REPETICIONES = 20

if (!Number.isInteger(FILAS_EXTRA) || FILAS_EXTRA < MINIMO) {
  console.error(`Indica un número entero de filas de al menos ${MINIMO}. Ejemplo: node scripts/benchmark.js 20000`)
  process.exit(1)
}

// Generador de números al azar con semilla: así los datos salen iguales en cada ejecución
function crearAzar(semilla) {
  let a = semilla
  return () => {
    a |= 0
    a = (a + 0x6d2b79f5) | 0
    let t = Math.imul(a ^ (a >>> 15), 1 | a)
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

const MOTIVOS = [
  'Control general de rutina', 'Vacunación anual', 'Desparasitación', 'Revisión de piel',
  'Cojera en pata trasera', 'Control postoperatorio', 'Problemas digestivos', 'Limpieza dental',
]

// Mide la mediana de varias ejecuciones (la mediana evita que un pico aislado dañe el resultado)
async function medir(sql) {
  await pool.query(sql) // calentamiento: la primera vez carga datos a memoria
  const tiempos = []
  for (let i = 0; i < REPETICIONES; i++) {
    const inicio = process.hrtime.bigint()
    await pool.query(sql)
    tiempos.push(Number(process.hrtime.bigint() - inicio) / 1e6)
  }
  tiempos.sort((x, y) => x - y)
  return tiempos[Math.floor(tiempos.length / 2)]
}

async function explicar(sql) {
  const [filas] = await pool.query(`EXPLAIN ${sql}`)
  const f = filas[0]
  return { tipo: f.type, indice: f.key ?? '(ninguno)', filas: f.rows, extra: f.Extra ?? '' }
}

async function main() {
  await pool.query(`DROP TABLE IF EXISTS ${TABLA}`)
  // Mismas columnas que cita, pero SIN llaves ni índices: es el punto de partida "sin índice"
  await pool.query(`
    CREATE TABLE ${TABLA} (
      FK_id_mascota INT NOT NULL,
      numero_cita INT NOT NULL,
      fecha_cita DATE NOT NULL,
      hora TIME NOT NULL,
      motivo VARCHAR(255),
      FK_id_veterinario INT NOT NULL
    )`)

  // 1) Copia de las citas reales
  await pool.query(`
    INSERT INTO ${TABLA} (FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario)
    SELECT FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario FROM cita`)
  const [[{ n: reales }]] = await pool.query(`SELECT COUNT(*) AS n FROM ${TABLA}`)

  // 2) Filas sintéticas: mascotas y veterinarios que existen de verdad, fechas de 2024 a 2026
  const [mascotas] = await pool.query('SELECT id_mascota FROM mascota')
  const [veterinarios] = await pool.query('SELECT id_veterinario FROM veterinario')
  const [maximos] = await pool.query(
    `SELECT FK_id_mascota AS id, MAX(numero_cita) AS maximo FROM ${TABLA} GROUP BY FK_id_mascota`)
  const siguiente = new Map(maximos.map((m) => [m.id, m.maximo + 1]))

  const azar = crearAzar(2026)
  const elegir = (lista) => lista[Math.floor(azar() * lista.length)]
  const inicio = Date.UTC(2024, 0, 1)
  const DIAS = 1065 // hasta noviembre de 2026

  const nuevas = []
  for (let i = 0; i < FILAS_EXTRA; i++) {
    const idMascota = elegir(mascotas).id_mascota
    const numero = siguiente.get(idMascota) ?? 1
    siguiente.set(idMascota, numero + 1)
    const fecha = new Date(inicio + Math.floor(azar() * DIAS) * 86400000).toISOString().slice(0, 10)
    const hora = `${String(8 + Math.floor(azar() * 10)).padStart(2, '0')}:${azar() < 0.5 ? '00' : '30'}:00`
    nuevas.push([idMascota, numero, fecha, hora, elegir(MOTIVOS), elegir(veterinarios).id_veterinario])
  }
  for (let i = 0; i < nuevas.length; i += 1000) {
    await pool.query(
      `INSERT INTO ${TABLA} (FK_id_mascota, numero_cita, fecha_cita, hora, motivo, FK_id_veterinario) VALUES ?`,
      [nuevas.slice(i, i + 1000)])
  }
  await pool.query(`ANALYZE TABLE ${TABLA}`) // actualiza las estadísticas que usa el optimizador
  const total = reales + FILAS_EXTRA
  console.log(`Tabla de prueba lista: ${reales} citas reales + ${FILAS_EXTRA} sintéticas = ${total} filas\n`)

  const idVeterinario = veterinarios[0].id_veterinario
  const idMascota = mascotas[0].id_mascota

  const PRUEBAS = [
    {
      nombre: 'Citas de un trimestre (rango de fechas)',
      sql: `SELECT COUNT(*) AS total FROM ${TABLA} WHERE fecha_cita BETWEEN '2026-01-01' AND '2026-03-31'`,
      indice: 'idx_bench_fecha',
      columnas: 'fecha_cita',
    },
    {
      nombre: `Agenda de un veterinario en un semestre (veterinario ${idVeterinario})`,
      sql: `SELECT COUNT(*) AS total FROM ${TABLA}
            WHERE FK_id_veterinario = ${idVeterinario} AND fecha_cita BETWEEN '2026-01-01' AND '2026-06-30'`,
      indice: 'idx_bench_vet_fecha',
      columnas: 'FK_id_veterinario, fecha_cita',
    },
    {
      nombre: `Últimas 5 citas de una mascota (mascota ${idMascota})`,
      sql: `SELECT numero_cita, fecha_cita FROM ${TABLA}
            WHERE FK_id_mascota = ${idMascota} ORDER BY numero_cita DESC LIMIT 5`,
      indice: 'idx_bench_mascota_numero',
      columnas: 'FK_id_mascota, numero_cita',
    },
  ]

  const resultados = []
  for (const prueba of PRUEBAS) {
    const planSin = await explicar(prueba.sql)
    const msSin = await medir(prueba.sql)

    await pool.query(`CREATE INDEX ${prueba.indice} ON ${TABLA} (${prueba.columnas})`)
    const planCon = await explicar(prueba.sql)
    const msCon = await medir(prueba.sql)
    await pool.query(`DROP INDEX ${prueba.indice} ON ${TABLA}`) // se borra para que no afecte la siguiente prueba

    resultados.push({ ...prueba, planSin, msSin, planCon, msCon })
    console.log(`\n=== ${prueba.nombre} ===`)
    console.log(`Índice probado: ${prueba.indice} (${prueba.columnas})`)
    console.table([
      { caso: 'SIN índice', 'tiempo (ms)': msSin.toFixed(2), tipo: planSin.tipo, índice: planSin.indice, 'filas leídas': planSin.filas, extra: planSin.extra },
      { caso: 'CON índice', 'tiempo (ms)': msCon.toFixed(2), tipo: planCon.tipo, índice: planCon.indice, 'filas leídas': planCon.filas, extra: planCon.extra },
    ])
  }

  // Resumen en Markdown para pegar en el documento de arquitectura
  let md = `# Resultado del benchmark de índices\n\n`
  md += `Tabla de prueba \`${TABLA}\`: ${reales} citas reales + ${FILAS_EXTRA} sintéticas = **${total} filas**. `
  md += `Cada tiempo es la mediana de ${REPETICIONES} ejecuciones.\n\n`
  md += `| Consulta | Índice | Sin índice (ms) | Con índice (ms) | Mejora | Plan sin índice | Plan con índice |\n|---|---|---|---|---|---|---|\n`
  for (const r of resultados) {
    md += `| ${r.nombre} | \`${r.indice}\` (${r.columnas}) | ${r.msSin.toFixed(2)} | ${r.msCon.toFixed(2)} | ${(r.msSin / r.msCon).toFixed(1)}x `
    md += `| ${r.planSin.tipo}, ${r.planSin.filas} filas | ${r.planCon.tipo}, ${r.planCon.filas} filas |\n`
  }
  const ruta = fileURLToPath(new URL('./resultado_benchmark.md', import.meta.url))
  writeFileSync(ruta, md, 'utf8')
  console.log(`\nResumen guardado en ${ruta}`)
}

try {
  await main()
} catch (error) {
  console.error('El benchmark falló:', error.message)
  process.exitCode = 1
} finally {
  await pool.query(`DROP TABLE IF EXISTS ${TABLA}`).catch(() => {})
  await pool.end()
}