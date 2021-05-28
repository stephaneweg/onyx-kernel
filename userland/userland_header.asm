format elf
use32

public IMAGE_START
extrn IMAGE_END
extrn _MAIN@4
extrn _ApplicationTitle

section ".text"
IMAGE_START:
	dd 0xAADDBBFF
	dd _MAIN@4	 ;init method
	dd 0x0
	dd 0x0
    dd IMAGE_END