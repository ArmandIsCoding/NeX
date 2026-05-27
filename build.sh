#!/bin/bash

# Detener el script si algún comando falla
set -e

echo "🔨 Compilando NeX OS... (Redireccionando binarios a /bin)"

# Asegurar que la carpeta bin exista por seguridad
mkdir -p bin

# 1. Compilar Stage 1 (Bootloader) -> directo a /bin
nasm -f bin OS/boot.asm -o bin/boot.bin

# 2. Compilar Stage 2 (Modo Protegido / Paginación / Long Mode) -> directo a /bin
nasm -f bin OS/boot_stage2.asm -o bin/boot_stage2.bin

# 3. Compilar Stage 3 (Kernel en C puro de 64 bits)
x86_64-elf-gcc -ffreestanding -mno-red-zone -m64 -c OS/kernel.c -o bin/kernel.o

# 4. Enlazar el objeto de C usando nuestro linker.ld para generar el binario plano del Kernel
x86_64-elf-ld -T OS/linker.ld bin/kernel.o -o bin/kernel.bin

echo "💾 Estructurando imagen de disco unificada..."

# 5. Crear un disco virtual limpio lleno de ceros (64KB de tamaño)
dd if=/dev/zero of=nexos.img bs=512 count=128 status=none

# 6. Insertar Stage 1 (Sector 0)
dd if=bin/boot.bin of=nexos.img conv=notrunc bs=512 count=1 status=none

# 7. Insertar Stage 2 (A partir del Sector 1)
dd if=bin/boot_stage2.bin of=nexos.img seek=1 conv=notrunc bs=512 status=none

# 8. Insertar Stage 3 (Nuestro Kernel en C a partir del Sector 17)
dd if=bin/kernel.bin of=nexos.img seek=17 conv=notrunc bs=512 status=none

echo "🚀 Lanzando NeX OS en QEMU..."

# 9. Ejecutar el emulador (-no-reboot evita el bucle infinito si hay un fallo)
qemu-system-x86_64 -drive format=raw,file=nexos.img -no-reboot