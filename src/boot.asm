# ORG 0x7C00
#       not needed anymore since the file gets assembled into a object file

.intel_syntax noprefix

.extern kmain

.code16
# vvv SET CODE AND STACK REGISTERS vvv -----------------------------------------

        # set cs:ip to 0x0000:0x7C00
        jmp     0x0000:start
start:

        # set the stack below 0x0000:0x7C00
        xor     ax,     ax
        mov     ss,     ax
        mov     sp,     0x7C00

# ^^^ SET CODE AND STACK REGISTERS ^^^ -----------------------------------------

# CURRENT REGISTERS STATE
#       ax      bx      cx      dx      cs      ds      es      ss
#       0x0000  0x????  0x????  0x????  0x0000  0x????  0x????  0x0000

# vvv ENABLE A20 LINE vvv ------------------------------------------------------
        
        # check if A20 line is already enabled
        mov     es,                     ax
        mov     ax,                     0xFFFF
        mov     ds,                     ax
        mov     word ptr[0x7E0E],       0x0000
        cmp     word ptr es:[0x7DFE],   0x55AA

        # do nothing if already enabled
        je      A20_enabled

        # query A20 gate support
        mov     ax,     0x2403                    
        int     0x15
        jc      safe_hlt        # halt on failure
        test    ah,     ah
        jnz     safe_hlt        # halt on failure

        # activate A20 gate
        mov     ax,     0x2401          
        int     0x15
        jc      safe_hlt        # halt on failure
        test    ah,     ah
        jnz     safe_hlt        # halt on failure

A20_enabled:
# ^^^ ENABLE A20 LINE ^^^ ------------------------------------------------------

# CURRENT REGISTERS STATE
#       ax      bx      cx      dx      cs      ds      es      ss
#       0x????  0x????  0x????  0x????  0x0000  0xFFFF  0x0000  0x0000

# vvv READ 9 EXTRA SECTORS vvv -------------------------------------------------

        # sectors will be placed after MBR at 0x7E00

        # set up registers to query int 0x13
        # dl (drive index) is assumed to be set by the BIOS
        # es (destination segment) is already set to 0x0000
        mov     ah,     0x02    # read subfunction
        mov     al,     0x09    # number of sectors (10 - 1)
        mov     ch,     0x00    # 0-7 cylinder bits
        mov     cl,     0x02    # 8-9 cylinder bits -> [--][------] <- sector
        mov     dh,     0x00    # head
        mov     bx,     0x7E00  # destination offset

        int     0x13            
        jnc     switch_mode     # halt on failure

# ^^^ READ 9 EXTRA SECTORS ^^^ -------------------------------------------------

# CURRENT REGISTERS STATE
#       ax      bx      cx      dx      cs      ds      es      ss
#       0x0001  0x7E00  0x0002  0x00??  0x0000  0xFFFF  0x0000  0x0000


# 16 BIT SAFE HALT LOOP
safe_hlt:
        hlt
        jmp     safe_hlt

# vvv SWITCH TO PROTECTED MODE vvv ---------------------------------------------
switch_mode:

        lgdt    [es:GDTR_value]         # load gdt
        cli                             # disable interrupts
        # enter protected mode
        mov     eax,    cr0             
        or      eax,    0x00000001
        mov     cr0,    eax
        # far jump at table index 1 in the GDT, RPL = 0, TI = 0
        jmp     0x0008:start_protected

start_protected:
# ^^^ SWITCH TO PROTECTED MODE ^^^ ---------------------------------------------
.code32

# CURRENT REGISTERS STATE
#       eax             ebx             ecx             edx
#       0x????????      0x????7E00      0x????0002      0x????00??
#       cs      ds      es      ss
#       0x0008  0xFFFF  0x0000  0x0000

# vvv PREPARE FOR C CODE vvv ---------------------------------------------------

        # reset stack
        mov     ax,     0x0010
        mov     ss,     ax
        mov     esp,    0x00080000      # below EBDA

        # set other segment registers
        mov     ds,     ax
        mov     es,     ax

# ^^^ PREPARE FOR C CODE ^^^ ---------------------------------------------------

# CURRENT REGISTERS STATE
#       eax             ebx             ecx             edx
#       0x????0010      0x????7E00      0x????0002      0x????00??
#       cs      ds      es      ss
#       0x0008  0x0010  0x0010  0x0010

# JUMP TO C
        call    kmain

# 32 BIT SAFE HALT LOOP
safe_hlt_protected:
        hlt
        jmp safe_hlt_protected

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
