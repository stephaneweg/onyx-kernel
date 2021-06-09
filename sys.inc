
beginProc consolePutChar,c
	mov eax,0x0
	mov ebx,[c]
	int 0x31
endProc 1

beginProc consoleWrite,t
	mov eax,0x1
	mov ebx,[t]
	int 0x31
endProc 1

beginProc consoleWriteLine,t
	mov eax,0x2
	mov ebx,[t]
	int 0x31
endProc 1


beginProc consoleWriteNumber,c,b
	mov eax,0x3
	mov ebx,[c]
	mov ecx,[b]
	int 0x31
endProc 2

beginProc consoleNewLine
	mov eax,0x4
	int 0x31
endProc

beginProc consolePrintOK
	mov eax, 0x5
	int 0x31
endProc

beginProc consoleBackSpace
	mov eax,0x6
	int 0x31
endProc

beginProc consoleSetForeground,c
	mov eax,0x7
	mov ebx,[c]
	int 0x31
endProc 1

beginProc consoleSetBackground,c
	mov eax,0x8
	mov ebx,[c]
	int 0x31
endProc 1

beginProc consoleClear
	mov eax,0xf
	int 0x31
endProc

beginProc consoleCreate
	mov eax,0xff
	int 0x31
endProc

beginProc exitProg
	mov eax,0x5
	int 0x30
endProc

macro ConsoleWriteFormat [s,v]{
	forward
		if s eq 's'
			xcall consoleWrite ,v
		else if s eq 'd'
			xcall consoleWriteNumber, v,10
		else if s eq 'x'
			xcall consoleWriteNumber, v,16
		end if
	common
}