.data
text: .asciz "en un pueblito no muy lejano viva una mam cerdita junto con sus tres cerditos todos eran muy felices hasta que un da la mam cerdita les dijo hijitos ustedes ya han crecido es tiempo de que sean cerditos adultos y vivan por s mismos antes de dejarlos ir les dijo en el mundo nada llega fcil por lo tanto deben aprender a trabajar para lograr sus sueos mam cerdita se despidi con un besito en la mejilla y los tres cerditos se fueron a vivir en el mundo el cerdito menor que era muy pero muy perezoso no prest atencin a las palabras de mam cerdita y decidi construir una casita de paja para terminar temprano y acostarse a descansar el cerdito del medio que era medio perezoso medio prest atencin a las palabras de mam cerdita y construy una casita de palos la casita le qued chueca porque como era medio perezoso no quiso leer las instrucciones para construirla la cerdita mayor que era la ms aplicada de todos prest mucha atencin a las palabras de mam cerdita y quiso construir una casita de ladrillos la construccin de su casita le tomara mucho ms tiempo pero esto no le import su nuevo hogar la albergara del fro y tambin del temible lobo feroz y hablando del temible lobo feroz este se encontraba merodeando por el bosque cuando vio al cerdito menor durmiendo tranquilamente a travs de su ventana al lobo le entr un enorme apetito y pens que el cerdito sera un muy delicioso bocadillo as que toc a la puerta y dijo cerdito cerdito djame entrar el cerdito menor se despert asustado y respondi no no y no nunca te dejar entrar el lobo feroz se enfureci y dijo soplar y resoplar y tu casa derribar el lobo sopl y resopl con todas sus fuerzas y la casita de paja se vino al piso afortunadamente el cerdito menor haba escapado hacia la casa del cerdito del medio mientras el lobo segua soplando el"
output_filename: .asciz "resultado.txt"    @ Nombre del archivo de salida
search_word: .space 301   @ Espacio para almacenar la primera palabra del texto

.text
.global _start

@ Inicio
_start:
    ldr r0, =text            @ Cargar dirección del texto
    sub sp, sp, #4000         @ Reservar espacio en la pila para la primera palabra
    mov r1, sp               @ Usar la pila para almacenar la primera palabra
    mov r8, #1               @ Valor inicial para que el programa continúe
	
    bl extract_first_word    @ Llamar a la función para extraer la primera palabra
    bl count_word_occurrences @ Llamar a la función para contar ocurrencias

    bl write_to_file         @ Llamar a la función para escribir en el archivo en binario

    @ Terminar el programa
    mov r7, #1               @ Syscall para salir
    mov r0, #0               @ Código de salida 0 (éxito)
    swi 0

@ Prepara los valores para extraer la primer palabra
extract_first_word:
    @ Guardar registros usados
    push {r4, r5, r6, r7, lr}
	
    mov r4, #0              @ Indice del texto
    mov r5, #0              @ Indice de la palabra
    mov r8, #0				@ Verificacion si se encontro una palabra

@ Extrae la primera palabra del texto
extract_loop:
    ldrb r6, [r0, r4]       @ Cargar el siguiente caracter del texto
	
    cmp r6, #0x23 			@ Compara para ver si ya se quito ese valor del texto
    beq continue			@ Si esa letra del texto ya se quito se cotinua con la busqueda
	
    cmp r6, #' '            @ Ver si es un espacio (fin de la palabra)
    beq check_word   		@ Si es un espacio, terminar

    cmp r6, #0              @ Ver si es el final del texto
    beq check_last_word   @ Si es el final del texto, terminar

    strb r6, [r1, r5]       @ Copiar caracter al buffer de busqueda
    add r4, r4, #1          @ Avanzar al siguiente carácter del texto
    add r5, r5, #1          @ Avanzar al siguiente índice de la palabra
    mov r8, #1				@ Se le pone uno cuando se le encontro una palabra
    b extract_loop
	
@ Continua con la busqueda
continue:
    add r4, r4, #1          @ Avanzar al siguiente carácter del texto
    b extract_loop
	
check_last_word:
    cmp r8, #0               @ Verifica si no se encontró una palabra
    beq write_to_file        @ Si no se encontró una palabra, ir a write_to_file
    b check_word             @ Si se encontró, continuar con check_word

check_word:
    sub r4, r4, #1          @ Retrocede para apuntar al último carácter de la palabra
    ldrb r6, [r0, r4]       @ Cargar el siguiente carácter del texto
    cmp r6, #0x23           @ Verifica si el carácter es el valor que debe omitirse
    add r4, r4, #2          @ Avanza en el texto
    mov r2, r5              @ Almacena la longitud de la palabra

    @ Añadir terminador NULL al final de la palabra
    mov r6, #0              @ Cargar NULL en r6
    strb r6, [r1, r5]       @ Escribir NULL al final de la palabra en la pila

    beq extract_loop        @ Regresa al bucle de extracción si corresponde


count_word_occurrences:
    @ Guarda registros usados
    push {r4, r5, r6, r7, lr}

    mov r3, #0              @ Inicializa el contador de ocurrencias
    mov r4, #0              @ Indice de texto
    mov r5, #0              @ Indice de palabra

