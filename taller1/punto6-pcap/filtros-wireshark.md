# Punto 6 — Filtros de Wireshark usados (en orden)

Archivo: `FollowTheLeader.pcap` (10 paquetes en total).

| # | Filtro / acción | Qué mostró |
|---|-----------------|------------|
| 1 | *Statistics → Protocol Hierarchy* (sin filtro) | Captura pequeña: solo TCP/IP con una capa HTTP y `data-text-lines`. Confirma que hay tráfico web en claro y que no hay TLS. |
| 2 | `tcp` | Los 10 paquetes: handshake (SYN/SYN-ACK/ACK), la petición, la respuesta y el cierre FIN entre `10.0.2.15` (cliente) y `10.0.2.5` (servidor, puerto 80). |
| 3 | `http` | Aísla los 2 paquetes relevantes: `GET / HTTP/1.1` (frame 4) y `HTTP/1.0 200 OK (text/html)` (frame 8). |
| 4 | `http.request` / `http.response` | Separa petición de respuesta para revisar cabeceras (`Host`, `User-Agent`, `Content-Type`) sin ruido de ACKs. |
| 5 | Clic derecho sobre frame 8 → *Follow → HTTP Stream* | Muestra la conversación completa en texto plano y revela la flag en el cuerpo de la respuesta: `ctfa{terrific_traffic}`. |
| 6 | `frame contains "ctfa"` | Verificación final: confirma que la flag viaja sin cifrar dentro del payload HTTP. |

Equivalente por línea de comandos (usado para verificar):

```bash
tshark -r FollowTheLeader.pcap                       # listado completo
tshark -r FollowTheLeader.pcap -Y http               # solo HTTP
tshark -r FollowTheLeader.pcap -Y 'frame contains "ctfa"' -x   # payload con la flag
```

## Referencias

- Wireshark Foundation. *Wireshark User's Guide — Building Display Filter Expressions.*
  https://www.wireshark.org/docs/wsug_html_chunked/ChWorkBuildDisplayFilterSection.html (consultado el 21 de agosto de 2026).
- CTF Academy. *Network Forensics — Challenge 1.*
  https://ctfacademy.github.io/network/challenge1/index.htm (consultado el 21 de agosto de 2026).
