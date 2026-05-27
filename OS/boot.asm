[org 0x7c00]

KERNEL_OFFSET equ 0x9000    ; Dirección de la RAM donde vamos a cargar el Sector 2

mov [BOOT_DRIVE], dl        ; La BIOS nos pasa en 'dl' el número de disco de arranque. Lo guardamos.

; --- CONFIGURAR PILA (STACK) ---
mov bp, 0x8000
mov sp, bp

; --- LEER DEL DISCO ---
mov ah, 0x02                ; Función BIOS: Leer sectores del disco
mov al, 1                   ; Cantidad de sectores que queremos leer (1 sector = 512 bytes)
mov ch, 0                   ; Cilindro 0
mov dh, 0                   ; Cabeza 0
mov cl, 2                   ; Sector 2 (El sector 1 es este Bootloader, el 2 es el que queremos)
mov dl, [BOOT_DRIVE]        ; Disco de arranque que guardamos antes

mov bx, 0
mov es, bx
mov bx, KERNEL_OFFSET       ; Destino en RAM: es:bx (0x0000:0x9000)

int 0x13                    ; ¡Llamada a la BIOS para que lea el disco!
jc error_disco              ; Si hay error (se enciende la bandera Carry), vamos a la rutina de error

; --- SALTO AL SEGUNDO PISO ---
jmp KERNEL_OFFSET           ; Saltamos directo a la dirección de RAM donde se cargó el Sector 2

error_disco:
    mov ah, 0x0e
    mov al, 'E'             ; Si falla el disco, imprime una 'E'
    int 0x10
    jmp $

BOOT_DRIVE: db 0            ; Variable para guardar el número de disco

times 510 - ($ - $$) db 0
dw 0xaa55