ENTRY(main_kernel)
OUTPUT_FORMAT(binary)

SECTIONS
{
    /* Vamos a acomodar el Kernel en la dirección 0x10000 (un espacio limpio en la RAM) */
    . = 0x10000;

    .text : {
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