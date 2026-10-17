# Evidencias P1-P2

**Responsable:** P1/P2

## Vulnerabilidad

SQL Injection en el login (`POST /rest/user/login`) — reto "Login Admin" de
Juice Shop. Payload: `' OR 1=1--` en el campo email, cualquier valor en
password. CVSS 3.1: **9.1 (Crítico)** —
`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. OWASP Top 10 A03 (Injection), CWE-89.

Causa raíz en el código: `routes/login.ts:34` del repo oficial de Juice Shop
(ver `../src-remediacion/`) — concatena `req.body.email` directamente en el
SQL en vez de usar parámetros vinculados.

## Qué va aquí

- `01-payload-en-formulario-login.png` — **Figura 1.** Payload en el campo
  email del login.
- `02-devtools-network-payload.png` — **Figura 2 (principal).** Pestaña
  **Network** de las DevTools de Chrome (`HTTP history`-equivalente a
  Burp), filtrada a la petición `login`, mostrando el payload crudo en el
  tab **Payload**: `{email: "' OR 1=1--", password: "cualquiercosa"}`.
  - `02-devtools-network-headers.png` — mismo request, tab **Headers**
    (método, URL, status 200 OK).
  - `02-devtools-network-response.png` — mismo request, tab **Response**
    (JSON con `"umail":"admin@juice-sh.op"` y el JWT).
  - `02-raw-request-response.txt` / `02-request-response-capturada.json` —
    la misma petición/respuesta en texto plano, con el JWT ya decodificado
    (`"role":"admin"`). Complementa las capturas de pantalla.
- `03-autenticado-como-admin.png` — **Figura 3.** Acceso al panel de
  administración (`/#/administration`) autenticado como `admin@juice-sh.op`,
  sin conocer la contraseña real.
- `exploit_sqli.js` — script (Playwright) que automatiza el login con el
  payload y captura las figuras 1 y 3 de forma reproducible.
- `capture_devtools_network.js` — script (CDP/Node, sin Playwright) que
  abre Chrome con las DevTools auto-adjuntas (`--auto-open-devtools-for-tabs`),
  filtra la petición `login` en el panel **Network** y captura las 3
  variantes de la Figura 2. Útil también como punto de partida para el
  **Punto 5 (Blue Team / Monitoreo)**: ya demuestra cómo se ve el ataque
  reflejado en una herramienta de monitoreo de red.

Ambos scripts requieren Juice Shop corriendo en `localhost:3000` (ver
`../evidencia/`).

## Reporte (4 slides)

El reporte completo, siguiendo el formato de la Clase 8, está armado como
Artifact (Slides). La página es privada por defecto — hay que compartirla
desde su menú Share para que el resto del equipo la vea. Estructura:

1. Qué es la vulnerabilidad, CVSS, alcance, afectados.
2. Pasos de explotación con las 3 figuras de evidencia.
3. Impacto + OWASP A03 + CWE-89.
4. Corrección recomendada (bridge hacia P3: parametrizar la consulta).
