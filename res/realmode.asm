org 0x3000
use32
    magic dd 0xABCDABCD
	pm_idt dd 0x0
	rm_registres:
		.eax:
		._ax:
			._al db 0x0
			._ah db 0x0
			     dw 0x0
		.ebx:
		._bx:
			._bl db 0x0
			._bh db 0x0
			     dw 0x0		
		.ecx:
		._cx:
			._cl db 0x0
			._ch db 0x0
			     dw 0x0
		.edx:
		._dx:	._dl db 0x0
			._dh db 0x0
			     dw 0x0
		.esi:		
			._si  dw 0x0
			     dw 0x0
		.edi:
			._di dw 0x0
			    dw 0x0

		._es:	dw 0x0
			dw 0x0
					
	.interrupt	db 0x0			;+52
			db 0x0
			dw 0x0
_RM_START@0:
cli
	; on charge notre gdt, idt et pile
	push ds
	push es
	push fs
	push gs
	mov [pm_esp],esp
	mov esp,0x4000
	lidt [rm_idt_ptr]
	;switcher de mode
	mov ax,0x38
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov gs,ax
	jmp 0x30:rmode
	use16
	rmode:
	mov eax,cr0
	xor al,1
	mov cr0,eax
	mov sp,0xe000
	mov ax,0x0
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	jmp 0x0:rmode1
	rmode1: 

	;effectuer les op?rations
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor esi,esi
	xor edi,edi
	mov ax, word [rm_registres._es]
	mov es,ax
	mov ax, word [rm_registres._ax]
	mov bx, word [rm_registres._bx]
	mov cx, word [rm_registres._cx]
	mov dx, word [rm_registres._dx]
	mov si, word [rm_registres._si]
	mov di, word [rm_registres._di]
	cmp byte [rm_registres.interrupt],0x10		;vga int
	jne @f
		int 0x10
	@@:
	cmp byte [rm_registres.interrupt],0x11		;bios ,return equipement list
	jne @f
		int 0x11
	@@:
	cmp byte [rm_registres.interrupt],0x12		;bios ,return conventional memory size
	jne @f
		int 0x12
	@@:
	cmp byte [rm_registres.interrupt],0x13		;low level disk sevice
	jne @f
		int 0x13
	@@:
	cmp byte [rm_registres.interrupt],0x14		;communicating via serial port
	jne @f
		int 0x14
	@@:
	cmp byte [rm_registres.interrupt],0x15		;misc
	jne @f
		int 0x15
	@@:
	cmp byte [rm_registres.interrupt],0x16		;Keyboard
	jne @f
		int 0x16
	@@:
	cmp byte [rm_registres.interrupt],0x17		;communicate with the printer
	jne @f
		int 0x17
	@@:
	cmp byte [rm_registres.interrupt],0x1a		;Real Time Clock services
	jne @f
		int 0x1a
	@@:

	;/sauvegarde des valeurs de retour
  mov word [rm_registres._ax],ax
  mov word [rm_registres._bx],bx
  mov word [rm_registres._cx],cx
  mov word [rm_registres._dx],dx
  mov word [rm_registres._si],si
  mov word [rm_registres._di],di
 
 
	;switcher de mode
	mov eax,cr0
	or eax,0x1
	mov cr0,eax
	mov ax,0x10
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	jmp 0x8:pmode
	use32
	pmode: 
	mov eax,[pm_idt]
	lidt [eax]
	mov ax,0x10
	mov ss,ax
	jmp 0x8:fin
	fin:
	mov esp,[pm_esp]
	pop gs
	pop fs
	pop es
	pop ds
	;/restauration des valeurs sauvegard?es
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor esi,esi
	xor edi,edi

	mov ax, word [rm_registres._ax]
	mov bx, word [rm_registres._bx]
	mov cx, word [rm_registres._cx]
	mov dx, word [rm_registres._dx]
	mov si, word [rm_registres._si]
	mov di, word [rm_registres._di]
sti
ret

;----------------------------------
; zone de donn?es
;----------------------------------
message db "Execution d'une interruption du bios",10,0
pm_esp dd 0
rm_idt_ptr: 
	dw 400h-1                  ; 256 real mode interrupt vectors * 4 - 1
	dd 0                       ; address of interrupt table
	dw 0


_end: