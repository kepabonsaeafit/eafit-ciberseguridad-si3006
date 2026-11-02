#!/usr/bin/env bash
# =============================================================================
# Punto 5 — Herramienta defensiva: demo completa y reproducible.
#
# Qué hace:
#   1. Se asegura de que Juice Shop esté corriendo (contenedor "juice-shop",
#      el mismo del Punto 1).
#   2. Pega dos "sensores" a la interfaz de red del contenedor de Juice Shop
#      (--net container:juice-shop, como un puerto SPAN/TAP en un switch):
#        - p5-tcpdump  : graba todo el tráfico del puerto 3000 en un .pcap
#                        (lo que después se abre en Wireshark).
#        - p5-suricata : IDS Suricata en vivo con las reglas de
#                        suricata/local.rules (detección del SQLi del Punto 2).
#   3. Lanza generar_trafico.sh (tráfico normal + el ataque).
#   4. Detiene los sensores y copia la evidencia a ./evidencias/:
#        p5-ataque-sqli.pcap, suricata-fast.log, suricata-eve.json,
#        suricata-alertas.json, trafico-generado.txt, tshark-*.txt
#
# Requisitos: Docker y, para los análisis tshark, Wireshark/tshark en el host
# (brew install --cask wireshark). No usa bind mounts: todo entra y sale con
# `docker cp`, así funciona aunque Docker Desktop no comparta la carpeta.
#
# Uso:  ./demo_p5.sh
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

APP=juice-shop
EVID=evidencias
SURI_IMG=jasonish/suricata:latest
DUMP_IMG=nicolaka/netshoot:latest
mkdir -p "$EVID"

log() { printf '\n\033[1;36m[P5] %s\033[0m\n' "$*"; }

# --- 1. Juice Shop ------------------------------------------------------------
if ! docker ps --format '{{.Names}}' | grep -qx "$APP"; then
  log "Levantando Juice Shop (Punto 1)…"
  docker rm -f "$APP" >/dev/null 2>&1 || true
  docker run -d -p 3000:3000 --name "$APP" bkimminich/juice-shop >/dev/null
fi
until curl -s -o /dev/null http://localhost:3000; do sleep 1; done
log "Juice Shop arriba en http://localhost:3000"

# --- 2. Sensores --------------------------------------------------------------
docker rm -f p5-tcpdump p5-suricata >/dev/null 2>&1 || true

log "Sensor 1: tcpdump grabando eth0 de ${APP} (tcp port 3000)…"
docker run -d --name p5-tcpdump --net "container:$APP" \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  "$DUMP_IMG" tcpdump -i eth0 -s 0 -U -w /tmp/p5.pcap 'tcp port 3000' >/dev/null

log "Sensor 2: Suricata IDS en vivo sobre eth0 de ${APP}…"
# Se habilita en el eve.json el body HTTP y el payload legibles, para que la
# alerta traiga el payload del atacante como evidencia.
docker create --name p5-suricata --net "container:$APP" \
  --cap-add NET_ADMIN --cap-add NET_RAW --cap-add SYS_NICE \
  --entrypoint sh "$SURI_IMG" -c '
    sed -i \
      -e "s/# payload-printable: yes/payload-printable: yes/" \
      -e "s/# http-body-printable: yes/http-body-printable: yes/" \
      /etc/suricata/suricata.yaml
    mkdir -p /var/log/suricata
    exec suricata -i eth0 -k none -S /etc/suricata/local.rules -l /var/log/suricata
  ' >/dev/null
docker cp -q suricata/local.rules p5-suricata:/etc/suricata/local.rules
docker start p5-suricata >/dev/null

# Espera a que Suricata termine de cargar reglas y empiece a capturar.
for _ in $(seq 1 60); do
  docker logs p5-suricata 2>&1 | grep -qi "engine started\|threads created" && break
  sleep 1
done
docker logs p5-suricata 2>&1 | grep -iE "signatures processed|rules successfully loaded|engine started|threads created" || true
sleep 2

# --- 3. Tráfico normal + ataque ----------------------------------------------
log "Generando tráfico normal + ataque SQLi del Punto 2…"
./generar_trafico.sh "${EVID}/trafico-generado.txt"
sleep 4   # deja que Suricata procese las últimas respuestas

# --- 4. Alertas en vivo -------------------------------------------------------
log "Alertas de Suricata (fast.log):"
docker exec p5-suricata cat /var/log/suricata/fast.log || true

