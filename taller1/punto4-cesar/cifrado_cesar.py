#!/usr/bin/env python3
"""
Cifrado Cesar - cifra y descifra permitiendo escoger la llave numerica.
Taller 1 - Ciberseguridad SI3006 - Universidad EAFIT.
Autor: Pedro Santiago Mafla Jaramillo.
"""


def cifrar_cesar(texto: str, llave: int) -> str:
    """
    Desplaza cada letra 'llave' posiciones en el alfabeto.
    - El modulo 26 permite que llaves > 26 (o negativas) den la vuelta al
      alfabeto sin salirse de el.
    - Se preservan mayusculas y minusculas por separado usando su 'base'
      ASCII ('A'=65, 'a'=97).
    - Todo caracter que NO sea una letra (numeros, espacios, tildes, signos)
      se deja intacto.
    """
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
    """Descifrar es cifrar con la llave contraria."""
    return cifrar_cesar(texto, -llave)


def _leer_llave() -> int:
    while True:
        try:
            return int(input("Ingrese la llave numerica: ").strip())
        except ValueError:
            print("La llave debe ser un numero entero. Intente de nuevo.")


def menu():
    print("=" * 44)
    print("        CIFRADO CESAR - Taller 1 SI3006")
    print("=" * 44)
    while True:
        print("\n1. Cifrar")
        print("2. Descifrar")
        print("3. Salir")
        op = input("Opcion: ").strip()
        if op == "1":
            texto = input("Texto a cifrar: ")
            llave = _leer_llave()
            print("Resultado cifrado :", cifrar_cesar(texto, llave))
        elif op == "2":
            texto = input("Texto a descifrar: ")
            llave = _leer_llave()
            print("Resultado descifrado :", descifrar_cesar(texto, llave))
        elif op == "3":
            print("Saliendo...")
            break
        else:
            print("Opcion no valida.")


if __name__ == "__main__":
    menu()
