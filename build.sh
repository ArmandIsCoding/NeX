#!/bin/bash

# Detener el script si algún comando falla
set -e

echo "🔨 Compilando NeX OS... (y de paso, haciendo historia)"

# 1. Compilar Stage 1 (Bootloader) especificando la carpeta OS
nasm -f bin OS/boot.asm -o OS/boot.bin

# 2. Compilar Stage 2 (Modo Protegido / GDT)
nasm -f bin OS/boot_stage2.asm -o OS/kernel.bin

# 3. Unificar los sectores en la imagen de disco en la raíz
cat OS/boot.bin OS/kernel.bin > nexos.img

echo "🚀 Lanzando NeX OS en QEMU..."

# 4. Ejecutar el emulador usando la imagen de la raíz
qemu-system-x86_64 -drive format=raw,file=nexos.img