// Evitamos que el compilador meta funciones e inicializaciones estándar
void main_kernel() {
    // Puntero directo a la memoria de video VGA (tipo short para meter caracteres de 2 bytes)
    unsigned short* vga_buffer = (unsigned short*)0xB8000;

    // Pintamos "Hola desde C!" un poco más abajo del "NeX 64" para ver ambos
    // 0x1f = fondo azul, texto blanco brillante
    char* mensaje = "Hola desde C!";
    
    // Saltamos la primera línea (80 caracteres) para no pisar el NeX 64
    int offset = 80; 

    for (int i = 0; mensaje[i] != '\0'; i++) {
        vga_buffer[offset + i] = (0x1f << 8) | mensaje[i];
    }

    // El equivalente al jmp $ de assembly: bucle infinito en C
    while(1);
}