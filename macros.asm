;; MACROS
; ------------------------------------
; Servirá para mostrar un mensaje en pantalla
mPrintMsg macro str
    push AX
    push DX

    mov DX, offset str
    mov AH, 09h
    int 21h

    pop DX
    pop AX
endm

mPrintPartialDirection macro str
    push AX
    push DX

    mov DX, str
    mov AH, 09h
    int 21h

    pop AX
    pop DX
endm

; ------------------------------------
mWaitEnter macro
    LOCAL wait_enter
    wait_enter:
        ; mPrintMsg pressEnterMsg
        mov AH, 08h
        int 21
        cmp AL, 0Dh
        jne wait_enter
endm
; ------------------------------------

mStartProgram macro
    LOCAL startProgram, exitProgram
    startProgram:
        mPrintTable
        mGetInputKeyboard
        mEvaluatePrompt
        cmp isRunProgram, 00h
        je startProgram
    exitProgram:
        mExit
endm

mEvaluatePrompt macro
    LOCAL startEvaluate, exeGuardar, exeImportar, exeSuma, exeSalir, endEvaluate, commandNotFound
    push AX
    push CX
    push DX
    push SI

    mov SI, offset keyBoardBuffer               ;; Cargamos a SI la dirección de memoria del buffer del teclado
    add SI, 02h

    mSkipWhiteSpace                             ;; Primero verificamos que el buffer no esté vacío
    cmp DL, 00h                                 ;; Como skipWhiteSpace carga a DL un 00h si está vacio, comparamos
    je commandNotFound

    mov DI, offset SALIRCommand
    mCompareStr
    cmp DL, 00
    jne exeSalir

    mCompareCommand GUARDARCommand
    cmp DL, 00
    jne exeGuardar

    mCompareCommand IMPORTARCommand
    cmp DL, 00
    jne exeImportar

    mCompareCommand SUMACommand
    cmp DL, 00
    jne exeGuardar

    mCompareCommand RESTACommand
    cmp DL, 00
    jne exeGuardar

    mCompareCommand MULTIPLICACIONCommand
    cmp DL, 00
    jne exeGuardar

    jmp commandNotFound

    exeSalir:
        mExit

    exeGuardar:                                     ;; Aquí podemos recibir un número o una celda
        mGuardar                                    ;; Ejecutamos un macro que nos ayuda a hacer la función de Guardar
        jmp endEvaluate                             ;; Lo devolvemos al inicio si ya se terminó el macro

    exeSuma:
        mSuma
        jmp endEvaluate
    
    exeImportar:
        mImportar
        jmp endEvaluate
    
    commandNotFound:
        mPrintMsg errorCommand
        mPrintMsg newLine
        mWaitEnter
    
    endEvaluate:
        pop SI
        pop DX
        pop CX
        pop AX
endm

mGuardar macro
    LOCAL startGuardar, errorArgs, endEvaluate

    add SI, 07                      ;; Le sumamos a la posición del buffer, el tamaño de la cadena

    mSkipWhiteSpace                 ;; Avanzamos a la siguiente palabra
    cmp DL, 00h                     ;; Mostramos mensaje de error si es el caso
    je errorArgs            

    ;; Para este punto, el punto SI, está posicionado en el primer caracter del arugmento 1 de la función
    ;; Por ejemplo, si se ingresa el comando GUARDAR 123 EN A1, el índice SI está posicionado en la dirección de memoria de 1

    startGuardar:
        mEvaluateGuardarArg1
        cmp DL, 00                  ;; Si la función retorna 00, significa que los argumentos son incorrectos
        je errorArgs                ;;

        mSkipWhiteSpace             ;; Nos saltamos los espacios
        cmp DL, 00                  
        je errorArgs

        mCompareCommand ENCommand   ;; Nos aseguramos que venga la palabra EN
        cmp DL, 00                  
        je errorArgs

        add SI, 02h                 ;; Avanzamos en el buffer
    
        mSkipWhiteSpace             ;; Nos saltamos los espacios otra vez
        cmp DL, 00
        je errorArgs

        mEvaluateGuardarArg2        ;; Evaluamos el argumento 2, que es únicamente una celda
        cmp DL, 00
        je errorArgs

        jmp endEvaluate             ;; Si todo sale bien, la función se ejecutó correctamente

    errorArgs:
        mPrintMsg errorArgsStr
        mPrintMsg GUARDARCommand
        mPrintMsg newLine
        mWaitEnter

    endEvaluate:
endm

;; Evalua el argumento 1 de la funcion GUARDAR, esta puede ser
;; NUMERO           ->  HASTA 5 DIGITOS
;; REFERENCIA       ->  CELDA DE LA A0 HASTA LA K22
;; VALOR_RETORNO    -> * (En este valor que almacena operaciones de otras funciones)

