OUTPUT_FORMAT("binary")

SECTIONS
{
    . = 0x7C00;

    .text :
    {
        build/boot.o(.text)
        *(.text)
    }

    .data :
    {
        *(.data)
    }

    .rodata :
    {
        *(.rodata)
    }

    .bss :
    {
        *(.bss)
    }

    . = 0xFFFE;
    .padding :
    {
        BYTE(0x00)
    }
}
