# Evidencia — Despliegue de Juice Shop (P1)

**Responsable:** P1/P2

## Qué va aquí

- `terminal-evidencia-p1.txt` — salida de `docker --version`, `docker ps` y
  `curl -I http://localhost:3000` confirmando el contenedor corriendo y el
  servidor respondiendo HTTP 200.
- `juice-shop-browser.png` — captura de la tienda cargada en el navegador
  (Figura 1).

## Cómo reproducirlo

```bash
docker pull bkimminich/juice-shop
docker run -d -p 3000:3000 --name juice-shop bkimminich/juice-shop
curl -I http://localhost:3000   # debe responder HTTP 200
```

Luego abrir `http://localhost:3000` en el navegador.

El paso a paso de explotación (P2, SQL injection en el login) y el reporte de
4 slides van en `evidencias-p1-p2/` y `reporte-slides/`.
