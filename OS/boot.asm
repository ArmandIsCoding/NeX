[org 0x7c00]

mov si, mensaje      ; Apuntamos el registro 'si' al inicio de nuestro texto

imprimir_cadena:
    lodsb            ; Carga el siguiente byte (caracter) desde 'si' hacia el registro 'al'
    cmp al, 0        ; ¿Es un cero? (Fin del texto)
    je bucle_infinito ; Si es cero, terminamos y vamos al bucle infinito
    
    mov ah, 0x0e     ; Si no es cero, configuramos modo teletipo de BIOS
    int 0x10         ; Imprimimos el caracter que está en 'al'
    jmp imprimir_cadena ; Volvemos a empezar para la siguiente letra

bucle_infinito:
    jmp bucle_infinito

mensaje:
    db "Hola desde mi propio OS!", 0 ; Nuestro texto terminado en 0 (Null-terminated)

times 510 - ($ - $$) db 0
dw 0xaa55