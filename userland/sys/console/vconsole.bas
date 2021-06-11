constructor VirtConsole()
    CursorX = 0
    CursorY = 0
    Foreground = 7
    Background = 0
    
    ConsoleWidth    = 0
    ConsoleHeight   = 0
    Buffer = 0
    
    NextConsole = Consoles
    Consoles = @this
end constructor

destructor VirtConsole()
    if (buffer<>0 and buffer<>&hA0000000) then
        Free(Buffer)
    end if
end destructor

function Virtconsole.Find(o as unsigned integer) as VirtConsole ptr
    if (o=0) then return SysConsole
    
    var con = Consoles
    while con<>0
        if (con->Owner = o) then return con
        con=con->NextConsole
    wend
    return Find(GetParentProcess(o))
end function

function Virtconsole.CreateDisplay() as VirtConsole ptr
    dim result as VirtConsole ptr = MAlloc(sizeof(VirtConsole))
    result->constructor()
    
    result->ConsoleWidth = 80
    result->ConsoleHeight = 25
    result->Buffer = cptr(unsigned byte ptr,&hA0000000)
    result->Clear()
    
    return result
end function


function Virtconsole.Create(w as integer,h as integer) as VirtConsole ptr
    dim result as VirtConsole ptr = MAlloc(sizeof(VirtConsole))
    result->constructor()
    
    result->SetSize(w,h)
    result->Clear()
    
    return result
end function



    
    

sub VirtConsole.SetSize(w as integer,h as integer)
    if ((w<>ConsoleWidth) or (h<>ConsoleHeight)) and (w>0) and (h>0) then
        ConsoleWidth = w
        ConsoleHeight = h
    end if
    if (buffer<>0 and buffer<>&HB8000) then
        Free(Buffer)
    end if
    
    Buffer = MAlloc(ConsoleWidth*ConsoleHeight*2)
    Clear()
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
        Buffer[(CursorY*consoleWidth+CursorX)*2]=c
        Buffer[(CursorY*consoleWidth+CursorX)*2+1]=(Background* 16 +Foreground)
        CursorX=CursorX+1
        
    end if
    if (CursorX>=consoleWidth) then 
        NewLine()
    end if
end sub


sub VirtConsole.PrintOK()
    Buffer[(CursorY*consoleWidth+consoleWidth-7)*2]=91 '['
    Buffer[(CursorY*consoleWidth+consoleWidth-6)*2]=32 ' '
    Buffer[(CursorY*consoleWidth+consoleWidth-5)*2]=79 'O'
    Buffer[(CursorY*consoleWidth+consoleWidth-4)*2]=75 'K'
    Buffer[(CursorY*consoleWidth+consoleWidth-3)*2]=32 ' '
    Buffer[(CursorY*consoleWidth+consoleWidth-2)*2]=93 ']'
    Buffer[(CursorY*consoleWidth+consoleWidth-1)*2]=32 ' '
    
    Buffer[(CursorY*consoleWidth+consoleWidth-7)*2+1]=(Background* 16 +10)
    Buffer[(CursorY*consoleWidth+consoleWidth-6)*2+1]=(Background* 16 +10)
    Buffer[(CursorY*consoleWidth+consoleWidth-5)*2+1]=(Background* 16 +9)
    Buffer[(CursorY*consoleWidth+consoleWidth-4)*2+1]=(Background* 16 +9)
    Buffer[(CursorY*consoleWidth+consoleWidth-3)*2+1]=(Background* 16 +10)
    Buffer[(CursorY*consoleWidth+consoleWidth-2)*2+1]=(Background* 16 +10)
    Buffer[(CursorY*consoleWidth+consoleWidth-1)*2+1]=(Background* 16 +10)
end sub

sub VirtConsole.PrintFAIL()
    	
	Buffer[(CursorY*consoleWidth+consoleWidth-7)*2]=asc("[")
    Buffer[(CursorY*consoleWidth+consoleWidth-6)*2]=asc("F")
    Buffer[(CursorY*consoleWidth+consoleWidth-5)*2]=asc("A")
    Buffer[(CursorY*consoleWidth+consoleWidth-4)*2]=asc("I")
    Buffer[(CursorY*consoleWidth+consoleWidth-3)*2]=asc("L")
    Buffer[(CursorY*consoleWidth+consoleWidth-2)*2]=asc("]")
    Buffer[(CursorY*consoleWidth+consoleWidth-1)*2]=asc(" ")
    
    
    Buffer[(CursorY*consoleWidth+consoleWidth-7)*2+1]=(Background* 16 +Foreground)
    Buffer[(CursorY*consoleWidth+consoleWidth-6)*2+1]=(Background* 16 +12)
    Buffer[(CursorY*consoleWidth+consoleWidth-5)*2+1]=(Background* 16 +12)
    Buffer[(CursorY*consoleWidth+consoleWidth-4)*2+1]=(Background* 16 +12)
    Buffer[(CursorY*consoleWidth+consoleWidth-3)*2+1]=(Background* 16 +12)
    Buffer[(CursorY*consoleWidth+consoleWidth-2)*2+1]=(Background* 16 +Foreground)
    Buffer[(CursorY*consoleWidth+consoleWidth-1)*2+1]=(Background* 16 +Foreground)
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
    Buffer[(CursorY*consoleWidth+CursorX)*2]=0
    Buffer[(CursorY*consoleWidth+CursorX)*2+1]=(Background* 16 +Foreground)
end sub

sub VirtConsole.WriteLine(src as unsigned byte ptr)
    This.Write(src)
    This.NewLine()
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
			Buffer[(CursorY*consoleWidth+CursorX)*2]=src[cpt]
			Buffer[(CursorY*consoleWidth+CursorX)*2+1]=(Background* 16 +Foreground)
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
    memcpy16(cptr(unsigned short ptr,cuint(Buffer)),cptr(unsigned short ptr,cuint(Buffer)+(consoleWidth*2)),consoleWidth*(consoleHeight-1))
    memset16(cptr(unsigned short ptr,cuint(Buffer)+consoleWidth*(consoleHeight-1)*2),(Background* 16 +Foreground) shl 8,consoleWidth)

	CursorY=CursorY-1
end sub

sub VirtConsole.Clear()
    memset16(cptr(unsigned short ptr,cuint(Buffer)),(Background* 16 +Foreground) shl 8,consoleWidth*consoleHeight)
    CursorX = 0
    CursorY = 0
end sub

