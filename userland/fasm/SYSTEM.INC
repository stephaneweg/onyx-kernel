
filepos 	 dd 0x0


;====================================================;
; exit_program.                               *fasm* ;
;====================================================;
exit_program:
	jmp MAIN.EndCallBack

;====================================================;
; get_environment_variable.                   *fasm* ;
;====================================================; 
get_environment_variable:
;Code will be added for "environment variable" later.;

	ret

;====================================================;
; make_timestamp.                             *fasm* ;
;====================================================;
make_timestamp:
;Code will be added for "timestamp" later.;
	
	ret

;====================================================;
; open.                                       *fasm* ;
; in                                                 ;
;    edx = zero-ended file name                      ;
;                                                    ;
; out                                                ;
;     ebx = file handle                              ;
;====================================================;
tempHandler  dd 0
FileSize_Handler dd 0
;====================================================;
; open.                                       *fasm* ;
;====================================================; 


msg_file_not_found db 'File not found',0
open:
	pushad

	mov eax,0x03  ; fopen
	mov esi,edx    ; file name
	int 0x33
	cmp eax,0
	ja .ok
		consoleWriteLine(msg_file_not_found)
		xor ebx,ebx
		mov [fileHandleNum],0
		jmp .end
	.ok:
	mov ebx,eax
	mov [fileHandleNum],ebx
	
	
	.end:
	popad
	mov ebx,[fileHandleNum]
	ret

;====================================================;
; read.                                       *fasm* ;
;====================================================; 
read:
	pushad
	mov eax,0x05 ;fread
	;handler in ebx
	;count in ecx
	;dest in esi
	mov edi,esi
	int 0x33
	popad
	clc
	
	
	ret

BufferAA dd 0

; ebx file handle
; ecx count of bytes to write
; edx pointer to buffer
;====================================================;
; write.                                      *fasm* ;
;====================================================; 
write:
	
	pushad
	mov eax,0x06
	;handle in ebx
	;count in ecx
	mov esi,edx
	int 0x33
	popad
	ret	

WriteFileToFloppyError:
	ret		


;====================================================;
; close.                                      *fasm* ;
;====================================================; 
close:	
	pushad
	mov eax,0x07 ;fflush and fclose
	mov ecx,1
	int 0x33
	popad
	ret

	
;====================================================;
; lseek.                                      *fasm* ;
;====================================================; 
lseek:
	pushad
	mov ecx,edx ;count
	xor edx,edx
	mov dl,al ; mode
	mov eax,0x09 ;fseek
	int 0x33
	mov   [filepos],eax
	popad
	mov eax,[filepos]
	ret

;====================================================;
; GetFileSize.                                       ;
;====================================================; 
flen:
	pushad
	;handler already in ebx
	mov eax,0x08
	int 0x33
	mov [filesize],eax
	popad
	mov eax,[filesize]
	ret

;====================================================;
; GetFileSize.                                       ;
;====================================================; 
GetFileSize:
	pushad
	mov ebx,[Fhandler]
	mov eax,0x08
	int 0x33
	mov [filesize],eax
	popad
	mov esi,[filesize]
	ret

;====================================================;
; create.                                     *fasm* ;
;====================================================; 
create:
	pushad
	mov eax,0x04
	mov esi,edx
	int 0x33
	mov [FileHandleNumer],eax
	popad
	mov ebx,[FileHandleNumer]
	ret


;====================================================;
; display_string.                             *fasm* ;
;====================================================; 
display_string:
	consoleWrite esi

;====================================================;
; display_number.                             *fasm* ;
;====================================================;
display_number:
	push	ebx
	mov	ecx,1000000000
	xor	edx,edx
	xor	bl,bl
display_loop:
	div	ecx
	push	edx
	cmp	ecx,1
	je	display_digit
	or	bl,bl
	jnz	display_digit
	or	al,al
	jz	digit_ok
	not	bl
display_digit:
	add	al,30h
	consolePutChar eax
digit_ok:
	mov	eax,ecx
	xor	edx,edx
	mov	ecx,10
	div	ecx
	mov	ecx,eax
	pop	eax
	or	ecx,ecx
	jnz	display_loop
	pop	ebx
	ret
;====================================================;
; display_user_messages                       *fasm* ;
;====================================================;
display_user_messages:
		mov	[displayed_count],0
		call	show_display_buffer
		cmp	[displayed_count],1
		jb	line_break_ok
		je	make_line_break
		mov	ax,word [last_displayed]
		cmp	ax,0A0Dh
		je	line_break_ok
		cmp	ax,0D0Ah
		je	line_break_ok
    make_line_break:
		consoleNewLine
    line_break_ok:
	ret
;====================================================;
; display_block.                              *fasm* ;
;====================================================; 
display_block:
	jecxz	block_displayed
	add	[displayed_count],ecx
	mov	al,[esi+ecx-1]
	mov	[last_displayed],al
	push	ebx
