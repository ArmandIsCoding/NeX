[org 0x9000]
bits 16                     ; Le avisamos al compilador que arrancamos en 16 bits

; ---------------------------------------------------------------------------
; STAGE 2: Entrada en Modo Real
; ---------------------------------------------------------------------------
mov ah, 0x0e
mov al, '2'                 ; Confirmación visual de que estamos en Stage 2 (16 bits)
int 0x10

; 1. Desactivar interrupciones (La BIOS ya no nos va a amparar)
cli

; 2. Cargar la GDT que pusiste al final
lgdt [gdt_descriptor]

; 3. Activar el Modo Protegido en el registro de control CR0 (el bit 0)
mov eax, cr0
or eax, 0x1
mov cr0, eax

; 4. Hacer un "Far Jump" (Salto Largo) para limpiar el pipeline del procesador
; y forzarlo a cargar nuestro segmento de código de 32 bits (0x08)
jmp 0x08:iniciar_modo_protegido

; ---------------------------------------------------------------------------
; STAGE 2: Conmutación a 32 bits (Modo Protegido)
; ---------------------------------------------------------------------------
bits 32                     ; ¡A partir de acá el compilador genera código de 32 bits!

iniciar_modo_protegido:
    ; Actualizamos los registros de segmento para apunten a nuestro segmento de datos (0x10)
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Configurar una nueva pila para el modo de 32 bits
    mov ebp, 0x90000
    mov esp, ebp

    ; --- ESCRIBIR EN LA MEMORIA DE VIDEO (0xB8000) ---
    ; En modo texto, cada caracter ocupa 2 bytes: [ASCII] y [Atributo/Color]
    ; 0x2f significa fondo verde (2) con texto blanco brillante (f)
    
    mov edi, 0xB8000        ; Dirección base de la memoria de video VGA
    
    ; Pintamos "NeX 32" caracter por caracter con color
    mov word [edi], 0x2f4e      ; 'N'
    mov word [edi + 2], 0x2f65  ; 'e'
    mov word [edi + 4], 0x2f58  ; 'X'
    mov word [edi + 6], 0x2f20  ; ' '
    mov word [edi + 8], 0x2f33  ; '3'
    mov word [edi + 10], 0x2f32 ; '2'

    jmp $                   ; Congelamos acá en 32 bits

; ---------------------------------------------------------------------------
; DATOS Y ESTRUCTURAS (Tu tabla GDT)
; ---------------------------------------------------------------------------
gdt_start:

gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start