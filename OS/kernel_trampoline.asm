[org 0x9000]                ; Le avisamos que va a estar en la dirección 0x9000 de la RAM

; Como estamos en Modo Real, vamos a usar un truco intermedio:
; Imprimimos una 'X' usando la BIOS para confirmar que el salto fue un éxito.

mov ah, 0x0e
mov al, 'X'                 ; 'X' de NeX OS
int 0x10

jmp $                       ; Nos congelamos acá