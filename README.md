# EAFIT · Ciberseguridad SI3006

Repositorio de equipo para el código y las evidencias técnicas de los talleres
de Ciberseguridad, semestre 2026-2. **El informe completo, el análisis y las
diapositivas viven en el Google Doc y en la presentación** — aquí solo va lo
que es código, script o archivo versionable (diagramas .drawio, capturas de
evidencia técnica).

## Estructura

```
eafit-ciberseguridad-si3006/
├── taller-1/
│   ├── punto3-bandit/        → Gerónimo
│   ├── punto4-cesar/         → Santiago
│   ├── punto5-codificacion/  → Santiago
│   ├── punto6-pcap/          → David
│   └── punto9-cloud/         → Valentina
├── taller-2/                 (cuando exista)
└── ...
```

Cada taller nuevo del semestre agrega una carpeta `taller-N/` al mismo repo.
No se crea un repo por taller.

## Cómo subir tu parte (sin usar comandos de git)

No hace falta saber usar git desde la terminal. Así de simple:

1. Entra a la carpeta que te corresponde (la de tu punto, arriba).
2. Botón **Add file → Upload files**.
3. Arrastra tus archivos (código, README de tu punto, evidencias).
4. Abajo, en "Commit changes", escribe un mensaje corto describiendo qué subiste
   (ej: `Agrego script de cifrado César y pruebas`).
5. Click en **Commit changes directly to the main branch**.

**Importante:** cada quien sube sus propios archivos con su propia cuenta de
GitHub. No le pases tus archivos a otro para que los suba por ti — el
historial de commits es evidencia de que cada uno hizo su parte.

## Si prefieres usar git

```bash
git clone https://github.com/<usuario-o-org>/eafit-ciberseguridad-si3006.git
cd eafit-ciberseguridad-si3006/taller-1/punto4-cesar
# agrega tus archivos aquí
git add .
git commit -m "Agrego script de cifrado César y pruebas"
git push
```

## Reglas del repo

- Escribe solo dentro de la carpeta de tu punto. Si necesitas algo de otra
  carpeta, pide que te lo compartan, no lo edites directamente.
- Cada carpeta de punto tiene su propio README con lo que debe contener.
- Sube evidencia real (capturas, salidas de comandos), no solo código.