mEvaluateGuardarArg1 macro
    LOCAL start, isAsterisk, isNumber, isCell, errorEvaluateArg, end
    push AX
    push BX
    push DI

    xor AX, AX
    xor BX, BX
    mov DL, 01

    mov AX, [SI]                        ;; Guardamos en AX, el valor del caracter que está en SI
    
    start:
        cmp AL, 02Ah                    ;; Lo primero que hacemos es evaluar si el caracter es un valor de retorno
        je isAsterisk                   ;; Si sí lo es, saltamos a la etiqueta que sirve para guardar el valor

        mIsNumber
        cmp DL, 00
        jne isNumber

        mIsCell
        cmp DL, 00
        jne isCell
    
    isAsterisk:
        mov DI, offset returnValue          ;; Apuntamos a la variable que tiene el valor de retorno
        mov BX, [DI]                        ;; Copiamos en BX el valor que tiene *
        mov [guardarParametroNumero], BX    ;; Lo copiamos en la variable del arg 1
        jmp end 

    isNumber:
        mov BX, [numberGotten]
        mov [guardarParametroNumero], BX
        jmp end

    isCell:
        push SI

        mov DI, offset cellPosition
        mov AX, [DI]
        mov SI, offset mainTable
        add SI, AX
        mov BX, [SI]
        mov [guardarParametroNumero], BX
        
        pop SI
        jmp end

    errorEvaluateArg:
        mov DL, 00                          ;; 00 será para marcar error

    end:
    pop DI
    pop BX
    pop AX
endm

mPrintSIIndex macro
    push SI

        mov DX, SI
        mov AH, 09h
        int 21h

    pop SI
endm

mEvaluateGuardarArg2 macro
    LOCAL start, end, error
    push AX
    push BX

    xor AX, AX
    start:

        mIsCell 
        cmp DL, 00
        je error

        mov BX, [cellPosition]                  ;; Le cargo la posicion
        mov AX, [guardarParametroNumero]        ;; 
        mov mainTable[BX], AX

        mov DL, 01
        jmp end

    error:
        mov DL, 00
    end:
    pop BX
    pop AX
endm

mCompareCommand macro commandStr
    mov DI, offset commandStr
    mCompareStr
endm

;; Este macro identifica si la cadena de caracteres es un numero
;; Si logra identificar un número, entonces modifica la posición de SI hasta donde encuentre espacios
;; Si no logra identificar un número, no hace nada con el indice SI
;; El indice SI lleva el control del buffer

mIsCell macro
    LOCAL start, end, isNot, success
    push AX
    push BX
    push CX
    
    xor AX, AX
    
    mov BX, SI              ;; Primer caracter de la celda teoricamente, si la celda es A22, está posicionado en A

        
    start:
        mIsLetter           ;; Si empieza con letra, puede ser una dirección de celda
        cmp DL, 00          ;; Si la funcion devuelve 00 significa que no es
        je isNot

        
        mIsNumber           ;; Ahora verificamos el numero, si si es numero, avanzamos
        cmp DL, 00
        jne success         ;; Aqui ponemos jne para no toparnos con el isNot
        
    isNot:
        mov DL, 00
        jmp end

    success:
        ;; (Fila * 11 + Col) * 2
        ;; Para este punto, tenemos el valor de la fila en recoveredStr y necesitamos convertila a numero
        ;; El valor de la columna está en colValue
        
        xor DX, DX
        mov AX, 0Bh                               ;; A CX le cargo el valor de 11
        mov BX, [numberGotten]                    ;; Obtengo el valor de la Fila
        mul BX                                    ;; Aquí tengo el valor de Fila * 11
        
        mov DI, offset colValue                   ;; Obtengo la dirección del valor de la columna
        mov BX, [DI]
        add AX, BX                                ;; Le sumamos el valor de la columna

        mov BX, 02h                               ;; Le cargo a BX el valor de 02 para multiplicarlo después
        mul BX

        cmp AX, 01FAh
        ja isNot

        mov DI, offset cellPosition               ;; Obtenemos la posición de memoria de la variable que guarda la posición del tablero
        mov [DI], AX                              ;; Le asignamos el valor calculado de AX
        mov DL, 01                                ;; si todo sale bien, devolvemos 01
    
    end:

    pop CX
    pop BX
    pop AX
endm

mIsLetter macro
    LOCAL start, end, success, isNot
    push BX
    push AX

    mov DL, 01          ;; Cargamos inicialmente 01 indicando que sí es letra
    xor CX, CX          ;; Limpiamos  CX
    
    mov BX, SI          ;; Cargamos la direccion de memoria de SI que apunta al buffer
    start:
        mov AL, [BX]    ;; Cargamos el valor que se encuentra actualmente en el buffer

        cmp AL, 041h    ;; Si es menor a 41 no es letra
        jb isNot

        cmp AL, 04Bh    ;; Si es mayor a 04b tampoco es letra
        ja isNot
        
    success:            
        inc SI                  ;; Si llega hasta acá, entonces aumenta el valor de SI en el buffer
        sub AL, 41h             ;; Le restamos el ASCII que indica el valor de la columna
        mov [colValue], AL      ;; Movemos ese valor a una variable en memoria
        jmp end                 ;; Nos vamos al final
    isNot:
        mov DL, 00
    end:
    pop AX
    pop BX
