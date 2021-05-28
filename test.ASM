format binary
org 0x40000000
use32
IMAGE_START:
	dd 0xAADDBBFF
	dd INIT	 ;init method
	dd 0x0
	dd 0x0
    dd IMAGE_END


align 4
INIT:
;create window
	;window create
	mov eax,0x02
	mov ebx,200
	shl ebx,16
	or ebx,100
	mov ecx,window_title
	int 0x35
	mov [mainwin],eax

	;button create
	mov eax,0x03
	mov ebx,[mainwin]
	mov ecx,120  ;ecx = w shl 16 or h 
	shl ecx,16
	or ecx,30
	mov edx,10
	shl edx,16
	or edx,10  ;edx = x shl 16 or y
	mov esi,button_label
	mov edi,BtnClick
	mov ebp,0
	int 0x35
	
	;wait for event
	mov eax,04
	int 0x30
	jmp $
ret

BtnClick:
	push ebp
	mov ebp,esp
	
	mov eax,0x70
	mov ebx,message_text
	mov ecx,message_title
	int 0x35
	
	;end callback
	mov esp,ebp
	pop ebp
	add esp,8
	mov eax,0x04
	int 0x30
ret
message_text db 'This is a message',0
message_title db 'Title of message',0

button_label db 'Click on me!',0
window_title db 'hello world',0
mainwin dd 0x0
btn1 dd 0x0

IMAGE_END: