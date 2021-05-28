format elf
use32

public system_halt
public Mboot

extrn _MAIN@4
extrn ConsoleWriteLine
section ".text"
jmp multiboot_entry
align  4
	Mboot:
		dd 0x1BADB002 ;magic
		dd 0x00000003 ;flags
		dd -(0x1BADB002+0x00000003)
	multiboot_entry:
		cli
		mov esp,pile
		push ebx
		call _MAIN@4
	
	system_halt:
		cli
	aloop: 
		hlt
	jmp     aloop

section ".bss"
	rb 1024*1024
pile:
