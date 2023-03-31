# Práctica 4

## Universidad de San Carlos de Guatemala
## Facultad de Ingeniería
## Escuela de Ciencias y Sistemas
## Arquitectura de Computadores y Ensambladores 1
## Sección B

## Descripción
El programa consiste en un sistema hojas de cálculo, que permite realizar operaciones básicas de hojas de cálculo, como sumar, restar, multiplicar, dividir, etc. Además, permite guardar y cargar hojas de cálculo.

## Requerimientos
Para poder jugar a este juego, es necesario tener instalado un emulador de entorno de sistema operativo DOS (Disk Operating System), como por ejemplo [DOSBox](https://www.dosbox.com/). Además, es necesario tener instalado el compilador de lenguaje ensamblador x86, [MASM](https://www.masm32.com/).

## Instalación
Para poder jugar a este juego, es necesario ejecutar el archivo .EXE llamado `main.exe`que se encuentra en la raíz del proyecto. Para ello, es necesario abrir el emulador de DOSBox y ejecutar el comando `main.exe`.
```bash
main.exe
```

## Uso
Una vez ejecutado el programa, se mostrará una introducción del creador del programa. Dentro del programa al realizar operaciones distintas a `GUARDAR`, el valor se guardará en el valor de retorno

<img src="./assets/1.png" alt="Descripción de la imagen" width="150">

A continuación se mostrará el tablero, y se le pedirá al usuario qué comando desea ejecutar. Para ello, se le pedirá que ingrese el comando en la consola, y presione la tecla `Enter`.

<img src="./assets/2.png" alt="Descripción de la imagen" width="150">

## Comandos


### GUARDAR: GUARDAR [Número o celda] EN [Celda]
Con este comando es posible colocar un valor arbitario en una celda. No se modifica el retorno.

<img src="./assets/3.png" alt="Descripción de la imagen" width="250">
<img src="./assets/4.png" alt="Descripción de la imagen" width="250">

### SUMA:  SUMA [Número o celda] Y [Número o celda]
Esta operación ejecutará una suma y el resultado de ésta será colocado en la variable de retorno.

<img src="./assets/5.png" alt="Descripción de la imagen" width="250">
<img src="./assets/6.png" alt="Descripción de la imagen" width="250">

### RESTA:  RESTA [Número o celda] Y [Número o celda]
Esta operación ejecutará una resta y el resultado de ésta será colocado en la variable de retorno. Si la resta se desborda, se mostrará un mensaje de advertencia.

<img src="./assets/8.png" alt="Descripción de la imagen" width="250">

### MULTIPLICACION: MULTIPLICACION [Número o celda] Y[Número o celda]
Se ejecutará una multiplicación de cantidades de 16 bits. El resultado será colocado en la variable de retorno. Si la operación llegara a generar un número que no puede ser representado con 5 digítos decimales, se mostrará una advertencia.

<img src="./assets/10.png" alt="Descripción de la imagen" width="250">

### DIVIDIR: DIVIDIR [Número o celda] ENTRE [Número o celda]
El comando ejecutará una división, la parte entera del resultado será colocada en la variable de retorno. No pueden existir las divisiones entre cero, por lo que se mostrará un mensaje

<img src="./assets/11.png" alt="Descripción de la imagen" width="250">

### POTENCIAR: POTENCIAR [Número o celda] A LA [Número o celda]
Esta operación permitirá ejecutar una potencia tomando como base el primer número y el número restante como exponente. El resultado no puede ser mayor a 5 dígitos, solo podrán ser exponentes posivitos. El resultado de la operación se colocará en el retorno.

<img src="./assets/12.png" alt="Descripción de la imagen" width="250">

### OLÓGICO: OLÓGICO [Número o celda] Y [Número o celda]
Este comando ejecutará un OR a nivel de bits con las cantidades brindadas como parámetros. El resultado de esta operación se colocará en el retorno.

<img src="./assets/13.png" alt="Descripción de la imagen" width="250">

### YLÓGICO: YLÓGICO [Número o celda] Y [Número o celda]
Este comando ejecutará un AND a nivel de bits con las cantidades brindadas como parámetros. El resultado de esta operación se colocará en el retorno.

 <img src="./assets/ylogico.png" alt="Descripción de la imagen" width="250">

### OXLÓGICO: OXLÓGICO [Número o celda] Y [Número o celda]
Este comando ejecutará un XOR a nivel de bits con las cantidades brindadas como parámetros. El resultado de esta operación se colocará en el retorno.

<img src="./assets/14.png" alt="Descripción de la imagen" width="250">

### NOLÓGICO: NOLÓGICO [Número o celda]
Este comando ejecutará un NOT a nivel de bits con las cantidad brindada como parámetro. El resultado de esta operación se colocará en el retorno.

<img src="./assets/not.png" alt="Descripción de la imagen" width="250">

### IMPORTAR: IMPORTAR [Nombre de archivo] SEPARADOR POR TABULADOR

El programa solicitará en qué columna se deben guardar los valores de las celdas, separadas por tabuladores. Los datos se empiezan a insertar desde la fila 0. Es necesario incluir nombre a los encabezados de cada columna

<img src="./assets/16.png" alt="Descripción de la imagen" width="250">

<img src="./assets/17.png" alt="Descripción de la imagen" width="250">

### Errores
Si se ingresa mal un comando, como por ejemplo, faltan argumentos en la función, se mostrará un mensaje de error.

<img src="./assets/9.png" alt="Descripción de la imagen" width="250">