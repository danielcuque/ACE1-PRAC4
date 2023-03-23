;; MACROS

; ------------------------------------
; Servirá para mostrar un mensaje en pantalla
mPrintMsg macro str
    mov DX, offset str
    mov AH, 09h
    int 21h
endm
; ------------------------------------

; ------------------------------------
mConfigData macro
    mov ax, @data
    mov ds, ax
endm
; ------------------------------------

; ------------------------------------
mWaitEnter macro
    inicio:
        mPrintMsg pressEnterMsg
        mov AH, 08h
        int 21
        cmp AL, 0Dh
        jne inicio
endm
; ------------------------------------

; ------------------------------------
mExit macro
mov AH, 4Ch
int 21h
endm
; ------------------------------------

mPrintTable macro table 
    mov DX, offset table
    mov AH, 09h
    int 21h
endm

mEmptyBuffer macro buffer
    mov SI, offset buffer
    mov CL, [SI]
    mov CH, 00
    add SI, 02 ;; Nos vamos al tercer byte del buffer que es donde empieza la informacion del teclado
    mov AL, 00
endm

