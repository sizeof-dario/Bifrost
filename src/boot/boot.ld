OUTPUT_FORMAT("binary")

SECTIONS
{
    . = 0x7C00;

    .text : {
        build/boot.o(.text)
        boot2_start = .;
        *(.text)
    }

    .data : { *(.data) }
    .rodata : { *(.rodata) }

    . = ALIGN(0x200);
    boot2_end = .;

    . = ALIGN(0x10);
    bss_start = .;

    .bss : { *(.bss) }
    
    . = ALIGN(0x10);
    bss_end = .;

    . = ALIGN(0x200) - 1;
    .padding : { BYTE(0x00) }

    . = ASSERT(. <= 0xFFFF, "Bootloader too big!");
}
