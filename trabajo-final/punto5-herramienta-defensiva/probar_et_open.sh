#!/usr/bin/env bash
# =============================================================================
# Punto 5 — ¿Detectan las reglas comunitarias el ataque del Punto 2?
#
# Corre Suricata en modo offline (-r) sobre el pcap del ataque usando SOLO el
# ruleset gratuito Emerging Threats Open (descargado con suricata-update),
# sin nuestras reglas locales. Sirve para justificar por qué hizo falta
# escribir suricata/local.rules.
#
# Uso:  ./probar_et_open.sh   (requiere haber corrido ./demo_p5.sh antes)
# Salida: evidencias/et-open-sobre-pcap.txt
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
OUT=evidencias/et-open-sobre-pcap.txt

docker rm -f p5-et >/dev/null 2>&1 || true
docker create --name p5-et --entrypoint sh jasonish/suricata:latest -c '
  suricata-update -q --no-test --no-reload >/dev/null 2>&1
  R=/var/lib/suricata/rules/suricata.rules
  mkdir -p /out
  suricata -r /tmp/p5.pcap -k none -l /out -S "$R" >/dev/null 2>&1
  echo "Ruleset: Emerging Threats Open (suricata-update), $(grep -c "^alert" $R) reglas activas"
  echo "Pcap analizado: evidencias/p5-ataque-sqli.pcap (tráfico normal + ataque SQLi del Punto 2)"
  echo
  echo "Alertas totales:                         $(wc -l < /out/fast.log)"
  echo "  de ellas \"TCPv4 invalid checksum\":     $(grep -c "invalid checksum" /out/fast.log || true)   (ruido: checksum offload de la red de Docker)"
  echo "  alertas relacionadas con SQLi/login:   $(grep -ciE "sql|inject|login|1=1" /out/fast.log || true)"
  echo
  echo "Alertas que NO son de checksum:"
  grep -v "invalid checksum" /out/fast.log || echo "  (ninguna)"
' >/dev/null
docker cp -q evidencias/p5-ataque-sqli.pcap p5-et:/tmp/p5.pcap
docker start -a p5-et 2>&1 | grep -v -i capabilit | tee "$OUT"
docker rm p5-et >/dev/null
