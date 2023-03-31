# Práctica 4

## Universidad de San Carlos de Guatemala
## Facultad de Ingeniería
## Escuela de Ciencias y Sistemas
## Arquitectura de Computadores y Ensambladores 1
## Sección B

## Objetivo
El proyecto consiste en la implementación de hojas de cálculo en ensamblador. El programa debe ser capaz de realizar operaciones aritméticas básicas, operaciones lógicas, operaciones de comparación, operaciones de desplazamiento, operaciones de entrada y salida, operaciones de control de flujo, operaciones de memoria, operaciones de cadena, operaciones de conversión, operaciones de interrupción, operaciones de llamada a procedimiento, operaciones de retorno de procedimiento, operaciones de manejo de pila, operaciones de manejo de registros, operaciones de manejo de banderas.

## Directivas de ensamblador
```asm
.MODEL small
.STACK
.RADIX 16
.DATA
```
- La directiva RADIX indica que se va a trabajar con números hexadecimales. 
- La directiva STACK indica que se va a utilizar la pila. 
- La directiva DATA indica que se va a declarar variables. 
- La directiva MODEL indica que se va a trabajar con un modelo de 16 bits.

En el `data segment` del archivo main, se declaran palabras reservadas que se van a utilizar para poder reconocer los comandos, en su primer byte va a estar el número de letras que tiene dicha palabra, para poder utilizar un macro de comparación de cadenas, y en los siguientes bytes se va a guardar la palabra reservada.

```asm
GUARDARCommand          DB 07h, 'GUARDAR', '$'
SUMACommand             DB 04h, 'SUMA', '$'
RESTACommand            DB 05h, 'RESTA', '$'
MULTIPLICACIONCommand   DB 0Eh, 'MULTIPLICACION', '$'
DIVIDIRCommand          DB 07h, 'DIVIDIR', '$'
POTENCIARCommand        DB 09h, 'POTENCIAR', '$'
OLOGICOCommand          DB 07h, 'OLOGICO', '$'
YLOGICOCommand          DB 07h, 'YLOGICO', '$'
OXLOGICOCommand         DB 08h, 'OXLOGICO', '$'
NOLOGICOCommand         DB 08h, 'NOLOGICO', '$'
```

Para hacer la conversión de número a letra, y viceversa, se guardan en variables dichos valores.

El número va a ser de 16 bytes, y el número en cadena va a ser de máximo 8 bytes

```asm
numberGotten DW ?
recoveredStr DB 7 DUP('$')
```

Las variables para guardar los parámetros de la funciones son: 
    
```asm
guardarParametroNumero DW 0
guardarParametroNumero2 DW 0
```

En el `code segment` se declaran el flujo principal del programa, en el que se va a llamar a la función `main`, que es la que va a llamar a las demás funciones en el archivo **MACROS.ASM**.

## Macros

### **mIsNumber macro**
Esta macro permite verificar si un string es un número o no. Primero se empujan los registros DX, AX y CX a la pila para preservar su valor. Se llama a la macro mEmptyBuffer para vaciar el buffer de teclado. Luego se muestra en la pantalla un mensaje que indica al usuario que ingrese su entrada. Se carga en DX la dirección de memoria del buffer de teclado, se llama a la macro mReadKeyboard para leer la entrada del usuario y se guarda en el registro AL el valor de retorno de la macro. Se compara el valor del registro AL con 0Dh, que es el código ASCII de la tecla "Enter". Si AL es igual a 0Dh, se salta a la etiqueta is_number para verificar si el string ingresado es un número o no. Si AL es diferente a 0Dh, se salta a la etiqueta wait_enter para volver a imprimir el mensaje y esperar a que el usuario presione "Enter" de nuevo. Se llama a la macro mIsNumber para verificar si el string ingresado es un número o no. Si el string ingresado es un número, se salta a la etiqueta is_number. Si el string ingresado no es un número, se salta a la etiqueta wait_enter para volver a imprimir el mensaje y esperar a que el usuario presione "Enter" de nuevo. Finalmente, se restauran los registros DX, AX y CX de la pila.

