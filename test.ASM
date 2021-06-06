format binary
org 0x40000000
use32
IMAGE_START:
		dd 0xAADDBBFF
		dd MAIN	 ;init method
_argc	dd 0x0
		dd _argv
		dd IMAGE_END
		
include 'macros.inc'
MAIN:
	push ebp
	mov ebp,esp
	
	
	var x
	var s
	
	mov dword [x],3
	mov dword [s],5
	
	xcall consoleWriteLine, lblHello
	xcall consoleWriteLine, lblHello1
	
	
	xcall consoleWriteNumber,[x],10
	xcall consoleNewLine
	xcall consoleWriteNumber,[s],10
	xcall consoleNewLine
	
	
	for x,1,5,1,f1
	xcall consoleWriteNumber,[x],10
	xcall consoleNewLine
	next x,f1
	xcall consoleNewLine
	
	for x,10,5,-1,f2
	xcall consoleWriteNumber,[x],10
	xcall consoleNewLine
	next x,f2
	xcall consoleNewLine
	
	xcall consoleWriteLine,lblHello2
	
	
	mov eax,0x5
	int 0x30
	jmp $

lblHello db 'Hello world',0
lblHello1 db 'this is a test with xcall',0
lblHello2 db 'This was a number',0

_argv rb 1024
IMAGE_END: