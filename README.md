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
├── trabajo-final/
│   ├── punto1-despliegue/            → Kevin
│   ├── punto2-explotacion/           → Kevin
│   ├── punto3-remediacion/           → Santiago
│   ├── punto4-arquitectura/          → Valentina
│   ├── punto5-herramienta-defensiva/ → David
│   ├── punto6-politicas-estandares/  → Gerónimo
│   └── punto7-devsecops/             → Gerónimo
└── ...
```

Cada taller nuevo del semestre agrega una carpeta `taller-N/` al mismo repo.
No se crea un repo por taller.

## Trabajo Final

Mismo esquema que los talleres: una subcarpeta `trabajo-final/puntoN-*/` por
cada punto del enunciado, cada una con su propio README. **Escribe solo
dentro de la carpeta de tu punto** — así nadie tiene que preguntar dónde
sube lo suyo ni crea carpetas propias sueltas en la raíz.

| Carpeta | Punto (enunciado) | % | Responsable |
|---|---|---|---|
| `punto1-despliegue/` | 1 — Despliegue del aplicativo | 5% | Kevin |
| `punto2-explotacion/` | 2 — Explotación de una vulnerabilidad | 5% | Kevin |
| `punto3-remediacion/` | 3 — Remediación de una vulnerabilidad | 10% | Santiago |
| `punto4-arquitectura/` | 4 — Seguridad en Arquitectura | 5% | Valentina |
| `punto5-herramienta-defensiva/` | 5 — Herramienta defensiva | 10% | David |
| `punto6-politicas-estandares/` | 6 — Gestión de políticas y estándares | 5% | Gerónimo |
| `punto7-devsecops/` | 7 — DevSecOps (SAST) | 10% | Gerónimo (si se recupera a tiempo) / David (si no, a partir del 23 de octubre) |

Los puntos 8 (Reporte, 20%) y 9 (Sustentación, 30%) no son carpetas de
código: el reporte es la presentación final que consolida la evidencia de
los puntos 1-7 (arma eso aparte, no en este repo), y la sustentación es en
vivo. Código de terceros clonado para trabajar (p. ej. el repo de Juice
Shop para Punto 3/7) nunca se sube al repo — ver `.gitignore` y el README
del punto correspondiente para el comando de clonado.

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
