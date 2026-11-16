/*
        Let's understand what we are dealing with:

        We want to start using C as soon as possible. So we go for a two-stage
        bootloader. This first stage's only job is to prep things up in order to
        load the second, bigger stage written in C.

        HUGE NOTE: we are in real mode, so we are restricted to 64KB segments.
        So, given that this sector will be placed at 0x7C00 that the space from
        0x0000 to 0x04FF is reserved and that we can't go past 0xFFFF, we get
        about 30KB of space both below and above it.
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

        # Update blkcnt
        movw    $boot2_end, %ax
        subw    $boot2_start, %ax
        shrw    $0x09, %ax
        movw    %ax, blkcnt

        # Load boot2 (we assume %dl = drive number, set by the BIOS)
        movw    $DAPACK, %si
        movb    $0x42, %ah
        int     $0x13
        jnc     z_bss

        # If we fail here, we can't do much more...
        movw    $load_fail, %si
        callw   puts
        jmp     die

        # Zero the bss
z_bss:  movw    $bss_start, %di
        movw    $bss_end, %cx
        xorl    %eax, %eax
        subw    %di, %cx
        shrw    $0x02, %cx
        rep stosl     

        # Jump to C code (should not return)
        pushl   %edx                   # Keep the drive number
        calll   boot2main
        # Fall through...

        movw    $boot2main_ret, %si
        callw   puts

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
blkcnt: .word 0x0000                    # Number of sectors to transfer
                                        #       Gets updated at runtime

        .word 0x7E00, 0x0000            # Transfer buffer
        .quad 0x0000000000000001        # LBA addr. of sector to read from disk

load_fail:      .string "Failed to load boot2...\r\n"
boot2main_ret:  .string "boot2main returned...\r\n"

.org 510
.word 0xAA55
