/*  BIFROST BOOTLOADER *********************************************************
    
        Version:            0.2.0

        Project repository: https://github.com/sizeof-dario/Bifrost.git

        Licence:            GNU General Public License v3.0                   
        
*******************************************************************************/





/*  Extern symbol fot kernel C "main" function.                               */
.extern kmain

/*  Initial target processor mode is real mode.                               */
.code16



/*  vvv SET NECESSARY CPU REGISTERS vvv ***************************************/

    /*  Set cs:ip pair to a known values pair.                                */
    jmp             $0x0000,        $start
start:

    /*  Set stack.                                                            */
    xor             %ax,            %ax
    mov             %ax,            %ss
    mov             $0x7C00,        %sp

/*  ^^^ SET NECESSARY CPU REGISTERS ^^^ ***************************************/



/*  vvv ENABLE A20 LINE vvv ***************************************************/

    /*  Check if A20 line is already enabled. If so, do nothing.              */
    call            A20_test
    jz              A20_enabled

    /*  Attempt to enable A20 line with BIOS function.                        */
    mov             $0x2401,        %ax
    int             $0x15
    call            A20_test
    jz              A20_enabled

    /*  Attempt to enable A20 line with keyboard controller.                  */
    call            A20_kbc
    call            A20_test_timeout
    jz              A20_enabled

    /*  Attempt to enable A20 line with fast A20 method.                      */
temp_loop:
    hlt
    jmp             temp_loop

A20_enabled:
/*  ^^^ HANDLE A20 LINE ^^^ ***************************************************/





/*  CURRENT MAIN REGISTERS STATE
    ax      bx      cx      dx      cs      ds      es      ss
    0x????  0x????  0x????  0x????  0x????  0x????  0x????  0x????            */

    xor     %ax,        %ax
    mov     %ax,        %es

    # Read 9 extra sectors
    
    # sectors will be placed after MBR at 0x7E00

        # set up registers to query int 0x13
        # dl (drive index) is assumed to be set by the BIOS
        # es (destination segment) is already set to 0x0000
    mov     $0x02,      %ah # read subfunction
    mov     $0x09,      %al # number of sectors (10 - 1)
    mov     $0x00,      %ch # 0-7 cylinder bits
    mov     $0x02,      %cl # 8-9 cylinder bits -> [--][------] <- sector
    mov     $0x00,      %dh # head
    mov     $0x7E00,    %bx # destination offset

    int     $0x13            
    jnc     switch_mode     # halt on failure

# 16 BIT SAFE HALT LOOP
safe_hlt:
    hlt
    jmp     safe_hlt

switch_mode:

    lgdt    %es:GDTR_value
    cli

    # enter protected mode
    mov     %cr0,       %eax
    or      $0x00000001,%eax
    mov     %eax,       %cr0

    # far jump at table index 1 in the GDT, RPL = 0, TI = 0
    jmp     $0x0008,    $start_protected

start_protected:
.code32

    # reset stack
    mov     $0x010,     %ax
    mov     %ax,        %ss
    mov     $0x00080000,%esp # below EBDA

    # other registers
    mov     %ax,        %ds
    mov     %ax,        %es

    # C
    call    kmain

safe_hlt_protected:
    hlt
    jmp safe_hlt_protected








/*  vvv A20 LINE SUBROUTINES vvv **********************************************/

/*  Test if A20 line is enabled. If so, ZF is set to 1, otherwise it is set to
    0. The subroutine doesn't preserve flags and pollutes memory outside the
    MBR, so it should only be called before loading the kernel.               */
A20_test:
    push            %ax
    push            %bx
    push            %ds
    push            %es

    xor             %ax,            %ax
    mov             %ax,            %ds
    mov             $0xFFFF,        %ax
    mov             %ax,            %es
    mov             0x7E00,         %ax
    mov             %ax,            %bx
    inc             %bx
    mov             %bx,            %es:0x7E10
    cmpw            0x7E00,         %ax      

    pop             %es
    pop             %ds
    pop             %bx
    pop             %ax
    ret

A20_test_timeout:
    push            %cx
    mov             $0xFFFF,        %cx
0:
    call            A20_test
    jz              1f
    dec             %cx
    jnz             0b
    or              $0x01,          %cl
