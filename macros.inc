nblocals equ 0

macro beginProc name,[arg]{
nblocals equ 0
num equ 8
forward
if ~ arg eq
  arg equ ebp+num
  num equ num+4
end if
common
name:
	push ebp
	mov ebp,esp
}

macro xcall proc, [arg]{
	common
    if ~ arg eq
   reverse
        pushd   arg
   common
    end if
        call    proc }

macro endProc n{
	mov esp,ebp
	pop ebp
	if ~ n eq
		ret n*4
	else
		ret
	end if
}

macro getParm reg,num{
	mov reg,[ebp+8+4*num]
}	

macro program{
	org 0x40000000
	use32
	IMAGE_START:
	dd 0xAADDBBFF
	dd MAIN	 ;init method
_argc	dd 0x0
		dd _argv
		dd IMAGE_END
		

}

macro endprogram{

_argv rb 1024
	IMAGE_END:
}

macro var name {
nblocals equ nblocals+4
sub esp,4
name equ ebp-(nblocals)
}


numFor equ 0
macro for variable,initial,last,steps,id{
	numFor equ numFor+1
	
	
	push initial
	pop dword [variable]
	
	push last
	pop dword [l.#id]
	
	if ~ steps eq
		push steps
	else
		push 1
	end if
	pop dword [s.#id]
	
	b.#id:
	mov eax,[variable]
	mov ebx,[l.#id]
	cmp eax,ebx
	if (steps>=0)
		jg  e.#id
	else
		jl  e.#id
	end if
}



macro next variable,id{
	mov eax,[variable]
	add eax,[s.#id]
	mov [variable],eax
	jmp b.#id
	s.#id dd 0x0
	l.#id dd 0x0
	
	e.#id:
	
}
	

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

beginProc consolePutChar,c
	mov eax,0x8
	mov ebx,[c]
	and ebx, 0xFF
	int 0x31
	
	mov esp,ebp
	pop ebp
	pop edi
endProc 1

beginProc exitProg
	mov eax,0x5
	int 0x30
endProc