endm

mIsNumber macro
    LOCAL start, createNumber, success, isNot, end, generateNumber
    push AX
    push BX
    push CX
    push DI
                
    mov CX, 00              ;; Este llevara el control de cuantas posiciones aumentar en SI en caso de que sí sea necesario
    mov BX, SI              ;; Copiamos la direccion de memoria de SI para no modificar SI si no es necesario
    mov DL, 01h             ;; Cargamos en un inicio a DL con 01 para indicar que es verdadero
    start:
        mov AL, [BX]
    
        cmp AL, 20h         ;; Si llegamos al espacio y todo está correcto, entonces generamos el numero
        je success

        cmp AL, 00h          ;; Comparamos que si es caracter nulo, llegamos al final
        je success

        cmp AL, 0Dh         ;; O comparamos que no sea un valor de retorno
        je success
 
        cmp AL, 30h         ;; Comparamos que el ASCII no sea menor al ASCII DE 1
        jb isNot

        cmp AL, 39h         ;; Comparamos que el ASCII no sea mayor al ASCII de 9
        ja isNot

        inc BX
        inc CX              ;; Incrementamos CX para poder hacer un loop y guardar el número recuperado en formato string
        jmp start

    isNot:
        mov DL, 00h         ;; Si no es número, entonces seteamos a DL como 0 y lo retornarmos
        jmp end

    success:
        xor AX, AX                          ;; Limpiamos a AX
        mov BX, offset recoveredStr      ;; Movemos la direccion de memoria del número a recuperar para insertarle datos
        
        cmp CX, 07h                         ;; Si el número es mayor a 5, significa que no es válido
        jl generateNumber                   ;; Si es menor a 5, entonces recuperamos el número

        mPrintMsg errorSizeOfNumber         ;; si no es válido, lo devolvemos a isNot    
        jmp isNot
        
        generateNumber:
            mResetrecoveredStr

            createNumber:
                mov AL, [SI]                    ;; Movemos el valor que se encuentra en SI a AX, por ejemplo, si en Si está 1, entonces lo movemos
                mov [BX], AL                    ;; Le insertamos ese valor a la variable de recoveredStr
                inc BX                          ;; Incrementamos DI
                inc SI                          ;; Incrementamos SI, para avanzar en el buffer
                loop createNumber               ;; Ciclamos
                mStringToNum                    ;; Convertimos el String a número
    end:
    pop DI
    pop CX
    pop BX
    pop AX
endm

mResetrecoveredStr macro
    LOCAL start
    push CX
    push BX
    push AX

    xor CX, CX
    mov CL, 07
    mov BX, offset recoveredStr
    mov AL, 24h

    start:
        mov [BX], AL
        inc BX
    loop start

    pop AX
    pop BX
    pop CX
endm

;; Pasos para importar
;; 1. Avanzar con el buffer la cantidad de letras que tiene la palabra IMPORTAR
;; 2. Saltarse los espacios para llegar al nombre del archivo
;; 3. Leer el archivo
;; 4. Leer la frase SEPARADO POR TABULADORES

mImportar macro
    LOCAL start, readFileName, end, fail, success
    push BX
    push AX
    push DI

    add SI, 08h                         ;; Aumentamos en 8 posiciones el índice SI que lleva el control del buffer del teclado
                                        ;; Para este punto, SI está en la posición del primer espacio después
                                        ;; del comando IMPORTAR

    mSkipWhiteSpace                     ;; Nos saltamos el espacio en blanco para llegar al nombre del archivo
    cmp DL, 00                          ;; Si el buffer no es nulo, entonces continuamos
    je fail

    mResetVarWithZero fileName                  ;; Reiniciamos el nombre del archivo
    lea BX, fileName                    ;; Obtenemos la direccion de memoria del archivo

    readFileName:
        mov AL, [SI]

        cmp AL, 00                     ;; Significa que al comando le faltan argumentos
        je fail

        cmp AL, 20h                     ;; Si es un espacio, significa que ya terminamos de leer el nombre
        je start                        ;; Deja a SI en el primer espacio después del nombre del archivo

        mov [BX], AL                    ;; Obtenemos el valor que está en SI y lo metemos al nombre del archivo

        inc BX                          ;; Incrementamos BX para avanzar a la siguiente posición
        inc SI                          ;; Incrementamos SI para avanzar en el buffer
        jmp readFileName 

    start:

        mSkipWhiteSpace                 ;; Nos saltamos los espacios para poder avanzar a la ultima declaración de los comandos
        cmp DL, 00
        je fail

        ; mCompareCommand PORTABCommand   ;; Comparamos que el comando esté completo
        ; cmp DL, 00
        ; je fail

        ; add SI, 011h                    ;; Aumentamos el contador de SI en 11 que es la cantida de palabras que tiene 'SEPARADO POR TAB'

        mReadFile                       ;; Cargamos la información del archivo al buffer
        jmp end

    fail:
        mPrintMsg newLine
        mPrintMsg errorArgsStr
        mPrintMsg IMPORTARCommand
        mPrintMsg newLine
        mWaitEnter

    end:
    pop DI
    pop AX
    pop BX