### **mIsLetter macro**
Esta macro permite verificar si un string es una letra o no. Primero se empujan los registros DX, AX y CX a la pila para preservar su valor. Se llama a la macro mEmptyBuffer para vaciar el buffer de teclado. Luego se muestra en la pantalla un mensaje que indica al usuario que ingrese su entrada. Se carga en DX la dirección de memoria del buffer de teclado, se llama a la macro mReadKeyboard para leer la entrada del usuario y se guarda en el registro AL el valor de retorno de la macro. Se compara el valor del registro AL con 0Dh, que es el código ASCII de la tecla "Enter". Si AL es igual a 0Dh, se salta a la etiqueta is_letter para verificar si el string ingresado es una letra o no. Si AL es diferente a 0Dh, se salta a la etiqueta wait_enter para volver a imprimir el mensaje y esperar a que el usuario presione "Enter" de nuevo. Se llama a la macro mIsLetter para verificar si el string ingresado es una letra o no. Si el string ingresado es una letra, se salta a la etiqueta is_letter. Si el string ingresado no es una letra, se salta a la etiqueta wait_enter para volver a imprimir el mensaje y esperar a que el usuario presione "Enter" de nuevo. Finalmente, se restauran los registros DX, AX y CX de la pila.

### **mIsCell macro**
De primero comprueba que el string ingresado esté compuesto de [LETRA] [NUMERO], la letra únicamente puede ser de la A a la K, y el numero de 0 a 9, de máximo 5 caracteres. Si el string ingresado no cumple con estas condiciones, se salta a la etiqueta wait_enter para volver a imprimir el mensaje y esperar a que el usuario presione "Enter" de nuevo. Si el string ingresado cumple con las condiciones, se salta a la etiqueta is_cell.

### Imprimir cadenas

Estas macros son utilizadas en el lenguaje de programación ensamblador para imprimir mensajes en la consola de la computadora. La macro mPrintMsg permite imprimir mensajes que están almacenados en la memoria de la computadora y la macro mPrintPartialDirection permite imprimir mensajes que son almacenados en el registro de la computadora.

Sintaxis
La sintaxis de ambas macros es la siguiente:


```
mPrintMsg macro str
    push AX
    push DX

    mov DX, offset str
    mov AH, 09h
    int 21h

    pop DX
    pop AX
endm
```

``` asm
mPrintPartialDirection macro str
    push AX
    push DX

    mov DX, str
    mov AH, 09h
    int 21h

    pop AX
    pop DX
endm
```
La macro mPrintMsg recibe como parámetro un string llamado str, que es la dirección del mensaje a imprimir. La macro mPrintPartialDirection recibe como parámetro un string llamado str, que es el mensaje a imprimir.

### Funcionamiento
La macro mPrintMsg guarda los registros AX y DX en la pila y luego mueve la dirección del mensaje a imprimir a DX. Después, establece el valor 09h en el registro AH, que indica que se va a realizar una operación de impresión, y finalmente hace una interrupción en la rutina de impresión del sistema operativo con el valor 21h. Finalmente, restaura los registros AX y DX de la pila.

Por otro lado, la macro mPrintPartialDirection guarda los registros AX y DX en la pila y luego mueve el mensaje a imprimir a DX. Después, establece el valor 09h en el registro AH, que indica que se va a realizar una operación de impresión, y finalmente hace una interrupción en la rutina de impresión del sistema operativo con el valor 21h. Finalmente, restaura los registros AX y DX de la pila.

### Funciones de entrada con teclado 

La macro `mWaitEnter` espera a que el usuario presione la tecla "Enter" para continuar la ejecución del programa.

#### Sintaxis
```asm
    mWaitEnter
```
#### Comportamiento
- Se define una etiqueta local llamada wait_enter.
- Se mueve el valor 08h al registro AH.
- Se llama a la interrupción 21h con int 21h, lo que imprime el mensaje "Press Enter" en la pantalla.
 Se compara el valor del registro AL con 0Dh, que es el código ASCII de la tecla "Enter".
- Si AL es diferente a 0Dh, se salta a la etiqueta wait_enter para volver a imprimir el mensaje y esperar a que el usuario presione "Enter" de nuevo.
- Si AL es igual a 0Dh, se continúa la ejecución del programa.

