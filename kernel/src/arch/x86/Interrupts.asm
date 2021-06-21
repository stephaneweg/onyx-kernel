macro exception intno
{
	align 4
	label int#intno
	;cli
		push 0x#intno
	jmp irq_common
}

macro interrupt intno
{
	align 4
	label int#intno
	;cli
		push dword 0
		push 0x#intno
	jmp irq_common
}

macro interrupts16 n{
	interrupt n#0
	interrupt n#1
	interrupt n#2
	interrupt n#3
	interrupt n#4
	interrupt n#5
	interrupt n#6
	interrupt n#7
	interrupt n#8
	interrupt n#9
	interrupt n#a
	interrupt n#b
	interrupt n#c
	interrupt n#d
	interrupt n#e
	interrupt n#f
}


macro inttab n{
	dd int#n#0,int#n#1,int#n#2,int#n#3,int#n#4,int#n#5,int#n#6,int#n#7,int#n#8,int#n#9,int#n#a,int#n#b,int#n#c,int#n#d,int#n#e,int#n#f
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
	;sti
iret

interrupt 00
interrupt 01
interrupt 02
interrupt 03
interrupt 04
interrupt 05
interrupt 06
interrupt 07
exception 08
interrupt 09
exception 0a
exception 0b
exception 0c
exception 0d
exception 0e
interrupt 0f

interrupt 10
exception 11
interrupt 12
interrupt 13
interrupt 14
exception 15
interrupt 16
interrupt 17
interrupt 18
interrupt 19
interrupt 1a
interrupt 1b
interrupt 1c
interrupt 1d
interrupt 1e
interrupt 1f

interrupts16 2
interrupts16 3
interrupts16 4
interrupts16 5
interrupts16 6
interrupts16 7
interrupts16 8
interrupts16 9
interrupts16 a
interrupts16 b
interrupts16 c
interrupts16 d
interrupts16 e
interrupts16 f

align 4
_INTERRUPT_TAB@0:
inttab 0
inttab 1
inttab 2
inttab 3
inttab 4
inttab 5
inttab 6
inttab 7
inttab 8
inttab 9
inttab a
inttab b
inttab c
inttab d
inttab e
inttab f
