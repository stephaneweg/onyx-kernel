#include once "console.bi"
#include once "stdlib.bi"


const consoleWidth=80
const consoleHeight=25



sub ConsoleInit()
    VIRT_CONSOLE_MEM = cptr(unsigned byte ptr,&HB8000)
    PHYS_CONSOLE_MEM = cptr(unsigned byte ptr,&HB8000)
    
    SYSCONSOLE.CursorX = 0
    SYSCONSOLE.CursorY = 0
    SYSCONSOLE.Foreground = 7
    SYSCONSOLE.BACKGROUND = 1
    SYSCONSOLE.PHYS = PHYS_CONSOLE_MEM
    SYSCONSOLE.VIRT = VIRT_CONSOLE_MEM
    CurrentConsole = @SYSCONSOLE
    
    ConsoleSetForeground(7)
    ConsoleSetBackground(0)
    ConsoleClear()
    ConsoleUpdateCursor()
    
    ConsoleSetForeground(9)
    ConsoleWrite(@KERNEL_NAME)
    ConsoleWrite(@" ")
    ConsoleWrite(@KERNEL_VERSION)
    ConsoleSetForeground(7)
    ConsoleWriteLine(@" ... System startup")
    
end sub

destructor VirtConsole()
    if (PHYS<>PHYS_CONSOLE_MEM) then
       PMM_FREEPAGE(PHYS)
    end if
end destructor

sub VirtConsole.Activate()
    CurrentConsole=@this
end sub

sub VirtConsole.PutChar(c as byte)
    
    if (c=13) then return
    
    if (c=10) then
        NewLine()
        return
    end if
    if (c=8) then
        BackSpace()
        return
    end if
    if (c=9) then
        CursorX=CursorX+5
    else
        VIRT[(CursorY*consoleWidth+CursorX)*2]=c
        VIRT[(CursorY*consoleWidth+CursorX)*2+1]=(Background* 16 +Foreground)
        CursorX=CursorX+1
        
    end if
    if (CursorX>=consoleWidth) then 
        NewLine()
    end if
end sub


sub VirtConsole.PrintOK()
    VIRT[(CursorY*consoleWidth+consoleWidth-7)*2]=91 '['
    VIRT[(CursorY*consoleWidth+consoleWidth-6)*2]=32 ' '
    VIRT[(CursorY*consoleWidth+consoleWidth-5)*2]=79 'O'
    VIRT[(CursorY*consoleWidth+consoleWidth-4)*2]=75 'K'
    VIRT[(CursorY*consoleWidth+consoleWidth-3)*2]=32 ' '
    VIRT[(CursorY*consoleWidth+consoleWidth-2)*2]=93 ']'
    VIRT[(CursorY*consoleWidth+consoleWidth-1)*2]=32 ' '
    
    VIRT[(CursorY*consoleWidth+consoleWidth-7)*2+1]=(Background* 16 +10)
    VIRT[(CursorY*consoleWidth+consoleWidth-6)*2+1]=(Background* 16 +10)
    VIRT[(CursorY*consoleWidth+consoleWidth-5)*2+1]=(Background* 16 +9)
    VIRT[(CursorY*consoleWidth+consoleWidth-4)*2+1]=(Background* 16 +9)
    VIRT[(CursorY*consoleWidth+consoleWidth-3)*2+1]=(Background* 16 +10)
    VIRT[(CursorY*consoleWidth+consoleWidth-2)*2+1]=(Background* 16 +10)
    VIRT[(CursorY*consoleWidth+consoleWidth-1)*2+1]=(Background* 16 +10)
end sub

sub VirtConsole.PrintFAIL()
    	
	VIRT[(CursorY*consoleWidth+consoleWidth-7)*2]=asc("[")
    VIRT[(CursorY*consoleWidth+consoleWidth-6)*2]=asc("F")
    VIRT[(CursorY*consoleWidth+consoleWidth-5)*2]=asc("A")
    VIRT[(CursorY*consoleWidth+consoleWidth-4)*2]=asc("I")
    VIRT[(CursorY*consoleWidth+consoleWidth-3)*2]=asc("L")
    VIRT[(CursorY*consoleWidth+consoleWidth-2)*2]=asc("]")
    VIRT[(CursorY*consoleWidth+consoleWidth-1)*2]=asc(" ")
    
    
    VIRT[(CursorY*consoleWidth+consoleWidth-7)*2+1]=(Background* 16 +Foreground)
    VIRT[(CursorY*consoleWidth+consoleWidth-6)*2+1]=(Background* 16 +12)
    VIRT[(CursorY*consoleWidth+consoleWidth-5)*2+1]=(Background* 16 +12)
    VIRT[(CursorY*consoleWidth+consoleWidth-4)*2+1]=(Background* 16 +12)
    VIRT[(CursorY*consoleWidth+consoleWidth-3)*2+1]=(Background* 16 +12)
    VIRT[(CursorY*consoleWidth+consoleWidth-2)*2+1]=(Background* 16 +Foreground)
    VIRT[(CursorY*consoleWidth+consoleWidth-1)*2+1]=(Background* 16 +Foreground)