endm

mResetVar macro var
    LOCAL start
    push CX
    push AX
    push DI

    lea DI, var
    mov CX, sizeof var
    mov AL, 024h
    start:
        mov [DI], AL
        inc DI
    loop start

    pop DI
    pop AX
    pop CX
endm

mResetVarWithZero macro var
    LOCAL start
    push CX
    push AX
    push DI

    lea DI, var
    mov CX, sizeof var
    mov AL, 00h
    start:
        mov [DI], AL
        inc DI
    loop start

    pop DI
    pop AX
    pop CX
endm

mReadFile macro
    LOCAL start, end, errorToOpen, errorToClose, success
    push AX
    push BX
    push CX

    xor CX, CX

    mov DX, offset fileName             ;; Obtenemos la posicion de memoria del nombre del archivo

    mov AL, 00                          ;; Modo de lectura
    mov AH, 3dh                         ;; Función para abrir el archivo
    int 21h                             ;; Provocamos la interrupción
    jc errorToOpen                      ;; Si el archivo no se puede abrir bien, entonces marcamos error

    mov [fileHandler], AX               ;; Cargamos el handle a una variable

    mReadHeadersCsv                     ;; Leemos los headers
    cmp DL, 00                          ;; Si devuelve error, entonces no continuamos
    je errorHeaders

    mProcessCell
    cmp DL, 00
    je errorCells
    
    ;; En esta sección ya podemos usar la info cargada al buffer
    mov DL, 01
    jmp success

    errorToOpen:
        mPrintMsg errorOpenFile         ;; Mostramos un mensaje de error de que no se pudo abrir el file
        jmp fail                        ;; Saltamos a file para poner a DL == 0
    
    errorToClose:
        mPrintMsg errorCloseFile        ;; Mostramos un error que no se pudo cerrar el archivo
    fail:
        mov DL, 00                      ;; Marcamos a DL con 0 para indicar que no se leyó bien el archivo
        mWaitEnter
        jmp end

    errorHeaders:                       ;; Para este caso si es necesario cerrar el archivo, ya que los las columnas están mal introducidas pero el archivo sí se abrió
        mPrintMsg newLine               ;; Mostramos el error en una nueva línea
        mPrintMsg errorHeadersStr       ;; Mostramos error de ingreso de columnas
        jmp fail                        ;; Seteamos a DL como error (00)
    
    errorCells:
        mPrintMsg newLine
        mPrintMsg errorCellsStr
        jmp fail
    
    success:
        mov DL, 01                      ;; Si todo sale bien, marcamos a DL como 01

    closeFile:
        mov BX, [fileHandler]           ;; Para cerrar el archivo, debemos de devolver el valor del handler a BX   
        mov AH, 03Eh                    ;; Cargamos a AH para hacer la interrupción de cerrar archivo
        int 21h                         ;; Cerramos el archivo
        jc errorToClose                 ;; Mandamos el error si el carry flag se activa

    end:                   
        pop CX
        pop BX
        pop AX
endm

mPrintCarryFlag macro
    push BX
    mov BX, 00
    mov [numberGotten], BX
    mov byte ptr [numberGotten], AL
    mPrintNumberConverted
    pop BX
endm

