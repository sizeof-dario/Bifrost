OUTPUT_FORMAT("binary")

SECTIONS
{
    . = 0x7C00;

    .text : {    
        build/boot.o(.text)
    }

    .data : { 
        __BOOT2_START = .;
        *(.data)
    }

    .rodata : { *(.rodata) }

    .text2 : {
        *(.text)
        . = ALIGN(0x200);
        __BOOT2_END = .;
    }

    # . = ALIGN(0x10);
    .bss : {
        __BSS_START = .;
        *(.bss) 
        . = ALIGN(0x10);
        __BSS_END = .;
    }
    
    /DISCARD/ : {
        *(.comment)
	}

    ASSERT(. <= 0xFFFF, "Bootloader too big!")
}
