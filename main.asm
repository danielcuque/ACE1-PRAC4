INCLUDE macros.asm

.MODEl small
.STACK
.RADIX 16
colDimension equ 11t ; 11 columnas
rowDimension equ 23t ; 23 filas
.DATA

; ------------------------------------
; Palabras reservadas
ENCommand DB 02, 'EN'
YCommand DB 01,'Y'
ENTRECommand DB 05,'ENTRE'
ALACommand DB 04, 'A LA'
HASTACommand DB 05,'HASTA'
DESDECommand DB 05,'DESDE'
HACIACommand DB 05,'HACIA'
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


; ------------------------------------
; Variables extra
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145', 0Dh, 0Ah, '$'
pressEnterMsg DB 'Presione ENTER para continuar', '$'
newLine DB 0Dh, 0Ah, '$'
espacio DB ' ', '$'
cero DB '0', '$'

; ------------------------------------
; Para las macros
gotten DW ?, '$'
recoveredStr DB 7 DUP('$')
; ------------------------------------
; Tablero
colName DB '      A      B      C      D      E      F      G      H      I      J      K  ', 0Dh, 0Ah, '$'
mainTable DW 253 dup(0)

; ------------------------------------

; ------------------------------------
; Buffer del teclado
keyBoard db 102 dup (0)

; ------------------------------------
; Mensajes de error
; ------------------------------------

.CODE
start:
main PROC
    mConfigData
    mPrintMsg infoMsg
    mWaitEnter
    mPrintTable
    mWaitEnter
    mExit
main ENDP
END start