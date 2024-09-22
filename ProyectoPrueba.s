    .data
text:   .asciz "este es un texto de prueba con palabras repetidas este es un texto"

    .text
    .global _start

_start:
    LDR R0, =text          @ Cargar la dirección del texto
    LDR R1, =0x500         @ Cargar la dirección de memoria donde se almacenarán las palabras (0x500)
    LDR R2, =0x300         @ Cargar la dirección de memoria donde se almacenarán los contadores (0x300)
    MOV R3, #0             @ Inicializar el índice de palabras únicas encontradas
    MOV R8, R1             @ Almacena la dirección inicial de 'words'
    MOV R9, R1             @ Almacena la dirección actual para nueva palabra

loop:
    LDRB R4, [R0], #1      @ Leer un byte del texto
    CMP R4, #0             @ Comprobar si es el final del texto
    BEQ EndProgram         @ Saltar a EndProgram si es el final

    CMP R4, #' '           @ Comparar con espacio (palabra delimitada)
    BEQ word_end           @ Saltar al final de la palabra

    STRB R4, [R9], #1      @ Almacenar el carácter en la posición actual de la palabra
    ADD R9, R9, #1         @ Mover al siguiente byte para la misma palabra
    B loop

word_end:
    @ Terminar la palabra actual
    MOV R5, #0             @ Colocar terminador de cadena
    STRB R5, [R9], #1

    @ Comprobar si la palabra ya está almacenada
    MOV R6, #0             @ Índice para palabras almacenadas
    MOV R7, R8             @ Dirección inicial de 'words'
check_word:
    CMP R6, R3             @ Comparar con el número de palabras únicas encontradas
    BEQ new_word           @ Si no se encuentra, es una nueva palabra

    MOV R0, R7             @ Dirección de la primera palabra
    MOV R1, R8             @ Dirección de la nueva palabra
    BL compare_words       @ Llamar a la subrutina de comparación
    CMP R0, #1             @ Verificar si las palabras son iguales
    BEQ increment_count    @ Si son iguales, incrementar el conteo
    ADD R6, #1             @ Incrementar índice
    ADD R7, #64            @ Mover a la siguiente palabra
    B check_word

increment_count:
    ADD R9, R2, R6         @ Calcular la dirección del conteo a partir de 0x300
    LDRB R10, [R9]         @ Cargar el conteo actual de la palabra
    ADD R10, R10, #1       @ Incrementar el conteo
    STRB R10, [R9]         @ Guardar el nuevo conteo
    B continue_loop

new_word:
    ADD R9, R2, R3         @ Calcular la dirección de la nueva palabra en 0x300
    MOV R7, #1
    STRB R7, [R9]          @ Almacenar el conteo inicial de la palabra
    ADD R3, R3, #1         @ Incrementar el número de palabras únicas

    ADD R9, R8, R3, LSL #6 @ Mover `R9` para apuntar al espacio para la siguiente palabra única
    B continue_loop

continue_loop:
    B loop



@ Subrutina para comparar dos palabras
compare_words:
    PUSH {R4, R5}          @ Guardar registros que se van a usar
    MOV R2, R0             @ R2 = dirección de la primera palabra
    MOV R3, R1             @ R3 = dirección de la segunda palabra

compare_loop:
    LDRB R4, [R2], #1      @ Leer byte de la primera palabra
    LDRB R5, [R3], #1      @ Leer byte de la segunda palabra
    CMP R4, R5             @ Comparar los bytes

    BNE words_not_equal    @ Si son diferentes, las palabras no son iguales
    CMP R4, #0             @ Comprobar si es el final de la primera palabra
    BEQ words_equal        @ Si es el final de la palabra y coinciden, son iguales

    B compare_loop         @ Continuar comparando

words_not_equal:
    MOV R0, #0             @ Las palabras no son iguales, retornar 0
    B compare_end

words_equal:
    MOV R0, #1             @ Las palabras son iguales, retornar 1

compare_end:
    POP {R4, R5}           @ Restaurar registros
    BX LR                  @ Retornar al llamador


EndProgram:
    @ Bucle infinito para terminar el programa
    B .                   

.end