mReadHeadersCsv macro
    LOCAL start, changeChar, showHeader, compareNextChar, endOfLine, continue, end, fail, success
    push DI
    push AX

    mPrintMsg newLine               ;; Imprimimos una nueva línea

    mResetVar fileLineBuffer        ;; Reiniciamos nuestro buffer que va a contener las líneas
    lea DI, fileLineBuffer          ;; Cargamos la direccion donde se van a guardar los headers del CSV

    mov [indexForCol], 00h

    start:
        mov BX, [fileHandler]       ;; Le cargamos el fileHandler
        mov CX, 1                   ;; Vamos a leer byte a byte, por lo que CX es 1
        mov DX, DI                  ;; Cargamos a DX la direccion donde se va a almacenar los headers

        mov AH, 3Fh                 ;; Con 3Fh empezamos a leer la información del archivo     
        int 21                      
        jc fail                     ;; Si el carry se carga, significa que hubo algún error
        
        mov AL, [DI]                ;; Pasamos el caracter de los headers a AL, 
                                    ;; Lo hacemos en AL, porque los caracteres son solo de 1 byte    

        cmp AL, 0Dh                 ;; Si llegamos al retorno de carro, significa que llegamos al final de línea
        je success

        cmp AL, 00h                 ;; También podemos indicar que si encontró un caracter nulo, se terminó la fila
        je success

        cmp AL, 0Ah                 ;; O si encuentra un salto de línea, significa que terminó
        je success

        cmp AL, 02Ch                ;; 02C = COMA (USAR ASCII TAB)
        je changeChar               ;; Si encuentra un tabulador, entonces lo reemplazamos con un signo de dolar para poder imprimirlo

        jmp continue                ;; Si no es ninguna de las anteriores, entonces seguimos iterando hasta terminar la línea

        changeChar:                 
            mov AL, 024h            ;; En este espacio cargamos los tabuladores como signo $, en lugar de su caracter de tab, en el buffer
            
        continue:
            mov [DI], AL            ;; Continuamos iterando, y guardamos en el buffer de headers el texto
            inc DI                  ;; Incrementamos DI para avanzar en el texto de la línea
            jmp start               ;; Repetimos lo mismo
    
    success:
        lea DI, fileLineBuffer          ;; Si todo salió bien, regresamos a DI a la posición incial del buffer para poder sacar la posición de la columna

        showHeader:
            
            mPrintMsg letraColumna          ;; Imprimimos el mensaje para preguntar en qué columna quiere que se guarde el header
            mPrintPartialDirection DI       ;; Imprimimos la direccion de memoria que contiene los headers, como los tabs se cambiaron por dolares
                                            ;; Entonces se imprime header por header
            mRequestColumn                  ;; Luego le solicitamos al usuario la columna
            cmp DL, 00                      ;; Si devuelve un valor erroneo, entonces nos vamos a fail
            je fail

            push DI                         ;; Guardamos los valores de DI y BX para poder usarlo
            push SI
            push BX
            push AX

                xor BX, BX
                xor AX, AX

                mov BL, [indexForCol]
                mov AL, [colValue]
                mov bufferColumnsPosition[BX], AL

                inc BL
                mov [indexForCol], BL

            pop AX
            pop BX                                  ;; Devolvemos sus valores a como estaban
            pop SI
            pop DI
        
            mPrintMsg newLine                       ;; Mostramos una nueva línea

        advanceChar:
            mov AL, [DI]                            ;; En este punto, DI está posicionado en la primera letra del header
                                                    ;; Por ejemplo si el header es (tarea 1$carnet)
                                                    ;; en la primera iteracion va a estar en 't'
            
            cmp AL, 024h                            ;; Si llegamos al dolar, entonces nos vamos a compareNextChar para asegurarnos que llegamos al final de la línea de headers
            je compareNextChar                      

            inc DI                                  ;; Si fuese una letra, entonces seguimos avanzando en DI
            jmp advanceChar

        compareNextChar:
            mov AL, [DI + 1]                        ;; Preguntamos si DI + 1 es un $, si sí es un dolar, significa que es el fin de línea
            cmp AL, 024h    

            je endOfLine
            inc DI                                  ;; Si es una letra, entonces mostramos nuevamente el header que le sigue, repetimos hasta llegar al final
            
            jmp showHeader              
            
    endOfLine:
        mov BX,[fileHandler]                        ;; Leemos un caracter extra para avanzar el CR y el LF
        mov CX, 1
        mov DX, DI
        
        mov AH, 3Fh
        int 21
        jc fail

        mov DL, 01h                                 ;; Devolvemos mensaje de éxito
        jmp end

    fail:
        mov DL, 00h
    end:
    pop AX
    pop DI
endm



;; DL == 0, no existe la columna
;; DL == 1, es correcta
mRequestColumn macro
    LOCAL start, fail, success, end
    push AX
    push CX
    push SI

    mEmptyBuffer bufferGetPosColumn     ;; Vaciamos el buffer para poder leer el valor de la columna

    mPrintMsg colonChar                 

    lea DX, bufferGetPosColumn          ;; Nos posicionamos en la memoria del buffer de la columna
    mov AH, 0Ah                         ;; Provocamos la interrupción
    int 21h
    
    add DX, 02h                         ;; Avanzamos 2 bytes para poder leer el caracter
    mov SI, DX                          ;; Cargamos ese caracter a SI

    mIsLetter
    cmp DL, 00
    je fail

    success:
        mov DL, 01
        jmp end
    fail:
        mov DL, 00
    end:
    pop SI
    pop CX
    pop AX

endm

mPrintOneChar macro char
    LOCAL start
    push DI
    lea DI, bufferPrintOneChar
    mov [DI], char
    mPrintMsg bufferPrintOneChar
    pop DI
endm

;; Si DX devuelve 1, significa que se leyó bien la línea
;; Si DX devuelve 2, significa que se llegó al final del archivo

mGetLineFromCsv macro
    LOCAL start, end, fail, endOfFile, endOfLine

    push AX
    push DI

    mResetVar fileLineBuffer        ;; Reiniciamos nuestro buffer que va a contener las líneas
    lea DI, fileLineBuffer

    start:

        mov BX, [fileHandler]       ;; Movemos a BX le atributo del handler
        mov CX, 1                   ;; Leemos caracter por caracter
        mov DX, DI

        mov AH, 3Fh                 ;; Usamos la interrupción para leer el archivo
        int 21h                     ;; 
        jc fail                     ;; Si no se puede leer el archivo, nos saltamos a fail

        cmp AX, 0
        je endOfFile

        mov AL, [DI]                ;;

        cmp AL, 0Dh                 ;; Si llegamos al retorno de carro, significa que llegamos al final de línea
        je endOfLine                ;; Si encuentra un retorno de carro, signifca que terminó la línea

        cmp AL, 00h                 ;; También podemos indicar que si encontró un caracter nulo, se terminó la fila
        je endOfLine

        cmp AL, 0Ah                 ;; O si encuentra un salto de línea, significa que terminó
        je endOfLine

        mov [DI], AL
        inc DI
        jmp start

    endOfLine:
        mov BX,[fileHandler]
        mov CX, 1
        mov DX, DI
        
        mov AH, 3Fh
        int 21
        jc fail

        mov DL, 01h
        jmp end
    endOfFile:
        mov DL, 02h
        jmp end
    fail:
        mov DL, 01h
    end:

        pop DI
        pop AX