# --- 5. Detener sensores y sacar evidencia -----------------------------------
log "Deteniendo sensores y copiando evidencia a ./${EVID}/…"
docker stop -t 10 p5-tcpdump p5-suricata >/dev/null
docker cp -q p5-tcpdump:/tmp/p5.pcap                      "${EVID}/p5-ataque-sqli.pcap"
docker cp -q p5-suricata:/var/log/suricata/fast.log       "${EVID}/suricata-fast.log"
docker cp -q p5-suricata:/var/log/suricata/eve.json       "${EVID}/suricata-eve.json"
docker cp -q p5-suricata:/var/log/suricata/suricata.log   "${EVID}/suricata-motor.log" 2>/dev/null || true
docker rm p5-tcpdump p5-suricata >/dev/null

# Solo los eventos de alerta, uno por línea y con formato legible.
if command -v python3 >/dev/null; then
  python3 - "${EVID}/suricata-eve.json" > "${EVID}/suricata-alertas.json" <<'PY'
import json, sys
alerts = [json.loads(l) for l in open(sys.argv[1]) if '"event_type":"alert"' in l]
print(json.dumps(alerts, indent=2, ensure_ascii=False))
PY
  log "Resumen de alertas (eve.json): qué vio el IDS y por qué"
  python3 - "${EVID}/suricata-alertas.json" <<'PY' | tee "${EVID}/suricata-alertas-resumen.txt"
import json, sys
alerts = json.load(open(sys.argv[1]))
print(f"Total alertas: {len(alerts)}\n")
for a in alerts:
    al, h = a["alert"], a.get("http", {})
    sev = "CRITICA" if al["severity"] == 1 else "ALTA"
    print(f"[{sev}] sid {al['signature_id']}  {a['timestamp'][11:23]} UTC  "
          f"{a['src_ip']}:{a['src_port']} -> {a['dest_ip']}:{a['dest_port']}")
    print(f"   regla : {al['signature']}")
    print(f"   http  : {h.get('http_method')} {h.get('url')}  -> status {h.get('status')}")
    print(f"   body  : {h.get('http_request_body_printable', '')}")
    print()
PY
fi

# --- 6. Análisis del pcap con tshark (Wireshark en CLI) ----------------------
if command -v tshark >/dev/null; then
  PCAP="${EVID}/p5-ataque-sqli.pcap"
  log "Análisis tshark del pcap…"
  # tshark entrega el body (http.file_data) en hex: se decodifica a texto.
  {
    echo "# Peticiones HTTP y respuestas en la captura (filtro de Wireshark: http)"
    echo "# tshark -r $PCAP -Y http -T fields -e frame.number -e tcp.stream -e ip.src -e http.request.method -e http.request.uri -e http.response.code -e http.file_data"
    tshark -r "$PCAP" -Y 'http' -T fields -E separator='	' \
      -e frame.number -e tcp.stream -e ip.src -e http.request.method \
      -e http.request.uri -e http.response.code -e http.file_data 2>/dev/null \
    | python3 -c '
import sys
print("%5s  %6s  %-14s %-6s %-32s %-6s %s" % ("frame", "stream", "origen", "método", "uri", "código", "body"))
for line in sys.stdin:
    f = line.rstrip("\n").split("\t")
    f += [""] * (7 - len(f))
    try:
        body = bytes.fromhex(f[6].replace(":", "")).decode("utf-8", "replace")
    except ValueError:
        body = f[6]
    body = " ".join(body.split())[:90]
    print(f"{f[0]:>5}  {f[1]:>6}  {f[2]:<14} {f[3]:<6} {f[4][:32]:<32} {f[5]:<6} {body}")
'
  } > "${EVID}/tshark-http-resumen.txt"

  # Stream TCP de la PRIMERA petición de login cuyo body trae la comilla
  # del payload  ' OR 1=1--  (ese es el ataque del Punto 2).
  STREAM=$(tshark -r "$PCAP" -Y 'http.request.uri contains "/rest/user/login" && http.file_data contains "OR 1=1"' \
            -T fields -e tcp.stream 2>/dev/null | head -1)
  {
    echo "# Filtro de Wireshark que aísla el ataque:"
    echo "#   http.request.method == \"POST\" && http.request.uri contains \"/rest/user/login\" && http.file_data contains \"OR 1=1\""
    echo "# Follow HTTP Stream del tcp.stream $STREAM"
    tshark -r "$PCAP" -q -z "follow,http,ascii,$STREAM" 2>/dev/null
  } > "${EVID}/tshark-follow-ataque.txt"
fi

log "Listo. Evidencia en ./${EVID}/"
ls -la "$EVID"
