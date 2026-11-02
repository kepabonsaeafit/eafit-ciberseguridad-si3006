# Punto 1 — Despliegue del aplicativo

**Responsable:** Kevin

## Decisión de despliegue

Se validó primero en Docker local (evidencia abajo) y luego se migró a una
**VM de Google Cloud Compute Engine** para tener la aplicación accesible
públicamente — necesario para que el resto del equipo (y el profesor)
puedan reproducir la explotación del Punto 2 sin depender de la máquina de
Kevin. Despliegue final:

- **VM:** `juice-shop-vm`, GCP Compute Engine, zona `us-central1-a`,
  `e2-small` (2 vCPU, 2 GB RAM), Debian 13 (trixie).
- **Contenedor:** mismo imagen que en local, `bkimminich/juice-shop`,
  mapeada al puerto 80 de la VM (`-p 80:3000`).
- **Firewall:** regla "Allow HTTP traffic" de GCP (puerto 80 abierto a
  internet) — necesaria para que el challenge sea accesible, pero implica
  que la vulnerabilidad del Punto 2 queda expuesta públicamente mientras la
  VM esté encendida. **Nota para Valentina (P4) y Santiago (P3):** esto es
  justo el tipo de decisión de arquitectura/exposición de red que le sirve
  de insumo a P4, y a P3 si deciden tratar el firewall como parte de la
  remediación (ver también `../punto2-explotacion/README.md`).
- **URL pública:** `http://34.56.167.155`

## Qué va aquí

- `terminal-evidencia-p1.txt` — salida de `docker --version`, `docker ps` y
  `curl -I http://localhost:3000` del despliegue **local** inicial.
- `juice-shop-browser.png` — captura de la tienda cargada en el navegador,
  despliegue **local** (Figura 1, versión inicial).
- `terminal-evidencia-p1-gcp.txt` — `docker ps` y `curl -I http://localhost`
  ejecutados por SSH dentro de la VM de GCP, confirmando el contenedor
  corriendo y el servidor respondiendo HTTP 200 en el despliegue real.
- `juice-shop-browser-gcp.png` — **Figura 1 (versión final).** Tienda
  cargada en `http://34.56.167.155`, ventana completa del navegador con la
  barra de direcciones visible.

## Cómo reproducirlo

**Local:**
```bash
docker pull bkimminich/juice-shop
docker run -d -p 3000:3000 --name juice-shop bkimminich/juice-shop
curl -I http://localhost:3000   # debe responder HTTP 200
```

**GCP Compute Engine:**
1. Crear proyecto y VM (`e2-small`, Debian, firewall "Allow HTTP traffic")
   desde la consola de GCP.
2. Por SSH (botón **SSH** de la consola, sin llaves que configurar):
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker.io
   sudo systemctl enable --now docker
   sudo docker run -d -p 80:3000 --name juice-shop --restart unless-stopped bkimminich/juice-shop
   ```
3. Abrir `http://<IP_EXTERNA_DE_LA_VM>` en el navegador.

El paso a paso de explotación (Punto 2, SQL injection en el login) y el
reporte de 4 slides van en `../punto2-explotacion/`.
