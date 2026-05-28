#include "video.h"

// Le indicamos al compilador que esta función va en una sección especial al principio
__attribute__((section(".text.main_kernel")))
void main_kernel() {
    // 1. Limpiamos la pantalla con el azul oficial de NeX
    kclear_screen(COLOR_BLUE);

    // 2. Imprimimos el cartel principal usando nuestra librería
    kprint_at("NeX OS (64-bits Nativo)", 0, 0, COLOR_YELLOW, COLOR_BLUE);
    
    // 3. Texto corrido con salto de línea
    kprint("\nHola desde el modulo video.c!\n");
    kprint("Esto ya se siente como un sistema operativo de verdad.");

    while(1);
}