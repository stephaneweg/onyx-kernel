

#include once "stdlib.bi"
#include once "stdlib.bas"

#include once "system.bi"
#include once "gdi.bi"
#include once "file.bi"
#include once "slab.bi"
#include once "tobject.bi"
#include once "font.bi"
#include once "fontmanager.bi"
#include once "gimage.bi"

#include once "system.bas"
#include once "gdi.bas"
#include once "slab.bas"
#include once "file.bas"

#include once "tobject.bas"
#include once "font.bas"
#include once "fontmanager.bas"
#include once "gimage.bas"


dim shared mainWin as unsigned integer
dim shared drawableImage as GImage ptr
declare sub TestThread()

dim shared Btn1 as unsigned integer
dim shared btn2 as unsigned integer
dim shared sem as unsigned integer
declare sub Thread1()
declare sub Thread2()
declare sub Thread3()
declare sub btnClick(btn as unsigned integer,parm as unsigned integer)
sub MAIN(p as any ptr) 
	SlabInit()
	MainWin = GDIWindowCreate(330,210,@"DEMOApp")
    drawableImage = cptr(GImage ptr,MAlloc(sizeof(GImage)))
	drawableImage->constructor(MainWin,5,5,320,200)
	drawableImage->Clear(&hFF000000)
    CreateThread(@TestThread,3)
	
	WaitForEvent()
end sub


sub btnClick(btn as unsigned integer,parm as unsigned integer)
	dim s as unsigned integer
	asm mov [s],esp
	
	MessageBoxShow(IntToStr(s,16),@"info")
	
	EndCallBack()
end sub

sub TestThread()
    dim rx as double = 0
    dim ry as double = 0
    dim ix as double = 1
    dim iy as double = 1
    dim c as integer = 0
    do
        c = c+1
		drawableImage->FillRectangle(rx,ry,rx+9,ry+9,c)
        drawableImage->Flush()
        rx += ix
        if (rx+9>=320) then rx = 310:ix=-ix
        if (rx<0) then rx = 0:ix=-ix
        
        
        ry += iy
        if (ry+9>=200) then ry = 190:iy=-iy
        if (ry<0) then ry = 0:iy=-iy
    loop
    
    
    
    
	do:loop
end sub

