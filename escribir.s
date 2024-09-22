.global _start

.data
output_filename:
    .asciz "escribir.txt"           /* Nombre del archivo de salida */
message:
    .asciz "Hola mundo\n"           /* Mensaje a escribir en memoria */

.text
_start:
    /* Abrir archivo de salida (escribir.txt) */
    mov r7, #5                      /* Syscall número 5: sys_open */
    ldr r0, =output_filename        /* Nombre del archivo de salida */
    mov r1, #0101                   /* O_RDWR (lectura y escritura) */
    
    /* Construir permisos en r2 (0777 en octal es 0x1FF en hexadecimal) */
    mov r2, #0x1B                   /* Cargar los bits más significativos (0x1B -> 11011) */
    orr r2, r2, #0x6                /* Añadir los bits menos significativos (0x6 -> 0110) */

    swi 0                           /* Llamar syscall */
    cmp r0, #0                      /* Verificar si la apertura fue exitosa */
    blt error_exit                  /* Si falla, salir con error */
    mov r4, r0                      /* Guardar el file descriptor del archivo de salida en r4 */

    /* Escribir el mensaje en el archivo */
    ldr r1, =message                /* Cargar la dirección del mensaje */
    mov r2, #11                     /* Longitud del mensaje "Hola mundo\n" (11 caracteres) */

    mov r7, #4                      /* Syscall número 4: sys_write */
    mov r0, r4                      /* File descriptor del archivo de salida */
    swi 0                           /* Llamar syscall */
    cmp r0, #0                      /* Comprobar si hay error */
    blt error_exit                  /* Si hay un error, salir */

close_file:
    /* Cerrar archivo */
    mov r7, #6                      /* Syscall número 6: sys_close */
    mov r0, r4                      /* Descriptor del archivo de salida */
    swi 0

error_exit:
    /* En caso de error, salir con código 1 */
    mov r7, #1                      /* Syscall número 1: sys_exit */
    mov r0, #1                      /* Código de salida 1 (error) */
    swi 0                           /* Llamar syscall */
