# Punto 5 — Herramienta defensiva

**Responsable:** David

## Qué pide el enunciado (Punto 5, 10%)

1. Demostrar con una herramienta de monitoreo sencilla (history de Burp o
   Wireshark) cómo se ve reflejado en la red el ataque del Punto 2.
2. Explicar qué herramienta de Blue Team se podría usar para monitorear y
   generar alertas ante un ataque como ese.

## Qué se hizo

- **Parte 1 — el ataque visto desde la red (Wireshark):** se grabó con
  `tcpdump` todo el tráfico del contenedor de Juice Shop mientras se mandaba
  tráfico normal y el ataque del Punto 2 (`' OR 1=1--` en el email del
  login). El `.pcap` se abrió en **Wireshark**. Con el filtro de la Figura 1
  se ven las 3 peticiones de login y sus respuestas: el login legítimo
  devuelve **401** y los dos con payload devuelven **200 + JWT de admin**.
- **Parte 2 — herramienta de Blue Team (Suricata IDS):** se puso **Suricata
  8.0.7** a escuchar la misma interfaz del contenedor, como si fuera un
  puerto SPAN o un TAP en la red, con 3 reglas propias
  (`suricata/local.rules`). Las alertas salieron **en vivo** en el mismo
  segundo del ataque, y el login legítimo no generó ninguna.
- **Hallazgo extra:** las **53.282 reglas comunitarias** de Emerging Threats
  Open **no detectaron** el SQLi (0 alertas relacionadas). Por eso hizo falta
  escribir reglas propias para el endpoint (`probar_et_open.sh`).

### Reglas Suricata (`suricata/local.rules`)

| sid | Qué detecta | Prioridad |
|---|---|---|
| 1000001 | `POST /rest/user/login` con tautología `' OR 1=1` (o `'a'='a'`) en el body | 2 — intento |
| 1000002 | Comilla seguida de comentario SQL (`'--`, `'#`, `'/*`) en el campo `email` | 2 — intento |
| 1000003 | Misma conexión marcada por 1000001/1000002 **y** el servidor respondió `200` con `"token":"eyJ…"` | **1 — SQLi exitoso** |

La 1000003 (con `flowbits`) es la que separa el ruido de lo urgente: dice
que el ataque **funcionó**, no solo que alguien lo intentó.

## Archivos

| Archivo | Qué es |
|---|---|
| `demo_p5.sh` | **Demo completa.** Levanta Juice Shop si no está, pega `tcpdump` y Suricata a la red del contenedor (`--net container:juice-shop`), manda el tráfico, muestra las alertas en vivo y copia toda la evidencia a `evidencias/`. |
| `generar_trafico.sh` | Tráfico normal (home, búsqueda, login fallido de `jim`) + el ataque `' OR 1=1--` + la variante `admin@juice-sh.op'--`. |
| `suricata/local.rules` | Las 3 reglas de detección. |
| `probar_et_open.sh` | Pasa el `.pcap` por el ruleset gratuito ET Open (sin nuestras reglas) para comparar. |
| `diagrama/arquitectura-deteccion.html` | Fuente del diagrama de la Figura 5. |
| `evidencias/p5-ataque-sqli.pcap` | Captura del tráfico. Se abre en Wireshark. |
| `evidencias/suricata-fast.log` | Alertas de Suricata, una por línea. |
| `evidencias/suricata-eve.json` / `suricata-alertas.json` | Log JSON completo de Suricata / solo las alertas (traen el body del atacante y la respuesta). |
| `evidencias/suricata-alertas-resumen.txt` | Resumen legible de las 4 alertas. |
| `evidencias/tshark-http-resumen.txt` / `tshark-follow-ataque.txt` | Lo mismo que muestra Wireshark, en texto (tshark). |
| `evidencias/et-open-sobre-pcap.txt` | Resultado de ET Open: 0 alertas de SQLi. |
| `evidencias/trafico-generado.txt` | Qué se mandó y qué respondió el servidor (401 / 200). |