@ Avanza al siguiente caracter
next_char:
    ldrb r6, [r0, r4]      @ Carga el siguiente caracter del texto
    cmp r6, #0             @ Compara con NULL (fin del texto)
    beq done               @ Si es el fin del texto, salir

    @ Comprueba si el carácter actual es el inicio de la palabra
    ldrb r7, [r1, r5]     @ Carga el carácter de la palabra a buscar
    cmp r6, r7            @ Compara con el carácter de la palabra
    beq check_match       @ Si coincide, comprobar el resto de la palabra

    @ Si no coincide, reiniciar índice de la palabra
    mov r5, #0			
    bne avanzar_palabra

@ Verifica el match de las dos letras
check_match:

    add r4, r4, #1 		@ Avanza al siguiente caracter del texto
    add r5, r5, #1		@ Avanza al siguiente índice de la palabra
	
    ldrb r6, [r0, r4]	@ Load de la siguiente letra del texto 
    ldrb r7, [r1, r5]	@ Load de la siguiente letra de la palabra  
	
    cmp r6, #' '		@ Compara el valor de la letra del texto con un espacio
    beq found_match_aux @ Si la palabra ya termino sigue con el auxiliar
    cmp r6, #0
    beq found_match_aux
    bne next_char		@ En caso de que no se sigue con el siguiente caracter


@ Avanza hasta la siguiente palabra del texto
avanzar_palabra:
    add r4, r4, #1		@ Avanza al siguiente caracter del texto
    ldrb r6, [r0, r4]	@ Load de la siguiente letra del texto
	
    cmp r6, #' '		@ Compara el valor de la letra del texto con un espacio
    beq next_char_aux	@ Si la palabra ya termino se sigue al siguiente caracter
	
    cmp r6, #0x23       @ Comparar para ver si ya se quito ese valor del texto
    beq next_char_aux	@ Si la palabra ya termino se sigue al siguiente caracter
	
    cmp r6, #0
    beq done
	
    bne avanzar_palabra @ Si no se cumplen las condiciones se hace un bucle hasta que se encuentre la siguiente palabra
	
next_char_aux:
    add r4, r4, #1		@ Avanza al siguiente caracter del texto
    ldrb r6, [r0, r4]
    cmp r6, #' '
    bne next_char
    add r4, r4, #1
    b next_char

found_match_aux:
    cmp r7, #0          @ Compara si r7 es igual a 0
    beq found_match     @ Si es igual a 0, salta a found_match
    cmp r7, #0xaa       @ Compara si r7 es igual a 0xaa
    beq found_match     @ Si es igual a 0xAA, salta a found_match
    b next_char         @ Si no es ninguno de los dos, sigue con la siguiente letra del texto

found_match:
    add r3, r3, #1      @ Incrementar contador de ocurrencias
    mov r5, #0          @ Reiniciar índice de la palabra
    add r9, r0, r4		@ Obtiene el numero de memoria actual posicionado en el texto
    sub r9, r9, r2		@ Resta el largo de la palabra
    mov r10, #0x23		@ Valor carga el valor del numeral en ascci a r10    
	
change_word:
    strb r10, [r9, r5]  @ Cambia el valor actual de letra del texto por un numeral
    add r5, r5, #1      @ Avanza a la siguiente letra del texto
    cmp r5, r2			@ Compara si el valor actual de la letra es igual a el largo de la palabra
    bne change_word     @ Si no se cumple se hace un bucle

restart:
    add r4, r4, #1      @ Suma a la siguiente letra del texto con r4
    mov r5, #0			@ Se reinician los valores
    mov r9, #0			@ Se reinician los valores
    b next_char
	
done:
    @ Restaurar registros
    pop {r4, r5, r6, r7, lr}
	
    mov r11, #0
    strb r11, [r1, r2]
    add r2, r2, #1
    strb r3, [r1, r2]
    add r2, r2, #1
    strb r11, [r1, r2]
    
    add r2, r2, #1
    add r1, r1, r2
    mov r2, #0
    
    b extract_first_word

@ Escribir el contenido en binario en el archivo
write_to_file:
    /* Abrir archivo de salida (escribir.txt) */
    mov r7, #5                      /* Syscall número 5: sys_open */
    ldr r0, =output_filename        /* Nombre del archivo de salida */
    mov r1, #0101                   /* O_RDWR (lectura y escritura) */
    
    /* Permisos (0777 en octal) */
    mov r2, #0x1B                   /* Cargar los bits más significativos (0x1B -> 11011) */
    orr r2, r2, #0x6                /* Añadir los bits menos significativos (0x6 -> 0110) */


    swi 0                           /* Llamar syscall */
    cmp r0, #0                      /* Verificar si la apertura fue exitosa */
    blt error_exit                  /* Si falla, salir con error */
    mov r4, r0                      /* Guardar el file descriptor del archivo de salida en r4 */

    /* Escribir el contenido de la memoria en el archivo */
    mov r1, sp                      /* Dirección de la memoria (pila) */
    mov r2, #4000                    /* Tamaño del contenido de la pila a escribir */

    mov r7, #4                      /* Syscall número 4: sys_write */
    mov r0, r4                      /* File descriptor del archivo de salida */
    swi 0                           /* Llamar syscall */

close_file:
    /* Cerrar archivo */
    mov r7, #6                      /* Syscall número 6: sys_close */
    mov r0, r4                      /* Descriptor del archivo de salida */
    swi 0

error_exit:
    /* En caso de error, salir con código 1 */
    mov r7, #1                      /* Syscall número 1: sys_exit */
    mov r0, #1                      /* Código de salida 1 (error) */
    swi 0

exit:
    mov r7, #1                      /* Syscall número 1: sys_exit */
    mov r0, #0                      /* Código de salida 1 (error) */
    swi 0
