sub ConsoleWrite(txt as unsigned byte ptr)
    asm
        mov eax,&h01
        mov ebx,[txt]
        int &h31
    end asm
end sub

sub ConsoleWriteLine(txt as unsigned byte ptr)
    asm
        mov eax,&h02
        mov ebx,[txt]
        int &h31
    end asm
end sub

sub ConsoleWriteNumber(n as unsigned integer,b as unsigned integer)
    asm
        mov eax,&h03
        mov ebx,[n]
        mov ecx,[b]
        int &h31
    end asm
end sub

sub ConsoleNewLine()
    asm
        mov eax,&h04
        int &h31
    end asm
end sub

sub ConsolePrintOK()
    asm
        mov eax,&h05
        int &h31
    end asm
end sub

sub ConsoleBackSpace()
    asm
        mov eax,&h06
        int &h31
    end asm
end sub

sub ConsoleSetForeground(c as unsigned integer)
    asm
        mov eax,&h07
        mov ebx,[c]
        int &h31
    end asm
end sub

sub ConsolePutChar(c as unsigned byte)
    asm
        mov eax,&h08
        mov ebx,[c]
        int &h31
    end asm
end sub
    