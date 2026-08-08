# Punto 6c — Identificación y explicación de la vulnerabilidad (OWASP Top 10)

## Vulnerabilidad identificada

**A02:2021 – Cryptographic Failures** (Fallos Criptográficos), categoría del OWASP Top 10 2021.

## Explicación

Al analizar el archivo `FollowTheLeader.pcap` con Wireshark, se identificó una conversación HTTP
entre el cliente `10.0.2.15` y el servidor `10.0.2.5`. El cliente realiza una petición `GET /` y el
servidor responde en **HTTP sin cifrar (texto plano)**, exponiendo directamente en el cuerpo de la
respuesta información sensible — en este caso la flag del reto:

```
ctfa{terrific_traffic}
```

Como la comunicación se realiza por HTTP en lugar de **HTTPS/TLS**, cualquier atacante con
capacidad de capturar tráfico en la red (sniffing, por ejemplo mediante ARP spoofing en una red
local o acceso a un punto intermedio de la comunicación) puede leer el contenido completo de la
petición y la respuesta sin ningún esfuerzo de descifrado, tal como se demostró al aplicar el
filtro `http` y usar la función *Follow HTTP Stream* en Wireshark.

Esto encaja directamente en **A02:2021 – Cryptographic Failures**, ya que la causa raíz no es una
falla de autenticación o autorización, sino la **ausencia de cifrado en tránsito** para datos que
deberían protegerse (credenciales, tokens, información confidencial, etc.). El Top 10 de OWASP
describe este riesgo como la transmisión de datos sensibles en claro por protocolos como HTTP,
FTP o SMTP, lo cual permite ataques de intercepción (*man-in-the-middle*, *network sniffing*).

## Impacto

- Exposición de información confidencial (credenciales, datos de sesión, datos de negocio) a
  cualquiera con acceso al segmento de red o a un punto intermedio de la ruta de tráfico.
- Facilita ataques de *session hijacking* o *credential theft* si en lugar de una flag viajaran
  credenciales reales de usuario.

## Recomendación de mitigación

- Forzar el uso de **HTTPS/TLS** en todos los servicios web (certificados válidos, redirección
  automática de HTTP a HTTPS, cabecera `HSTS`).
- Cifrar cualquier protocolo de transferencia de archivos o administración remota (usar SFTP/FTPS
  en vez de FTP, SSH en vez de Telnet).
- Realizar auditorías periódicas de tráfico de red para detectar servicios que aún transmiten
  información sensible sin cifrar.
