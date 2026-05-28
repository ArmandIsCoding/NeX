ENTRY(main_kernel)
OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x10000;

    .text : {
        /* Forzamos a que el símbolo de la función main_kernel vaya primero */
        *(.text.main_kernel)
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}