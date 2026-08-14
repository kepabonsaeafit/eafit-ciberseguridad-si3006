# Cifrado César — Taller 1 Ciberseguridad SI3006 (EAFIT)

**Responsable:** Santiago

## Qué hay en esta carpeta

- ✅ `cifrado_cesar.py` — script que cifra y descifra con César, permitiendo
  escoger la llave numérica.
- ✅ `pruebas.md` — evidencia de las 5 pruebas pedidas por el enunciado,
  incluyendo una con llave mayor a 26 (llaves 30 y 100) y una con
  caracteres especiales (números, signos y tildes).

Script en Python que **cifra y descifra** con el algoritmo César permitiendo escoger la llave numérica.

## Uso
```bash
python3 cifrado_cesar.py
```
Menú:
1. Cifrar (pide texto y llave)
2. Descifrar (pide texto y llave)
3. Salir

## Cómo funciona
- Fórmula: `(letra − base + llave) % 26 + base` con base `'A'=65` / `'a'=97`.
- El `% 26` permite llaves mayores a 26 y negativas (dan la vuelta al alfabeto).
- Mayúsculas y minúsculas se tratan por separado.
- Números, espacios, tildes y signos se conservan intactos.
- Descifrar = cifrar con `−llave`.

## Pruebas realizadas

Las 5 pruebas exigidas por el enunciado (incluyendo una con llave mayor a
26 y una con caracteres especiales) están documentadas en `pruebas.md`,
en esta misma carpeta, con la tabla completa, la transcripción de cada
corrida y la verificación matemática de cada resultado.
