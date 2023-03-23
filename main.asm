INCLUDE macros.asm

.MODEl small
.STACK
.RADIX 16
colDimension equ 11
rowDimension equ 23
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
; ------------------------------------

; ------------------------------------
; Comandos para operaciones sobre celdas
GUARDARCommand DB 'GUARDAR'
SUMACommand DB 'SUMA'
RESTACommand DB 'RESTA'
MULTIPLICACIONCommand DB 'MULTIPLICACION'
DIVIDIRCommand DB 'DIVIDIR'
POTENCIARCommand DB 'POTENCIAR'
OLOGICOCommand DB 'OLOGICO'
YLOGICOCommand DB 'YLOGICO'
OXLOGICOCommand DB 'OXLOGICO'
NOLOGICOCommand DB 'NOLOGICO'
; ------------------------------------
; ------------------------------------
; Comandos para operaciones sobre rangos
LLENARCommand DB 'LLENAR'
PROMEDIOCommand DB 'PROMEDIO'
MINIMOCommand DB 'MINIMO'
MAXIMOCommand DB 'MAXIMO'
; ------------------------------------

; ------------------------------------
; Comandos para operaciones sobre ficheros
IMPORTARCommand DB 'IMPORTAR'
TABULADORCommand DB 09h
EXPORTARCommand DB 'EXPORTAR'
; ------------------------------------

; Creamos la información de incio, seguido de la espera de ENTER para pasar al menú
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145', 0Dh, 0Ah, '$'

; ------------------------------------
; Variables extra

pressEnterMsg DB 'Presione ENTER para continuar', 0Dh, 0Ah, '$'
; ------------------------------------

; ------------------------------------
; Tablero
colName DB '             A     B     C     D     E     F     G     H     I     J     K  ', 0Dh, 0Ah, '$'
rowName DB '   0 '
mainTable DB 253 dup(0)
; ------------------------------------

; ------------------------------------
; Mensajes de error
; ------------------------------------

.CODE
start:
main PROC
mConfigData
mPrintMsg infoMsg
mWaitEnter
mPrintMsg colName


;; Llamamos a la interrupcion del programa
mExit
main ENDP
END start