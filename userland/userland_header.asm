format elf
use32

public IMAGE_START
public _init
extrn IMAGE_END
extrn _MAIN@8
extrn _ApplicationTitle

section ".text"
IMAGE_START:
		dd 0xAADDBBFF
		dd _init	 ;init method
_argc:	dd 0x0
		dd _argv
		dd IMAGE_END
	
	
_init:
	push _argv
	push dword [_argc]
	call _MAIN@8
ret

section ".bss"
_argv:
	rb 1024