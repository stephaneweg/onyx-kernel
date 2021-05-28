macro outportb port,val
{
	mov al,val
	out port,al
}
macro int_elem_err mylabel,intno
{
	align 4
    label mylabel
    cli
		push intno
	jmp irq_common
}
macro int_elem mylabel,intno
{
	align 4
    label mylabel
    cli
		push dword 0
		push intno
	jmp irq_common
}

format elf
use32


macro save_context
{
	push ds
	push es
	push fs
	push gs
	
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
	push ebp
	
}

macro restore_context
{
	pop ebp
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	
	pop gs
	pop fs
	pop es
	pop ds
}
public _INTERRUPT_TAB@0
extrn _INT_HANDLER@4

section ".text"

align 4
irq_common:
	;the error code and int number is in the stack
    save_context

	mov ebp,esp
	push ebp
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    call _INT_HANDLER@4
	mov esp,eax
	restore_context
	add esp,8 ; skip error code and int number
	sti
iret

int_elem int00,0x00
int_elem int01,0x01
int_elem int02,0x02
int_elem int03,0x03
int_elem int04,0x04
int_elem int05,0x05
int_elem int06,0x06
int_elem int07,0x07
int_elem_err int08,0x08
int_elem int09,0x09
int_elem_err int0a,0x0a
int_elem_err int0b,0x0b
int_elem_err int0c,0x0c
int_elem_err int0d,0x0d
int_elem_err int0e,0x0e
int_elem int0f,0x0f

int_elem int10,0x10
int_elem_err int11,0x11
int_elem int12,0x12
int_elem int13,0x13
int_elem int14,0x14
int_elem_err int15,0x15
int_elem int16,0x16
int_elem int17,0x17
int_elem int18,0x18
int_elem int19,0x19
int_elem int1a,0x1a
int_elem int1b,0x1b
int_elem int1c,0x1c
int_elem int1d,0x1d
int_elem int1e,0x1e
int_elem int1f,0x1f

int_elem int20,0x20
int_elem int21,0x21
int_elem int22,0x22
int_elem int23,0x23
int_elem int24,0x24
int_elem int25,0x25
int_elem int26,0x26
int_elem int27,0x27
int_elem int28,0x28
int_elem int29,0x29
int_elem int2a,0x2a
int_elem int2b,0x2b
int_elem int2c,0x2c
int_elem int2d,0x2d
int_elem int2e,0x2e
int_elem int2f,0x2f

int_elem int30,0x30
int_elem int31,0x31
int_elem int32,0x32
int_elem int33,0x33
int_elem int34,0x34
int_elem int35,0x35
int_elem int36,0x36
int_elem int37,0x37
int_elem int38,0x38
int_elem int39,0x39
int_elem int3a,0x3a
int_elem int3b,0x3b
int_elem int3c,0x3c
int_elem int3d,0x3d
int_elem int3e,0x3e
int_elem int3f,0x3f
int_elem int40,0x40

align 4
_INTERRUPT_TAB@0:
dd int00,int01,int02,int03,int04,int05,int06,int07,int08,int09,int0a,int0b,int0c,int0d,int0e,int0f
dd int10,int11,int12,int13,int14,int15,int16,int17,int18,int19,int1a,int1b,int1c,int1d,int1e,int1f
dd int20,int21,int22,int23,int24,int25,int26,int27,int28,int29,int3a,int2b,int2c,int2d,int2e,int2f
dd int30,int31,int32,int33,int34,int35,int36,int37,int38,int39,int3a,int3b,int3c,int3d,int3e,int3f
dd int40
