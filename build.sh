#!/bin/bash
set -e
echo "🔨 Compilando NeX OS..."
mkdir -p bin
nasm -f bin OS/boot.asm -o bin/boot.bin
nasm -f bin OS/boot_stage2.asm -o bin/boot_stage2.bin
x86_64-elf-gcc -O2 -ffreestanding -mno-red-zone -m64 -c OS/kernel.c -o bin/kernel.o -fno-stack-protector -mno-sse -mno-mmx -mno-sse2
x86_64-elf-gcc -O2 -ffreestanding -mno-red-zone -m64 -c OS/video.c -o bin/video.o -fno-stack-protector -mno-sse -mno-mmx -mno-sse2
x86_64-elf-ld -T OS/linker.ld bin/kernel.o bin/video.o -o bin/kernel.bin
echo "💾 Creando imagen nexos.img..."
dd if=/dev/zero of=nexos.img bs=512 count=128 status=none
dd if=bin/boot.bin of=nexos.img conv=notrunc bs=512 count=1 status=none
dd if=bin/boot_stage2.bin of=nexos.img seek=1 conv=notrunc bs=512 status=none
dd if=bin/kernel.bin of=nexos.img seek=17 conv=notrunc bs=512 status=none
echo "🚀 Iniciando QEMU..."
qemu-system-x86_64 -drive format=raw,file=nexos.img -no-reboot -d int,cpu_reset
