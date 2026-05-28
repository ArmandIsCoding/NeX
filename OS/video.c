#include "video.h"

// Puntero base a la memoria de video VGA mapeada por el hardware
unsigned short* vga_buffer = (unsigned short*)0xB8000;

// Variables globales para recordar la posición actual del cursor
int cursor_x = 0;
int cursor_y = 0;

// Limpia toda la pantalla rellenándola con espacios en blanco del color elegido
void kclear_screen(char color_fondo) {
    unsigned short atributo = (color_fondo << 4) | 0x0; // Fondo con texto negro implícito
    unsigned short espacio_vacio = (atributo << 8) | ' ';

    for (int i = 0; i < 80 * 25; i++) {
        vga_buffer[i] = espacio_vacio;
    }
    
    // Reiniciamos el cursor a la esquina superior izquierda
    cursor_x = 0;
    cursor_y = 0;
}

// Imprime una cadena en una coordenada X, Y específica
void kprint_at(char* texto, int x, int y, char color_texto, char color_fondo) {
    // Calculamos el offset lineal en base a la grilla bidimensional (80 columnas por fila)
    int offset = (y * 80) + x;
    unsigned short atributo = (color_fondo << 4) | (color_texto & 0x0F);

    for (int i = 0; texto[i] != '\0'; i++) {
        // Evitamos desbordar la pantalla física
        if (offset + i >= 80 * 25) break; 
        
        vga_buffer[offset + i] = (atributo << 8) | texto[i];
    }
}

// Imprime texto corrido respetando saltos de línea básicos (\n)
void kprint(char* texto) {
    unsigned short atributo = (COLOR_BLUE << 4) | (COLOR_WHITE & 0x0F); // Por defecto: Blanco sobre Azul NeX

    for (int i = 0; texto[i] != '\0'; i++) {
        // Si encontramos un salto de línea, bajamos de fila y volvemos al margen izquierdo
        if (texto[i] == '\n') {
            cursor_x = 0;
            cursor_y++;
            continue;
        }

        int offset = (cursor_y * 80) + cursor_x;
        vga_buffer[offset] = (atributo << 8) | texto[i];
        
        cursor_x++;
        
        // Si llegamos al final de la línea de 80 caracteres, saltamos automáticamente
        if (cursor_x >= 80) {
            cursor_x = 0;
            cursor_y++;
        }
        
        // Si desbordamos las 25 filas, reiniciamos arriba (a futuro haremos scroll!)
        if (cursor_y >= 25) {
            cursor_y = 0;
        }
    }
}