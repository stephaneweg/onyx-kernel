
macro consoleWrite t{
	pusha
	push t
	pop ebx
	mov eax,0x01
	int 0x31
	popa
}

macro consoleWriteLine t{
	pusha
	push t
	pop ebx
	mov eax,0x02
	int 0x31
	popa
}

macro consoleWriteNumber n,b{
	pusha
	mov eax,0x03
	mov ebx,n
	mov ecx,b
	int 0x31
}

macro consoleNewLine{
	pusha
	mov eax,0x04
	int 0x31
	popa
}
macro consolePutChar c{
	pusha
	push c
	pop ebx
	and ebx,0xFF
	mov eax,0x08
	int 0x31
	popa
}

macro exitProg{
	mov eax,0x05
	int 0x30
}

format binary
org 0x40000000
use32
IMAGE_START:
	dd 0xAADDBBFF
	dd MAIN	 ;init method
_argc	dd 0x0
		dd _argv
		dd IMAGE_END

		
MAIN:
	consoleWriteLine lblHello
	exitProg
	
lblHello db 'Hello world',0

_argv rb 1024
IMAGE_END: