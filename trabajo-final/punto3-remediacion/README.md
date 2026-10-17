# Punto 3 — Remediación de una vulnerabilidad

**Responsable:** Santiago

## Estado actual

**Vacío — solo este README.** No se ha escrito ningún código de remediación
todavía. Lo único que hay es el comando para clonar el repo oficial de Juice
Shop, documentado abajo, para que arranques de una sin perder tiempo
configurando el entorno.

## Qué va aquí

El código de la corrección (y la demo en vivo de que la vulnerabilidad del
Punto 2 quedó solucionada).

La causa raíz ya está localizada — no hace falta que la busques de cero:

- **Archivo/línea:** `routes/login.ts:34` del repo oficial de Juice Shop.
- **Vulnerabilidad:** SQL Injection en el login (`POST /rest/user/login`,
  payload `' OR 1=1--`). Detalle completo en
  `../punto2-explotacion/P2_Reporte_Vulnerabilidad.md`.
- **Fix propuesto** (consulta parametrizada con `bind`, ya verificado que
  compila): ver la Slide 4 de ese mismo reporte. El repo oficial de Juice
  Shop ya trae la solución de referencia en
  `data/static/codefixes/loginAdminChallenge_4_correct.ts`.

## Cómo clonar el código fuente

El repositorio oficial de OWASP Juice Shop, clonado localmente para poder
corregir el código y correr el SAST (Punto 7):

```bash
git clone --depth 1 https://github.com/juice-shop/juice-shop.git trabajo-final/punto3-remediacion/juice-shop
```

El código de terceros **no se sube a este repo** (pesa ~54 MB y tiene su
propio historial de git) — está ignorado vía `.gitignore`. Cada integrante
que necesite trabajar sobre el código (Santiago en Punto 3, Gerónimo en
Punto 7) lo clona localmente con ese comando.
