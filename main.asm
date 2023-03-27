INCLUDE macros.asm

.MODEl small
.STACK
.RADIX 16
colDimension equ 11t ; 11 columnas
rowDimension equ 23t ; 23 filas
.DATA

; ------------------------------------
; Palabras reservadas
ENCommand DB 02h,'EN'
YCommand DB 01h,'Y'
ENTRECommand DB 05h,'ENTRE'
ALACommand DB 04,'A LA'
HASTACommand DB 05h,'HASTA'
DESDECommand DB 05h,'DESDE'
HACIACommand DB 05h,'HACIA'
SALIRCommand DB 05h, 'SALIR'
PORTABCommand DB 017h,'SEPARADOR POR TABULADOR'
; ------------------------------------

; ------------------------------------
; Comandos para operaciones sobre celdas
GUARDARCommand DB 07h, 'GUARDAR', '$'
SUMACommand DB 04h,'SUMA'
RESTACommand DB 05h,'RESTA'
MULTIPLICACIONCommand DB 0Eh,'MULTIPLICACION'
DIVIDIRCommand DB 07h,'DIVIDIR'
POTENCIARCommand DB 09,'POTENCIAR'
OLOGICOCommand DB 07h,'OLOGICO'
YLOGICOCommand DB 07h,'YLOGICO'
OXLOGICOCommand DB 08h,'OXLOGICO'
NOLOGICOCommand DB 08h,'NOLOGICO'
; ------------------------------------
; ------------------------------------
; Comandos para operaciones sobre rangos
LLENARCommand DB 06h,'LLENAR'
PROMEDIOCommand DB 08h,'PROMEDIO'
MINIMOCommand DB 06h,'MINIMO'
MAXIMOCommand DB 06h,'MAXIMO'
; ------------------------------------

; ------------------------------------
; Comandos para operaciones sobre ficheros
IMPORTARCommand DB 08h,'IMPORTAR'
EXPORTARCommand DB 08h,'EXPORTAR'
TABULADORCommand DB 09h
; ------------------------------------

; ------------------------------------
; Variables extra
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145', 0Dh, 0Ah, '$'
pressEnterMsg DB 'Presione ENTER para continuar', '$'
newLine DB 0Dh, 0Ah, '$'
espacio DB ' ', '$'
counterToGetIndexGotten DW 0            ;; Esta variable me servirá para poder hacer el corrimiento de SI e insertar el numero donde corresponde
returnValue DW 0                        ;; Esta variable se invocará cuando se utilice el caracter *

testStr DB 'testeando $'
; ------------------------------------
; Para las macros
numberGotten DW ?
recoveredStr DB 7 DUP('$')

; ------------------------------------
; Tablero
colName DB 0Dh,'      A      B      C      D      E      F      G      H      I      J      K  ', 0Dh, 0Ah, '$'
mainTable DW 253 dup(0)
cellPosition DW 0
colValue DB 0

; ------------------------------------
; Parametros para el comando IMPORTAR
fileNameBuffer DB 100h dup(0)

; ------------------------------------
; Buffer del teclado

colonChar DB ': $'
currentCommandId DB 00h
isRunProgram DB 00h
keyBoardBuffer DB 102h dup (0ff, 0)

; ------------------------------------
; Parametros para GUARDAR

guardarParametroNumero DW 0

; ------------------------------------
; ------------------------------------
; Mensajes de error
errorCommand DB 'El comando no existe', '$'
errorArgsStr DB 'Faltan argumentos en la funcion ' , '$'
errrorValueArgs DB 'Valores incorrectos' , '$'

errorSizeOfNumber DB 'Numero demasiado grande $'
; ------------------------------------

.CODE
start:
    main PROC
        mov ax, @data
        mov ds, ax
        mPrintMsg infoMsg
        mWaitEnter
        mStartProgram
    main ENDP
END start