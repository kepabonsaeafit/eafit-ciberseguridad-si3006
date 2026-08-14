# Paso a paso — Codificación y cifrado (Punto 5)

Este documento es la evidencia completa del proceso. Incluye la cadena en
cada etapa, los comandos exactos ejecutados para llegar a cada resultado
(reproducibles en terminal sin depender de ninguna herramienta gráfica), y
verificaciones cruzadas independientes de la contraseña final.

## Cadena original

```
5a474d334f4449354f4449324d5463784f574d314f544979596a4a6d4e3259354d6a55345a544d304e44673d
```

Longitud: 88 caracteres.

**Advertencia del enunciado:** esta cadena tiene más de dos capas. Al
desenvolver las primeras se obtiene una cadena que *parece* la respuesta
pero no lo es: es un valor intermedio. Hay que seguir analizando el tipo
de dato antes de dar el punto por cerrado.

---

## Capa 1 — Identificación y decodificación

**Tipo:** Hexadecimal.

**Cómo se identificó:** la cadena tiene 88 caracteres (longitud par) y usa
únicamente los símbolos `0-9` y `a-f`. Ese patrón es inconfundible de una
codificación hexadecimal, donde cada byte se representa con 2 dígitos
(88 / 2 = 44 bytes resultantes).

**Con CyberChef (cyberchef.io):**
1. Pegar la cadena original en el panel "Input".
2. Arrastrar la operación **"From Hex"** (categoría *Data format*) al
   panel "Recipe", con el delimitador en "Auto".
3. El panel "Output" muestra el resultado decodificado.

**Con terminal (equivalente exacto, reproducible por cualquiera):**
```bash
$ echo "5a474d334f4449354f4449324d5463784f574d314f544979596a4a6d4e3259354d6a55345a544d304e44673d" | xxd -r -p
ZGM3ODI5ODI2MTcxOWM1OTIyYjJmN2Y5MjU4ZTM0NDg=
```
(Si `xxd` no está instalado: `sudo apt install xxd`, o usar el bloque de
Python de abajo, que da exactamente el mismo resultado — verificado.)

**Con Python (equivalente exacto):**
```python
>>> bytes.fromhex("5a474d334f4449354f4449324d5463784f574d314f544979596a4a6d4e3259354d6a55345a544d304e44673d").decode()
'ZGM3ODI5ODI2MTcxOWM1OTIyYjJmN2Y5MjU4ZTM0NDg='
```

**Resultado (capa 1):**
```
ZGM3ODI5ODI2MTcxOWM1OTIyYjJmN2Y5MjU4ZTM0NDg=
```
Longitud: 44 caracteres.

---

## Capa 2 — Identificación y decodificación

**Tipo:** Base64.

**Cómo se identificó:** cadena alfanumérica (mayúsculas, minúsculas y
dígitos) que termina en `=` (carácter de relleno / padding típico de
Base64) y cuya longitud es múltiplo de 4 (44 caracteres = 11 × 4).

**Con CyberChef:**
1. Sobre el resultado de la Capa 1, agregar la operación **"From Base64"**
   (categoría *Data format*), alfabeto estándar `A-Za-z0-9+/=`.
2. El "Output" muestra el resultado.

**Con terminal:**
```bash
$ echo "ZGM3ODI5ODI2MTcxOWM1OTIyYjJmN2Y5MjU4ZTM0NDg=" | base64 -d
dc78298261719c5922b2f7f9258e3448
```

**Con Python:**
```python
>>> import base64
>>> base64.b64decode("ZGM3ODI5ODI2MTcxOWM1OTIyYjJmN2Y5MjU4ZTM0NDg=").decode()
'dc78298261719c5922b2f7f9258e3448'
```

**Resultado (capa 2):**
```
dc78298261719c5922b2f7f9258e3448
```
Longitud: 32 caracteres.

> ⚠️ **Este resultado PARECE la contraseña pero NO lo es.** Es un valor
> intermedio: 32 caracteres hexadecimales, sin `=`, no legible como texto
> ni con espacios ni con estructura de palabra. Esa longitud (32 hex =
> 128 bits) y ese charset son la huella característica de un **hash**, no
> de una codificación reversible.

---

## Capa 3 — Identificación y resolución

**Qué quedó:** `dc78298261719c5922b2f7f9258e3448` — 32 caracteres
hexadecimales, todo minúsculas, sin separadores.

