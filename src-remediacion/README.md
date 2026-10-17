# src-remediacion — Código fuente para P3 (remediación) y P7 (SAST)

## Qué va aquí

El repositorio oficial de OWASP Juice Shop, clonado localmente para poder:

- Localizar y corregir en código la vulnerabilidad explotada en P2 (SQL injection
  en el login) — insumo para P3.
- Correr el análisis SAST sobre el código fuente — insumo para P7.

El código de terceros **no se sube a este repo** (pesa ~54 MB y tiene su propio
historial de git). Está ignorado vía `.gitignore`.

## Cómo clonarlo

```bash
git clone --depth 1 https://github.com/juice-shop/juice-shop.git src-remediacion/juice-shop
```

Cada integrante que necesite trabajar sobre el código (Santiago en P3, Gerónimo
en P7) lo clona localmente con ese comando.
