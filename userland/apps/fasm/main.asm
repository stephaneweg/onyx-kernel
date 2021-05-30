
; flat assembler interface for DosExtreme
; Copyright (c) 1999-2010, Tomasz Grysztar.
; All rights reserved.
format binary
org 0x40000000
use32
IMAGE_START:
	dd 0xAADDBBFF
	dd INIT	 ;init method
	dd 0x0
	dd 0x0
    dd _IMAGE_END
	

mainWin			dd 0x0
txtFileName		dd 0x0
txtOutputFile	dd 0x0
txtArguments	dd 0x0
consoleOut		dd 0x0
btnAssemble		dd 0x0
appTitle		db 'Flat Assembler',0
lblInputFile	db 'Input file :',0
lblOutputFile	db 'Output file : ',0
lblArguments	db 'Arguments :',0
lblAssemble		db 'Assemble',0
lblInfo			db 'Info',0
lblExecute		db 'Execute',0
lblFileNameMandatory	db 'File name is mandatory',0
lblOutputFileMandatory	db 'Output file is mandatory',0


macro consoleWrite t{
pusha
push t
pop ecx
mov eax,0x16
mov ebx,[consoleOut]
int 0x35
popa
}
macro consoleWriteLine t{
pusha
push t
pop ecx
mov eax,0x17
mov ebx,[consoleOut]
int 0x35
popa
}
macro consolePutChar c{
pusha
push c
pop ecx
and ecx,0xFF
mov eax,0x18
mov ebx,[consoleOut]
int 0x35
popa
}

macro consoleNewLine{
pusha
mov eax,0x19
mov ebx,[consoleOut]
int 0x35
popa
}
INIT:
	;window create
	mov eax,0x02
	mov ebx,375
	shl ebx,16
	or ebx,315
	mov ecx,appTitle
	int 0x35
	mov [mainWin],eax
	
	;textblock create
	mov eax,0x05
	mov ebx,[mainWin]
	mov ecx,7  ;0 shl 16 or 7
	xor edx,edx ; cplor black
	mov esi,lblInputFile
	int 0x35
	
	mov eax,0x05
	mov ebx,[mainWin]
	mov ecx,32  ;0 shl 16 or 32
	xor edx,edx ; cplor black
	mov esi,lblOutputFile
	int 0x35
	
	mov eax,0x05
	mov ebx,[mainWin]
	mov ecx,57  ;0 shl 16 or 32
	xor edx,edx ; cplor black
	mov esi,lblArguments
	int 0x35
	
	
	;textbox create
	mov eax,0x04
	mov ebx,[mainWin]
	mov ecx,250
	shl ecx,16
	or ecx,20
	mov edx,120
	shl edx,16
	or edx,5
	int 0x35
	mov [txtFileName],eax
	
	mov eax,0x04
	mov ebx,[mainWin]
	mov ecx,250
	shl ecx,16
	or ecx,20
	mov edx,120
	shl edx,16
	or edx,30
	int 0x35
	mov [txtOutputFile],eax
	
	mov eax,0x04
	mov ebx,[mainWin]
	mov ecx,250
	shl ecx,16
	or ecx,20
	mov edx,120
	shl edx,16
	or edx,55
	int 0x35
	mov [txtArguments],eax
	
	;button create
	push ebp
	mov eax,0x03
	mov ebx,[mainWin]
	mov ecx,90  ;ecx = w shl 16 or h 
	shl ecx,16
	or ecx,30
	mov edx,280
	shl edx,16
	or edx,80  ;edx = x shl 16 or y
	mov esi,lblAssemble
	mov edi,BtnAssembleClick
	mov ebp,0
	int 0x35
	
	mov eax,0x03
	mov ebx,[mainWin]
	mov ecx,90
	shl ecx,16
	or ecx,30
	xor edx,edx
	or edx,80
	mov esi,lblExecute
	mov edi,BtnRunClick
	mov ebp,0
	int 0x35
	
	;console create
	mov eax,0x06
	mov ebx,[mainWin]
	mov ecx,375
	shl ecx,16
	add ecx,195
	mov edx,115
	int 0x35
	mov [consoleOut],eax
	pop ebp
	
	
	
	;wait for event
	mov eax,esp
	mov [savedESP],eax
	mov eax,04
	int 0x30
ret

savedESP dd 0x0

align 4
BtnRunClick:
	
	push ebp
	mov ebp,esp
	
	;get text
	mov eax,0x13
	mov ebx,[txtOutputFile]
	mov edi,outputFileBuff
	int 0x35
	
	;open file
	mov eax, 0x01
	mov esi,outputFileBuff
	mov edi,IMAGE_END
	int 0x33
	test eax,eax
	jz .notOpened
	;file size already in ecx
	mov eax,0x1 ;execute process loaded in memory
	mov ebx,IMAGE_END ;adress of loaded process
	int 0x30
	
	
	.notOpened:
	
	mov esp,ebp
	pop ebp
	
	;end callback
	mov eax,[savedESP]
	mov esp,eax
	mov eax,0x04
	int 0x30
ret


BtnAssembleClick:
	
	mov eax,esp
	mov [savedESP],eax
	
	mov edi,BEGIN_OF_RESERVED
	mov ecx,IMAGE_END
	sub ecx,edi
	xor eax,eax
	cld
	rep movsb
	mov [fileHandleNum],0x0
	mov [filebufferPos],0x0
	
	;get textbox text
	mov eax,0x13
	mov ebx,[txtFileName]
	mov edi,inputFileBuff
	int 0x35
	mov eax,0x13
	mov ebx,[txtOutputFile]
	mov edi,outputFileBuff
	int 0x35
	mov eax,0x13
	mov ebx,[txtArguments]
	mov edi,argumentsBuff
	int 0x35
	
	mov al,[inputFileBuff]
	test al,al
	jnz .okFileName
	consoleWriteLine(lblFileNameMandatory)
	jmp .EndCallBack
	.okFileName:
	
	
	mov al,[outputFileBuff]
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
	
	;end callback
	mov eax,[savedESP]
	mov esp,eax
	mov eax,0x04
	int 0x30
ret


information:
	consoleWriteLine(_usage)
	jmp BtnAssembleClick.EndCallBack



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
	jmp	BtnAssembleClick.EndCallBack



;----------------------------------------------------;
; get_params.                                        ;
;----------------------------------------------------;
get_params:
	mov	[input_file],inputFileBuff
	mov	[output_file],outputFileBuff
	mov	[symbols_file],0
	mov	[memory_setting],0
	mov	[passes_limit],100
	mov	esi,argumentsBuff
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

_copyright db 'Copyright (c) 1999-2012, Tomasz Grysztar',13,10,0

_logo db 'flat assembler  version ',VERSION_STRING,0
_usage db 'usage: fasm <source> [output]',10
       db 'optional settings:',10
       db ' -m <limit>    set the limit in kilobytes for the available memory',10
       db ' -p <limit>    set the maximum allowed number of passes',10
       db ' -s <file>     dump symbolic information for debugging',10
       db 0
_memory_prefix db '  (',0
_memory_suffix db ' kilobytes memory)',13,10,0
_passes_suffix db ' passes, ',0
_seconds_suffix db ' seconds, ',0
_bytes_suffix db ' bytes.',13,10,0

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

include 'variable.inc'

inputFileBuff	rb 256
outputFileBuff	rb 256
argumentsBuff	rb 256

BEGIN_OF_RESERVED:
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

filebuffer rb 400000h
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
