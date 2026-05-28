[org 0x9000]
bits 16

; Asegurar segmentos a 0
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x8000

; Diagnóstico: Etapa 2
mov ah, 0x0e
mov al, '2'
int 0x10

; Guardar disco
mov [boot_drive], dl

; Cargar Kernel (Sector 17 -> 0x1000:0000)
mov ah, 0x42
mov si, dap
int 0x13
jnc kernel_ok
mov ah, 0x0e
mov al, 'E'
int 0x10
jmp $

kernel_ok:
mov ah, 0x0e
mov al, 'K'
int 0x10

; --- PASO A MODO PROTEGIDO 32 BITS ---
cli
lgdt [gdt32_ptr]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp 0x08:start32

bits 32
start32:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x90000

    ; Diagnóstico VGA: 'P'
    mov byte [0xb8000], 'P'
    mov byte [0xb8001], 0x1F

    ; --- PREPARAR PAGINACIÓN IA-32e ---
    ; 1. Limpiar 12KB (0x1000 - 0x3FFF)
    mov edi, 0x1000
    xor eax, eax
    mov ecx, 3072
    rep stosd

    ; 2. Estructura: PML4 (0x1000) -> PDPT (0x2000) -> PD (0x3000)
    mov dword [0x1000], 0x2003      ; PML4[0]
    mov dword [0x2000], 0x3003      ; PDPT[0]
    
    ; 3. Mapear 4MB usando 2 entradas de 2MB (Huge Pages)
    ; Cubre 0x00000 hasta 0x3FFFFF (Kernel está en 0x10000)
    mov dword [0x3000], 0x00000083  ; 0 - 2MB
    mov dword [0x3008], 0x00200083  ; 2MB - 4MB

    ; 4. Habilitar PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; 5. Cargar CR3
    mov eax, 0x1000
    mov cr3, eax

    ; 6. Habilitar Long Mode en EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; 7. Habilitar Paginación
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; 8. Cargar GDT 64
    lgdt [gdt64_ptr]

    ; 9. SALTO A 64 BITS (Selector 0x08 de la GDT64)
    jmp 0x08:start64

bits 64
start64:
    ; Configurar selectores de datos (0x10 es el segmento de datos en GDT64)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov rsp, 0x9F000

    ; Diagnóstico VGA: '64'
    mov word [0xb8002], 0x1f36 ; '6'
    mov word [0xb8004], 0x1f34 ; '4'

    ; SALTO AL KERNEL EN C (Cargado en 0x10000)
    mov rax, 0x10000
    jmp rax

; --- SEGMENTOS Y DATOS ---
align 16
boot_drive: db 0

align 16
dap:
    db 0x10
    db 0x00
    dw 64          ; 32 KB
    dw 0x0000
    dw 0x1000      ; Cargar en 0x1000:0000 = 0x10000
    dq 17

align 16
gdt32:
    dq 0 ; Null
    dq 0x00cf9a000000ffff ; Code (0x08)
    dq 0x00cf92000000ffff ; Data (0x10)
gdt32_ptr:
    dw $ - gdt32 - 1
    dd gdt32

align 16
gdt64:
    dq 0 ; Null (0x00)
    dq 0x00af9a000000ffff ; Code 64 (0x08) - L=1
    dq 0x00cf92000000ffff ; Data 64 (0x10)
gdt64_ptr:
    dw $ - gdt64 - 1
    dd gdt64

times 8192 - ($ - $$) db 0