endm

mProcessCell macro
    LOCAL start, end, endOfFile, continue, proccesPosition, fail
    push SI
    push CX

    start:
        mGetLineFromCsv
        mov CX, 00                 ;; CX nos va a servir para poder saber en qué posición se debe insertar el numero

        lea SI, fileLineBuffer

        proccesPosition:

            mIsNumberForCell        ;; Preguntamos si la celda es un número
            mPrintPartialDirection SI
            mWaitEnter

            cmp DL, 00              ;; O si devuelve que no es un número, entonces marcamos error
            je fail
            
            ;; Si todo está bien, entonces vamos a utilizar el número
            
            cmp DL, 02              ;; Avanza de posición hasta que termina con $$$ 
            je continue             ;; Y evaluamos la siguiente línea

            jmp proccesPosition

        continue:
            cmp DL, 02h
            je endOfFile
            jmp start

    endOfFile:
        mov DL, 01
        jmp end

    fail:
        mov DL, 00

    end:
        pop CX
        pop SI
endm

mTruncateFile macro
    LOCAL failed
    push CX

    mov CX, 0
    lea DX, offset 
    mov AH, 03C

    int 21h

    jc failed

    mov fileHandler, AX
    jmp end:

    failed:
        

    end:
    pop CX
endm

mShowTest macro
    mPrintMsg testStr
    mWaitEnter
endm

;; Este macro avanza en la posición del buffer en el que se carga
mIsNumberForCell macro
    LOCAL start, createNumber, success, isNot, end, generateNumber
    push AX
    push BX
    push CX
    push DI
                
    mov CX, 00              ;; Este llevara el control de cuantas posiciones aumentar en SI en caso de que sí sea necesario
    mov BX, SI              ;; Copiamos la direccion de memoria de SI para no modificar SI si no es necesario
    mov DL, 01h             ;; Cargamos en un inicio a DL con 01 para indicar que es verdadero
   
    start:
        
        mov AL, [BX]
    
        cmp AL, 2Ch          ;; Si llegamos a la coma y todo está correcto, entonces generamos el numero
        je success

        cmp AL, 24h          ;; Comparamos que si es caracter nulo, llegamos al final
        je endOfBuffer

        cmp AL, 0Dh          ;; O comparamos que no sea un valor de retorno
        je success
 
        cmp AL, 30h          ;; Comparamos que el ASCII no sea menor al ASCII DE 1
        jb isNot

        cmp AL, 39h          ;; Comparamos que el ASCII no sea mayor al ASCII de 9
        ja isNot

        inc BX
        inc CX               ;; Incrementamos CX para poder hacer un loop y guardar el número recuperado en formato string
        jmp start

    isNot:
        mov DL, 00h          ;; Si no es número, entonces seteamos a DL como 0 y lo retornarmos
        jmp end

    endOfBuffer:
        mov DL, 02h          ;; El codigo 02 será para decir que el buffer terminó
        
    success:
        xor AX, AX                          ;; Limpiamos a AX
        mov BX, offset recoveredStr      ;; Movemos la direccion de memoria del número a recuperar para insertarle datos
        
        cmp CX, 07h                         ;; Si el número es mayor a 5, significa que no es válido
        jl generateNumber                   ;; Si es menor a 5, entonces recuperamos el número

        mPrintMsg errorSizeOfNumber         ;; si no es válido, lo devolvemos a isNot    
        jmp isNot
        
        generateNumber:

            mResetrecoveredStr

            createNumber:
                
                mov AL, [SI]                    ;; Movemos el valor que se encuentra en SI a AX, por ejemplo, si en Si está 1, entonces lo movemos
                mov [BX], AL                    ;; Le insertamos ese valor a la variable de recoveredStr
                inc BX                          ;; Incrementamos DI
                inc SI                          ;; Incrementamos SI, para avanzar en el buffer
                loop createNumber               ;; Ciclamos
            inc SI
            mStringToNum                    ;; Convertimos el String a número

    end:
        pop DI
        pop CX
        pop BX
        pop AX
endm



mSuma macro

endm

;; Este macro avanza el macro hasta encontrar una palabra
;; SI es la posicion del buffer
;; DL es 00 si se terminó el buffer
;; DL es 01 si es una palabra
;; Si el buffer encuentra una palabra, deja posicionado a SI en la direccion que tiene el caracter

