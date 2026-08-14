# Pruebas — Cifrado César (Punto 4)

Este documento es la evidencia completa de las 5 pruebas exigidas por el
enunciado. Incluye: el código exacto que se ejecutó, la transcripción real
de cada corrida del programa (equivalente textual de la captura de terminal),
y la verificación matemática de por qué cada resultado es correcto.

## Tabla de pruebas

| # | Texto de entrada | Llave | Cifrado | Descifrado |
|---|---|---|---|---|
| 1 | Hola Mundo | 3 | Krod Pxqgr | Hola Mundo |
| 2 | Ataque al amanecer | 5 | Fyfvzj fq frfsjhjw | Ataque al amanecer |
| 3 | Red Team EAFIT | 30 | Vih Xieq IEJMX | Red Team EAFIT |
| 4 | Clave: N0ct@I #2026! | 13 | Pynir: A0pg@V #2026! | Clave: N0ct@I #2026! |
| 5 | Los 5 Mosqueteros áéíóú | 100 | Hko 5 Ikomqapanko áéíóú | Los 5 Mosqueteros áéíóú |

Prueba 3 usa llave 30 (> 26). Pruebas 4 y 5 usan caracteres especiales,
números y tildes que no se cifran.

---

## 1. Código ejecutado

Archivo: `cifrado_cesar.py` (contenido completo en este mismo directorio).

Núcleo del algoritmo:

```python
def cifrar_cesar(texto: str, llave: int) -> str:
    resultado = []
    for ch in texto:
        if ch.isascii() and ch.isupper():
            base = ord('A')
            resultado.append(chr((ord(ch) - base + llave) % 26 + base))
        elif ch.isascii() and ch.islower():
            base = ord('a')
            resultado.append(chr((ord(ch) - base + llave) % 26 + base))
        else:
            resultado.append(ch)  # no-letras se copian tal cual
    return "".join(resultado)


def descifrar_cesar(texto: str, llave: int) -> str:
    return cifrar_cesar(texto, -llave)
```

Cómo se ejecutó cada prueba (modo interactivo real del programa):

```
$ python3 cifrado_cesar.py
============================================
        CIFRADO CESAR - Taller 1 SI3006
============================================

1. Cifrar
2. Descifrar
3. Salir
Opcion:
```

---

## 2. Transcripción completa de las 5 pruebas

### Prueba 1 — texto simple, llave pequeña

```
Opcion: 1
Texto a cifrar: Hola Mundo
Ingrese la llave numerica: 3
Resultado cifrado : Krod Pxqgr

Opcion: 2
Texto a descifrar: Krod Pxqgr
Ingrese la llave numerica: 3
Resultado descifrado : Hola Mundo
```

**Verificación manual letra por letra (primeras 4 letras de "Hola"):**

| Letra | Posición (0-25) | + llave (3) | mod 26 | Letra cifrada |
|---|---|---|---|---|
| H | 7 | 10 | 10 | K |
| o | 14 | 17 | 17 | r |
| l | 11 | 14 | 14 | o |
| a | 0 | 3 | 3 | d |

→ "Hola" cifra a "Krod" ✔ coincide con el resultado del programa.

---

### Prueba 2 — texto más largo, llave 5

```
Opcion: 1
Texto a cifrar: Ataque al amanecer
Ingrese la llave numerica: 5
Resultado cifrado : Fyfvzj fq frfsjhjw

Opcion: 2
Texto a descifrar: Fyfvzj fq frfsjhjw
Ingrese la llave numerica: 5
Resultado descifrado : Ataque al amanecer
```

Los espacios entre palabras no son letras, por lo tanto no se cifran y
permanecen exactamente en la misma posición en el texto cifrado.

---

### Prueba 3 — llave MAYOR A 26 (requisito explícito del enunciado)

```
Opcion: 1
Texto a cifrar: Red Team EAFIT
Ingrese la llave numerica: 30
Resultado cifrado : Vih Xieq IEJMX

Opcion: 2
Texto a descifrar: Vih Xieq IEJMX
Ingrese la llave numerica: 30
Resultado descifrado : Red Team EAFIT
```

**Por qué funciona con llave > 26:** el operador `% 26` reduce cualquier
llave a su equivalente dentro del rango 0-25. Aquí `30 % 26 = 4`, así que
cifrar con llave 30 produce exactamente el mismo resultado que cifrar con
llave 4. Verificación:

```python
>>> (30 % 26)
4
>>> cifrar_cesar("Red Team EAFIT", 30) == cifrar_cesar("Red Team EAFIT", 4)
True
```

---

### Prueba 4 — caracteres especiales y números (requisito explícito)

```
Opcion: 1
Texto a cifrar: Clave: N0ct@I #2026!
Ingrese la llave numerica: 13
Resultado cifrado : Pynir: A0pg@V #2026!

Opcion: 2
Texto a descifrar: Pynir: A0pg@V #2026!
Ingrese la llave numerica: 13
Resultado descifrado : Clave: N0ct@I #2026!
```

Nótese que `:`, `0`, `@`, `#`, `2`, `0`, `2`, `6`, `!` aparecen IDÉNTICOS en
el texto cifrado y en el original — el algoritmo no los toca porque
`ch.isascii() and (ch.isupper() or ch.islower())` es `False` para todos
ellos, y caen en la rama `else: resultado.append(ch)`.

---

### Prueba 5 — llave grande (100) + caracteres acentuados

```
Opcion: 1
Texto a cifrar: Los 5 Mosqueteros áéíóú
Ingrese la llave numerica: 100
Resultado cifrado : Hko 5 Ikomqapanko áéíóú

Opcion: 2
Texto a descifrar: Hko 5 Ikomqapanko áéíóú
Ingrese la llave numerica: 100
Resultado descifrado : Los 5 Mosqueteros áéíóú
```

`100 % 26 = 22`, por lo tanto el desplazamiento real aplicado es 22. Las
vocales acentuadas (á é í ó ú) no son ASCII puro (`ch.isascii()` da `False`
para ellas), así que tampoco se cifran — se copian igual que el número "5".

---

## 3. Tabla resumen

| # | Texto de entrada | Llave | Llave efectiva (mod 26) | Cifrado | Descifrado | ¿Coincide con entrada? |
|---|---|---|---|---|---|---|
| 1 | Hola Mundo | 3 | 3 | Krod Pxqgr | Hola Mundo | Sí |
| 2 | Ataque al amanecer | 5 | 5 | Fyfvzj fq frfsjhjw | Ataque al amanecer | Sí |
| 3 | Red Team EAFIT | 30 | 4 | Vih Xieq IEJMX | Red Team EAFIT | Sí |
| 4 | Clave: N0ct@I #2026! | 13 | 13 | Pynir: A0pg@V #2026! | Clave: N0ct@I #2026! | Sí |
| 5 | Los 5 Mosqueteros áéíóú | 100 | 22 | Hko 5 Ikomqapanko áéíóú | Los 5 Mosqueteros áéíóú | Sí |

En las 5 pruebas: `descifrar_cesar(cifrar_cesar(texto, llave), llave) == texto`.

## 4. Cómo reproducir exactamente estas pruebas

```bash
git clone https://github.com/kepabonsaeafit/eafit-ciberseguridad-si3006.git
cd eafit-ciberseguridad-si3006/punto-4-cesar
python3 cifrado_cesar.py
```

Y repetir la secuencia Opción → Texto → Llave que aparece en cada
transcripción de arriba; el resultado debe ser exactamente el mostrado.
