# Punto 5 — Herramienta defensiva

**Responsable:** _(sin asignar)_

## Qué va aquí

Según el enunciado (Punto 5, 10%):

1. Demostrar, con una herramienta de monitoreo sencilla (history de Burp,
   Wireshark, o el panel Network de las DevTools), cómo se ve reflejado en
   la red el ataque explotado en el Punto 2.
2. Explicar qué herramienta de Blue Team se podría usar para monitorear y
   generar alertas ante un ataque como ese.

## Punto de partida (no reinventar la rueda)

El Punto 2 ya incluye capturas reales del ataque visto desde la pestaña
**Network** de Chrome DevTools (equivalente al HTTP history de Burp) y un
script que las reproduce:

- `../punto2-explotacion/02-devtools-network-payload.png` (+ `-headers`,
  `-response`)
- `../punto2-explotacion/capture_devtools_network.js`

Eso cubre el punto 1 de este ítem (cómo se ve el ataque en la red). Lo que
falta aquí es la parte 2: explicar/proponer la herramienta de alertas (p.
ej. un WAF con reglas OWASP CRS, un IDS como Suricata, o alertas sobre los
logs de Juice Shop) y, si da el tiempo, una demo de esa alerta disparándose.
