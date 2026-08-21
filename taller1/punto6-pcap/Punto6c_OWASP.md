# Punto 6c — Identificación y explicación de la vulnerabilidad (OWASP Top 10)

## Vulnerabilidad identificada

**A04:2025 – Cryptographic Failures** (Fallos Criptográficos), categoría del OWASP Top 10 2025.

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

Esto encaja directamente en **A04:2025 – Cryptographic Failures**, ya que la causa raíz no es una
falla de autenticación o autorización, sino la **ausencia de cifrado en tránsito** para datos que
deberían protegerse (credenciales, tokens, información confidencial, etc.). El Top 10 de OWASP
describe este riesgo como la transmisión de datos sensibles en claro por protocolos como HTTP,
FTP o SMTP, lo cual permite ataques de intercepción (*man-in-the-middle*, *network sniffing*).

> Nota: en el `.pcap` analizado (`FollowTheLeader.pcap`) el único dato sensible expuesto en claro
> fue la flag del reto (`ctfa{terrific_traffic}`), no credenciales de usuario/contraseña — la
> captura completa consta de 10 paquetes: handshake TCP, un `GET /` y la respuesta HTTP con la
> flag. El enunciado del punto pide identificar credenciales expuestas; en este `.pcap` no viajó
> ningún usuario/contraseña, por lo que el hallazgo reportable es la flag en texto plano como
> evidencia del mismo problema de fondo (transmisión sin cifrar).

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

## Referencias

- OWASP Foundation. *OWASP Top 10 — Cryptographic Failures.*
  https://owasp.org/Top10/ (consultado el 21 de agosto de 2026).
- Wireshark Foundation. *Wireshark User's Guide — Following Protocol Streams.*
  https://www.wireshark.org/docs/wsug_html_chunked/ChAdvFollowStreamSection.html (consultado el 21 de agosto de 2026).
- CTF Academy. *Network Forensics — Challenge 1.*
  https://ctfacademy.github.io/network/challenge1/index.htm (consultado el 21 de agosto de 2026).

## Qué va en la diapositiva

- **Flag:** `ctfa{terrific_traffic}` — obtenida del cuerpo de una respuesta HTTP.
- **Cómo:** filtro `http` en Wireshark → *Follow HTTP Stream* sobre la conversación
  `10.0.2.15 → 10.0.2.5:80` (captura de 10 paquetes).
- **Vulnerabilidad:** Cryptographic Failures (OWASP Top 10) — datos sensibles en tránsito sin cifrar.
- **Causa raíz:** HTTP en vez de HTTPS/TLS; cualquiera que esnife la red lee todo sin descifrar nada.
- **Impacto:** *sniffing* / MITM → robo de credenciales o secuestro de sesión si en vez de la flag
  viajaran credenciales reales.
- **Mitigación:** HTTPS obligatorio + HSTS, y reemplazar protocolos en claro (FTP→SFTP, Telnet→SSH).
- *(Captura de pantalla del Follow HTTP Stream con la flag resaltada.)*
