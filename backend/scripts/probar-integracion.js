import { spawnSync } from 'node:child_process'

const resultado = spawnSync(process.execPath, ['--test'], {
  env: { ...process.env, PROBAR_MYSQL: '1' },
  stdio: 'inherit',
})
if (resultado.error) throw resultado.error
process.exitCode = resultado.status ?? 1
