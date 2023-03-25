INCLUDE macros.asm

.MODEl small
.STACK
.RADIX 16
colDimension equ 11t ; 11 columnas
rowDimension equ 23t ; 23 filas
.DATA

; ------------------------------------
; Palabras reservadas
ENCommand DB 'EN'
YCommand DB 'Y'
ENTRECommand DB 'ENTRE'
ALACommand DB 'A LA'
HASTACommand DB 'HASTA'
DESDECommand DB 'DESDE'
HACIACommand DB 'HACIA'
SALIRCommand DB 'SALIR'
PORTABCommand DB 'SEPARADOR POR TABULADOR'
; ------------------------------------

; ------------------------------------
; Comandos para operaciones sobre celdas
GUARDARCommand DB 07,'GUARDAR'
SUMACommand DB 04,'SUMA'
RESTACommand DB '05,RESTA'
MULTIPLICACIONCommand DB 0Eh,'MULTIPLICACION'
DIVIDIRCommand DB 07,'DIVIDIR'
POTENCIARCommand DB 09,'POTENCIAR'
OLOGICOCommand DB 07,'OLOGICO'
YLOGICOCommand DB 07,'YLOGICO'
OXLOGICOCommand DB 09,'OXLOGICO'
NOLOGICOCommand DB 09,'NOLOGICO'
; ------------------------------------
; ------------------------------------
; Comandos para operaciones sobre rangos
LLENARCommand DB 06,'LLENAR'
PROMEDIOCommand DB 08,'PROMEDIO'
MINIMOCommand DB 06,'MINIMO'
MAXIMOCommand DB 06,'MAXIMO'
; ------------------------------------

; ------------------------------------
; Comandos para operaciones sobre ficheros
IMPORTARCommand DB 'IMPORTAR'
TABULADORCommand DB 09h
EXPORTARCommand DB 'EXPORTAR'
; ------------------------------------
; Variables para utilizarlas como auxiliares para comparar la evaluacion de comandos
isStringEqual DB 00h  ;; El estado 0 representa que no son iguales 

; ------------------------------------
; Variables extra
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145', 0Dh, 0Ah, '$'
pressEnterMsg DB 'Presione ENTER para continuar', '$'
newLine DB 0Dh, 0Ah, '$'
espacio DB ' ', '$'
counterToGetIndexGotten DW 0 ;; Esta variable me servirá para poder hacer el corrimiento de SI e insertar el numero donde corresponde
; ------------------------------------
; Para las macros
numberGotten DW ?, '$'
recoveredStr DB 7 DUP('$')
; ------------------------------------
; Tablero
colName DB 0Dh,'      A      B      C      D      E      F      G      H      I      J      K  ', 0Dh, 0Ah, '$'
mainTable DW 253 dup(0)

; ------------------------------------
; Variables para leer el archivo de entrada
fileNameBuffer DB 100h dup(0)

; ------------------------------------
; Buffer del teclado
keyBoardBuffer db 100h dup (0ff,0)
colonChar db ': $'
isRunProgram DB 00h
; ------------------------------------
; Mensajes de error
errorCommand DB 'El comando no existe', '$'
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