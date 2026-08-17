# Punto 3 — Bandit 0 a 10
# Solución de los retos Bandit, niveles 0 al 10

## De qué se trata

Bandit es un juego de la página [OverTheWire](https://overthewire.org/wargames/bandit/) pensado para aprender a moverse por una máquina Linux usando la terminal. Cada nivel es un pequeño acertijo: hay una contraseña escondida en algún lado del servidor y hay que encontrarla. Esa contraseña es la flag del nivel y, al mismo tiempo, es el usuario y la clave con la que entramos al nivel siguiente. Nosotros hicimos los niveles del 0 al 10 conectándonos desde PowerShell en Windows.

El servidor del juego es `bandit.labs.overthewire.org` y trabaja en el puerto `2220`. La forma de entrar siempre es la misma: nos conectamos por SSH con el usuario del nivel y la contraseña que sacamos del nivel anterior.

## Cómo nos conectamos desde PowerShell

Windows ya trae el cliente de SSH incluido, así que no tuvimos que instalar nada. Abrimos PowerShell y escribimos el comando de conexión cambiando el número del usuario según el nivel en el que estemos:

```powershell
ssh bandit0@bandit.labs.overthewire.org -p 2220
```

La primera vez que uno se conecta, el servidor pregunta si confía en él. Se responde escribiendo `yes` y se presiona Enter. Después pide la contraseña. Es importante aclarar que mientras uno escribe la contraseña la pantalla no muestra nada, ni siquiera asteriscos; eso es normal y no significa que el teclado no esté funcionando. Se escribe (o se pega con clic derecho) y se presiona Enter.

Para salir de un nivel y volver a Windows se escribe:

```bash
exit
```

## Comandos que usamos

Antes de entrar a cada nivel dejamos aquí la explicación de las herramientas que fuimos necesitando, para no repetirlas en cada punto:

| Comando | Para qué sirve |
| --- | --- |
| `ls` | Muestra la lista de archivos que hay en la carpeta donde estamos parados. Con la opción `-a` también muestra los archivos ocultos y con `-l` muestra el detalle (tamaño, dueño, permisos). |
| `cat` | Imprime en pantalla el contenido de un archivo de texto. |
| `cd` | Sirve para entrar a una carpeta. |
| `file` | Revisa un archivo y nos dice qué tipo de contenido tiene, por ejemplo si es texto legible o datos binarios. |
| `find` | Busca archivos por características, como el tamaño, el dueño o el grupo al que pertenecen. |
| `grep` | Busca una palabra dentro de un archivo y muestra la línea donde aparece. |
| `sort` | Ordena las líneas de un archivo, lo que sirve para dejar juntas las que se repiten. |
| `uniq` | Trabaja con líneas repetidas; con la opción `-u` nos deja solamente las que aparecen una sola vez. |
| `strings` | Saca el texto legible que está mezclado dentro de un archivo binario. |
| `base64` | Codifica o decodifica texto; con la opción `-d` lo decodifica. |
| `\|` (pipe) | Une dos comandos: toma lo que sale del primero y se lo entrega al segundo. |

---

## Nivel 0

**Qué pedía el reto**

El reto pedía simplemente conectarse al servidor por SSH con el usuario `bandit0` y la contraseña `bandit0`.

**Paso a paso**

Abrimos PowerShell y escribimos el comando de conexión.

```powershell
ssh bandit0@bandit.labs.overthewire.org -p 2220
```

Cuando pidió la contraseña escribimos `bandit0` y presionamos Enter. Al entrar cambió el texto de la línea de la terminal y apareció `bandit0@bandit`, que nos confirmó que ya estábamos dentro del servidor del juego.

Este nivel no tiene contraseña que buscar, la contraseña ya nos la daba la página. Lo único que se pedía era lograr la conexión.

<img width="1050" height="811" alt="image" src="https://github.com/user-attachments/assets/25ce15ee-7641-4957-a335-dbdf401f8eea" />


---

## Nivel 0 al Nivel 1

**Qué pedía el reto**

La contraseña del siguiente nivel estaba guardada en un archivo llamado `readme`, dentro de la carpeta personal del usuario.

**Paso a paso**

Ya conectados como `bandit0`, listamos lo que había en la carpeta.

```bash
ls
```

Nos apareció un solo archivo llamado `readme`, así que lo leímos.

```bash
cat readme
```

El archivo trae un texto de bienvenida y al final la línea con la contraseña.

```
The password you are looking for is: 6y2kwnwK6grgvwvpvLaa2T1cpFEKOhNR
```

**Flag encontrada:** `6y2kwnwK6grgvwvpvLaa2T1cpFEKOhNR`

<img width="1050" height="239" alt="image" src="https://github.com/user-attachments/assets/704515b2-dc62-4a56-9d87-21083f419ef5" />


---

## Nivel 1 al Nivel 2

**Qué pedía el reto**

La contraseña estaba en un archivo cuyo nombre es un solo guion.

**Paso a paso**

Entramos con el usuario `bandit1` y la contraseña que acabábamos de encontrar.

```powershell
ssh bandit1@bandit.labs.overthewire.org -p 2220
```

Listamos la carpeta y vimos el archivo llamado `-`.

```bash
ls
```

Al intentar leerlo de la forma normal no funciona, porque en Linux el guion se interpreta como si fuera una opción del comando y no como el nombre del archivo. La solución fue escribir `./` antes del nombre, que quiere decir "el archivo que está en esta misma carpeta".

```bash
cat ./-
```

**Flag encontrada:** `PK8fYLZg2hnHSz83plBL1iEPKdD3QToB`



<img width="984" height="158" alt="image" src="https://github.com/user-attachments/assets/5f8eefaf-f881-4639-a640-4e9fa93e1638" />


---

## Nivel 2 al Nivel 3

**Qué pedía el reto**

La contraseña estaba en un archivo cuyo nombre tiene espacios en la mitad.

**Paso a paso**

Entramos como `bandit2` y listamos la carpeta.

```bash
ls
```

El archivo se llamaba `--spaces in this filename--`. Como el nombre tiene espacios, la terminal lo entendería como varios archivos distintos, y como además empieza con guiones también los tomaría como opciones. Por eso lo escribimos entre comillas y con `./` adelante.

```bash
cat "./--spaces in this filename--"
```

**Flag encontrada:** `7ZZ2LFrykP2zEyvBl4m3clcL7tGYJPME`


<img width="1050" height="114" alt="image" src="https://github.com/user-attachments/assets/0b527d96-1c0c-4bd3-9c26-de6d036e15c9" />


---

## Nivel 3 al Nivel 4

**Qué pedía el reto**

La contraseña estaba en un archivo oculto dentro de la carpeta `inhere`.

**Paso a paso**

Entramos como `bandit3` y revisamos la carpeta `inhere`. Con un `ls` normal no aparecía nada, porque en Linux los archivos que empiezan con punto están ocultos. Usamos la opción `-a` para que se vieran todos.

```bash
ls -a inhere
```

Ahí apareció el archivo `...Hiding-From-You` y lo leímos.

```bash
cat "inhere/...Hiding-From-You"
```

**Flag encontrada:** `xzTXq1rDJQVVAzdv5cHq1TQytTWufAMq`


<img width="1050" height="172" alt="image" src="https://github.com/user-attachments/assets/55a5d329-dfc0-4888-8698-6718ca63d105" />


---

## Nivel 4 al Nivel 5

**Qué pedía el reto**

Dentro de la carpeta `inhere` había diez archivos y solo uno de ellos era texto que se pudiera leer.

**Paso a paso**

Entramos como `bandit4`, nos metimos a la carpeta y listamos.

```bash
cd inhere
ls
```

Los archivos se llamaban `-file00` hasta `-file09`. En lugar de abrirlos uno por uno, usamos `file` para que nos dijera de qué tipo era cada uno. El símbolo `*` significa "todos los archivos".

```bash
file ./*
```

El resultado mostró que casi todos eran datos binarios y que únicamente `-file07` aparecía como ASCII text, es decir, texto normal. Ese fue el que leímos.

```
./-file07: ASCII text
```

```bash
cat ./-file07
```

**Flag encontrada:** `6C7h9GD8M6ai5nr7wo1RonrzFjj9yIrG`


<img width="1050" height="555" alt="image" src="https://github.com/user-attachments/assets/8656f33a-b172-440e-86b1-29b8f0a6e1db" />


---

## Nivel 5 al Nivel 6

**Qué pedía el reto**

El archivo con la contraseña estaba en algún lugar dentro de `inhere` y cumplía tres condiciones: pesaba exactamente 1033 bytes, era texto legible y no era ejecutable.

**Paso a paso**

Entramos como `bandit5`. Como había muchísimas carpetas y archivos, buscar a mano era imposible, así que usamos `find` con las condiciones que nos daba el enunciado.

```bash
find inhere -type f -size 1033c ! -executable
```

En el comando, `-type f` indica que buscamos archivos y no carpetas, `-size 1033c` indica el tamaño exacto en bytes (la `c` es de bytes) y `! -executable` descarta los que sí son ejecutables.

La búsqueda devolvió un único resultado y lo leímos.

```
inhere/maybehere07/.file2
```

```bash
cat inhere/maybehere07/.file2
```

**Flag encontrada:** `pXa26xhMWaC2SvDotA4r9EgZkulOeSBW`


<img width="1050" height="143" alt="image" src="https://github.com/user-attachments/assets/66b68ed2-bb85-4429-be2b-7f5ecaaf5114" />


---

## Nivel 6 al Nivel 7

**Qué pedía el reto**

Esta vez el archivo podía estar en cualquier parte del servidor. Las pistas eran que pertenecía al usuario `bandit7`, al grupo `bandit6` y pesaba 33 bytes.

**Paso a paso**

Entramos como `bandit6` y lanzamos la búsqueda desde la raíz del sistema, que se escribe con `/`. Le agregamos `2>/dev/null` al final para que no nos llenara la pantalla con los mensajes de error de las carpetas a las que nuestro usuario no tiene permiso de entrar.

```bash
find / -user bandit7 -group bandit6 -size 33c 2>/dev/null
```

Nos devolvió la ruta del archivo y lo leímos.

```
/var/lib/dpkg/info/bandit7.password
```

```bash
cat /var/lib/dpkg/info/bandit7.password
```

**Flag encontrada:** `Bmnnvf82KzQlfxgAI2d1zYbr1u9pr3E3`

<img width="1050" height="162" alt="image" src="https://github.com/user-attachments/assets/4cad08c0-5253-4965-9fc4-20413769f428" />


---

## Nivel 7 al Nivel 8

**Qué pedía el reto**

La contraseña estaba dentro del archivo `data.txt`, en la línea que estuviera al lado de la palabra `millionth`.

**Paso a paso**

Entramos como `bandit7`. El archivo `data.txt` es muy grande, así que no tenía sentido abrirlo completo. Usamos `grep` para que buscara directamente la palabra.

```bash
grep millionth data.txt
```

El comando mostró únicamente la línea que nos interesaba, con la palabra `millionth` y al lado la contraseña.

```
millionth      VR1ljMayciFxbnUokuQmJFw6QC9VKtub
```

**Flag encontrada:** `VR1ljMayciFxbnUokuQmJFw6QC9VKtub`

<img width="928" height="142" alt="image" src="https://github.com/user-attachments/assets/30079ce4-a086-4006-9caf-89345df8fc88" />

---

## Nivel 8 al Nivel 9

**Qué pedía el reto**

En el archivo `data.txt` todas las líneas estaban repetidas, menos una. Esa línea única era la contraseña.

**Paso a paso**

Entramos como `bandit8`. Aquí combinamos dos comandos con el pipe. Primero `sort` ordena el archivo para que las líneas iguales queden pegadas una debajo de otra, y después `uniq -u` deja solamente las que aparecen una sola vez.

```bash
sort data.txt | uniq -u
```

Esto era necesario porque `uniq` solo compara líneas que estén seguidas; si no ordenamos primero, no detecta las repeticiones.

**Flag encontrada:** `EjmOSvuAu7sGAHqHVcBDPirRe9T03kxl`

<img width="881" height="145" alt="image" src="https://github.com/user-attachments/assets/ce88ea97-88d2-4e4e-8111-68e26a32837e" />

---

## Nivel 9 al Nivel 10

**Qué pedía el reto**

La contraseña estaba dentro de un archivo con mucha información ilegible, en una de las pocas líneas de texto que se podían leer y que venía marcada con varios signos igual.

**Paso a paso**

Entramos como `bandit9`. Como el archivo es binario, con `cat` solo salían símbolos raros. Usamos `strings` para sacar el texto legible y le pasamos ese resultado a `grep` para quedarnos con las líneas que tuvieran el signo igual.

```bash
strings data.txt | grep '='
```

Entre los resultados aparecieron cuatro líneas que, leídas seguidas, decían *the password is* y luego la contraseña.

```
========== the
========== password
========== is
========== B0s2khmbT9u0geKuOoVGW3JZKhndE3BG
```

**Flag encontrada:** `B0s2khmbT9u0geKuOoVGW3JZKhndE3BG`


<img width="894" height="584" alt="image" src="https://github.com/user-attachments/assets/ae44545b-dc27-430a-9b98-21158a3f918c" />


---

## Nivel 10 al Nivel 11

**Qué pedía el reto**

La contraseña estaba en `data.txt` pero codificada en base64.

**Paso a paso**

Entramos como `bandit10` y primero miramos el archivo para confirmar cómo se veía.

```bash
cat data.txt
```

Salió un texto raro terminado en dos signos igual, que es la forma típica de base64. Vale aclarar que base64 no es un cifrado, es solo una manera de representar información en texto, así que se puede devolver a su forma original sin necesidad de ninguna clave.

```
VGhlIHBhc3N3b3JkIGlzIHBZZk9ZNkh3VXNEajVyTDlVdnloVTdNQ212OHZONVJvCg==
```

Lo decodificamos con la opción `-d`.

```bash
base64 -d data.txt
```

```
The password is pYfOY6HwUsDj5rL9UvyhU7MCmv8vN5Ro
```

**Flag encontrada:** `pYfOY6HwUsDj5rL9UvyhU7MCmv8vN5Ro`

<img width="1050" height="184" alt="image" src="https://github.com/user-attachments/assets/99c61f04-094d-43c6-8c78-b80cbdf76951" />

---

## Resumen de las flags

Estas son todas las contraseñas que fuimos encontrando, en el orden en que las sacamos. Cada una fue la llave para entrar al nivel siguiente.

| Nivel | Contraseña |
| --- | --- |
| 0 | `6y2kwnwK6grgvwvpvLaa2T1cpFEKOhNR` |
| 1 | `PK8fYLZg2hnHSz83plBL1iEPKdD3QToB` |
| 2 | `7ZZ2LFrykP2zEyvBl4m3clcL7tGYJPME` |
| 3 | `xzTXq1rDJQVVAzdv5cHq1TQytTWufAMq` |
| 4 | `6C7h9GD8M6ai5nr7wo1RonrzFjj9yIrG` |
| 5 | `pXa26xhMWaC2SvDotA4r9EgZkulOeSBW` |
| 6 | `Bmnnvf82KzQlfxgAI2d1zYbr1u9pr3E3` |
| 7 | `VR1ljMayciFxbnUokuQmJFw6QC9VKtub` |
| 8 | `EjmOSvuAu7sGAHqHVcBDPirRe9T03kxl` |
| 9 | `B0s2khmbT9u0geKuOoVGW3JZKhndE3BG` |
| 10 | `pYfOY6HwUsDj5rL9UvyhU7MCmv8vN5Ro` |

## Conclusiones

Los primeros once niveles de Bandit nos sirvieron para agarrarle confianza a la terminal de Linux. Lo que más nos quedó claro es que casi siempre existe un comando que hace el trabajo pesado por uno: en vez de abrir diez archivos a mano, `file` nos dijo cuál servía, y en vez de recorrer carpeta por carpeta, `find` encontró el archivo en segundos.

También aprendimos a tener cuidado con los nombres de archivo raros, porque un guion o un espacio pueden hacer que un comando sencillo falle, y a combinar comandos con el pipe para resolver en una sola línea cosas que por separado no salían. Por último, el nivel de base64 nos dejó una idea importante: que algo se vea ilegible no quiere decir que esté protegido.
