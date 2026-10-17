# Punto 7 — DevSecOps

**Responsable:** Gerónimo

## Qué va aquí

Según el enunciado (Punto 7, 10%): implementar (puede ser local) una
herramienta de SAST open source o con versión gratuita, y usarla para
identificar si la vulnerabilidad explotada en el Punto 2 (SQL injection en
`routes/login.ts:34`) es detectable.

Listado de referencia de herramientas:
[OWASP Source Code Analysis Tools](https://owasp.org/www-community/Source_Code_Analysis_Tools).

## Punto de partida

El código fuente a analizar se clona igual que en el Punto 3 — mismo
comando, mismo .gitignore (no se sube el código de terceros al repo):

```bash
git clone --depth 1 https://github.com/juice-shop/juice-shop.git trabajo-final/punto3-remediacion/juice-shop
```

(Si prefieres tu propio clon en vez de compartir el de Santiago, usa esa
misma ruta para que el SAST corra sobre el código real, línea 34 de
`routes/login.ts`, y no sobre una copia desactualizada.)

Deja aquí: la configuración de la herramienta SAST que uses, el reporte/
salida que genera marcando (o no) el hallazgo, y una captura de evidencia.
