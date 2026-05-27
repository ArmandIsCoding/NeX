#!/bin/bash

# Detener si algo falla
set -e

echo "🔨 Compilando NeX OS... (y de paso, haciendo historia)"

# 1. Compilar Stage 1 y Stage 2
nasm -f bin OS/boot.asm -o OS/boot.bin
nasm -f bin OS/boot_stage2.asm -o OS/kernel.bin

# 2. Crear un disco virtual en blanco de 64KB lleno de ceros (128 bloques de 512 bytes)
dd if=/dev/zero of=nexos.img bs=512 count=128 status=none

# 3. Insertar el Stage 1 en el sector 0 (sin truncar el resto del archivo)
dd if=OS/boot.bin of=nexos.img conv=notrunc bs=512 count=1 status=none

# 4. Insertar el Stage 2 a partir del sector 1 (justo después del bootloader)
dd if=OS/kernel.bin of=nexos.img seek=1 conv=notrunc bs=512 status=none

echo "🚀 Lanzando NeX OS en QEMU..."

# 5. Ejecutar el emulador
qemu-system-x86_64 -drive format=raw,file=nexos.img