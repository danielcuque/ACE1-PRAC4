;; MACROS

printMsg macro str
    mov DX, offset str
    mov AH, 09h
    int 21h
endm

.MODEl small
.STACK 100h
.RADIX 16
colDimension equ 11
rowDimension equ 24
.DATA

mainTable DB dup(0)

.CODE
start:
main PROC



;; Llamamos a la interrupcion del programa
exit:
mov AH, 4CH
int 21h
main ENDP
END start