mSkipWhiteSpace macro
    LOCAL start, goWord, isWord, endBuffer, endSkip
    mov DX, offset keyBoardBuffer
    add DX, 102h

    start:
        mov AL, [SI]                ;; Copiamos el valor que se encuentra en SI para comparar

        cmp AL, 20h                 ;; Si el caracter es un ESPACIO entonces seguimos recorriendo
        je goWord

        cmp AL, 0Dh                 ;; Si el caracter es un CR entonces seguimos recorriendo
        je goWord

        cmp AL, 00h                 ;; Si el caracter es nulo, entonces significa que el buffer acabó
        je endBuffer                
        jmp isWord                  ;; Si el indice SI no es ninguno, entonces significa que es una palabra
        
    goWord:
        inc SI                      ;; Incrementamos SI para poder seguir a la siguiente posición y dejar posicionado en SI el caracter diferente de nulo
        cmp SI, DX                  ;; Si el puntero SI tiene el tamaño de 256, significa que llegamos al final del buffer
        jae endBuffer               
        jmp start                   ;; De lo contrario, seguimos iterando
    endBuffer:
        mov DL, 00h                 ;; Carga 00h para indicar que el buffer se terminó
        jmp endSkip         
    isWord: 
        mov DL, 01h                 ;; Si es un caracter, entonces DL es 01
    endSkip:
endm

;; Este macro necesita un valor en SI y DI
;; SI el offset de la cadena A, la cadena apunta al tamaño de la misma
;; DI al offset de la cadena B que se quiere comparar con A
;; CX guarda el tamaño de una de las cadenas
;; DL guarda si son iguales
;; DL == 0 si no son iguales
;; DL == 1 si sí son iguales
mCompareStr macro
    LOCAL compareLoop, equal, notEqual, endCompare
    push AX
    push BX
    push SI
    push DI

    mov DX, 00h       
    mov CL, [DI]
    inc DI
    compareLoop:
        mov AL, [DI]
        mov BL, [SI]
        cmp AL, BL
        jne endCompare
        inc DI
        inc SI
        loop compareLoop
    
    mov DL, 01

    endCompare:
    pop DI
    pop SI
    pop BX
    pop AX
endm


; ------------------------------------
mNumToString macro
    LOCAL extract, store, continueStore, addZeroToLeft, negative
    ;; Protegemos nuestros registros
    push AX
    push BX
    push CX
    push DX
    push SI
    push DI

    mov BX, 0Ah                             ;; Cargamos a BX con 10
    xor CX, CX                              ;; Limpiamos a cx
    mov AX, numberGotten                    ;; Le cargamos a AX el valor del numero que queremos convertir

    extract:
        xor DX, DX                          ;; Limpio a DX
        div BX                              ;; Obtengo el residuo de la division 
        add DX, 30h                         ;; Le sumo a DX el valor de 30 hexa para que el residuo se mueva hacia la posicion del no. ASCII
        push DX                             ;; Meto ese valor de DX en el top de la pila
        inc CX                              ;; Incremento a CX en 1 para asi poder ejecutar el loop
        cmp AX, 0                           ;; Si ax no es 0, entonces sigo ejecutando el bloque de codigo
        jne extract

    ;; En esta sección vamos a añadir los 0s que faltan al numero hacia la izquierda
    push DX                                 ;; Primero guardamos la informacion de DX para poder utilizarlo como registro de cuantos 0s faltan

    mov SI, 0                               ;; Colocamos a SI

    mov DX, 06h                             ;; Inicialmente serán 6, ya que si recibimos el valor de 1, entonces queremos que se muestre como 000001
    sub DX, CX                              ;; El valor de CX nos ayudará a saber el tamaño del numero, para el caso de 1, será 6 - 1 = 5
                                            ;; Por lo que agregaremos 5 0s
    mov [counterToGetIndexGotten], DX       ;; Muevo el valor en el que se quedó DX para poder correrme a esa posición de la cadena

    addZeroToLeft:
        cmp DX, 00h                         ;; Comparo si DX no es 0, si es cero, significa que el num es de 5 cifras
        je continueStore                    ;; Saltamos a otra etiqueta
        mov recoveredStr[SI], 30h           ;; Si no es asi, entonces modificamos la etiqueta recovered Str donde insertará los 0s que hagan falta
        dec DX                              ;; Decrementamos a DX para que poder acabar el ciclo
        inc SI                              ;; Incrementamos SI para avanzar en la cadena
        jmp addZeroToLeft                   ;; Creamos un pseudo loop para insertar los 0s

    continueStore:
        pop DX                              ;; Sacamos el valor de DX que estaba en el top para poder regresarlo a como estaba
        mov SI, 0                           ;; Inicializo a SI en 0
        add SI, [counterToGetIndexGotten]   ;; Nos movemos con SI, hacia el numero en memoria que le corresponde a la cadena

    ;; TODO: Convertir a negativo

    store:
        pop DX                              ;; Despues tengo que hacer la misma cantidad de pops que de push, e ir sacando los valores de DX 
        mov recoveredStr[SI], DL            ;; El resultado de las operaciones se almacenan en la parte baja de DX por lo que 
                                            ;; usamos D low (DL) 
        inc SI                              ;; Incrementamos en 1 la dirección de memoria para acceder al byte que le corresponde int SI += 1
        loop store                          ;; Se ejecuta el loop hasta que CX llegue a 0
    
    ; Regresamos sus registros al estado en el que estaban
    pop DI
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
endm 
; ------------------------------------

