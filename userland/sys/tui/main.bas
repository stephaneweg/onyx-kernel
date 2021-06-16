
#include once "in_out.bi"
#include once "stdlib.bi"
#include once "system.bi"
#include once "slab.bi"
#include once "file.bi"
#include once "console.bi"
#include once "drivers/mouse.bi"
#include once "drivers/keyboard.bi"


dim shared XRes as unsigned integer
dim shared YRes as unsigned integer
dim shared Bpp as unsigned integer
dim shared BytesPerPixel as unsigned integer
dim shared TMPString as unsigned byte ptr
dim shared TMPString2 as unsigned byte ptr

declare sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 




dim shared lockCritical as unsigned integer

declare sub SpinLock()
declare sub SpinUnLock()

sub SpinLock()
    while lockCritical<>0:wend
        lockCritical = 1
end sub 
sub SpinUnLock()
   lockCritical=0
end sub

type TBuffer field = 1
	BuffPtr as unsigned short ptr
	Width as unsigned integer
	Height as unsigned integer
	
	declare sub Clear(fg as unsigned byte,bg as unsigned byte)
	
end type

sub TBuffer.Clear(fg as unsigned byte,bg as unsigned byte)
	dim cc as unsigned short = (((bg and &hF) shl 4) or (fg and &hF)) shl 8
	memset16(BuffPtr,cc,Width*Height)
end sub


dim shared ConsoleBuff as TBuffer





#include once "stdlib.bas"
#include once "system.bas"
#include once "slab.bas"
#include once "file.bas"
#include once "console.bas"
#include once "drivers/mouse.bas"
#include once "drivers/keyboard.bas"

declare sub GuiLoop(p as any ptr)

sub MAIN(argc as unsigned integer,argv as unsigned byte ptr ptr) 
	SlabInit()
    ConsoleBuff.BuffPtr= Malloc(80*25*2)
    ConsoleBuff.Width  = 80
	ConsoleBuff.Height = 25
	
	
    INIT_KBD()
    INIT_MOUSE()
	
	
    ConsoleWrite(@"Init Textmode Desktop system")
	ConsoleBuff.Clear(15,1)
	do
		memcpy( cptr(any ptr, &hA0000000),ConsoleBuff.BuffPtr,80*25*2)
	loop
end sub





