
dim shared STDIO_DISABLE_BRK as unsigned integer
sub ConsolePutChar(c as unsigned byte)
    STDIO_WRITE_BYTE(0,c)
end sub
    
sub ConsoleWrite(txt as unsigned byte ptr)
    STDIO_WRITE(0,txt)
end sub

sub ConsoleWriteLine(txt as unsigned byte ptr)
    STDIO_WRITE_LINE(0,txt)
end sub

sub ConsoleWriteNumber(n as unsigned integer,b as unsigned integer)
    STDIO_WRITE(0,intToStr(n,b))
end sub

sub ConsoleNewLine()
    STDIO_WRITE_BYTE(0,10)
end sub


sub ConsoleBackSpace()
    STDIO_WRITE_BYTE(0,8)
end sub


sub ConsolePrintOK()
    'asm
    '    mov eax,&h05
    '    int &h31
    'end asm
end sub

sub ConsoleSetForeground(c as unsigned integer)
    'asm
    '    mov eax,&h07
    '    mov ebx,[c]
    '    int &h31
    'end asm
end sub

sub ConsoleSetBackground(c as unsigned integer)
    'asm
    '    mov eax,&h08
    '    mov ebx,[c]
    '    int &h31
    'end asm
end sub


sub ConsoleClear()
    'asm
    '    mov eax,&hF
    '    int &h31
    'end asm
end sub

function STDIO_CREATE() as unsigned integer
    asm
        mov eax,&h100
        int 0x31
        mov [function],eax
    end asm
end function

function STDIO_SET_IN(fd as unsigned integer) as unsigned integer
    asm
        mov eax,&h101
        mov ebx,[fd]
        int 0x31
        mov [function],eax
    end asm
end function

function STDIO_SET_OUT(fd as unsigned integer) as unsigned integer
    asm
        mov eax,&h102
        mov ebx,[fd]
        int 0x31
        mov [function],eax
    end asm
end function

function STDIO_READ(fd as unsigned integer) as unsigned byte
    dim  b as unsigned byte
    asm
        mov eax,&h103
        mov ebx,[fd]
        int 0x31
        mov [b],al
        mov [STDIO_ERR_NUM],ebx
    end asm
    
    'if (STDIO_DISABLE_BRK=0) then
        if (b=STD_KEY_CTRL) then
            dim bb as unsigned byte = STDIO_READ(fd)
            if (bb=asc("c")) then 
                ExitApp()
            end if
            b = bb
        end if
    'end if
    return b
end function

sub STDIO_WRITE_BYTE(fd as unsigned integer,b as unsigned byte)
    asm
        mov eax,&h104
        mov ebx,[fd]
        mov ecx,[b]
        int 0x31
    end asm
end sub


sub STDIO_WRITE(fd as unsigned integer,b as unsigned byte ptr)
    asm
        mov eax,&h105
        mov ebx,[fd]
        mov esi,[b]
        int 0x31
    end asm
end sub


sub STDIO_WRITE_LINE(fd as unsigned integer,b as unsigned byte ptr)
    STDIO_WRITE(fd,b)
    STDIO_WRITE_BYTE(fd,10)
end sub