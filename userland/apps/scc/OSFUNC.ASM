include "macros.inc"
;
; OS function implementation
; SmallC for KolibriOS
;

;B+ General definitions

;B+ File defs
 ;const
  ;param
  BAD	equ -1
  files equ 100
  save_buffer		equ 0x20000 ;32
  save_buffer_w 	equ 0x400000 ;32
  save_file_name	equ 0x20000

  ;system
  EOF equ -1

 ;memory
 fileinfo     equ _IMAGE_END
 start_data   equ (fileinfo+16384)
 ;
 mem_heap equ 0x100000
 ;
 g_handle equ 0x300000
  ;dword - pointer - relative to file
  ;dword - begin of file
  ;dword - file size
  ;dword - 0/1 <=> read/write

;B+ Main OS functions
ppp dd 70

_OS_fopen:

mov eax,[esp+4]
cmp  byte [eax],'w'
je	.open_write

.open_read:
	mov eax,0x3
	mov esi,[esp+8]
	int 0x33
	;handle in eax
  ret

.open_write:
	mov eax,0x4 ;file create
	mov esi,[p_filename]
	int 0x33
	;handle in eax
  ret
  
;B+ Close file
 ;esp+4 - file handle
_OS_fclos:
	mov eax,0x7
	mov ebx,[esp+4]
	mov ecx,1
	int 0x33
  ret
;E:.

_f_byte dd 0x0

_OS_fgetc:
   mov eax,0x5 ;fread
   mov ebx,[esp+4]
   mov ecx,1
   mov edi,_f_byte
   int 0x33
   mov eax,[_f_byte]
  ret
;E:.

;rrr db 'g',0

_OS_fputc:
	mov eax,[esp+8]
	mov [_f_byte],eax
	
	mov eax,0x6  		;fwrite
	mov ebx,[esp+4]		;file handle
	mov ecx,1			;1 byte
	mov esi,_f_byte
	int 0x33
	xor  eax,eax
  ret
;E:.

_OS_callo:
;B+ Alloc memory
  ;find all size
  mov  eax,[esp+4]
  mov  ebx,[esp+8]
  mul  ebx
 push eax

  ;clear memory
  mov  edi,[.mem_p]
  xor  eax,eax
  mov  ecx,[esp]
  cld
rep  stosb

  ;update new memory pointer
 pop  ebx
 push dword [.mem_p]
  add  ebx,7
  and  ebx,not 7
  add  [.mem_p],ebx

  ;return value
 pop  eax
  ret

.mem_p dd mem_heap
;E:.

_OS_exit:
	mov eax,0x5
	int 0x30
  ret




;B+ Test procedures

;B+ Definitions
LEFTMARGIN equ 11
BEGIN_CHARS equ 20
NL equ 10
;E:.

print_textcolor dd 0x00ffff

_file_beg:
	;B+ Show begin of file - test fopen
	;esp+4 - file handle (descriptor)

 ;' mov  eax,[esp+4]
 ;' mov  ebx,10 shl 16 + 30
 ; mov  ecx,[print_textcolor]
 ; mov  edx,[eax+4]
 ; mov  esi,BEGIN_CHARS
 ; mov  eax,4
 ; int  0x40
  ret
;E:.

_outstrg:
;B+ Draw black text - test function call
 ;esp+4*4 - x
 ;esp+4*3 - y
 ;esp+4*2 - *c
 ;esp+4*1 - len

;  mov  ebx,[esp+4*4]
;  shl  ebx,16
;  mov  bx,[esp+4*3]
;  mov  ecx,[print_textcolor]
;  mov  edx,[esp+4*2]
;  mov  esi,[esp+4]
;  mov  eax,4
;  int  0x40
  ret
;E:.

test_outch:
	mov eax,0x0
	mov ebx,[esp+8]
	and ebx,0xFF
	int 0x31
  ret

.x_coord dd LEFTMARGIN
.y_coord dd 60
.out_char db 0
;E:.




p_filename dd 0x0

