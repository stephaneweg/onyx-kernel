declare sub XConsoleBlinkThread()
sub XConsoleCREATE(parent as unsigned integer,_x as unsigned integer,_y as unsigned integer,_width as unsigned integer,_height as unsigned integer)
	xConsoleDrawable = cptr(GImage ptr,MAlloc(sizeof(GImage)))
    xConsoleDrawable->Constructor(parent,_x,_y,_width,_height)
	xConsoleDrawable->CLEAR(&hFF000000)
	xConsoleDrawable->Flush()
	
	xConsoleCursorX = 0
	xConsoleCursorY = 0
    xConsoleMaxX = ((_width-4)\8)
    xConsoleMaxY = (_height-4)\FontManager.ML->FontHeight
	
	xConsoleSTD_OUT = STDIO_CREATE()
	xConsoleSTD_IN	= STDIO_CREATE()
	STDIO_SET_OUT(xConsoleSTD_OUT)
	STDIO_SET_IN(xConsoleSTD_IN)
	
	CreateThread(@XConsoleThread,3)
	CreateThread(@XConsoleBlinkThread,3)
	
	GDIOnKeyPress(parent,@XConsoleOnKeyPress)
end sub

sub XConsoleOnKeyPress(elem as unsigned integer,k as unsigned integer)
    STDIO_WRITE_BYTE(xConsoleSTD_IN,k)
	EndCallBack()
end sub

sub XConsoleBlinkThread()
    dim a as integer = 0
    do
        dim xx1 as unsigned integer = 2+xConsoleCursorX*8
        dim yy1 as unsigned integer = 2+xConsoleCursorY*FontManager.ML->FontHeight
        if a = 0 then
            xConsoleDrawable->FillRectangle(xx1,yy1,xx1+7,yy1+FontManager.ML->FontHeight-1,&hFF000000)
            xConsoleDrawable->DrawChar(asc("_"),xx1,yy1,&hFFAAAAAA,FontManager.ML,1)
            xConsoleDrawable->FLush()
            a = 1
        else
            xConsoleDrawable->FillRectangle(xx1,yy1,xx1+7,yy1+FontManager.ML->FontHeight-1,&hFF000000)
            xConsoleDrawable->FLush()
            a = 0
        end if
        
        waitN(500)
    loop
end sub

sub XConsoleThread()
	dim b as unsigned byte
	do
		b = STDIO_READ(xConsoleSTD_OUT)
		if (b<>0) then 
            XCONSOLEPUTCHAR(b)
        else
            WaitN(100)
        end if
	loop
end sub


sub XCONSOLEPUTCHAR(b as unsigned byte)
    dim x1 as unsigned integer = 2+xConsoleCursorX*8
    dim y1 as unsigned integer = 2+xConsoleCursorY*FontManager.ML->FontHeight
	if (b=13) then
		exit sub
	elseif (b=10) then
        xConsoleDrawable->FillRectangle(x1,y1,x1+7,y1+FontManager.ML->FontHeight-1,&hFF000000)
        
		XConsoleNewLine()
	elseif (b=8) then 
        xConsoleDrawable->FillRectangle(x1,y1,x1+7,y1+FontManager.ML->FontHeight-1,&hFF000000)
        
		XConsoleBackSpace()
	elseif(b=9) then
        xConsoleDrawable->FillRectangle(x1,y1,x1+7,y1+FontManager.ML->FontHeight-1,&hFF000000)
		
        xConsoleCursorX += 5-(xConsoleCursorX mod 5)
		if (xConsoleCursorX>=xConsoleMaxX) then XConsoleNewLine()
	else
        xConsoleDrawable->FillRectangle(x1,y1,x1+7,y1+FontManager.ML->FontHeight-1,&hFF000000)
		xConsoleDrawable->DrawChar(b,x1,y1,&hFFAAAAAA,FontManager.ML,1)
		xConsoleCursorX+=1
		if (xConsoleCursorX>=xConsoleMaxX) then XConsoleNewLine()
	end if
    'dim xx1 as unsigned integer = 2+xConsoleCursorX*8
	'dim yy1 as unsigned integer = 2+xConsoleCursorY*FontManager.ML->FontHeight
    
    'xConsoleDrawable->FillRectangle(xx1,yy1,xx1+7,yy1+FontManager.ML->FontHeight-1,&hFF000000)
    'xConsoleDrawable->DrawChar(asc("_"),xx1,yy1,&hFFAAAAAA,FontManager.ML,1)
	xConsoleDrawable->Flush()
end sub

sub XCONSOLENEWLINE()
	xConsoleCursorX=0
	xConsoleCursorY+=1
	if (xConsoleCursorY>=xConsoleMaxY) then XCONSOLESCROLL()
end sub

sub XConsoleBackSpace()
    if (xConsoleCursorX=0) then
		if (xConsoleCursorY>0) then
			xConsoleCursorX=xConsoleMaxX-1
			xConsoleCursorY-=1
		end if
	else
		xConsoleCursorX-=1
	end if
    dim x1 as unsigned integer = 2+xConsoleCursorX*8
    dim y1 as unsigned integer = 2+xConsoleCursorY*FontManager.ML->FontHeight
	xConsoleDrawable->FillRectangle(x1,y1,x1+7,y1+FontManager.ML->FontHeight-1,&hFF000000)
end sub

sub XCONSOLESCROLL()
	dim destY as unsigned integer = 2
	dim srcY  as unsigned integer = 2+FontManager.ML->FontHeight
	xConsoleDrawable->PutOtherPart(xConsoleDrawable,0,destY,0,srcY,xConsoleDrawable->_width,xConsoleDrawable->_height-srcY,0)
	xConsoleDrawable->FillRectangle(0,xConsoleDrawable->_height-srcY,xConsoleDrawable->_width-1,xConsoleDrawable->_height-1,&hFF000000)
	xConsoleCursorY-=1
end sub