### **mGetInputKeyboard macro**
Esta macro permite leer un string del teclado y guardarlo en el buffer de teclado. Primero se empujan los registros DX, AX y CX a la pila para preservar su valor. Se llama a la macro mEmptyBuffer para vaciar el buffer de teclado. Luego se muestra en la pantalla un mensaje que indica al usuario que ingrese su entrada. Se carga en DX la dirección de memoria del buffer de teclado, se carga en AH el valor 0Ah que corresponde al servicio de lectura de una cadena de caracteres desde el teclado con retorno de carro y finalmente se llama a la interrupción 21h de la rutina de servicios del sistema operativo para leer la cadena. Por último, se recuperan los registros DX, AX y CX desde la pila.

### **mEvaluatePrompt macro**
Esta macro evalúa un comando ingresado por el usuario en el buffer de teclado. Primero se empujan los registros AX, CX, DX y SI a la pila para preservar su valor. Se carga en SI la dirección de memoria del buffer de teclado sumándole 02h para omitir el tamaño de la cadena en el buffer. Se llama a la macro mSkipWhiteSpace para omitir espacios en blanco en el buffer de teclado. Se compara el valor de la cadena siguiente para comprobar que sea un comando válido. Si el comando es válido, se llama a la macro mEvaluateCommand para evaluar el comando. Si el comando no es válido, se muestra un mensaje de error en la pantalla. Por último, se recuperan los registros AX, CX, DX y SI desde la pila.

### **mEvaluateCommand macro**
Esta macro evalúa un comando ingresado por el usuario en el buffer de teclado. Primero se empujan los registros AX, CX, DX y SI a la pila para preservar su valor. Se llama a la macro mSkipWhiteSpace para omitir espacios en blanco en el buffer de teclado. Se compara el valor de la cadena siguiente para comprobar que sea un comando válido. Si el comando es válido, se llama a la macro mEvaluateCommand para evaluar el comando. Si el comando no es válido, se muestra un mensaje de error en la pantalla. Por último, se recuperan los registros AX, CX, DX y SI desde la pila.

### **mGuardar macro**

Este macro es utilizado para guardar un valor en una celda específica de la hoja de cálculo. Toma como argumentos el valor que se va a guardar y la ubicación de la celda.

La sintaxis para utilizar este macro es la siguiente:

php
Copy code
GUARDAR `<valor | celda | valor de retorno>` EN `<ubicación de la celda>`
Donde `<valor>` puede ser cualquier número entero, una celda, donde se copia su valor, o el valor de retorno que generan otros comandos y `<ubicación de la celda>` es una letra en mayúscula seguida de un número (por ejemplo, A1, B2, C3, etc.).

Si los argumentos ingresados no son correctos, el macro mostrará un mensaje de error indicando que se ha ingresado una sintaxis incorrecta


### **mImportar macro**

Este macro es utilizado para importar archivos CSV a la hoja de cálculo. Toma como argumento el nombre del archivo CSV que se va a importar.

La sintaxis para utilizar este macro es la siguiente:

```asm
IMPORTAR `<nombre del archivo> SEPARADO POR TABULADOR`
```

Donde `<nombre del archivo>` es el nombre del archivo CSV que se va a importar. El archivo debe estar en la misma carpeta que el archivo .asm del programa.

Si los argumentos ingresados no son correctos, el macro mostrará un mensaje de error indicando que se ha ingresado una sintaxis incorrecta.

Mostrará error si las banderas de carry y zero están activas. Pueden ser errores al cerrar el archivo o al leer el archivo.

### **mReadFile macro**

Este macro es utilizado para leer un archivo CSV y guardar su contenido en la hoja de cálculo. Toma como argumentos el nombre del archivo CSV que se va a leer y el separador de columnas.

### **mReadLine macro**

Este macro es utilizado para leer una línea de un archivo CSV y guardar su contenido en la hoja de cálculo. Toma como argumentos el nombre del archivo CSV que se va a leer, el separador de columnas y el número de línea que se va a leer.

### **mReadCell macro**

Este macro es utilizado para leer una celda de un archivo CSV y guardar su contenido en la hoja de cálculo. Toma como argumentos el nombre del archivo CSV que se va a leer, el separador de columnas, el número de línea y el número de columna que se va a leer.

### **mSuma macro**

Este comando toma como argumento únicamente dos valores, que pueden ser números, celdas o valores de retorno, y almacenará el valor se almacenará en el vlaor de retorno.

Las siguientes macros usan la misma lógica que la macro mSuma, pero para otros comandos. Estos son:

- mResta
- mMultiplicacion
- mDivision
- mPotencia
- mOLogico
- mYLogico
- mXorLogico
