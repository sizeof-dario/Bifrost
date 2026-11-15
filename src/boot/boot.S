/* 
        Let's understand what we are dealing with:
 
        We want to start using C as soon as possible. So, we're gonna use a two-
        stages bootloader. This first stage's only job will be to load the
        second, bigger stage written in C.
 
        HUGE NOTE HERE: we are in real mode, so C will only let use short 
        pointers for a fixed segment register.  In principle, we could change
        segment registers with some inline assembly, but we don't need so much
        space, so we'll try to stay in the 0x0000-0xFFFF range.
        
        Given that this sector will be placed at 0x7C00, that it occupies 512
        bytes, that the space from 0x0000 to 0x04FF is occupied by the IVT and
        the BDA and that we can't go past 0xFFFF, we get about 30KB of space
        both below and above it.
 
        Thus, we place the stack below it, so that it can grow downwards, and we
        reserve the upper space to the second stage. To be more precise, the
        latter will occupy 65 sectors, number obtained by doing:
        (0xFFFF - 0x7E00 + 1)/512 = 0x8200/512 = 33280/512 = 65
*/

.extern boot2main

.code16
        # Set up registers
        ljmp    $0x0000, $start
start:  xorw    %ax, %ax
        movw    %ax, %ds
        movw    %ax, %es
        movw    %ax, %ss
        movw    $0x7C00, %sp
        cld

        # Load boot2
        movw    $DAPACK, %si
        movb    $0x42, %ah
        int     $0x13
        jnc     boot2

        # If we fail here, we can't do much more...
        movw    $load_fail, %si
        callw   puts
        jmp     die

        # Jump to C code (should not return)
boot2:  pushl   %edx                   # We need to bring the drive number with
                                       # us for when the kernel will be loaded.
        calll   boot2main
        # Fall through...

die:    hlt
        jmp     die

# Display a string on screen
#       %si = string address
puts:   pusha
        movb    $0x0E, %ah
        xorw    %bx, %bx
0:      lodsb   (%si), %al
        testb   %al, %al
        jz      1f
        int     $0x10
        jmp     0b
1:      popa
        retw

DAPACK: .byte 0x10                      # Size of packet
        .byte 0x00                      # Always 0
        .word 0x41                      # Number of sectors to transfer
        .word 0x7E00, 0x0000            # Transfer buffer
        .quad 0x0000000000000001        # LBA addr. of sector to read from disk

load_fail: .string "Failed to load boot2...\r\n"
.org 510
.word 0xAA55
