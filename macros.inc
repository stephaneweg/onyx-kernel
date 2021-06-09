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
format binary
use32
org 0x40000000
IMAGE_START:
		dd 0xAADDBBFF
		dd MAIN	 ;init method
_argc	dd 0x0
		dd _argv
		dd IMAGE_END
		

}

macro endProgram{

_tmpNext dd 0x0
_tryStackPos dd _tryStack
_tryStack:
	rb 1024

_argv rb 1024
	IMAGE_END:
}

macro try id{
	local .n
	
	mov eax,dword [_tryStackPos]
	
	mov dword [eax],.n
	add eax,4
	
	mov dword [eax],ebp
	add eax,4
	
	mov dword [eax],esp
	add eax,4
	mov dword [_tryStackPos],eax
	
	xor eax,eax
	.n:
	test eax,eax
	jnz catch#id
}
macro endtry id{
	jmp ecatch#id
	etry#id:
	mov eax,[_tryStackPos]
	sub eax,12
	mov dword [_tryStackPos],eax
	ecatch#id:
}

macro throw x{
	mov eax,[_tryStackPos]
	sub eax,12
	mov dword [_tryStackPos],eax
	
	mov ebp,[eax+4]
	mov esp,[eax+8]
	push dword [eax]
	pop dword [_tmpNext]
	
	mov eax,x
	push dword [_tmpNext]
	ret
}

macro catch id{
	jmp etry#id
	catch#id:
	
}
	
	
	
macro var name {
nblocals equ nblocals+4
sub esp,4
name equ ebp-(nblocals)
}

macro xcmp v1,v2{
	push dword v1
	pop dword eax
	push dword v2
	pop dword ebx
	cmp eax,ebx
}

macro ifeq v1,v2,id{
	xcmp v1,v2
	jne .suite#id
}

macro ifl v1,v2,id{
	xcmp v1,v2
	jnl .suite#id
}

macro ifg v1,v2,id{
	xcmp v1,v2
	jng .suite#id
}


macro endif id{
	.suite#id:
}

numFor equ 0
macro for variable,initial,last,steps,id{
	numFor equ numFor+1
	
	
	push dword initial
	pop dword [variable]
	
	push dword last
	pop dword [l.#id]
	
	if ~ steps eq
		push dword steps
	else
		push dword 1
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

macro twoOP v1,v2{
	mov eax,v1
	mov ebx,v2
}

macro xmul v1,v2{
	twoOP v1,v2
	imul eax,ebx
	push eax
}

macro xadd v1,v2{
	twoOP v1,v2
	add eax,ebx
	push eax
}

macro xsub v1,v2{
	twoOP v1,v2
	sub eax,ebx
	push eax
}

macro let dst{
	pop dst
}
	


macro string n,t{
	n db t,0
}