end sub

sub VirtConsole.BackSpace()
    if (CursorX=0) then
        if (CursorY>0) then
            CursorX=consoleWidth-1
			CursorY-=1
        end if
        
    else
        CursorX-=1
    end if
    VIRT[(CursorY*consoleWidth+CursorX)*2]=0
    VIRT[(CursorY*consoleWidth+CursorX)*2+1]=(Background* 16 +Foreground)
end sub
sub VirtConsole.WriteLine(src as unsigned byte ptr)
    this.Write(src)
    this.NewLine()
end sub

sub VirtConsole.Write(src as unsigned byte ptr)
    dim cpt as integer
    cpt=0
    WHILE src[cpt] <> 0
		if (src[cpt]=10) then 
			NewLine()
		elseif(src[cpt]=9) then
			CursorX=CursorX+5
			if (CursorX>=consoleWidth) then NewLine()
		elseif(src[cpt]=13) then
		else
			VIRT[(CursorY*consoleWidth+CursorX)*2]=src[cpt]
			VIRT[(CursorY*consoleWidth+CursorX)*2+1]=(Background* 16 +Foreground)
			CursorX=CursorX+1
			if (CursorX>=consoleWidth) then NewLine()
		end if
        cpt=cpt+1
    WEND
end sub

sub VirtConsole.NewLine()
    CursorX=0
    CursorY=CursorY+1
    if (CursorY>=consoleHeight) then Scroll()
end sub

sub VirtConsole.Scroll()
    memcpy16(cptr(unsigned short ptr,cuint(VIRT)),cptr(unsigned short ptr,cuint(VIRT)+(consoleWidth*2)),consoleWidth*(consoleHeight-1))
    memset16(cptr(unsigned short ptr,cuint(VIRT)+consoleWidth*(consoleHeight-1)*2),(Background* 16 +Foreground) shl 8,consoleWidth)

	CursorY=CursorY-1
end sub

sub VirtConsole.Clear()
    memset16(cptr(unsigned short ptr,cuint(VIRT)),(Background* 16 +Foreground) shl 8,consoleWidth*consoleHeight)
    CursorX = 0
    CursorY = 0
end sub


sub ConsoleSetForeground(c as byte)
    CurrentConsole->Foreground=c
end sub

sub ConsoleSetBackground(c as byte)
    CurrentConsole->Background=c
end sub

sub ConsoleWriteLine(src as unsigned byte ptr)
    CurrentConsole->WriteLine(src)
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

sub ConsolePutChar (c as byte)  
    CurrentConsole->PutChar(c)
end sub

sub ConsolePrintOK()
    CurrentConsole->PrintOK()
end sub
    

sub ConsolePrintFAIL()
    CurrentConsole->PrintFAIL()
end sub

sub ConsoleBackSpace()
    CurrentConsole->BackSpace()
end sub

sub ConsoleWrite(src as unsigned byte ptr)
    CurrentConsole->Write(src)
end sub

sub ConsoleNewLine()
    CurrentConsole->NewLine()
end sub

sub ConsoleClear()
    CurrentConsole->Clear()
end sub

sub ConsoleUpdateCursor()
    'dim position as unsigned short=consoleCursorY*consoleWidth+consoleCursorX
 
    'dim out1 as unsigned byte = cast(unsigned byte,position and &hFF)
	'dim out2 as unsigned byte = cast(unsigned byte,(position shr 8) and &hFF)
    '// cursor LOW port to vga INDEX register
    'outb(&h3D4, &h0F)
    'outb(&h3D5,[out1] )
    '// cursor HIGH port to vga INDEX register
    'outb(&h3D4, &h0E)
    'outb(&h3D5,[out2] )
end sub








 