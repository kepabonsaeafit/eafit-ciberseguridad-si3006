# P2 — Reporte de Vulnerabilidad: SQL Injection en Login (OWASP Juice Shop)

**Responsable:** P1/P2
**Rama:** `trabajo-final/p1-p2-juice-shop-sqli`
**Formato:** Clase 8, slide 14 (Risk/CVSS, Finding, Affected devices, Risk scenario, Impact, Likelihood, MITRE/CWE, Corrective actions)

---

## Slide 1 — Finding

**Finding:** SQL Injection en el endpoint de autenticación permite bypass completo de login sin credenciales válidas.

**Scope:** `POST /rest/user/login` (formulario de login, reto "Login Admin" de Juice Shop)

**Affected devices:** instancia de Juice Shop desplegada en Docker local (`juice-shop:3000`); aplica a cualquier despliegue que use el mismo código fuente (`routes/login.ts`).

**CVSS v3.1:** **9.1 (Crítico)**
Vector: `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`

| Métrica | Valor | Significado |
|---|---|---|
| AV | N (Network) | explotable remotamente |
| AC | L (Low) | sin condiciones especiales |
| PR | N (None) | sin privilegios previos |
| UI | N (None) | sin interacción de la víctima |
| S | U (Unchanged) | — |
| C / I | H / H (High) | confidencialidad e integridad totalmente comprometidas |
| A | N (None) | no afecta disponibilidad |

**Risk scenario:** un atacante no autenticado, sin herramientas especializadas, envía una única petición HTTP con el payload `' OR 1=1--` en el campo email. La consulta SQL generada por el servidor evalúa la condición como siempre verdadera, autenticando al atacante como el primer usuario de la tabla `Users` — en este caso `admin@juice-sh.op` — sin conocer la contraseña real.

---

## Slide 2 — Pasos de reproducción

1. Navegar a `http://localhost:3000/#/login`.
2. En el campo **email**, ingresar: `' OR 1=1--`
3. En el campo **password**, ingresar cualquier valor (no se valida).
4. Enviar el formulario / interceptar la petición `POST /rest/user/login`.
5. La respuesta HTTP 200 incluye un JWT cuyo payload decodificado contiene `"role":"admin"` y `"email":"admin@juice-sh.op"`.
6. Verificar el acceso navegando a `/#/administration` (panel exclusivo de administrador).

**Evidencia (figuras) — archivos fuente en `evidencias-p1-p2/`:**

- **Figura 1.** Payload en el campo email del formulario de login.
  `[ESPACIO PARA IMAGEN]` → `evidencias-p1-p2/01-payload-en-formulario-login.png`
- **Figura 2.** Petición y respuesta HTTP interceptadas, con el JWT decodificado mostrando `role: admin`.
  `[ESPACIO PARA IMAGEN/CÓDIGO]` → `evidencias-p1-p2/02-raw-request-response.txt` (o `02-request-response-capturada.json`)
- **Figura 3.** Acceso al panel de administración autenticado como `admin@juice-sh.op`, sin conocer la contraseña real.
  `[ESPACIO PARA IMAGEN]` → `evidencias-p1-p2/03-autenticado-como-admin.png`

---

## Slide 3 — Impacto y clasificación

**Impact:** confidencialidad e integridad comprometidas por completo. Un atacante obtiene control total de la cuenta administradora: acceso a todos los usuarios registrados, pedidos, feedback de clientes, y capacidad de modificar o eliminar esos datos.

**Likelihood:** alta — explotación trivial, un único payload, sin autenticación previa, sin interacción de la víctima, sin herramientas especializadas (basta un navegador o `curl`).

**CWE:** CWE-89 — Improper Neutralization of Special Elements used in an SQL Command ('SQL Injection')

**OWASP Top 10:** A03 — Injection

**MITRE ATT&CK:** T1190 — Exploit Public-Facing Application (el atacante explota una aplicación expuesta públicamente para obtener acceso inicial sin credenciales)

---

## Slide 4 — Remediación

**Causa raíz:** `routes/login.ts:34` (repo oficial de Juice Shop, clonado en `src-remediacion/juice-shop/`) construye la consulta SQL concatenando `req.body.email` directamente dentro del string, sin sanitizar ni parametrizar la entrada del usuario.

**P3 — Corrección de código (consultas parametrizadas en Sequelize):**

```typescript
// Vulnerable — routes/login.ts:34
models.sequelize.query(
  `SELECT * FROM Users WHERE email = '${req.body.email}' AND password = '${hash}' AND deletedAt IS NULL`,
  { model: UserModel, plain: true }
)

// Corregido — consulta parametrizada (bind)
models.sequelize.query(
  `SELECT * FROM Users WHERE email = $1 AND password = $2 AND deletedAt IS NULL`,
  { bind: [req.body.email, hash], model: UserModel, plain: true }
)
```

**P4 — Control compensatorio (WAF):** desplegar un Web Application Firewall (p. ej. reglas OWASP CRS en ModSecurity, o AWS WAF) delante de `/rest/user/login` para detectar y bloquear patrones de inyección SQL (`OR 1=1`, comillas simples sin escapar, comentarios SQL `--`) como defensa en profundidad mientras se despliega el fix de código.

**P6 — Mapeo normativo:**
- **ISO/IEC 27001:2022 — A.8.28** (Secure coding): exige aplicar prácticas de codificación segura, específicamente el uso de consultas parametrizadas en vez de concatenación de entrada de usuario en comandos SQL.
- **OWASP ASVS 5.3.4**: la aplicación debe usar consultas parametrizadas, ORMs seguros o escapado apropiado específico del motor de base de datos para prevenir inyección en toda interacción con la base de datos.

**P7 — SAST:** el patrón vulnerable (concatenación de `req.body.*` dentro de un template literal pasado a `sequelize.query`) es detectable automáticamente por herramientas de análisis estático (Semgrep, CodeQL, SonarQube) siguiendo el flujo de datos no confiables (`req.body`) hasta un sumidero de ejecución SQL. Correr el SAST sobre `src-remediacion/juice-shop/routes/login.ts` debe marcar la línea 34 como hallazgo de SQL Injection.