1:
    pop             %cx
    ret

/*  Attempt to enable A20 line with keyboard controller.                      
    Data port: 0x60
    Status/Command port: 0x64
    This routine currently does NOT:
        - Check if the controller is present;
        - Empty the data buffer in advance;   
        - Handle permanently disabled keyboard.                               */
A20_kbc:
    push            %ax
    push            %bx
    push            %cx
    pushf

    /*  Disable Interrupts.                                                   */
    cli

    /*  Disable keyboard.                                                     */
    call            A20_wait_status_can_write
    test            %cx,            %cx
    jz              1f
    mov             $0xAD,          %al
    outb            %al,            $0x64

    /*  Read current status from data port.                                   */
    call            A20_wait_status_can_write
    test            %cx,            %cx
    jz              0f
    mov             $0xD0,          %al
    outb            %al,            $0x64
    call            A20_wait_status_can_read
    test            %cx,            %cx
    jz              0f
    inb             $0x60,          %al

    /*  Enable A20 line.                                                      */
    or              $0b00000010,    %al
    mov             %al,            %bl

    /*  Update status.                                                        */
    call            A20_wait_status_can_write
    test            %cx,            %cx
    jz              0f
    mov             $0xD1,          %al
    outb            %al,            $0x64
    call            A20_wait_status_can_write
    test            %cx,            %cx
    jz              0f
    mov             %bl,            %al
    outb            %al,            $0x60
0:

    /*  Enable keyboard.                                                      */
    call            A20_wait_status_can_write
    test            %cx,            %cx
    jz              1f
    mov             $0xAE,          %al
    outb            %al,            $0x64
1:

    /*  Make sure last command took effect.                                   */
    call            A20_wait_status_can_write

    popf
    pop             %cx
    pop             %bx
    pop             %ax
    ret

/*  Wait for command port to be ready for write operation.
    The subroutine reads status register until bit 1 is 0 to know if writing to
    kbc ports is possible; it uses the cx register to signal possible timeout
    failure with a 0 value.                                                   */
A20_wait_status_can_write:
    push            %ax
    mov             $0xFFFF,        %cx    
0:
    outb            %al,            $0x80          /* al value is irrelevant. */
    inb             $0x64,          %al
    and             $0b00000010,    %al
    jz              1f
    dec             %cx
    jnz             0b
1:
    pop             %ax
    ret

/*  Wait for command port to be ready for read operation.
    The subroutine reads status register until bit 0 is 1 to know if reading
    from kbc ports is possible; it uses the cx register to signal possible
    timeout failure with a 0 value.                                           */
A20_wait_status_can_read:
    push            %ax
    mov             $0xFFFF,        %cx    
0:
    outb            %al,            $0x80          /* al value is irrelevant. */
    inb             $0x64,          %al
    and             $0b00000001,    %al
    jnz             1f
    dec             %cx
    jnz             0b
1:
    pop             %ax
    ret

/*  ^^^ A20 LINE SUBROUTINES ^^^ **********************************************/



# vvv GLOBAL DESCRIPTOR TABLE vvv ----------------------------------------------
GDT:
# null segment
.quad 0
# code segment
#       base            = 0x00000000
#       limit           = 0xFFFFF
#
#                         P DPL S E D/C R/A A
#       access byte     = 1 00  1 1 0   0   0 = 0x98
#
#                         G DB L R
#       flags           = 1 1  0 0 = 0xC
.word 0xFFFF
.fill 3, 1, 0x00
.byte 0x98
.byte 0xCF # 0xC0 + 0x0F
.byte 0x00
# data segment
#       base            = 0x00000000
#       limit           = 0xFFFFF
#
#                         P DPL S E D/C R/A A
#       access byte     = 1 00  1 0 0   1   0 = 0x92
#
#                         G DB L R
#       flags           = 1 1  0 0 = 0xC
.word 0xFFFF
.fill 3, 1, 0x00
.byte 0x92
.byte 0xCF # 0xC0 + 0x0F
.byte 0x00
GDT_end:

GDTR_value:
.word GDT_end - GDT - 1
.long GDT
# ^^^ GLOBAL DESCRIPTOR TABLE ^^^ ----------------------------------------------

.org 510
.word 0xAA55
