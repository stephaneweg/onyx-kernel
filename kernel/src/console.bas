#include once "console.bi"
#include once "stdlib.bi"
dim shared consoleCursorX as integer
dim shared consoleCursorY as integer
dim shared consoleForeground as byte
dim shared consoleBackGround as byte

const consoleWidth=80
const consoleHeight=25

sub ConsoleInit()
    ConsoleSetForeground(7)
    ConsoleSetBackground(1)
    consoleCursorX=0
    consoleCursorY=0
    ConsoleClear()
    ConsoleUpdateCursor()
    
    
    ConsoleWrite(@KERNEL_NAME):ConsoleWrite(@" "):ConsoleWriteLine(@KERNEL_VERSION)
    ConsoleWriteLine(@"System startup")
end sub

sub ConsoleSetForeground(c as byte)
    consoleForeground=c
end sub

sub ConsoleSetBackground(c as byte)
    consoleBackGround=c
end sub

sub ConsoleWriteLine(src as unsigned byte ptr)
    ConsoleWrite(src)
    ConsoleNewLine()
    ConsoleUpdateCursor()
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
    
sub ConsolePutChar (c as byte)  
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
        consoleCursorX=consoleCursorX+5
    else
    dim dst as byte ptr
    dst = CPtr(Byte Ptr, &HB8000)
	
        dst[(consoleCursorY*consoleWidth+consoleCursorX)*2]=c
        dst[(consoleCursorY*consoleWidth+consoleCursorX)*2+1]=(consoleBackGround* 16 +consoleForeGround)
        consoleCursorX=consoleCursorX+1
        
    end if
    if (consoleCursorX>=consoleWidth) then ConsoleNewLine()
        ConsoleUpdateCursor()
end sub

sub ConsolePrintOK()
    dim dst as byte ptr
    dst = CPtr(Byte Ptr, &HB8000)
	
	dst[(consoleCursorY*consoleWidth+consoleWidth-7)*2]=91 '['
    dst[(consoleCursorY*consoleWidth+consoleWidth-6)*2]=32 ' '
    dst[(consoleCursorY*consoleWidth+consoleWidth-5)*2]=79 'O'
    dst[(consoleCursorY*consoleWidth+consoleWidth-4)*2]=75 'K'
    dst[(consoleCursorY*consoleWidth+consoleWidth-3)*2]=32 ' '
    dst[(consoleCursorY*consoleWidth+consoleWidth-2)*2]=93 ']'
    dst[(consoleCursorY*consoleWidth+consoleWidth-1)*2]=32 ' '
    
    
    dst[(consoleCursorY*consoleWidth+consoleWidth-7)*2+1]=(consoleBackGround* 16 +consoleForeGround)
    dst[(consoleCursorY*consoleWidth+consoleWidth-6)*2+1]=(consoleBackGround* 16 +consoleForeGround)
    dst[(consoleCursorY*consoleWidth+consoleWidth-5)*2+1]=(consoleBackGround* 16 +10)
    dst[(consoleCursorY*consoleWidth+consoleWidth-4)*2+1]=(consoleBackGround* 16 +10)
    dst[(consoleCursorY*consoleWidth+consoleWidth-3)*2+1]=(consoleBackGround* 16 +consoleForeGround)
    dst[(consoleCursorY*consoleWidth+consoleWidth-2)*2+1]=(consoleBackGround* 16 +consoleForeGround)
    dst[(consoleCursorY*consoleWidth+consoleWidth-1)*2+1]=(consoleBackGround* 16 +consoleForeGround)
end sub
    