DisplayCharacter:
	lods	byte [esi]
	call	DisplayChar
	loopd	DisplayCharacter
	pop	ebx
block_displayed:
	ret

;====================================================;
; display_character.                          *fasm* ;
;====================================================; 
display_character:
	lods	byte [esi]
	call	DisplayChar  
	loopd	display_character
	ret
;====================================================;
; fatal_error.                                *fasm* ;
;====================================================;  
fatal_error:
	consoleWriteLine(error_prefix)
	pop	esi
	consoleWriteLine esi
	consoleWriteLine(error_suffix)
	jmp	MAIN.EndCallBack
;====================================================;
; assembler_error.                            *fasm* ;
;====================================================;  
assembler_error:
	call	display_user_messages
	push	dword 0
	mov	ebx,[current_line]
get_error_lines:
	push	ebx
	test	byte [ebx+7],80h
	jz	display_error_line
	mov	edx,ebx
find_definition_origin:
	mov	edx,[edx+12]
	test	byte [edx+7],80h
	jnz	find_definition_origin
	push	edx
	mov	ebx,[ebx+8]
	jmp	get_error_lines
display_error_line:
	mov	esi,[ebx]
	call	display_string
	mov	esi,line_number_start
	call	display_string
	mov	eax,[ebx+4]
	and	eax,7FFFFFFFh
	call	display_number
	mov	al,']'
	call	display_character1 
	pop	esi
	cmp	ebx,esi
	je	line_number_ok
	mov	al,20h
	call	display_character1 
	push	esi
	mov	esi,[esi]
	movzx	ecx,byte [esi]
	inc	esi
	call	display_block
	mov	esi,line_number_start
	call	display_string
	pop	esi
	mov	eax,[esi+4]
	and	eax,7FFFFFFFh
	call	display_number
	mov	al,']'
	call	display_character1 
      line_number_ok:
	mov	esi,line_data_start
	call	display_string
	mov	esi,ebx
	mov	edx,[esi]
	call	open
	mov	al,2
	xor	edx,edx
	call	lseek
	mov	edx,[esi+8]
	sub	eax,edx
	push	eax
	xor	al,al
	call	lseek
	mov	ecx,[esp]
	mov	edx,[additional_memory]
	lea	eax,[edx+ecx]
	cmp	eax,[additional_memory_end]
	ja	out_of_memory
	call	read
	call	close
	pop	ecx
	mov	esi,[additional_memory]
get_line_data:
	mov	al,[esi]
	cmp	al,0Ah
	je	display_line_data
	cmp	al,0Dh
	je	display_line_data
	cmp	al,1Ah
	je	display_line_data
	or	al,al
	jz	display_line_data
	inc	esi
	loop	get_line_data
display_line_data:
	mov	ecx,esi
	mov	esi,[additional_memory]
	sub	ecx,esi
	call	display_block
	mov	esi,cr_lf
	call	display_string
	pop	ebx
	or	ebx,ebx
	jnz	display_error_line
	mov	esi,error_prefix
	call	display_string
	pop	esi
	call	display_string
	mov	esi,error_suffix
	call	display_string
	jmp MAIN.EndCallBack
	
;====================================================;
; DisplayChar.                                       ;
;====================================================; 
DisplayChar:
	pushad
	consolePutChar eax
	popad
	ret

;====================================================;
; display_character1.                                ;
;====================================================; 
display_character1:
	pushad
	consolePutChar eax
	popad
	ret

;====================================================;
; next line.                                         ;
;====================================================; 
Next_line:
	consoleNewLine
	ret
      
;====================================================;
; space.                                             ;
;====================================================; 
space:
	consolePutChar 32
	ret   

;====================================================;
; tab.                                               ;
;====================================================; 
tab:
	consolePutChar 9
	ret
;====================================================;
; Just in case no fat module loaded                  ;
;====================================================;
NoModuleLoaded:
	stc
	ret

;====================================================;
; Data.                                              ;
;====================================================;
var		  			dd 0
LoadAdressOfFile	dd 0
testfile	  		dd 0
NameAddress	  		dd 0
AdressAddOn	  		dd 0
AmountOfBytes	  	dd 0
NumberOfBinFile   	dd 0
Buffer		  		dd 0
Fhandler	  		dd 0
FileHandleNumer   	dd 0
ErrorCode	  		db 0
filesize	  		dd 0x0
FileNameVar	  		dd 0
error_prefix	  	db 'error: ',0
error_suffix	  	db '.',10,0
line_data_start   	db ':',10,0
cr_lf		  		db 10,0
line_number_start 	db ' [',0
space1		  		db ' ',0
tab1		  		db '      ',0
macro dm string { db string,0 }

