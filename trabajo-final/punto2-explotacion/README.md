# Punto 2 — Explotación de una vulnerabilidad

**Responsable:** Kevin

## Vulnerabilidad

SQL Injection en el login (`POST /rest/user/login`) — reto "Login Admin" de
Juice Shop. Payload: `' OR 1=1--` en el campo email, cualquier valor en
password. CVSS 3.1: **9.1 (Crítico)** —
`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. OWASP Top 10:2025 A05 (Injection), CWE-89.

Explotado contra el despliegue real en **GCP Compute Engine**
(`http://34.56.167.155`, ver `../punto1-despliegue/`), no contra localhost.

Causa raíz en el código: `routes/login.ts:34` del repo oficial de Juice Shop
(ver `../punto3-remediacion/`) — concatena `req.body.email` directamente en
el SQL en vez de usar parámetros vinculados. Ese fix es scope del **Punto 3
(Santiago)** — aquí solo queda documentada la causa raíz para que la
remediación no empiece de cero.

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
  sin conocer la contraseña real. Captura de ventana completa: se ve la
  barra de direcciones con `34.56.167.155`.
- `00-challenge-login-admin-resuelto.png` — evidencia adicional: banner
  nativo de Juice Shop ("You successfully solved a challenge: Login
  Admin") al completar el bypass, confirmación independiente del impacto.
- `exploit_sqli.js` — script (Playwright) que automatiza el login con el
  payload y captura las figuras 1 y 3 de forma reproducible.
- `capture_devtools_network.js` — script (CDP/Node, sin Playwright) que
  abre Chrome con las DevTools auto-adjuntas (`--auto-open-devtools-for-tabs`),
  filtra la petición `login` en el panel **Network** y captura las 3
  variantes de la Figura 2. Útil también como punto de partida para el
  **Punto 5 (Herramienta defensiva)**: ya demuestra cómo se ve el ataque
  reflejado en una herramienta de monitoreo de red.
- `P2_Reporte_Vulnerabilidad.md` — reporte estructurado de la vulnerabilidad
  (ver sección siguiente).

Ambos scripts automatizan el ataque contra `localhost:3000` y fueron el
método usado para la primera versión de esta evidencia (despliegue local).
Las figuras actuales (`00-*` a `03-*`) corresponden a una repetición
**manual** del mismo ataque contra el despliegue real en GCP
(`34.56.167.155`, ver `../punto1-despliegue/`), hecha así porque el entorno
de automatización no tiene salida de red hacia la IP pública de la VM. El
payload, los pasos y el resultado (JWT con `role: admin`) son idénticos en
ambos casos — solo cambia el host.

## Reporte (4 slides)

`P2_Reporte_Vulnerabilidad.md` tiene el contenido estructurado de las 4
slides, siguiendo el formato de la Clase 8. El mismo contenido también está
armado como Artifact (Slides) — la página es privada por defecto, hay que
compartirla desde su menú Share para que el resto del equipo la vea.
Estructura:

1. Qué es la vulnerabilidad, CVSS, alcance, afectados.
2. Pasos de explotación con las 3 figuras de evidencia.
3. Impacto + OWASP A05:2025 + CWE-89.
4. Corrección recomendada (bridge hacia Punto 3: parametrizar la consulta).