### Figuras

- `evidencias/figura-p5-1-wireshark-payload-sqli.png`: **Figura 1.**
  Wireshark con el filtro de login. El login legítimo (frame 31) recibe
  `401`; el frame 41 lleva `String value: ' OR 1=1--` en el campo `email` y
  su respuesta (frame 43) es `200 OK`.
- `evidencias/figura-p5-2-wireshark-follow-http-stream.png`: **Figura 2.**
  *Follow HTTP Stream* del ataque. En rojo, la petición del atacante con el
  payload; en azul, la respuesta con el JWT y `"umail":"admin@juice-sh.op"`.
- `evidencias/figura-p5-3-suricata-alertas-en-vivo.png`: **Figura 3.**
  `fast.log` de Suricata con las 4 alertas (2 intentos y 2 exitosos) y la
  prueba de que el login legítimo no alertó (0 falsos positivos).
- `evidencias/figura-p5-4-suricata-resumen-alertas.png`: **Figura 4.**
  Resumen del `eve.json`: cada alerta con regla, IP:puerto y el body exacto
  que la disparó.
- `evidencias/figura-p5-5-arquitectura-deteccion.png`: **Figura 5.** Dónde
  se ubica cada pieza: atacante → Juice Shop, copia del tráfico → Suricata →
  SIEM → SOC.

Las figuras 1 a 4 salen de **la misma corrida**: el puerto origen `26141`
del ataque en Wireshark es el mismo que aparece en la alerta de Suricata.

## Cómo reproducirlo

Requisitos: Docker. Para el análisis en texto, también Wireshark/tshark
(`brew install --cask wireshark`).

```bash
cd trabajo-final/punto5-herramienta-defensiva
./demo_p5.sh          # ~30 s: sensores + tráfico + alertas + evidencia
./probar_et_open.sh   # opcional: comparación contra ET Open

# Ver el ataque en Wireshark con el mismo filtro de la Figura 1:
open -a Wireshark evidencias/p5-ataque-sqli.pcap
#   filtro: http.request.uri contains "/rest/user/login" || http.response.code == 401 || json.key == "authentication"
#   clic derecho sobre la petición del ataque → Follow → HTTP Stream (Figura 2)
```

Los scripts no usan *bind mounts*: los archivos entran y salen de los
contenedores con `docker cp`. Así funcionan aunque Docker Desktop no comparta
la carpeta del repo.

## Notas para la sustentación

- **¿Por qué Suricata y no solo Wireshark?** Wireshark sirve para mirar e
  investigar después, pero no alerta. Suricata inspecciona el mismo tráfico
  en tiempo real, entiende HTTP (método, URI, body, código de respuesta) y
  escribe `eve.json`, que cualquier SIEM (Wazuh, Elastic, Splunk) ingiere
  directamente.
- **¿Por qué no un WAF?** El WAF bloquea, y ese es el control perimetral del
  Punto 4. El IDS es el control de **detección**: no rompe la aplicación si
  una regla da falso positivo, y además ve si el ataque tuvo éxito (regla
  1000003), cosa que un WAF que solo mira la petición no sabe.
- **¿Qué tan rápido se detecta?** En la demo, la alerta queda escrita en el
  mismo segundo del ataque: en `fast.log` la alerta de intento y la de éxito
  quedan a ~1 ms una de otra. Lo que tarde en llegar al analista depende del
  SIEM y de la notificación (segundos).
- **Limitaciones:** si la app corre con HTTPS, el IDS necesita ver el tráfico
  ya descifrado (detrás del balanceador o del proxy que termina TLS). Un
  atacante puede ofuscar el payload (por ejemplo `'` en vez de `'` en
  el JSON, o `OR 2>1`), y una firma no cubre todas las variantes. Por eso
  esto complementa el fix de código del Punto 3, no lo reemplaza.
