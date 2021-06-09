format binary
org 0x40000000
use32
IMAGE_START:
	dd 0xAADDBBFF
	dd MAIN	 ;init method
_argc	dd 0x0
		dd _argv
		dd _END_END
	
;E:.

;B+ Include C files
  ; Compiler tools
  include "INTRINS.ASM"

  ; C Library ("stdio.asm")
  include "LIBSTD.ASM"

  ; MenuetOS implement
  include "OSFUNC.ASM"

_fopen	equ _OS_fopen
_fputc	equ _OS_fputc
_fgetc	equ _OS_fgetc
_fclose equ _OS_fclos

  ;Main program (compiled from C)
  include "GETARG.ASM"
  include "CC1.ASM"
  include "CC2.ASM"
  include "CC3.ASM"
  include "CC4.ASM"
;E:.

_main_win	dd 0x0
_txt_Input	dd 0x0
_txt_output	dd 0x0
MAIN:
	;create window
	mov eax,0x2
	mov ebx,320*65536+320 ;w shl 16 + h
	mov ecx,caption
	int 0x35
	mov dword [_main_win],eax

	;create label
	mov eax,0x5
	mov ebx,dword [_main_win]
	mov ecx,0*65536+12
	mov edx,0xFF000000
	mov esi,txt_path
	int 0x35
	
	;create textbox
	mov eax,0x4
	mov ebx, dword [_main_win]
	mov ecx, 100*65536+30
	mov edx, 150*65536+5
	int 0x35
	mov dword [_txt_Input],eax
	
	
	
	;create label
	mov eax,0x5
	mov ebx,dword [_main_win]
	mov ecx,0*65536+47
	mov edx,0xFF000000
	mov esi,txt_file
	int 0x35
	
	;create textbox
	mov eax,0x4
	mov ebx, dword [_main_win]
	mov ecx, 100*65536+30
	mov edx, 150*65536+40
	int 0x35
	mov dword [_txt_output],eax
	

	;create button
	mov eax,0x3
	mov ebx,dword [_main_win]
	mov ecx,100*65536+30
	mov edx, 0*65536+75
	mov esi,txt_compile
	mov edi,BTNCLICK
	push ebp
	mov ebp,0
	int 0x35
	pop ebp
	
	
	;wait for event
	mov eax,0x04
	int 0x30
	jmp $
	
BTNCLICK:
	push ebp
	mov ebp,esp
	
	mov eax,0x14
	mov ebx,[_txt_Input]
	mov edi,inp_file
	int 0x35
	mov [p_filename],inp_file

  mov  [_input],-1
  mov  [_input2],-1
  mov  [_usexpr],1
  mov  [_ccode],1
  mov  [_quote],34
  mov  [test_outch.y_coord],60
	
	push dword 4
	push args
	;B+ Save exit ESP
	mov  [exit_esp],esp
	call _main
	add  esp,8
  
	;end callback
	mov esp,ebp
	add esp,12
	mov eax,0x04
	int 0x30
	jmp $
	
	
 



rel_x dd 60
rel_y dw 0x0
c_place dd 0x0
r_pos dd 0x0
char db '?'
;E:.

;E:.

;B+ Data area

;B+ Interface
inp_file: times 100 db '/SYS/TEST.C',0
f_len dd 7



txt_compile db 'Compile',0
txt_path    db 'Input file :',0
txt_file    db 'Output file :',0
;E:.

;B+ Main arguments
args dd arg_str0,inp_file,arg_str2,arg_str3,arg_str4

arg_str0 db 'CC',0
arg_str1 db 'prog',0
arg_str2 db '-m',0
arg_str3 db '-a',0
arg_str4 db '-p',0
;E:.

;B+ System parameters
exit_esp dd 0x0
;E:.

caption db  'Small C compiler for KolibriOS v 0.5.3'
caption_end: db 0

times 8-($ mod 8) db 0
;E:.

_IMAGE_END:
_argv  rb 1024*1024*10
_END_END:
