
; flat assembler interface for DosExtreme
; Copyright (c) 1999-2010, Tomasz Grysztar.
; All rights reserved.
format binary
org 0x40000000
use32
IMAGE_START:
	dd 0xAADDBBFF
	dd MAIN	 ;init method
_argc	dd 0x0
		dd _argv
		dd _END_END
	



macro consolePutChar c{
	pusha
	push c
	pop ebx
	and ebx,0xFF
	mov eax,0x0
	int 0x31
	popa
}

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

macro exitProg{
	mov eax,0x05
	int 0x30
}


MAIN:
	consoleWriteLine _logo
	
	mov eax,dword [_argc]
	cmp eax,2
	jb information

	
	
	mov edi,BEGIN_OF_RESERVED
	mov ecx,IMAGE_END
	sub ecx,edi
	xor eax,eax
	cld
	rep stosb

	mov [fileHandleNum],0x0
	mov [filebufferPos],0x0
	

	mov eax,dword [_argv+0]
	mov eax,dword [eax]
	test al,al
	jnz .okFileName
	consoleWriteLine(lblFileNameMandatory)
	jmp .EndCallBack
	.okFileName:
	
	mov eax, dword [_argv+4]
	mov eax, dword [eax]
	test al,al
	jnz .okFileName2
	consoleWriteLine(lblOutputFileMandatory)
	jmp .EndCallBack
	.okFileName2:
	
	mov [stack_limit],AS_STACK_END
	mov [memory_start],MEM_START
	mov [memory_end],IMAGE_END
	mov [additional_memory],ADD_MEM_START
	mov [additional_memory_end],ADD_MEM_END
	
	;get parameters
	call	get_params   
	jc		information
	
	jmp CommandlineLoopsExit
	.EndCallBack:
	
	exitProg
ret


information:
	consoleWriteLine(_usage)
	jmp MAIN.EndCallBack



CommandlineLoopsExit:
	
	mov [fileHandleNum],0
	mov [memory_end],IMAGE_END
	mov [memory_start],MEM_START
	mov [additional_memory],ADD_MEM_START
	mov [additional_memory_end],ADD_MEM_END
	
	mov	esi,_memory_prefix
	call	display_string
	mov	eax,[memory_end]
	sub	eax,[memory_start]
	add	eax,[additional_memory_end]
	sub	eax,[additional_memory]
	shr	eax,10
	call	display_number
	mov	esi,_memory_suffix
	call	display_string

	call	preprocessor
	call	parser
	call	assembler
	call	formatter

	call	display_user_messages
	movzx	eax,[current_pass]
	inc	eax
	call	display_number
	mov	esi,_passes_suffix
	call	display_string
	jmp	display_bytes_count		     ;;;;;;;;;;;;;;
	;call	[TimerSecondCount]
	mov eax,[start_time]
	sub	eax,[start_time]
	mov	ebx,100
	mul	ebx
	mov	ebx,182
	div	ebx
	or	eax,eax
	jz	display_bytes_count
	xor	edx,edx
	mov	ebx,10
	div	ebx
	push	edx
	call	display_number
	mov	al,'.'
	call	display_character1
	pop	eax
	call	display_number
	mov	esi,_seconds_suffix
	call	display_string
display_bytes_count:
	mov	eax,[written_size]
	call	display_number
	mov	esi,_bytes_suffix
	call	display_string
	xor	al,al
	jmp	MAIN.EndCallBack




;----------------------------------------------------;
; get_params.                                        ;
;----------------------------------------------------;
get_params:

	mov eax,dword [_argv+0]
	mov	[input_file],eax

	mov eax,dword [_argv+4]
	mov	[output_file],eax

	mov	[symbols_file],0
	mov	[memory_setting],0
	mov	[passes_limit],100

	mov eax,dword [_argc]
	cmp eax,3
	jb all_params


	mov	esi,dword [_argv+8]
	mov	edi,params
    find_param:
	lodsb
	cmp	al,20h
	je	find_param
	cmp	al,'-'
	je	option_param
	cmp	al,0Dh
	je	all_params
	or	al,al
	jz	all_params
	process_param:
	cmp	al,22h
	je	string_param
    copy_param:
	stosb
	lodsb
	cmp	al,20h
	je	param_end
	cmp	al,0Dh
	je	param_end
	or	al,al
	jz	param_end
	jmp	copy_param
    string_param:
	lodsb
	cmp	al,22h
	je	string_param_end
	cmp	al,0Dh
	je	param_end
	or	al,al
	jz	param_end
	stosb
	jmp	string_param
    option_param:
	lodsb
	cmp	al,'m'
	je	memory_option
	cmp	al,'M'
	je	memory_option
	cmp	al,'p'
	je	passes_option
	cmp	al,'P'
	je	passes_option
	cmp	al,'s'
	je	symbols_option
	cmp	al,'S'
	je	symbols_option
    invalid_option:
	stc
	ret
    get_option_value:
	xor	eax,eax
	mov	edx,eax
    get_option_digit:
	lodsb
	cmp	al,20h
	je	option_value_ok
	cmp	al,0Dh
	je	option_value_ok
	or	al,al
	jz	option_value_ok
	sub	al,30h
	jc	bad_params_value
	cmp	al,9
	ja	bad_params_value
	imul	edx,10
	jo	bad_params_value
	add	edx,eax
	jc	bad_params_value
	jmp	get_option_digit
    option_value_ok:
	dec	esi
	clc
	ret
    bad_params_value:
	stc
	ret
    memory_option:
	lodsb
	cmp	al,20h
	je	memory_option
	cmp	al,0Dh
	je	invalid_option
	or	al,al
	jz	invalid_option
	dec	esi
	call	get_option_value
	jc	invalid_option
	or	edx,edx
	jz	invalid_option
	cmp	edx,1 shl (32-10)
	jae	invalid_option
	mov	[es:memory_setting],edx
	jmp	find_param
    passes_option:
	lodsb
	cmp	al,20h
	je	passes_option
	cmp	al,0Dh
	je	invalid_option
	or	al,al
	jz	invalid_option
	dec	esi
	call	get_option_value
	jc	bad_params
	or	edx,edx
	jz	invalid_option
	cmp	edx,10000h
	ja	invalid_option
	mov	[es:passes_limit],dx
	jmp	find_param
    symbols_option:
	mov	[es:symbols_file],edi
      find_symbols_file_name:
	lodsb
	cmp	al,20h
	jne	process_param
	jmp	find_symbols_file_name
    param_end:
	dec	esi
    string_param_end:
	xor	al,al
	stosb
	jmp	find_param
    all_params:
	xor	al,al
	stosb

	cmp	[input_file],0
	je	bad_params
	clc
	ret
    bad_params:
	stc
	ret

include 'system.inc'

include 'version.inc'

_copyright db 'Copyright (c) 1999-2012, Tomasz Grysztar',10,0

_logo db 'flat assembler version ',VERSION_STRING,' - port for Onyx',0
_usage db 'usage: fasm <source> [output]',10
       db 'optional settings:',10
       db ' -m <limit>    set the limit in kilobytes for the available memory',10
       db ' -p <limit>    set the maximum allowed number of passes',10
       db ' -s <file>     dump symbolic information for debugging',10
       db 0
_memory_prefix	db '  (',0
_memory_suffix	db ' kilobytes memory)',10,0
_passes_suffix	db ' passes, ',0
_seconds_suffix db ' seconds, ',0
_bytes_suffix	db ' bytes.',10,0

include 'errors.inc'
include 'symbdump.inc'
include 'preproce.inc'
include 'parser.inc'
include 'exprpars.inc'
include 'assemble.inc'
include 'exprcalc.inc'
include 'formats.inc'
include 'x86_64.inc'
include 'avx.inc'

include 'tables.inc'
include 'messages.inc'

align 4

filebufferPos	dd 0x0
fileHandleNum   dd 0x0


BEGIN_OF_RESERVED:
include 'variable.inc'
inputFileBuff	rb 256
outputFileBuff	rb 256
argumentsBuff	rb 256
return dd ?
command_line dd ?
memory_setting dd ?
environment dd ?
timestamp dq ?
start_time dd ?
displayed_count dd ?
last_displayed db ?
character db ?

params rb 100h
Stack2:  rb 1024*100
Stack1:  rb 1024		 			; remember the stack works backward

fileHandles		rd 3*100

buffer rb 1000h
AS_STACK_START:
	rb 1024*1024
AS_STACK_END:
ADD_MEM_START:
			rb 1024*1024
ADD_MEM_END:
MEM_START:
	abuff	rb 1024*1024
IMAGE_END:
rb 1024*1024*10	
_IMAGE_END:
_argv  rb 1024
_END_END:
