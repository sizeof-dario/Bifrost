.extern kmain

.code16

	# set code segment and instruction pointer to known values pair
	ljmp	$0x0000,	$start
start:

	# set stack segment and pointer pair
	xor	%ax,	%ax
	mov	%ax,	%ss
	mov	$0x7C00,	%sp

	# check if A20 line is already enabled
	mov	%ax,	%es
	mov	$0xFFFF,	%ax
	mov	%ax,	%ds
	movw	$0x0000,	0x7E0E
	cmpw	$0x55AA,	%es:0x7DFE
