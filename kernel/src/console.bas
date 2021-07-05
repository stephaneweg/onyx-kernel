#include once "console.bi"
#include once "stdlib.bi"



sub ConsoleInit()
    CONSOLE_MEM = cptr(unsigned byte ptr,&HB8000)
    
    consoleWidth            = 80
    consoleHeight           = 25
    consoleLineOffset       = 0
    consoleCursorX          = 0
    consoleCursorY          = 0
    consoleForeground       = 7
    consoleBackground       = 0
    ConsoleClear()
    ConsoleUpdateCursor()
    
    ConsoleSetForeground(9)
    ConsoleWrite(@KERNEL_NAME)
    ConsoleWrite(@" ")
    ConsoleWrite(@KERNEL_VERSION)
    ConsoleWriteLine(@" startup ...")
    ConsoleSetForeground(7)
    ConsoleNewLine
end sub

sub ConsolePutChar(c as byte)
    
    if (c=13) then return
    
    if (c=10) then
        ConsoleNewLine()
        return
    end if
    if (c=8) then
        ConsoleBackSpace()
        return
    end if
    if (c=9) then
        consoleCursorX += 5-(consoleCursorX mod 5)
        if (consoleCursorX>=consoleWidth) then ConsoleNewLine()
    else
        CONSOLE_MEM[(consoleLineOffset+consoleCursorX)*2]=c
        CONSOLE_MEM[(consoleLineOffset+consoleCursorX)*2+1]=((consoleBackground* 16) +consoleForeground)
        consoleCursorX=consoleCursorX+1
        
    end if
    if (consoleCursorX>=consoleWidth) then 
        ConsoleNewLine()
    end if
    ConsoleUpdateCursor()
end sub


sub ConsolePrintOK()
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-7)*2]=91 '['
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-6)*2]=32 ' '
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-5)*2]=79 'O'
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-4)*2]=75 'K'
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-3)*2]=32 ' '
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-2)*2]=93 ']'
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-1)*2]=32 ' '
    
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-7)*2+1]=(consoleBackground* 16 + 9)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-6)*2+1]=(consoleBackground* 16 + consoleForeground)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-5)*2+1]=(consoleBackground* 16 + 10)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-4)*2+1]=(consoleBackground* 16 + 10)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-3)*2+1]=(consoleBackground* 16 + consoleForeground)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-2)*2+1]=(consoleBackground* 16 + 9)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-1)*2+1]=(consoleBackground* 16 + consoleForeground)
end sub

sub ConsolePrintFAIL()
    	
	CONSOLE_MEM[(consoleLineOffset+consoleWidth-7)*2]=asc("[")
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-6)*2]=asc("F")
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-5)*2]=asc("A")
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-4)*2]=asc("I")
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-3)*2]=asc("L")
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-2)*2]=asc("]")
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-1)*2]=asc(" ")
    
    
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-7)*2+1]=(consoleBackground* 16 + 9)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-6)*2+1]=(consoleBackground* 16 + 12)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-5)*2+1]=(consoleBackground* 16 + 12)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-4)*2+1]=(consoleBackground* 16 + 12)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-3)*2+1]=(consoleBackground* 16 + 12)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-2)*2+1]=(consoleBackground* 16 + 9)
    CONSOLE_MEM[(consoleLineOffset+consoleWidth-1)*2+1]=(consoleBackground* 16 + consoleForeground)
end sub

sub ConsoleBackSpace()
    if (consoleCursorX=0) then
        if (consoleCursorY>0) then
            consoleCursorX=consoleWidth-1
			consoleCursorY-=1
        end if
        
    else
        consoleCursorX-=1
    end if
    consoleLineOffset = consoleCursorY * consoleWidth
    CONSOLE_MEM[(consoleLineOffset+consoleCursorX)*2]=0
    CONSOLE_MEM[(consoleLineOffset+consoleCursorX)*2+1]=(consoleBackground* 16 +consoleForeground)
    
    ConsoleUpdateCursor()
end sub

sub ConsoleWriteLine(src as unsigned byte ptr)
    ConsoleWrite(src)
    ConsoleNewLine()
    
    ConsoleUpdateCursor()
end sub

