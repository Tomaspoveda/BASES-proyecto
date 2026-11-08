// Truquito: las rutas son async y si algo falla adentro, Express no se entera.
// Esto las envuelve para que cualquier error vaya directo al manejador de errores.
// Se usa así: router.get('/', envolver(async (req, res) => { ... }))
export const envolver = (funcion) => (req, res, next) => {
  Promise.resolve(funcion(req, res)).catch(next)
}
