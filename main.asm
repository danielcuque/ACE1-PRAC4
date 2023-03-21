;; MACROS

.RADIX 16
.DATA
.CODE
start:
main PROC



;; Llamamos a la interrupcion del programa
exit:
mov AH, 4CH
int 21h
main ENDP
END start