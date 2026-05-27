[org 0x9000]
bits 16                     ; Iniciamos en 16 bits (Modo Real)

; Aseguramos DS = 0 para el adresamiento correcto
xor ax, ax
mov ds, ax

; ---------------------------------------------------------------------------
; STAGE 2: Inicialización y Salto a Modo Protegido (32-bits)
; ---------------------------------------------------------------------------
mov ah, 0x0e
mov al, '2'                 ; Indicador visual de Stage 2 activo
int 0x10

; Guardar número de disco (DL viene del Stage 1)
mov [boot_drive_s2], dl

; --- CARGAR EL KERNEL DESDE EL DISCO A 0x10000 ---
; Usamos lectura extendida (LBA) para mayor compatibilidad
mov ah, 0x42                ; Función extendida de lectura
mov si, kernel_dap          ; DS:SI → Disk Address Packet
int 0x13
jc error_kernel

cli                         ; Desactivar interrupciones
lgdt [gdt_descriptor]       ; Cargar GDT inicial

mov eax, cr0
or eax, 0x1                 ; Activar bit de Modo Protegido
mov cr0, eax

jmp 0x08:iniciar_modo_protegido ; Salto largo para aplicar los 32-bits

error_kernel:
    mov ah, 0x0e
    mov al, 'K'             ; Imprime 'K' si falla la carga del Kernel
    int 0x10
    jmp $

; ---------------------------------------------------------------------------
bits 32

iniciar_modo_protegido:
    mov ax, 0x10            ; Cargar segmento de datos de la GDT
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; 1. Limpiar el espacio de memoria para las tablas (de 0x1000 a 0x4000) con ceros
    mov edi, 0x1000
    mov cr3, edi            ; CR3 debe apuntar a la base de la PML4 (0x1000)
    xor eax, eax
    mov ecx, 3072           ; Cantidad de dwords para limpiar 12KB de RAM
    rep stosd

    ; 2. Enlazar las estructuras (Mamushkas de memoria)
    ; Las direcciones base llevan el bit 0 y 1 en '1' (Presente + Lectura/Escritura)
    mov edi, 0x1000
    mov dword [edi], 0x2003      ; PML4[0] apunta a PDPT (0x2000)
    
    mov edi, 0x2000
    mov dword [edi], 0x3003      ; PDPT[0] apunta a PD (0x3000)

    ; 3. Configurar el Page Directory (PD) para mapear una página gigante de 2MB
    ; 0x83 significa: Presente (0x1) + Lectura/Escritura (0x2) + Size enorme de 2MB (0x80)
    mov edi, 0x3000
    mov dword [edi], 0x00000083  ; PD[0] apunta directamente al bloque físico 0x0

    ; 4. Habilitar PAE (Physical Address Extension), obligatorio para 64-bits
    mov eax, cr4
    or eax, 1 << 5               ; Activar el bit 5 (PAE)
    mov cr4, eax

    ; 5. Activar el Modo Largo en el registro específico del procesador (EFER MSR)
    mov ecx, 0xC0000080          ; Dirección del EFER MSR
    rdmsr                        ; Lee el registro
    or eax, 1 << 8               ; Activa el bit 8 (Long Mode Enabler)
    wrmsr                        ; Escribe el cambio

    ; 6. Activar la Paginación para que la CPU procese los cambios
    mov eax, cr0
    or eax, 1 << 31              ; Activa el bit 31 (Paging)
    mov cr0, eax

    ; 7. Cargar una nueva GDT de 64 bits para el tramo definitivo
    lgdt [gdt64_descriptor]
    jmp 0x08:iniciar_modo_largo  ; ¡SALTO DE FE AL MUNDO DE 64 BITS!

; ---------------------------------------------------------------------------
; STAGE 2: MODO LARGO SEGURO (64-bits en Assembly)
; ---------------------------------------------------------------------------
bits 64
iniciar_modo_largo:
    mov rax, 0x10           ; Registro de datos para Modo Largo
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; Limpiar pantalla con fondo azul (0x1f)
    mov rdi, 0xB8000
    mov rcx, 2000           ; 80 columnas * 25 filas = 2000 caracteres
.limpiar:
    mov word [rdi], 0x1f20  ; Espacio en blanco con fondo azul
    add rdi, 2
    loop .limpiar

    ; Imprimir "NeX 64" en la esquina superior izquierda
    mov rdi, 0xB8000
    mov word [rdi], 0x1f4e      ; 'N'
    mov word [rdi + 2], 0x1f65  ; 'e'
    mov word [rdi + 4], 0x1f58  ; 'X'
    mov word [rdi + 6], 0x1f20  ; ' '
    mov word [rdi + 8], 0x1f36  ; '6'
    mov word [rdi + 10], 0x1f34 ; '4'

    ; --- EL GRAN SALTO A C ---
    ; Saltamos a la dirección física 0x10000, mapeada en nuestro linker.ld
    mov rax, 0x10000
    jmp rax

    jmp $                        ; Flag de seguridad por si C retorna (no debería)

; ---------------------------------------------------------------------------
; TABLAS DE DATOS Y DESCRIPTORES
; ---------------------------------------------------------------------------

boot_drive_s2: db 0

; Disk Address Packet (DAP) para cargar el Kernel desde LBA 17
kernel_dap:
    db 0x10             ; Tamaño del paquete (16 bytes)
    db 0x00             ; Reservado
    dw 16               ; Sectores a leer (16 × 512 = 8KB)
    dw 0x0000           ; Offset destino
    dw 0x1000           ; Segmento destino (0x1000 × 16 = físico 0x10000)
    dq 17               ; LBA de inicio del Kernel en el disco

; --- GDT de 16/32 bits ---
gdt_start:
gdt_null: dd 0x0, 0x0
gdt_code: dw 0xffff, 0x0
          db 0x0, 10011010b, 11001111b, 0x0
gdt_data: dw 0xffff, 0x0
          db 0x0, 10010010b, 11001111b, 0x0
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; --- NUEVA GDT EXCLUSIVA DE 64 BITS (Exigida por el Long Mode) ---
gdt64_start:
gdt64_null:
    dq 0x0
gdt64_code:
    ; El bit de granularidad cambia para indicar modo de 64 bits (bit 21 en el segundo dword)
    dq 0x00209a0000000000 
gdt64_data:
    dq 0x0000920000000000
gdt64_end:
gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dq gdt64_start

times 8192 - ($ - $$) db 0  ; Fuerza a que el Stage 2 mida exactamente 16 sectores