sub ConsoleWrite(src as unsigned byte ptr)
    dim cpt as integer
    cpt=0
    WHILE src[cpt] <> 0
		if (src[cpt]=10) then 
			ConsoleNewLine()
		elseif(src[cpt]=9) then
			consoleCursorX += 5-(consoleCursorX mod 5)
			if (consoleCursorX>=consoleWidth) then ConsoleNewLine()
		elseif(src[cpt]=13) then
		else
			CONSOLE_MEM[(consoleLineOffset+consoleCursorX)*2]=src[cpt]
			CONSOLE_MEM[(consoleLineOffset+consoleCursorX)*2+1]=(consoleBackground* 16 +consoleForeground)
			consoleCursorX=consoleCursorX+1
			if (consoleCursorX>=consoleWidth) then ConsoleNewLine()
		end if
        cpt=cpt+1
    WEND
end sub

sub ConsoleNewLine()
    consoleCursorX=0
    consoleCursorY=consoleCursorY+1
    if (consoleCursorY>=consoleHeight) then ConsoleScroll()
    consoleLineOffset = consoleCursorY*ConsoleWidth
end sub

sub ConsoleScroll()
    memcpy16(cptr(unsigned short ptr,cuint(CONSOLE_MEM)),cptr(unsigned short ptr,cuint(CONSOLE_MEM)+(consoleWidth*2)),consoleWidth*(consoleHeight-1))
    memset16(cptr(unsigned short ptr,cuint(CONSOLE_MEM)+consoleWidth*(consoleHeight-1)*2),(consoleBackground* 16 +consoleForeground) shl 8,consoleWidth)

	consoleCursorY=consoleCursorY-1
    consoleLineOffset = consoleCursorY*ConsoleWidth
end sub

sub ConsoleClear()
    memset16(cptr(unsigned short ptr,cuint(CONSOLE_MEM)),(consoleBackground* 16 +consoleForeground) shl 8,consoleWidth*consoleHeight)
    consoleCursorX = 0
    consoleCursorY = 0
    consoleLineOffset = consoleCursorY*ConsoleWidth
end sub


sub ConsoleSetForeground(c as byte)
    consoleForeground=c
end sub

sub ConsoleSetBackground(c as byte)
    consoleBackground=c
end sub

sub ConsoleWriteTextAndHex(src as unsigned byte ptr,n as unsigned integer,newline as boolean)
    ConsoleWrite(src)
    ConsoleWrite(@" 0x")
    ConsoleWriteNumber(n,16)
    if (newline) then ConsoleNewLine()
end sub

sub ConsoleWriteTextAndDec(src as unsigned byte ptr,n as unsigned integer,newline as boolean)
    ConsoleWrite(src)
    ConsoleWrite(@" ")
    ConsoleWriteNumber(n,10)
    if (newline) then ConsoleNewLine()
end sub

sub ConsoleWriteTextAndSize(src as unsigned byte ptr,s as unsigned integer,newline as boolean)
    ConsoleWrite(src)
    ConsoleWrite(@" ")
    if (s<&h400) then 
        ConsoleWriteNumber(s,10)
        ConsoleWrite(@" Bytes")
    elseif (s<&h100000) then
        ConsoleWriteNumber(s shr 10,10)
        ConsoleWrite(@" KB")
    else
        ConsoleWriteNumber(s shr 20,10)
        ConsoleWrite(@" MB")
    end if
    
    if (newline) then ConsoleNewLine()
end sub
    
sub ConsoleWriteSigned(number as integer)
	dim myNumber as unsigned integer
	myNumber=number
	
	if (number <0) then
		ConsolePutChar(45)
		myNumber=&hffffffff - number
	end if
	ConsoleWriteNumber(myNumber,10)
end sub

sub ConsoleWriteUNumber(number as unsigned integer,abase as unsigned integer)
    ConsoleWrite(UIntToStr(number,abase))
end sub

sub ConsoleWriteNumber(number as integer,abase as unsigned integer)
    ConsoleWrite(IntToStr(number,abase))
end sub

sub ConsoleUpdateCursor()
    dim position as unsigned short=consoleCursorY*consoleWidth+consoleCursorX
 
    dim out1 as unsigned byte = cast(unsigned byte,position and &hFF)
	dim out2 as unsigned byte = cast(unsigned byte,(position shr 8) and &hFF)
    '// cursor LOW port to vga INDEX register
    outb(&h3D4, &h0F)
    outb(&h3D5,[out1] )
    '// cursor HIGH port to vga INDEX register
    outb(&h3D4, &h0E)
    outb(&h3D5,[out2] )
end sub








 