; ------------------------------------
;
mStringToNum macro
    LOCAL nextNum, end
    ;; Protejo los registros que voy a usar en el macros
    push AX
    push BX
    push CX
    push DX
    push SI

    xor SI, SI ; Limpio SI
    xor AX, AX ; Limpio AX
    xor DX, DX ; Limpio DX
    mov BX, 0Ah ; Cargo a BX con 10 decimal
    
    nextNum:
        mul BX 
        mov DL, recoveredStr[SI]
        sub DL, 30h
        add AX, DX
        inc SI
        mov DL, recoveredStr[SI]
        cmp DL, 24h
        je end
        jmp nextNum
    end:
        mov [numberGotten], AX

    ;; Protejo los registros que voy a usar en el macros
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
endm
; ------------------------------------

; ------------------------------------
mPrintTable macro
    LOCAL printRows, printCols
    push BX
    push CX
    push DX
    push DI
    push SI

    mPrintMsg colName

    mov SI, offset mainTable                    ;; Obtenemos la direccion de memoria del tablero
    mov BX, 00h                                 ;; Colocamos en 0 a BX para llevar el registro del numero de filas

    mov CX, 17h                                 ;; Colocamos en CX el numero de filas

    printRows:
        mov [numberGotten], BX                  ;; Cargamos a numberGotten con el registro contador, en este caso es BX
        mNumToString                            ; Usamos el macro para convertir el número que se almacenó en numberGotten y covertilo a str
        
        push DX
        mov DX, offset recoveredStr
        add DX, 04h
        mPrintPartialDirection DX           ;; Le mandamos esa dirección de memoria a la macro
        mPrintMsg espacio                   ;; Le damos un espacio para separarlo de la cuadricula
        pop DX

        push CX                             ;; Protegemos nuestro registro CX que guarda el contador para imprimir las filas
        mov CX, 0Bh                         ;; Lo inicializamos en B = 11 dec  para imprimir las columnas
        printCols:
            mov DI, offset numberGotten     ;; Movemos la direccion de memoria del numero obtenido
            mov DX, [SI]                    ;; Le cargamos a DX el valor de la posición del tablero
            mov [DI], DX                    ;; Movemos el valor que se encuentra en la posición DI del arreglo 
            mPrintNumberConverted           ;; Imprimimos el valor de la celda
            add SI, 02h                     ;; Al ser una DW, es necesario avanzar 2 bytes
            loop printCols                  ;; Ciclamos hasta que el contador llegue a 0 indicando que ya se imprimieron las columnas

            pop CX                          ;; Regresamos el valor del contador de las filas a su estado original
            inc BX                          ;; Incrementamos en 1 el contador que lleva el registro de las filas
            dec CX                          ;; Incrementamos CX para poder recorrer todo el arreglo
            cmp CX, 00h                     ;; Si CX no es cero, entones que siga imprimiendo filas
            jne printRows                   ;; Regresamos a imprimir una nueva fila
    
    ;; Regresamos a su estado original los registros
    pop SI
    pop DI
    pop DX
    pop CX
    pop BX
endm
; ------------------------------------

mPrintNumberConverted macro
    mNumToString 
    mPrintMsg recoveredStr
    mPrintMsg espacio
endm

; ------------------------------------
mEmptyBuffer macro buffer
    LOCAL emptyBuffer
    push SI
    push CX
    push AX

    mov SI, offset buffer
    mov CL, [SI]
    mov CH, 00
    add SI, 02

    mov AL, 24h

    emptyBuffer:
        mov [SI], AL
        inc SI
        loop emptyBuffer

    pop DX
    pop CX
    pop SI
endm

mEmptyBufferWithZero macro buffer
    LOCAL emptyBuffer
    push SI
    push CX
    push AX

    mov SI, offset buffer
    mov CL, [SI]
    mov CH, 00
    add SI, 02

    mov AL, 00h

    emptyBuffer:
        mov [SI], AL
        inc SI
        loop emptyBuffer

    pop DX
    pop CX
    pop SI
endm


; ------------------------------------
; Macro para leer con el teclado y guardarlo en el buffer del teclado
mGetInputKeyboard macro
    push DX
    push AX
    push CX

    mEmptyBuffer keyBoardBuffer

    mPrintMsg colonChar

    mov DX, offset keyBoardBuffer
    mov AH, 0Ah
    int 21h

    pop CX
    pop AX
    pop DX
endm
; ------------------------------------
; ------------------------------------
; Macro para salir del programa
mExit macro
    mov AH, 4Ch ;4C en hexa servirá para cargar y generar la int del programa
    int 21h
endm
; ------------------------------------