**Por qué NO es codificación:** una codificación (Hex, Base64) siempre es
reversible por definición — cualquiera la revierte sin necesitar
información extra, solo conociendo el algoritmo. Un **hash**, en cambio,
es de una sola vía por diseño: no existe una operación matemática
"deshacer MD5". La única forma de recuperar el texto original es
*adivinar* la entrada, hashearla, y comparar el resultado contra el hash
objetivo (ataque de diccionario o fuerza bruta).

**Identificación del algoritmo:** 32 caracteres hexadecimales = 16 bytes =
128 bits de salida → esa longitud de salida es específica de **MD5**
(SHA-1 serían 40 hex / 160 bits, SHA-256 serían 64 hex / 256 bits).

**Herramienta de crackeo:** CrackStation (crackstation.net), que compara
el hash contra tablas precomputadas y diccionarios de contraseñas
filtradas (rockyou y similares).

Pasos en CrackStation:
1. Ir a crackstation.net.
2. Pegar `dc78298261719c5922b2f7f9258e3448` en el campo de búsqueda.
3. Resolver el captcha y pulsar "Crack Hashes".
4. El resultado muestra el hash tipo `MD5` y el texto plano `Hola1234`.

**Verificación independiente (sin depender de CrackStation), en terminal:**
```bash
$ echo -n "Hola1234" | md5sum
dc78298261719c5922b2f7f9258e3448  -
```

**Verificación independiente en Python:**
```python
>>> import hashlib
>>> hashlib.md5(b"Hola1234").hexdigest()
'dc78298261719c5922b2f7f9258e3448'
```

Ambos coinciden exactamente con el hash de la capa 2, lo que confirma que
`Hola1234` es la contraseña correcta (y no una coincidencia parcial).

**Chequeo de sensibilidad a mayúsculas/minúsculas** (para descartar
variantes cercanas):
```python
>>> hashlib.md5(b"hola1234").hexdigest()
'ccee5504c9d889922b101124e9e43b71'   # NO coincide -> confirma que la "H" debe ir en mayúscula
```

---

## Contraseña final encontrada

```
Hola1234
```

---

## Resumen de la cadena de transformaciones

```
Cadena original (88 chars hex)
  └─ From Hex ──▶ ZGM3ODI5ODI2MTcxOWM1OTIyYjJmN2Y5MjU4ZTM0NDg=  (44 chars, Base64)
        └─ From Base64 ──▶ dc78298261719c5922b2f7f9258e3448  (32 hex, hash MD5, valor intermedio)
              └─ Crackeo por diccionario / md5sum ──▶ Hola1234  (contraseña real, texto plano)
```

## Diferencia entre codificar, cifrar y hashear

- **Codificar:** transforma datos a otro formato para transporte o
  compatibilidad, sin ningún secreto de por medio. Cualquiera puede
  revertirlo conociendo el algoritmo (ej. Hex, Base64). No aporta
  confidencialidad, solo cambia la representación.
- **Cifrar:** transforma datos usando una clave, de forma que solo quien
  tiene la clave puede revertirlo (ej. César, AES). Aporta
  confidencialidad real.
- **Hashear:** produce una huella de longitud fija, de una sola vía
  (ej. MD5, SHA-256). No es reversible matemáticamente; se usa para
  verificar integridad o para almacenar contraseñas sin guardarlas en
  texto plano (comparando hashes, nunca revirtiéndolos).

Este punto usa las tres: la cadena estaba **codificada** dos veces
(Hex → Base64) y, en el fondo, **hasheada** (MD5). Por eso el valor
intermedio de la capa 2 parecía la respuesta, pero había que reconocerlo
como un hash y crackearlo —no "decodificarlo"— para llegar a la
contraseña real.

## Cómo reproducir el proceso completo de punta a punta

```bash
# Capa 1: Hex -> Base64
echo "5a474d334f4449354f4449324d5463784f574d314f544979596a4a6d4e3259354d6a55345a544d304e44673d" | xxd -r -p

# Capa 2: Base64 -> hash MD5
echo "ZGM3ODI5ODI2MTcxOWM1OTIyYjJmN2Y5MjU4ZTM0NDg=" | base64 -d

# Capa 3: crackear el MD5 (o verificar el candidato directamente)
echo -n "Hola1234" | md5sum
# Debe imprimir: dc78298261719c5922b2f7f9258e3448
```
