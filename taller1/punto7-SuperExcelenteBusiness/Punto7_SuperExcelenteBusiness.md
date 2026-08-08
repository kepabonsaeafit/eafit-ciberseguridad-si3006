# Punto 7 — SuperExcelenteBusiness

**Contexto:** Red `10.10.1.0/24`, host `10.10.1.99` (gestor de BD de empleados), puerto 23
(Telnet) abierto, puerto 21 (FTP) abierto, puerto 5000 (API de redirección de servicios para
manejo de archivos Excel). IPs dinámicas vía DHCP. Objetivo: primer análisis de scope antes de
firmar contrato de pruebas ofensivas.

## a. Recomendaciones de seguridad para el segmento de red

- **Eliminar Telnet (puerto 23):** transmite credenciales y comandos en texto plano.
  Reemplazar por **SSH** para cualquier administración remota.
- **Revisar necesidad real de FTP (puerto 21):** si se requiere transferencia de archivos,
  migrar a **SFTP/FTPS** (cifrado). Si no es indispensable, cerrarlo.
- **Segmentar la red (VLANs):** separar el segmento de empleados del segmento donde vive el
  gestor de BD (`10.10.1.99`) y la API. Hoy están en el mismo `/24`, lo que facilita movimiento
  lateral si un endpoint de empleado es comprometido.
- **Endurecer la API del puerto 5000:** validar que tenga autenticación/autorización, control de
  entrada (evitar *path traversal* o *SSRF* en la lógica de "redirección de servicios" y manejo
  de archivos Excel), y que no esté expuesta más allá de lo necesario.
- **Controlar el DHCP:** implementar reservas o **NAC (Network Access Control)** y logging de
  asignaciones, ya que IPs dinámicas dificultan la trazabilidad de quién hizo qué en la red.
- **Firewall interno / ACLs** entre segmentos, restringiendo qué IPs pueden llegar al host de BD.
- **Cifrado en tránsito** para todo el tráfico hacia el gestor de BD (evitar protocolos en claro
  entre la API y la BD).

## b. Información extra a levantar en el reconocimiento (para el pentest ofensivo)

- **Escaneo completo del segmento** (`nmap -sV -p- 10.10.1.0/24`) para mapear todos los hosts
  activos y puertos abiertos adicionales, no solo los tres ya identificados.
- **Banner grabbing** en los puertos 21, 23 y 5000 para identificar versiones de software
  (vulnerabilidades conocidas / CVEs asociados).
- **Enumeración FTP:** verificar si permite acceso anónimo, listar directorios, permisos de
  escritura.
- **Fingerprinting de la API (puerto 5000):** identificar framework/tecnología, endpoints
  disponibles, si expone documentación (Swagger/OpenAPI), y si valida rutas de archivos de forma
  segura (riesgo de *path traversal* al leer/escribir Excel).
- **Identificar el motor de base de datos** detrás de `10.10.1.99` y su puerto asociado
  (ej. 1433 SQL Server, 3306 MySQL, 5432 PostgreSQL) — no reportado aún en el escaneo inicial.
- **Documentar el comportamiento del DHCP** como vector adicional: en un segmento plano y con
  asignación dinámica, ataques tipo **rogue DHCP** o **ARP spoofing** son viables para
  interceptar tráfico de empleados.
- **Relación entre los tres hallazgos:** confirmar si la API (5000) tiene conectividad directa a
  la BD (.99), lo que ampliaría el impacto de una explotación exitosa de la API.

Esta información adicional es la que justifica ante el cliente por qué vale la pena el contrato
ofensivo: no solo se identificaron puertos abiertos, sino una hipótesis de cadena de ataque
(FTP/Telnet en claro → movimiento lateral → API sin validar → acceso a BD de empleados) que debe
confirmarse con pruebas autorizadas.
