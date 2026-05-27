# NeX OS

> *"The people who are crazy enough to think they can change the world are the ones who do."* — Steve Jobs

**NeX** es un sistema operativo experimental, didáctico y bestialmente rápido, nacido del puro placer de programar a bajo nivel y entender el corazón de las máquinas. 

Este proyecto no busca competir con los gigantes modernos, sino sentarse sobre sus hombros. Nace como un homenaje directo a la era de **NeXTSTEP** —aquel momento en la historia de la informática donde la genialidad se cocinó fuera de los márgenes establecidos— y cierra un círculo poético: ser diseñado y compilado desde la herencia directa de esa revolución, hoy materializada en la arquitectura moderna de una Mac Mini.

NeX es un lienzo en blanco para explorar la gestión de memoria, los registros del procesador y la mística de ver arrancar un kernel propio desde el cero absoluto.

---

## ⚡ El Espíritu de NeX OS

* **Brutalmente Rápido:** Sin peso muerto, sin telemetría, sin capas innecesarias. Solo el código y el silicio.
* **Didáctico por Naturaleza:** Diseñado para ser leído, roto, modificado y comprendido bit a bit.
* **Mística de Garage:** Código con alma. Hecho por la diversión de domar el hardware y revivir la era dorada de la informática donde el software se sentía artesanal.

## 🧠 Inspiración Histórica

En 1985, fuera de Apple, Jobs fundó NeXT con la premisa de crear computadoras avanzadas para la educación y la ciencia. De ese ecosistema de software nacieron las bases de lo que hoy usamos a diario, la primera página web del mundo y la ingeniería que cambió la industria. 

**NeX** rescata esa chispa: la noción de que construir un sistema operativo propio es la forma definitiva de honrar la historia de la informática.

---

## 🛠️ Requisitos Previos (Para macOS / Apple Silicon M4)

Dado que estamos compilando desde un chip con arquitectura ARM64 pero apuntamos a una arquitectura destino x86_64 de 64 bits (*Bare-Metal*), necesitamos un entorno de compilación cruzada (*Cross-Compiler*).

Instalá las herramientas necesarias usando **Homebrew**:

```bash
brew install nasm qemu x86_64-elf-gcc

```

* `nasm`: El ensamblador para traducir nuestro código x86 a binario puro.
* `qemu`: El emulador de hardware hiperrápido para testear el OS de forma segura.
* `x86_64-elf-gcc`: Compilador de C puro optimizado para generar ejecutables limpios sin dependencias de macOS ni de Linux.

---

## 🚀 Cómo Compilar y Ejecutar

Para ensamblar los sectores, unificar nuestro disco virtual y arrancar **NeX OS**, ejecutá la siguiente secuencia en tu terminal:

### 1. Compilar los componentes base

```bash
# Compilar el Sector 1 (Bootloader de 512 bytes en Modo Real 16-bits)
nasm -f bin boot.asm -o boot.bin

# Compilar el Sector 2 (Trampolín hacia el Kernel y Modo Protegido)
nasm -f bin kernel_trampoline.asm -o kernel.bin

```

### 2. Generar la imagen de disco unificada

Pegamos ambos sectores en un único archivo binario monolítico que simula nuestro disco de arranque, rompiendo la barrera inicial de los 512 bytes:

```bash
cat boot.bin kernel.bin > nexos.img

```

### 3. Lanzar NeX OS en el emulador

```bash
qemu-system-x86_64 -drive format=raw,file=nexos.img

```

---

## 🗺️ Mapa de Ruta (Roadmap)

* [x] **Fase 1:** Bootloader básico de 512 bytes e impresión de caracteres vía BIOS (Modo Real).
* [x] **Fase 2:** Romper el límite físico del sector de arranque leyendo multi-sectores desde disco (`int 0x13`).
* [ ] **Fase 3:** Crear la GDT (Global Descriptor Table), activar el Modo Protegido de 32 bits y configurar la paginación de memoria para saltar al **Modo Largo de 64 bits**.
* [ ] **Fase 4:** Inicializar nuestro primer Kernel en C puro de 64 bits escribiendo directo en la memoria de video (`0xB8000`).

---

*Hecho solo por diversión, porque tirar código a bajo nivel es lo más parecido a la magia que tenemos.*

---

⚓ [Volver a helloworld.com.ar](https://helloworld.com.ar)