sub ConsolePrintFAIL()
    dim dst as byte ptr
    dst = CPtr(Byte Ptr, &HB8000)
	
	dst[(consoleCursorY*consoleWidth+consoleWidth-7)*2]=asc("[")
    dst[(consoleCursorY*consoleWidth+consoleWidth-6)*2]=asc("F")
    dst[(consoleCursorY*consoleWidth+consoleWidth-5)*2]=asc("A")
    dst[(consoleCursorY*consoleWidth+consoleWidth-4)*2]=asc("I")
    dst[(consoleCursorY*consoleWidth+consoleWidth-3)*2]=asc("L")
    dst[(consoleCursorY*consoleWidth+consoleWidth-2)*2]=asc("]")
    dst[(consoleCursorY*consoleWidth+consoleWidth-1)*2]=asc(" ")
    
    
    dst[(consoleCursorY*consoleWidth+consoleWidth-7)*2+1]=(consoleBackGround* 16 +consoleForeGround)
    dst[(consoleCursorY*consoleWidth+consoleWidth-6)*2+1]=(consoleBackGround* 16 +12)
    dst[(consoleCursorY*consoleWidth+consoleWidth-5)*2+1]=(consoleBackGround* 16 +12)
    dst[(consoleCursorY*consoleWidth+consoleWidth-4)*2+1]=(consoleBackGround* 16 +12)
    dst[(consoleCursorY*consoleWidth+consoleWidth-3)*2+1]=(consoleBackGround* 16 +12)
    dst[(consoleCursorY*consoleWidth+consoleWidth-2)*2+1]=(consoleBackGround* 16 +consoleForeGround)
    dst[(consoleCursorY*consoleWidth+consoleWidth-1)*2+1]=(consoleBackGround* 16 +consoleForeGround)
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


sub ConsoleBackSpace()
    dim dst as byte ptr
    dst = CPtr(Byte Ptr, &HB8000)
   
    if (consoleCursorX=0) then
        if (consoleCursorY>0) then
            consoleCursorX=consoleWidth-1
			consoleCursorY-=1
        end if
        
    else
        consoleCursorX-=1
    end if
    dst[(consoleCursorY*consoleWidth+consoleCursorX)*2]=0
    dst[(consoleCursorY*consoleWidth+consoleCursorX)*2+1]=(consoleBackGround* 16 +consoleForeGround)
	
    ConsoleUpdateCursor()
end sub

sub ConsoleWriteNumber(number as unsigned integer,abase as unsigned integer)
    ConsoleWrite(IntToStr(number,abase))
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

sub ConsoleWrite(src as unsigned byte ptr)
    
    dim cpt as integer
    dim dst as byte ptr
    dst = CPtr(Byte Ptr, &HB8000)
    cpt=0
    WHILE src[cpt] <> 0
		if (src[cpt]=10) then 
			ConsoleNewLine()
		elseif(src[cpt]=9) then
			consoleCursorX=consoleCursorX+5
			if (consoleCursorX>=consoleWidth) then ConsoleNewLine()
		elseif(src[cpt]=13) then
		else
			dst[(consoleCursorY*consoleWidth+consoleCursorX)*2]=src[cpt]
			dst[(consoleCursorY*consoleWidth+consoleCursorX)*2+1]=(consoleBackGround* 16 +consoleForeGround)
			consoleCursorX=consoleCursorX+1
			if (consoleCursorX>=consoleWidth) then ConsoleNewLine()
		end if
        cpt=cpt+1
    WEND
    ConsoleUpdateCursor()
end sub

sub ConsoleNewLine()
    consoleCursorX=0
    consoleCursorY=consoleCursorY+1
    if (consoleCursorY>=consoleHeight) then ConsoleScroll()
    ConsoleUpdateCursor()
end sub


sub ConsoleClear()
    memset16(cptr(unsigned short ptr,&HB8000),(consoleBackGround* 16 +consoleForeGround) shl 8,consoleWidth*consoleHeight)
    consoleCursorX = 0
    consoleCursorY = 0
    ConsoleUpdateCursor()
end sub

sub ConsoleScroll()
    
    memcpy16(cptr(unsigned short ptr,&HB8000),cptr(unsigned short ptr,&HB8000+(consoleWidth*2)),consoleWidth*(consoleHeight-1))
    memset16(cptr(unsigned short ptr,&HB8000+consoleWidth*(consoleHeight-1)*2),(consoleBackGround* 16 +consoleForeGround) shl 8,consoleWidth)

	consoleCursorY=consoleCursorY-1
    ConsoleUpdateCursor()
end sub
 