// Elementos decorativos del tema; no contienen lógica de la aplicación.
export function Gatito({ className = '' }) {
  return (
    <svg className={className} viewBox="0 0 320 350" fill="none" aria-hidden="true">
      <path d="M235 281c68 36 76-42 44-37" stroke="#F2EDE2" strokeWidth="23" strokeLinecap="round" />
      <path d="M89 194c-17 38-23 86-17 125 40 15 129 18 183-2-5-65-28-107-64-121" fill="#F2EDE2" />
      <path d="M67 113 48 38l68 31c28-12 63-13 91 0l50-38 7 89c20 74-23 108-95 108-75 0-118-41-102-115Z" fill="#F2EDE2" />
      <path d="m65 59 12 61 27-38-39-23Zm180-6-31 39 34 17-3-56Z" fill="#245761" />
      <ellipse cx="112" cy="148" rx="20" ry="30" stroke="#245761" strokeWidth="4" />
      <ellipse cx="114" cy="148" rx="13" ry="24" fill="#245761" />
      <ellipse cx="199" cy="148" rx="20" ry="30" stroke="#245761" strokeWidth="4" />
      <ellipse cx="201" cy="148" rx="13" ry="24" fill="#245761" />
      <path d="M148 178q8-5 15 0-6 10-15 0" fill="#245761" />
      <path d="m143 220 29 1-6 22 15 57-24 21-20-23 14-55-8-23Z" fill="#245761" />
      <g stroke="#365940" strokeWidth="9" strokeLinecap="round">
        <path d="m148 52-9-23m27 23 5-28m-47 39-22-8m82 7 23-10m-76 30-20 8m42-4-5 20m25-24 10 19m5-24 23 7" />
      </g>
      <path d="M83 319q-8-14 3-27m133 29q9-16-1-30" stroke="#D7D8C5" strokeWidth="3" strokeLinecap="round" />
    </svg>
  )
}

export function Ramita({ className = '' }) {
  return (
    <svg className={className} viewBox="0 0 100 140" fill="none" aria-hidden="true">
      <g stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <path d="M46 133C34 92 58 57 64 9M45 108C19 111 12 95 14 83c20-1 33 9 31 25Zm2-24C66 86 82 72 80 60 61 61 51 70 47 84ZM52 62C27 61 24 43 28 35c17 5 26 12 24 27Zm7-22C76 38 85 25 80 15 66 19 60 27 59 40ZM64 12C52 24 49 31 54 40" />
      </g>
    </svg>
  )
}

export function GatoDormido({ className = '' }) {
  return (
    <svg className={className} viewBox="0 0 180 85" fill="none" aria-hidden="true">
      <path d="M56 65c-36-6-18-39 19-33 11-18 60-20 63 4 29-5 37 27 11 33-22 5-72 6-101 0" fill="currentColor" />
      <path d="m49 42 2-24 20 15 18-17 9 29" fill="currentColor" />
      <path d="M139 56c28-1 40-23 18-36-17-10-45-3-36-12 11-11 38-7 48 5 22 26 1 59-29 56" stroke="currentColor" strokeWidth="10" strokeLinecap="round" />
      <path d="m57 48 8 2 7-4m13 2 7 2 6-5" stroke="#F2EDE2" strokeWidth="2.5" strokeLinecap="round" />
    </svg>
  )
}

export function IconoCuidado({ tipo, ...props }) {
  const trazos = {
    citas: 'M5 6h14v14H5zM8 3v6m8-6v6M5 11h14m-10 4 2 2 4-4',
    mascotas: 'M8 12c-6 5-3 9 4 9s10-4 4-9c-2-2-6-2-8 0ZM5 7v2m5-6v3m4-3v3m5 1v2',
    duenos: 'M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM2 21v-3a7 7 0 0 1 14 0v3m2-17a4 4 0 0 1 0 8m2 3a6 6 0 0 1 2 5',
    cariño: 'M12 20S2 14 2 7a5 5 0 0 1 10-1A5 5 0 0 1 22 7c0 7-10 13-10 13Z',
  }
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true" {...props}><path d={trazos[tipo] || trazos.cariño} /></svg>
}
